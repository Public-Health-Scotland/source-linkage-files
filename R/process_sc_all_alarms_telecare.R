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
  sc_demog_lookup = read_file(get_sc_demog_lookup_path()),
  write_to_disk = TRUE
) {
  # Data Cleaning-----------------------------------------------------

  # fix "no visible binding for global variable"
  service_end_date <- period_end_date <- service_start_date <- service_type <-
    default <- sending_location <- social_care_id <- pkg_count <-
    record_keydate1 <- smrtype <- period <- record_keydate2 <- anon_chi <-
    gender <- dob <- postcode <- recid <- person_id <- sc_send_lca <-
    period_start_date <- NULL

  # add per in social_care_id in Renfrewshire
  data <- data %>%
    fix_scid_renfrewshire()

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
        default = NA_character_
      ),
      convert_sc_sending_location_to_lca(sending_location)
    )
  ]

  data <- data %>%
    add_fy_qtr_from_period()
  data[, financial_quarter := NULL]

  data.table::setkey(sc_demog_lookup, sending_location, social_care_id, financial_year)
  # left-join: keep all rows of `data`, bring columns from `sc_demog_lookup`
  data <- sc_demog_lookup[
    data,
    on = .(sending_location, social_care_id, financial_year),
    roll = "nearest" # exact match on first 2 cols; nearest on financial_year
  ]
  # To do nearest join is because some sc episode happen in say 2018,
  # but demographics data submitted in the following year, say 2019.


  # Replace social_care_id with latest if needed (assuming replace_sc_id_with_latest is a custom function)
  data <- data.table::as.data.table(replace_sc_id_with_latest(data))

  # Deal with episodes that have a package across quarters
  data[, pkg_count := seq_len(.N), by = list(
    sending_location,
    social_care_id,
    record_keydate1,
    smrtype,
    period
  )]

  # Order data before summarizing
  data.table::setorder(
    data,
    sending_location,
    social_care_id,
    record_keydate1,
    smrtype,
    period,
    extract_date,
    consistent_quality
  )

  # Summarize to merge episodes
  qtr_merge <- data[, list(
    sc_latest_submission = data.table::last(period),
    record_keydate2 = data.table::last(record_keydate2),
    anon_chi = data.table::last(anon_chi),
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
    create_person_id() %>%
    select_linking_id()

  if (write_to_disk) {
    write_file(
      qtr_merge,
      get_sc_at_episodes_path(check_mode = "write"),
      group_id = 3206 # hscdiip owner
    )
  }

  return(qtr_merge)
}
