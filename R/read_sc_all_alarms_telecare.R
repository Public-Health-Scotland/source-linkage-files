#' Read Social Care Alarms Telecare data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_alarms_telecare <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {
  # Read in data---------------------------------------

  ## read in data - social care 2 demographic
  at_full_data <- dplyr::tbl(
    sc_dvprod_connection,
    dbplyr::in_schema("social_care_2", "equipment_snapshot")
  ) %>%
    dplyr::select(
      "sending_location",
      "social_care_id",
      "period",
      "period_start_date",
      "period_end_date",
      "service_type",
      "service_start_date",
      "service_end_date",
      "service_start_date_after_period_end_date"
    ) %>%
    dplyr::collect() %>%
    dplyr::distinct()

  if (!fs::file_exists(get_sandpit_extract_path(type = "at"))) {
    at_full_data %>%
      write_file(get_sandpit_extract_path(type = "at"))

    at_full_data %>%
      process_tests_sc_sandpit(type = "at")
  } else {
    at_full_data <- at_full_data
  }

  at_full_data <- at_full_data %>%
    dplyr::mutate(
      period_start_date = dplyr::if_else(
        .data$period == "2017",
        lubridate::as_date("2018-01-01"),
        .data$period_start_date
      )
    ) %>%
    # fix bad period - 2017 only has Q4
    dplyr::mutate(
      period = dplyr::if_else(
        .data$period == "2017",
        paste0(.data$period, "Q4"),
        .data$period
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(c("sending_location", "service_type"), ~ as.integer(.x))
    ) %>%
    dplyr::arrange(.data$sending_location, .data$social_care_id) %>%
    dplyr::filter(.data$service_start_date_after_period_end_date != 1)

  return(at_full_data)
}
