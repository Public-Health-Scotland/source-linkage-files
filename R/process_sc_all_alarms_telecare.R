#' Process the all Alarms Telecare extract
#'
#' @description This will read and process the
#' all Alarms Telecare extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_sc_all_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
#' @export
#'
process_sc_all_alarms_telecare <- function(
    data,
    sc_demog_lookup = read_file(get_sc_demog_lookup_path()) %>% slfhelper::get_chi(),
    write_to_disk = TRUE) {
  # Data Cleaning-----------------------------------------------------

  # fix "no visible binding for global variable"
  service_end_date <- period_end_date <- service_start_date <- service_type <-
    default <- sending_location <- social_care_id <- pkg_count <-
    record_keydate1 <- smrtype <- period <- record_keydate2 <- chi <-
    gender <- dob <- postcode <- recid <- person_id <- sc_send_lca <-
    period_start_date <- NULL

  # Convert to data.table
  data.table::setDT(data)
  data.table::setDT(sc_demog_lookup)

  # Fix dates and create new variables
  data[
    ,
    service_end_date := fix_sc_missing_end_dates(
      service_end_date,
      period_end_date
    )
  ]
  data[
    ,
    service_start_date := fix_sc_start_dates(
      service_start_date,
      period_start_date
    )
  ]
  data[
    ,
    service_end_date := fix_sc_end_dates(
      service_start_date,
      service_end_date,
      period_end_date
    )
  ]


  # Rename columns
  data.table::setnames(
    data,
    old = c("service_start_date", "service_end_date"),
    new = c("record_keydate1", "record_keydate2")
  )

  # Additional mutations
  data[
    ,
    c(
      "recid",
      "smrtype",
      "sc_send_lca"
    ) := list(
      "AT",
      data.table::fcase(
        service_type == 1L,
        "AT-Alarm",
        service_type == 2L,
        "AT-Tele",
        default,
        NA_character_
      ),
      convert_sc_sending_location_to_lca(sending_location)
    )
  ]

  # RIGHT_JOIN with sc_demog_lookup
  data <- data[sc_demog_lookup, on = list(sending_location, social_care_id)]

  # Replace social_care_id with latest if needed (assuming replace_sc_id_with_latest is a custom function)
  data <- replace_sc_id_with_latest(data)


  # Deal with episodes that have a package across quarters
  data[, pkg_count := seq_len(.N), by = list(
    sending_location,
    social_care_id,
    record_keydate1,
    smrtype,
    period
  )]

  # Order data before summarizing
  data <- data %>%
    dplyr::group_by(
      .data$sending_location,
      .data$social_care_id,
      .data$record_keydate1,
      .data$smrtype,
      .data$period
    ) %>%
    # Sort prior to merging
    dplyr::arrange(.by_group = TRUE) %>%
    dplyr::ungroup() %>%
    data.table::as.data.table()

  # Summarize to merge episodes
  qtr_merge <- data[, list(
    sc_latest_submission = data.table::last(period),
    record_keydate2 = data.table::last(record_keydate2),
    chi = data.table::last(chi),
    gender = data.table::last(gender),
    dob = data.table::last(dob),
    postcode = data.table::last(postcode),
    recid = data.table::last(recid),
    sc_send_lca = data.table::last(sc_send_lca)
  ), by = list(
    sending_location,
    social_care_id,
    record_keydate1,
    smrtype,
    pkg_count
  )]

  # Convert back to data.frame if necessary
  qtr_merge <- as.data.frame(qtr_merge) %>%
    slfhelper::get_anon_chi()


  if (write_to_disk) {
    write_file(
      qtr_merge,
      get_sc_at_episodes_path(check_mode = "write")
    )
  }

  return(qtr_merge)
}
