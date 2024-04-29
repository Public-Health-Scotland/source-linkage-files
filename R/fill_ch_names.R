#' Fix and fill care home name and postcodes
#'
#' @param ch_data partially cleaned up care home data as a
#' [tibble][tibble::tibble-package]
#' @param ch_name_lookup_path Path to the 'official' Care Home name Excel
#' Workbook, this defaults to [get_slf_ch_name_lookup_path()]
#' @param spd_path Path to the Scottish Postcode Directory (rds) version, this
#' defaults to [get_spd_path()]
#'
#' @return the same data with improved accuracy and completeness of the Care
#' Home names and postcodes, as a [tibble][tibble::tibble-package].
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
        .data[["ch_postcode"]] %in% dplyr::pull(
          read_file(spd_path, col_select = "pc7"),
          "pc7"
        ),
        .data[["ch_postcode"]],
        NA_character_
      )
    )

  # Care Home name lookup from the Care Inspectorate
  # Contact: IntelligenceTeam@careinspectorate.gov.scot
  ch_name_lookup <- openxlsx::read.xlsx(ch_name_lookup_path, # (n = 3256)
    detectDates = TRUE
  ) %>%
    # Drop any Care Homes that were closed before 2017/18
    dplyr::select(
      ch_postcode = "AccomPostCodeNo",
      ch_name_validated = "ServiceName",
      ch_date_registered = "DateReg",
      ch_date_cancelled = "DateCanx"
    ) %>%
    dplyr::filter(
      is.na(.data[["ch_date_cancelled"]]) |
        (.data[["ch_date_cancelled"]] >= start_fy("1718")) #(n = 1375)
    ) %>%
    # Standardise the postcode and CH name
    dplyr::mutate(
      ch_postcode = phsmethods::format_postcode(.data[["ch_postcode"]]),
      ch_name_validated = clean_up_free_text(.data[["ch_name_validated"]]),
      ch_date_registered = lubridate::as_date(.data[["ch_date_registered"]]),
      ch_date_cancelled = lubridate::as_date(.data[["ch_date_cancelled"]])
    ) %>%
    # Merge any duplicates, and get the interval each CH name was active
    dplyr::group_by(.data[["ch_postcode"]], .data[["ch_name_validated"]]) %>%
    dplyr::summarise(
      # Find the latest date for each CH name / postcode
      latest_close_date = dplyr::if_else(
        is.na(max(.data[["ch_date_cancelled"]])), # if is na set to todays date as still open
        Sys.Date(),
        max(.data[["ch_date_cancelled"]])
      ),
      open_interval = lubridate::interval(
        min(.data[["ch_date_registered"]]),
        .data[["latest_close_date"]]
      )
    ) %>%
    dplyr::ungroup()

  # Generate some metrics for how the submitted names connect to the valid names
  ch_name_best_match <- ch_data %>%
    dplyr::distinct(.data[["ch_postcode"]], .data[["ch_name"]]) %>%
    dplyr::left_join(ch_name_lookup,
      by = dplyr::join_by("ch_postcode"),
      multiple = "all",
      na_matches = "never"
    ) %>%
    tidyr::drop_na() %>%
    # Work out string distances between names for each postcode
    dplyr::mutate(
      match_distance_jaccard = stringdist::stringdist(
        .data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "jaccard"
      ),
      match_distance_cosine = stringdist::stringdist(
        .data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "cosine"
      ),
      match_mean = (.data[["match_distance_jaccard"]] +
        .data[["match_distance_cosine"]]) / 2.0
    ) %>%
    # Drop any name matches which aren't very close
    dplyr::filter(.data[["match_distance_jaccard"]] <= 0.25 |
      .data[["match_distance_cosine"]] <= 0.3) %>%
    dplyr::group_by(
      .data[["ch_postcode"]],
      .data[["ch_name"]],
      .data[["open_interval"]]
    ) %>%
    dplyr::mutate(
      min_match_mean = min(.data[["match_mean"]], na.rm = TRUE)
    ) %>%
    # Identify the closest match in case there are multiple close matches
    # If there's still multiple matches just pick the shortest
    dplyr::arrange(
      "min_match_mean",
      length(.data[["ch_name_validated"]])
    ) %>%
    dplyr::ungroup() %>%
    dplyr::distinct(.data[["ch_postcode"]],
      .data[["ch_name"]],
      .keep_all = TRUE
    ) %>%
    dplyr::select(
      "ch_postcode",
      "ch_name",
      "ch_name_validated",
      "open_interval",
      "latest_close_date"
    ) %>%
    dplyr::arrange(
      "ch_postcode",
      "ch_name",
      "open_interval"
    )

  # name is not a match. replaces name with better match if possible
  no_match_pc_name_bad <- ch_data %>%
    dplyr::anti_join(ch_name_lookup,
      by = dplyr::join_by("ch_postcode"),
      na_matches = "never"
    ) %>%
    dplyr::filter(
      !is.na(.data[["ch_name"]]) & !is.na(.data[["ch_postcode"]])
    ) %>%
    dplyr::left_join(ch_name_best_match,
      by = dplyr::join_by(
        "ch_name",
        closest("ch_admission_date" <= "latest_close_date")
      ),
      multiple = "last",
      na_matches = "never",
      suffix = c("_old", "")
    ) %>%
    dplyr::mutate(
      ch_postcode = dplyr::if_else(!is_missing(.data[["ch_postcode"]]),
        .data[["ch_postcode"]],
        .data[["ch_postcode_old"]]
      )
    )

  # cases where care home anme and postcode are missing
  no_match_pc_name_missing <- ch_data %>% # (n = 135)
    dplyr::anti_join(ch_name_lookup,
      by = dplyr::join_by("ch_postcode"),
      na_matches = "never"
    ) %>%
    dplyr::filter(is.na(.data[["ch_name"]]) & is.na(.data[["ch_postcode"]]))

  # cases where care home name is present but postcode is missing.
  # assigns new postcode if possible
  no_match_pc_missing <- ch_data %>%
    dplyr::anti_join(ch_name_lookup,
      by = dplyr::join_by("ch_postcode"),
      na_matches = "never"
    ) %>%
    dplyr::filter(
      !is.na(.data[["ch_name"]]) & is.na(.data[["ch_postcode"]])
    ) %>%
    dplyr::left_join(ch_name_best_match,
      by = dplyr::join_by(
        "ch_name",
        closest("ch_admission_date" <= "latest_close_date")
      ),
      multiple = "last",
      na_matches = "never",
      suffix = c("_old", "")
    ) %>%
    dplyr::mutate(
      ch_postcode = dplyr::if_else(!is_missing(.data[["ch_postcode"]]),
        .data[["ch_postcode"]],
        .data[["ch_postcode_old"]]
      )
    )

  # cases where care home name is missing but postcode is present
  no_match_name_missing <- ch_data %>% # (n = 3589)
    dplyr::anti_join(ch_name_lookup,
      by = dplyr::join_by("ch_postcode"),
      na_matches = "never"
    ) %>%
    dplyr::filter(is.na(.data[["ch_name"]]) & !is.na(.data[["ch_postcode"]]))


  ch_name_pc_clean <- ch_data %>%
    # Remove records with no matching postcode, we'll add them back later
    dplyr::semi_join(ch_name_lookup,
      by = dplyr::join_by("ch_postcode"),
      na_matches = "never"
    ) %>%
    dplyr::left_join(ch_name_best_match,
      by = dplyr::join_by(
        "ch_postcode",
        "ch_name",
        closest("ch_admission_date" <= "latest_close_date")
      ),
      na_matches = "never"
    ) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_name = dplyr::if_else(!is_missing(.data[["ch_name_validated"]]),
        .data[["ch_name_validated"]],
        .data[["ch_name"]]
      )
    ) %>%
    # Bring back the records which had no postcode match
    dplyr::bind_rows(
      no_match_pc_name_bad,
      no_match_pc_name_missing,
      no_match_pc_missing,
      no_match_name_missing
    )

  # TODO Check if we can fill in ch_names or ch_postcodes when a client has
  # multiple episodes

  return(ch_name_pc_clean)
}
