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
      "service_type",
      "service_start_date",
      "service_end_date"
    ) %>%
    # fix bad period (2017, 2020, 2021, and so on)
    dplyr::mutate(
      period = dplyr::if_else(
        grepl("\\d{4}$", .data$period),
        paste0(.data$period, "Q4"),
        .data$period
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(c("sending_location", "service_type"), ~ as.integer(.x))
    ) %>%
    dplyr::arrange(.data$sending_location, .data$social_care_id) %>%
    dplyr::collect()

  return(at_full_data)
}
