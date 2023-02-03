#' Fix and fill care home name and postcodes
#'
#' @param ch_data partially cleaned up care home data as a
#' [tibble][tibble::tibble-package]
#' @param ch_name_lookup_path path to the 'official' Care Home name Excel
#' Workbook, this defaults to [get_slf_ch_name_lookup_path()]
#'
#' @return the same data with improved accuracy and completeness of the Care
#' Home names and postcodes, as a [tibble][tibble::tibble-package].
#' @export
fill_ch_names <- function(ch_data,
                          ch_name_lookup_path = get_slf_ch_name_lookup_path(),
                          spd_path = get_spd_path()) {
  ch_data <- ch_data %>%
    # Make the care home name more uniform
    dplyr::mutate(ch_name = clean_up_free_text(.data[["ch_name"]])) %>%
    # correct postcode formatting
    dplyr::mutate(
      dplyr::across(
        dplyr::contains("postcode"),
        phsmethods::format_postcode
      ),
      # Replace invalid postcode with NA
      # Get a list of confirmed valid Scottish postcodes from the SPD
      ch_postcode = dplyr::if_else(
        .data[["ch_postcode"]] %in% dplyr::pull(readr::read_rds(spd_path), "pc7"),
        .data[["ch_postcode"]],
        NA_character_
      )
    )

  # Care Home name lookup from the Care Inspectorate
  # Previous contact 'Al Scougal' <Al.Scougal@careinspectorate.gov.scot>
  ch_name_lookup <- readxl::read_xlsx(ch_name_lookup_path) %>%
    # Drop any Care Homes that were closed before 2017/18
    dplyr::select(
      ch_postcode = "AccomPostCodeNo",
      ch_name_validated = "ServiceName",
      ch_date_registered = "DateReg",
      ch_date_cancelled = "DateCanx"
    ) %>%
    dplyr::filter(is.na(.data[["ch_date_cancelled"]]) | .data[["ch_date_cancelled"]] >= start_fy("1718")) %>%
    # Standardise the postcode and CH name
    dplyr::mutate(
      ch_postcode = phsmethods::format_postcode(.data[["ch_postcode"]]),
      ch_name_validated = clean_up_free_text(.data[["ch_name_validated"]])
    ) %>%
    # Merge any duplicates, and get the interval each CH name was active
    dplyr::group_by(.data[["ch_postcode"]], .data[["ch_name_validated"]]) %>%
    dplyr::summarise(open_interval = lubridate::interval(
      min(.data[["ch_date_registered"]]),
      pmin(max(.data[["ch_date_cancelled"]]), Sys.Date(), na.rm = TRUE)
    )) %>%
    dplyr::ungroup() %>%
    # Find the latest date for each CH name
    dplyr::mutate(latest_close_date = lubridate::int_end(.data[["open_interval"]])) %>%
    dplyr::arrange("open_interval")

  # Generate some metrics for how the submitted names connect to the valid names
  ch_name_match_metrics <- ch_data %>%
    dplyr::distinct(.data[["ch_postcode"]], .data[["ch_name"]]) %>%
    dplyr::left_join(ch_name_lookup, by = "ch_postcode") %>%
    tidyr::drop_na() %>%
    # Work out string distances between names for each postcode
    dplyr::mutate(
      match_distance_jaccard = stringdist::stringdist(.data[["ch_name"]], .data[["ch_name_validated"]],
        method = "jaccard"
      ),
      match_distance_cosine = stringdist::stringdist(.data[["ch_name"]], .data[["ch_name_validated"]],
        method = "cosine"
      ),
      match_mean = (.data[["match_distance_jaccard"]] + .data[["match_distance_cosine"]]) / 2.0
    ) %>%
    # Drop any name matches which aren't very close
    dplyr::filter(.data[["match_distance_jaccard"]] <= 0.25 |
      .data[["match_distance_cosine"]] <= 0.3) %>%
    dplyr::group_by(.data[["ch_postcode"]], .data[["ch_name"]]) %>%
    # Identify the closest match in case there are multiple close matches
    dplyr::mutate(
      min_jaccard = min(.data[["match_distance_jaccard"]], na.rm = TRUE),
      min_cosine = min(.data[["match_distance_cosine"]], na.rm = TRUE),
      min_match_mean = min(.data[["match_mean"]], na.rm = TRUE)
    ) %>%
    dplyr::ungroup()

  no_postcode_match <- ch_data %>%
    dplyr::anti_join(ch_name_lookup, by = "ch_postcode")

  name_postcode_clean <- ch_data %>%
    # Remove records with no matching postcode, we'll add them back later
    dplyr::semi_join(ch_name_lookup, by = "ch_postcode") %>%
    # Create a unique ID per row so we can get rid of duplicates later
    dplyr::mutate(ch_record_id = dplyr::row_number()) %>%
    # Match CH names with the generated metrics and the lookup. This will create
    # duplicates which should be filtered out as we identify matches
    dplyr::left_join(ch_name_match_metrics, by = c("ch_postcode", "ch_name")) %>%
    dplyr::mutate(
      # Work out the duration of the stay
      # If the end date is missing set this to the end of the quarter
      stay_interval = lubridate::interval(
        .data[["ch_admission_date"]],
        min(.data[["ch_discharge_date"]], .data[["record_date"]], na.rm = TRUE)
      ),
      # Highlight which stays overlap with an open care home name
      stay_overlaps_open = lubridate::int_overlaps(
        .data[["stay_interval"]], .data[["open_interval"]]
      ) &
        lubridate::int_start(.data[["stay_interval"]]) >= lubridate::int_start(.data[["open_interval"]]),
      # Highlight which names seem to be good matches
      name_match = dplyr::case_when(
        # Exact match
        ch_name == ch_name_validated ~ TRUE,
        # Submitted name is missing and stay dates are valid for the CH
        is.na(ch_name) & stay_overlaps_open ~ TRUE,
        # This name had the closest 'jaccard' distance of all possibilities
        (min_jaccard == match_distance_jaccard) &
          match_distance_jaccard <= 0.25 ~ TRUE,
        # This name had the closest 'cosine' distance of all possibilities
        (min_cosine == match_distance_cosine) &
          match_distance_cosine <= 0.3 ~ TRUE,
        # This name had the closest 'mean' distance (used when the above disagree)
        (min_match_mean == match_mean) & match_mean <= 0.25 ~ TRUE,
        # No good match
        TRUE ~ FALSE
      )
    ) %>%
    # Group by record
    # - There will be duplicate rows per record if there are
    # multiple 'options' for the possible CH name.
    dplyr::group_by(.data[["ch_record_id"]]) %>%
    dplyr::mutate(
      # Highlight where the record has no matches out of any of the options
      no_name_matches = !any(.data[["name_match"]]),
      # Highlight where the record has no overlaps with any of the options
      no_overlaps = !any(.data[["stay_overlaps_open"]])
    ) %>%
    # Keep a record if:
    # 1) It's name matches `name_match`
    # Or either
    # 2)a) None of the option's names match AND this option overlaps in dates
    # e.g. the submitted name is missing but the dates match)
    # or 2)b) None of the option's names match AND none of the dates overlap
    # (i.e. we don't have any idea what name to use)
    dplyr::filter(dplyr::n() == 1L |
      sum(.data[["name_match"]]) == 1L | !any(.data[["name_match"]])) %>%
    # For the records which still have multiple options
    # (usually multiple names matched)
    dplyr::filter(dplyr::n() == 1L |
      lubridate::int_end(.data[["open_interval"]]) == .data[["latest_close_date"]]) %>%
    dplyr::filter(dplyr::n() == 1L | .data[["match_mean"]] == .data[["min_match_mean"]]) %>%
    dplyr::ungroup() %>%
    # Bring back to single record with no duplicates introduce by the lookup
    dplyr::distinct(.data[["ch_record_id"]], .keep_all = TRUE) %>%
    # Replace the ch name with our best guess at the proper name from the lookup
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_name = dplyr::if_else(is.na(.data[["ch_name_validated"]]),
        .data[["ch_name"]],
        .data[["ch_name_validated"]]
      )
    ) %>%
    # Bring back the records which had no postcode match
    dplyr::bind_rows(no_postcode_match)

  (check_names <- name_postcode_clean %>%
    dplyr::count(.data[["ch_name_old"]], .data[["ch_name"]], sort = TRUE))

  return(name_postcode_clean)
}
