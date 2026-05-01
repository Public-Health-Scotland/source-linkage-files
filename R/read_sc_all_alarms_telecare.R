#' Read Social Care Alarms Telecare data
#'
#' @param sc_dvprod_connection Connection to the BI denodo platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_alarms_telecare <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE), BYOC_MODE) {
  # Read in data---------------------------------------
  log_slf_event(stage = "read", status = "start", type = "at", year = "all")

  ## read in data - social care 2 demographic
  at_full_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("social_care_2", "equipment_snapshot") # TODO: update SDL table
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
    dplyr::distinct() %>%
    dplyr::collect()

  latest_quarter <- at_full_data %>%
    dplyr::arrange(dplyr::desc(.data$period)) %>%
    dplyr::pull(.data$period) %>%
    utils::head(1)
  cli::cli_alert_info(stringr::str_glue("Alarm Telecare data is available up to {latest_quarter}."))

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

  log_slf_event(stage = "read", status = "complete", type = "at", year = "all")

  return(at_full_data)
}
