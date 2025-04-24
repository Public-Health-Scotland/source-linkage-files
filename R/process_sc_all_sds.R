#' Process the all SDS extract
#' @description This will read and process the
#' all SDS extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_sc_all_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
#' @export
#'
process_sc_all_sds <- function(
    data,
    sc_demog_lookup = read_file(get_sc_demog_lookup_path()),
    write_to_disk = TRUE) {
  # Match on demographics data (chi, gender, dob and postcode)
  matched_sds_data <- data %>%
    dplyr::filter(.data$sds_start_date_after_period_end_date != 1) %>%
    dplyr::right_join(
      sc_demog_lookup,
      by = c("sending_location", "social_care_id")
    ) %>%
    # when multiple social_care_id from sending_location for single CHI
    # replace social_care_id with latest
    replace_sc_id_with_latest() %>%
    dplyr::select(-.data$sds_start_date_after_period_end_date) %>%
    dplyr::distinct() %>%
    # sds_options may contain only a few NA, replace NA by 0
    dplyr::mutate(
      sds_option_1 = tidyr::replace_na(.data$sds_option_1, 0),
      sds_option_2 = tidyr::replace_na(.data$sds_option_2, 0),
      sds_option_3 = tidyr::replace_na(.data$sds_option_3, 0)
    )

  # Data Cleaning ---------------------------------------
  # Convert matched_sds_data to data.table
  sds_full_clean <- data.table::as.data.table(matched_sds_data)
  rm(matched_sds_data)

  # fix "no visible binding for global variable"
  sds_option_4 <- sds_start_date <- sds_period_start_date <- sds_end_date <-
    sds_period_end_date <- received <- sds_option <- sending_location <-
    period <- record_keydate1 <- record_keydate2 <- social_care_id <-
    smrtype <- period_rank <- record_keydate1_rank <- record_keydate2_rank <-
    distinct_episode <- episode_counter <- anon_chi <- gender <- dob <- postcode <-
    recid <- person_id <- sc_send_lca <- NULL

  # Deal with SDS option 4
  # Convert option flags into logical T/F
  cols_sds_option <- grep(
    "^sds_option_",
    names(sds_full_clean),
    value = TRUE
  )
  sds_full_clean[, (cols_sds_option) := lapply(.SD, function(x) {
    data.table::fifelse(x == 1L, TRUE, FALSE)
  }),
  .SDcols = cols_sds_option
  ]

  # Derived SDS option 4 when a person receives more than one option
  sds_full_clean[,
    sds_option_4 := rowSums(.SD) > 1L,
    .SDcols = cols_sds_option
  ]

  # If SDS start date or end date is missing, assign start/end of FY
  sds_full_clean[
    ,
    sds_start_date := fix_sc_start_dates(sds_start_date, sds_period_start_date)
  ]
  sds_full_clean[
    ,
    sds_end_date := fix_sc_missing_end_dates(sds_end_date, sds_period_end_date)
  ]
  sds_full_clean[
    ,
    sds_end_date := fix_sc_end_dates(sds_start_date, sds_end_date, sds_period_end_date)
  ]

  sds_full_clean[, c(
    "sds_period_start_date",
    "sds_period_end_date",
    "sds_start_date_after_end_date"
  ) := NULL]

  # Rename for matching source variables
  data.table::setnames(
    sds_full_clean,
    c("sds_start_date", "sds_end_date"),
    c("record_keydate1", "record_keydate2")
  )

  sds_full_clean <- unique(sds_full_clean)

  cols_sds_option <- grep(
    "^sds_option_",
    names(sds_full_clean),
    value = TRUE
  )
  # Pivot longer on sds option variables
  sds_full_clean_long <- data.table::melt(
    sds_full_clean,
    id.vars = setdiff(names(sds_full_clean), cols_sds_option),
    measure.vars = cols_sds_option,
    variable.name = "sds_option",
    value.name = "received"
  )
  rm(sds_full_clean)
  sds_full_clean_long <- sds_full_clean_long[received == TRUE, ]
  sds_full_clean_long[
    ,
    sds_option := paste0("SDS-", sub("sds_option_", "", sds_option))
  ]

  # Filter rows where they received a package and remove duplicates
  sds_full_clean_long <- unique(sds_full_clean_long)

  # Include source variables
  sds_full_clean_long[, c(
    "smrtype",
    "recid",
    "sc_send_lca"
  ) :=
    list(
      sds_option,
      "SDS",
      convert_sc_sending_location_to_lca(sending_location)
    )]

  # Group, arrange and create flags for episodes
  sds_full_clean_long[,
    c(
      "period_rank",
      "record_keydate1_rank",
      "record_keydate2_rank"
    ) := list(
      rank(period),
      rank(record_keydate1),
      rank(record_keydate2)
    ),
    by = list(sending_location, social_care_id, smrtype)
  ]
  data.table::setorder(
    sds_full_clean_long,
    period_rank,
    record_keydate1_rank,
    record_keydate2_rank
  )

  sds_full_clean_long[,
    distinct_episode :=
      (data.table::shift(record_keydate2, type = "lag") < record_keydate1) %>%
      tidyr::replace_na(TRUE),
    by = list(sending_location, social_care_id, smrtype)
  ]

  sds_full_clean_long[,
    episode_counter := cumsum(distinct_episode),
    by = list(sending_location, social_care_id, smrtype)
  ]

  # Merge episodes by episode counter
  final_data <- sds_full_clean_long[, list(
    sc_latest_submission = data.table::last(period),
    record_keydate1 = min(record_keydate1),
    record_keydate2 = max(record_keydate2),
    anon_chi = data.table::last(anon_chi),
    gender = data.table::last(gender),
    dob = data.table::last(dob),
    postcode = data.table::last(postcode),
    recid = data.table::last(recid),
    sc_send_lca = data.table::last(sc_send_lca)
  ), by = list(sending_location, social_care_id, smrtype, episode_counter)]
  rm(sds_full_clean_long)

  # Drop episode_counter and convert back to data.frame if needed
  final_data <- as.data.frame(final_data[, -"episode_counter"])
  # final_data now holds the processed data in the format of a data.frame

  if (write_to_disk) {
    write_file(
      final_data,
      get_sc_sds_episodes_path(check_mode = "write"),
      group_id = 3206 # hscdiip owner
    )
  }

  return(final_data)
}
