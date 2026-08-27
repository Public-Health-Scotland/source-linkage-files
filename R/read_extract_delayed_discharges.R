#' Read Delayed Discharges extract
#'
#' @param denodo_connect Connection to denodo database
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
read_extract_delayed_discharges <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "dd", year = "all")

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read Extract
  extract_delayed_discharges <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_dd_source")
  ) %>%
    dplyr::select(
      anon_chi = "patient_chi",
      postcode = "postcode",
      dd_responsible_lca = "local_authority_responsible",
      original_admission_date = "original_admission_date",
      rdd = "ready_discharge_date",
      delay_end_date = "delayed_discharge_end_date",
      delay_end_reason = "delayed_discharge_reason",
      primary_delay_reason = "primary_delay_reason",
      secondary_delay_reason = "secondary_delay_reason",
      hbtreatcode = "health_board_of_treatment",
      location = "location_code",
      spec = "specialty",
      monthflag = "month_flag"
    ) %>%
    dplyr::collect() %>%
    dplyr::mutate(
      monthflag = lubridate::my(.data[["monthflag"]]),
      delay_end_reason = as.integer(.data[["delay_end_reason"]])
    )

  log_slf_event(stage = "read", status = "complete", type = "dd", year = "all")

  return(extract_delayed_discharges)
}
