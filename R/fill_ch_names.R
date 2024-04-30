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
  # fix the issue "no visible binding for global variable x, y"
  x <- y <- NULL

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
      ),
      ch_name_keyword = ch_name_extract_keyword(.data[["ch_name"]])
    ) %>%
    # add unique identifier
    dplyr::mutate(
      unique_identifier = dplyr::row_number(),
      ch_pc_partial = stringr::str_sub(.data[["ch_postcode"]], 1, -2),
      ch_pc_partial2 = stringr::str_sub(.data[["ch_postcode"]], 1, -3),
      ch_pc_partial3 = stringr::str_sub(.data[["ch_postcode"]], 1, -5),
      ch_pc_partial4 = gsub("\\d.*", "", stringr::str_sub(.data[["ch_postcode"]], 1, 2))
    )
  # There are many cases where a patient have many same ch_name and ch_pc, but
  # there is one episode where ch_pc is different while ch_name is the same.
  # fix this case here

  # Contact: IntelligenceTeam@careinspectorate.gov.scot
  # for an updated lookup list
  ch_name_lookup <- openxlsx::read.xlsx(ch_name_lookup_path,
    detectDates = TRUE
  ) %>%
    # Drop any Care Homes that were closed before 2017/18
    dplyr::select(
      ch_postcode = "AccomPostCodeNo",
      ch_name_validated = "ServiceName",
      ch_date_registered = "DateReg",
      ch_date_cancelled = "DateCanx",
      ch_active = tidyselect::contains("ServiceStatusAt")
    ) %>%
    dplyr::filter(is.na(.data[["ch_date_cancelled"]]) |
      (.data[["ch_date_cancelled"]] >= start_fy("1718"))) %>%
    # Standardise the postcode and CH name
    dplyr::mutate(
      ch_postcode = phsmethods::format_postcode(.data[["ch_postcode"]]),
      ch_name_validated = clean_up_free_text(.data[["ch_name_validated"]]),
      ch_date_registered = lubridate::as_date(.data[["ch_date_registered"]]),
      ch_date_cancelled = lubridate::as_date(.data[["ch_date_cancelled"]]),
      ch_active = dplyr::case_match(
        .data[["ch_active"]],
        "Active" ~ TRUE,
        c("Cancelled", "Inactive") ~ FALSE
      )
    ) %>%
    # Merge any duplicates, and get the interval each CH name was active
    dplyr::group_by(.data[["ch_postcode"]], .data[["ch_name_validated"]]) %>%
    dplyr::summarise(
      # Find the latest date for each CH name / postcode
      ch_date_registered = dplyr::first(.data[["ch_date_registered"]]),
      latest_close_date = dplyr::if_else(is.na(max(.data[["ch_date_cancelled"]])),
        Sys.Date(),
        max(.data[["ch_date_cancelled"]])
      ),
      open_interval = lubridate::interval(
        min(.data[["ch_date_registered"]]),
        .data[["latest_close_date"]]
      ),
      ch_active = any(.data[["ch_active"]])
    ) %>%
    dplyr::ungroup() %>%
    dplyr::rename(ch_postcode_lookup = .data[["ch_postcode"]]) %>%
    dplyr::mutate(
      ch_pc_partial = stringr::str_sub(.data[["ch_postcode_lookup"]], 1, -2),
      ch_pc_partial2 = stringr::str_sub(.data[["ch_postcode_lookup"]], 1, -3),
      ch_pc_partial3 = stringr::str_sub(.data[["ch_postcode_lookup"]], 1, -5),
      ch_pc_partial4 = gsub("\\d.*", "", stringr::str_sub(.data[["ch_postcode_lookup"]], 1, 2)),
      ch_name_validated_keyword = ch_name_extract_keyword(.data[["ch_name_validated"]])
    )


  # When matching the name, we need to consider episode time
  # because the ch_name may match best with the one closed
  # while the episode happen after it close.
  # Namely, it is supposed to a new care home
  # although the ch_name is not as alike as the closed one.


  ## postcode matching process ----
  # Generate some metrics for how the submitted names connect to the valid names
  ch_pc_match <- ch_data %>%
    dplyr::left_join(
      ch_name_lookup,
      by = "ch_pc_partial",
      multiple = "all",
      na_matches = "never"
    ) %>%
    # Work out string distances between names for each postcode
    dplyr::mutate(
      match_distance_jaccard = stringdist::stringdist(.data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "jaccard"
      ),
      match_distance_cosine = stringdist::stringdist(.data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "cosine"
      ),
      match_mean = (.data[["match_distance_jaccard"]] +
        .data[["match_distance_cosine"]]) / 2.0,
      # ch_name_keyword distances
      match_distance_jaccard2 = stringdist::stringdist(.data[["ch_name_keyword"]],
        .data[["ch_name_validated_keyword"]],
        method = "jaccard"
      ),
      match_distance_cosine2 = stringdist::stringdist(.data[["ch_name_keyword"]],
        .data[["ch_name_validated_keyword"]],
        method = "cosine"
      ),
      match_mean2 = (.data[["match_distance_jaccard2"]] +
        .data[["match_distance_cosine2"]]) / 2.0
    ) %>%
    # ch_admission_date might be inaccurate.
    dplyr::filter(.data[["ch_admission_date"]] <= .data[["latest_close_date"]]) %>%
    dplyr::mutate(
      postcode_matching = (.data[["ch_postcode"]] == .data[["ch_postcode_lookup"]]),
      ### quality 1L-12L ----
      matching_quality_indicator_overall = dplyr::case_when(
        # 1 to 12, from perfect to ok.
        # 100L, terrible.

        # if care home postcode perfectly match, then
        # even if care home name is NA,
        # we still overwrite the ch_name from ch_name_lookup
        .data[["match_mean"]] < 0.001 &
          .data[["postcode_matching"]] ~ 1L,
        .data[["match_mean2"]] < 0.001 &
          .data[["postcode_matching"]] ~ 2L,
        .data[["match_mean"]] < 0.001 &
          !.data[["postcode_matching"]] ~ 3L,
        .data[["match_mean2"]] < 0.001 &
          !.data[["postcode_matching"]] ~ 4L,
        .data[["match_mean"]] < 0.1 &
          .data[["postcode_matching"]] ~ 5L,
        .data[["match_mean2"]] < 0.1 &
          .data[["postcode_matching"]] ~ 6L,
        .data[["match_mean"]] < 0.1 &
          !.data[["postcode_matching"]] ~ 7L,
        .data[["match_mean2"]] < 0.1 &
          !.data[["postcode_matching"]] ~ 8L,
        (.data[["match_mean"]] < 0.4 |
          .data[["match_mean2"]] < 0.4) &
          .data[["postcode_matching"]] ~ 9L,
        (.data[["match_mean"]] < 0.4 |
          .data[["match_mean2"]] < 0.4) &
          !.data[["postcode_matching"]] ~ 10L,
        is.na(.data[["ch_name"]]) &
          .data[["postcode_matching"]] ~ 11L,
        is.na(.data[["ch_name"]]) &
          !.data[["postcode_matching"]] ~ 12L,
        .default = 100L
        # cases 100L will be improved in the next section
        # 100L means no matching
      )
    ) %>%
    dplyr::select(
      "unique_identifier",
      "chi",
      "ch_postcode",
      "ch_postcode_lookup",
      "postcode",
      "ch_name",
      "ch_name_keyword",
      "ch_name_validated",
      "ch_name_validated_keyword",
      "match_mean",
      "match_mean2",
      # "open_interval",
      "ch_admission_date",
      "qtr_start",
      "ch_date_registered",
      "latest_close_date",
      "ch_active",
      "postcode_matching",
      "matching_quality_indicator_overall",
      tidyselect::everything()
    ) %>%
    dplyr::arrange(
      .data[["unique_identifier"]],
      .data[["matching_quality_indicator_overall"]]
    ) %>%
    dplyr::distinct(.data[["unique_identifier"]],
      .keep_all = TRUE
    )


  # fix matching quality being 100, meaning bad
  # After this great process,
  # there are around 7.5% with matching_quality_indicator_overall being 100
  # This means that
  # cases coming from postcode matching does not matching names at all
  # But some of them may vaguely matching name
  # but match only main area of postcode (say EH1, G1)
  # We now try to find out these cases

  ### quality 13L ----
  # continuous episodes with consistent ch_name and inconsistent ch_postcode
  # here to fix some postcode, which is part of fixing matching quality being 100.
  # Cases to be fixed here:
  # For some ch records, for a chi number,
  # ch_name are consistent while
  # ch_postcode are different,
  # and those episodes seem consistent, indicated by good matching quality.
  # Then, overwrite the minority of records with matching quality being 100.
  ch_pc_match <- ch_pc_match %>%
    dplyr::arrange(
      .data[["chi"]],
      .data[["ch_name"]],
      .data[["matching_quality_indicator_overall"]]
    ) %>%
    dplyr::group_by(.data[["chi"]], .data[["ch_name"]]) %>%
    dplyr::mutate(
      # Best_quality_within_group_chi_name is supposed to be minimum within a group.
      # Since we sort matching_quality_indicator_overall, first is ok.
      best_quality_within_group_chi_name =
        dplyr::first(.data[["matching_quality_indicator_overall"]]),
      ch_postcode_lookup_best =
        dplyr::first(.data[["ch_postcode_lookup"]]),
      ch_name_validated_best =
        dplyr::first(.data[["ch_name_validated"]]),
      ch_name_validated_keyword_best =
        dplyr::first(.data[["ch_name_validated_keyword"]])
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      overwrite_pc = (.data[["matching_quality_indicator_overall"]] == 100L &
        .data[["best_quality_within_group_chi_name"]] <= 10L),
      matching_quality_indicator_overall =
        dplyr::if_else(.data[["overwrite_pc"]],
          13L,
          .data[["matching_quality_indicator_overall"]]
        ),
      ch_postcode_lookup =
        dplyr::if_else(.data[["overwrite_pc"]],
          .data[["ch_postcode_lookup_best"]],
          .data[["ch_postcode_lookup"]]
        ),
      ch_name_validated =
        dplyr::if_else(.data[["overwrite_pc"]],
          .data[["ch_name_validated_best"]],
          .data[["ch_name_validated"]]
        ),
      ch_name_validated_keyword =
        dplyr::if_else(.data[["overwrite_pc"]],
          .data[["ch_name_validated_keyword_best"]],
          .data[["ch_name_validated_keyword"]]
        )
    )

  ### quality 14L ----
  # if ch_postcode perfect match,
  # then we accept ch_name_lookup and overwrite ch_name

  col_to_select <- c(
    "unique_identifier",
    "matching_quality_indicator_overall",
    "sending_location",
    "latest_sc_id",
    "chi",
    "ch_name",
    "ch_postcode",
    "social_care_id",
    "period",
    "period_start_date",
    "period_end_date",
    "ch_provider",
    "reason_for_admission",
    "type_of_admission",
    "nursing_care_provision",
    "ch_admission_date",
    "ch_discharge_date",
    "age",
    "record_date",
    "qtr_start",
    "latest_flag",
    "gender",
    "dob",
    "postcode",
    "date_of_death",
    "ch_name_validated",
    "open_interval",
    "latest_close_date",
    "ch_name_old",
    "ch_postcode_old",
    "ch_name_keyword"
  )

  ch_pc_match <- ch_pc_match %>%
    dplyr::mutate(matching_quality_indicator_overall = dplyr::if_else(.data[["matching_quality_indicator_overall"]] == 100L &
      .data[["postcode_matching"]],
    14L,
    .data[["matching_quality_indicator_overall"]]
    )) %>%
    # now remove cases of quality being 100L for the next section:
    # ch_name matching
    dplyr::filter(.data[["matching_quality_indicator_overall"]] != 100L) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name = .data[["ch_name_validated"]],
      ch_postcode = .data[["ch_postcode_lookup"]]
    ) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ## matching by ch_name, quality 15L-21L ----
  ### perfect matching by ch_name, and main part of postcode, quality 15L ----
  # ch_name matching, then overwrite postcode from ch_lookup
  # 15L means perfect matching name,
  # and relevant dates align,
  # but not the main part of the postcode, say "EH12"

  ch_name_match1 <- ch_data %>%
    dplyr::anti_join(ch_pc_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    dplyr::inner_join(
      ch_name_lookup,
      by = dplyr::join_by(
        x$ch_name == y$ch_name_validated,
        x$ch_admission_date <= y$latest_close_date,
        x$ch_admission_date >= y$ch_date_registered,
        # some care homes have same name, so use ch_pc_partial2 to filter
        "ch_pc_partial3"
      )
    ) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name_validated = .data[["ch_name"]],
      # ch_name_validated is omitted because of join_by(), add back
      ch_postcode = .data[["ch_postcode_lookup"]],
      matching_quality_indicator_overall = 15L
    ) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ### fizzy matching by ch_name, and matching main part of postcode, quality 16L ----
  ch_match <- dplyr::bind_rows(ch_pc_match, ch_name_match1)

  ch_name_match2 <- ch_data %>%
    dplyr::anti_join(ch_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    dplyr::inner_join(
      ch_name_lookup,
      by = dplyr::join_by(
        x$ch_name_keyword == y$ch_name_validated_keyword,
        x$ch_admission_date <= y$latest_close_date,
        x$ch_admission_date >= y$ch_date_registered,
        "ch_pc_partial3"
      ),
      na_matches = "never"
    ) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name = .data[["ch_name_validated"]],
      ch_postcode = .data[["ch_postcode_lookup"]],
      matching_quality_indicator_overall = 16L,
      match_distance_jaccard = stringdist::stringdist(.data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "jaccard"
      )
    ) %>%
    dplyr::arrange(
      .data[["unique_identifier"]],
      .data[["match_distance_jaccard"]]
    ) %>%
    dplyr::distinct(.data[["unique_identifier"]], .keep_all = TRUE) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ### fizzy matching by ch_name, and same city, quality 17L ----
  ch_match <-
    dplyr::bind_rows(ch_pc_match, ch_name_match1, ch_name_match2)

  ch_name_match3 <- ch_data %>%
    dplyr::anti_join(ch_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    dplyr::inner_join(
      ch_name_lookup,
      by = dplyr::join_by(
        x$ch_name_keyword == y$ch_name_validated_keyword,
        x$ch_admission_date <= y$latest_close_date,
        x$ch_admission_date >= y$ch_date_registered,
        "ch_pc_partial4"
      ),
      na_matches = "never"
    ) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name = .data[["ch_name_validated"]],
      ch_postcode = .data[["ch_postcode_lookup"]],
      matching_quality_indicator_overall = 17L,
      match_distance_jaccard = stringdist::stringdist(.data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "jaccard"
      )
    ) %>%
    dplyr::arrange(
      .data[["unique_identifier"]],
      .data[["match_distance_jaccard"]]
    ) %>%
    dplyr::distinct(.data[["unique_identifier"]], .keep_all = TRUE) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ch_match <- dplyr::bind_rows(
    ch_pc_match,
    ch_name_match1,
    ch_name_match2,
    ch_name_match3
  )

  ### ch_postcode and postcode exchange, then matching, quality 18L----
  ch_pc_exchange_match1 <- ch_data %>%
    dplyr::anti_join(ch_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    dplyr::mutate(
      intermediate_pc = .data[["ch_postcode"]],
      ch_postcode = .data[["postcode"]],
      postcode = .data[["ch_postcode"]],
      ch_pc_partial = stringr::str_sub(.data[["ch_postcode"]], 1, -2),
      ch_pc_partial2 = stringr::str_sub(.data[["ch_postcode"]], 1, -3),
      ch_pc_partial3 = stringr::str_sub(.data[["ch_postcode"]], 1, -5)
    ) %>%
    dplyr::select(-.data[["intermediate_pc"]]) %>%
    dplyr::inner_join(
      ch_name_lookup,
      by = dplyr::join_by(
        x$ch_name_keyword == y$ch_name_validated_keyword,
        x$ch_admission_date <= y$latest_close_date,
        x$ch_admission_date >= y$ch_date_registered,
        "ch_pc_partial"
      ),
      na_matches = "never"
    ) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name = .data[["ch_name_validated"]],
      ch_postcode = .data[["ch_postcode_lookup"]],
      matching_quality_indicator_overall = 18L,
      match_distance_jaccard = stringdist::stringdist(.data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "jaccard"
      )
    ) %>%
    dplyr::arrange(
      .data[["unique_identifier"]],
      .data[["match_distance_jaccard"]]
    ) %>%
    dplyr::distinct(.data[["unique_identifier"]], .keep_all = TRUE) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ch_match <- dplyr::bind_rows(
    ch_pc_match,
    ch_name_match1,
    ch_name_match2,
    ch_name_match3,
    ch_pc_exchange_match1
  )

  ## Other matching processes ----
  ### quality 19L----
  # ch_postcode and postcode exchange,
  # then fizzy match ch_name, and matching main part of postcode
  ch_pc_exchange_match2 <- ch_data %>%
    dplyr::anti_join(ch_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    dplyr::mutate(
      intermediate_pc = .data[["ch_postcode"]],
      ch_postcode = .data[["postcode"]],
      postcode = .data[["ch_postcode"]],
      ch_pc_partial = stringr::str_sub(.data[["ch_postcode"]], 1, -2),
      ch_pc_partial2 = stringr::str_sub(.data[["ch_postcode"]], 1, -3),
      ch_pc_partial3 = stringr::str_sub(.data[["ch_postcode"]], 1, -5)
    ) %>%
    dplyr::select(-.data[["intermediate_pc"]]) %>%
    dplyr::inner_join(
      ch_name_lookup,
      by = dplyr::join_by(
        x$ch_name_keyword == y$ch_name_validated_keyword,
        x$ch_admission_date <= y$latest_close_date,
        x$ch_admission_date >= y$ch_date_registered,
        "ch_pc_partial3"
      ),
      na_matches = "never"
    ) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name = .data[["ch_name_validated"]],
      ch_postcode = .data[["ch_postcode_lookup"]],
      matching_quality_indicator_overall = 19L,
      match_distance_jaccard = stringdist::stringdist(.data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "jaccard"
      )
    ) %>%
    dplyr::arrange(
      .data[["unique_identifier"]],
      .data[["match_distance_jaccard"]]
    ) %>%
    dplyr::distinct(.data[["unique_identifier"]], .keep_all = TRUE) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ch_match <- dplyr::bind_rows(
    ch_pc_match,
    ch_name_match1,
    ch_name_match2,
    ch_name_match3,
    ch_pc_exchange_match1,
    ch_pc_exchange_match2
  )


  ### quality 20L----
  # perfect match care home name, regardless of postcode,
  # excluding those duplicated care home names.
  unique_ch_name <- unique(ch_name_lookup$ch_name_validated)

  ch_name_match4 <- ch_data %>%
    dplyr::anti_join(ch_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    dplyr::inner_join(
      ch_name_lookup,
      by = dplyr::join_by(
        x$ch_name == y$ch_name_validated,
        x$ch_admission_date <= y$latest_close_date,
        x$ch_admission_date >= y$ch_date_registered
      ),
      na_matches = "never"
    ) %>%
    dplyr::filter(.data[["ch_name"]] %in% unique_ch_name) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      # add ch_name_validated back since omitted in join_by()
      ch_name_validated = .data[["ch_name"]],
      ch_postcode = .data[["ch_postcode_lookup"]],
      matching_quality_indicator_overall = 20L
    ) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ch_match <- dplyr::bind_rows(
    ch_pc_match,
    ch_name_match1,
    ch_name_match2,
    ch_name_match3,
    ch_pc_exchange_match1,
    ch_pc_exchange_match2,
    ch_name_match4
  )

  ### quality 21L----
  # fizzy match care home name, regardless of postcode,
  # excluding those duplicated care home names.
  ch_name_match5 <- ch_data %>%
    dplyr::anti_join(ch_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    dplyr::inner_join(
      ch_name_lookup,
      by = dplyr::join_by(
        x$ch_name_keyword == y$ch_name_validated_keyword,
        x$ch_admission_date <= y$latest_close_date,
        x$ch_admission_date >= y$ch_date_registered
      ),
      na_matches = "never"
    ) %>%
    dplyr::filter(.data[["ch_name"]] %in% unique_ch_name) %>%
    dplyr::mutate(
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name = .data[["ch_name_validated"]],
      ch_postcode = .data[["ch_postcode_lookup"]],
      matching_quality_indicator_overall = 21L,
      match_distance_jaccard = stringdist::stringdist(.data[["ch_name"]],
        .data[["ch_name_validated"]],
        method = "jaccard"
      )
    ) %>%
    dplyr::arrange(
      .data[["unique_identifier"]],
      .data[["match_distance_jaccard"]]
    ) %>%
    dplyr::distinct(.data[["unique_identifier"]], .keep_all = TRUE) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ch_match <- dplyr::bind_rows(
    ch_pc_match,
    ch_name_match1,
    ch_name_match2,
    ch_name_match3,
    ch_pc_exchange_match1,
    ch_pc_exchange_match2,
    ch_name_match4,
    ch_name_match5
  )



  # add 100L for non-matching episodes
  ch_no_match <- ch_data %>%
    dplyr::anti_join(ch_match,
      by = dplyr::join_by("unique_identifier")
    ) %>%
    # dplyr::distinct(ch_name, .keep_all = TRUE) %>%
    dplyr::mutate(
      matching_quality_indicator_overall = 100L,
      ch_name_old = .data[["ch_name"]],
      ch_postcode_old = .data[["ch_postcode"]],
      ch_name_validated = NA_character_,
      open_interval = NA,
      latest_close_date = NA,
      ch_date_registered = NA
    ) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ### quality 30L----
  # episodes sharing common chi
  # and ch_name with those episodes with good match quality
  ch_data_final <- dplyr::bind_rows(ch_match, ch_no_match) %>%
    dplyr::arrange(
      .data[["chi"]], .data[["ch_name_keyword"]],
      .data[["matching_quality_indicator_overall"]]
    ) %>%
    dplyr::group_by(
      .data[["chi"]],
      .data[["ch_name_keyword"]]
    ) %>%
    dplyr::mutate(
      same_ch_name = (dplyr::first(.data[["matching_quality_indicator_overall"]]) <= 10L &
        .data[["matching_quality_indicator_overall"]] == 100L),
      ch_name = dplyr::if_else(.data[["same_ch_name"]],
        dplyr::first(.data[["ch_name"]]),
        .data[["ch_name"]]
      ),
      ch_postcode = dplyr::if_else(.data[["same_ch_name"]],
        dplyr::first(.data[["ch_postcode"]]),
        .data[["ch_postcode"]]
      ),
      matching_quality_indicator_overall = dplyr::if_else(.data[["same_ch_name"]],
        30L,
        .data[["matching_quality_indicator_overall"]]
      )
    ) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(.data[["unique_identifier"]]) %>%
    dplyr::select(dplyr::all_of(col_to_select))

  ## For any future amendment or quality check ----
  # ch_data_final %>%
  #   dplyr::group_by(matching_quality_indicator_overall) %>%
  #   dplyr::summarise(n = dplyr::n()) %>%
  #   dplyr::mutate(pct = n/sum(n)*100) %>%
  #   print(n=100) %>%
  #   write.csv("ch_quality.csv")

  ## produce output ----
  col_output <- c(
    "sending_location",
    "latest_sc_id",
    "chi",
    "ch_name",
    "ch_postcode",
    "social_care_id",
    "period",
    "period_start_date",
    "period_end_date",
    "ch_provider",
    "reason_for_admission",
    "type_of_admission",
    "nursing_care_provision",
    "ch_admission_date",
    "ch_discharge_date",
    "age",
    "record_date",
    "qtr_start",
    "latest_flag",
    "gender",
    "dob",
    "postcode",
    "date_of_death",
    "ch_name_validated",
    "open_interval",
    "latest_close_date",
    "ch_name_old",
    "ch_postcode_old"
  )

  return(ch_data_final %>%
    dplyr::select(dplyr::all_of(col_output)))
}


#' extract keyword in a care home name
#' @param ch_name care home names
ch_name_extract_keyword <- function(ch_name) {
  ch_stopwords <- c(
    "home",
    "homes",
    "care",
    "house",
    "nursing",
    "centre",
    "court",
    "lodge",
    "residential",
    "view",
    "st",
    "park",
    "manor",
    "grange",
    "grove",
    "futures",
    "respite",
    "unit",
    "hall",
    "ltd",
    "the",
    "for",
    "elderly",
    "limited",
    "service",
    "services",
    "place",
    "suite",
    "luxury"
  ) %>% stringr::str_to_title()
  ch_name <-
    gsub(paste0(ch_stopwords, collapse = "|"), "", ch_name) %>%
    stringr::str_trim(side = "right")
  return(ch_name)
}
