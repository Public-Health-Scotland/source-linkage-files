#' Read Delayed Discharges extract
#'
#' @param file_path Path to DD extract
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
read_extract_delayed_discharges <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    file_path = get_dd_path(BYOC_MODE = BYOC_MODE),
    BYOC_MODE) {

  log_slf_event(stage = "read", status = "start", type = "dd", year = NA) # TO-DO: confirm if year is used in DD

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read Extract
  extract_delayed_discharges <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_delayed_discharges_source") # TO-DO: change to correct bucket name after migration
  ) %>%
    dplyr::select(
      # TO-DO: verify variable names after migration
      patient_chi = "patient_chi",
      postcode = "postcode",
      dd_responsible_lca = "local_authority_responsibile",
      original_admission_date = "original_admission_date",
      rdd = "ready_dischage_date",
      delay_end_date = "delayed_discharge_end_date",
      delayed_discharge_reason = "delayed_discharge_reason",
      delay_end_reason = "delay_end_reason",
      primary_delay_reason = "primary_delay_reason",
      secondary_delay_reason = "secondary_delay_reason",
      hbtreatcode = "health_board_of_treatment",
      location = "location_code",
      spec = "speciality",
      monthflag = "month_flag"
    ) %>%
    dplyr::collect() %>%
    dplyr::mutate(
      monthflag = lubridate::my(.data[["monthflag"]]),
      delay_end_reason = as.integer(.data[["delay_end_reason"]])
    ) %>%
    slfhelper::get_anon_chi("patient_chi")

  log_slf_event(stage = "read", status = "complete", type = "dd", year = NA) # TO-DO: confirm if year is used in DD

  return(extract_delayed_discharges)
}
