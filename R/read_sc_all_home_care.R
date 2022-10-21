#' Read Social Care Home Care data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
read_sc_all_home_care <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {

   # Read in data---------------------------------------

  # read in data - social care 2 home care
  home_care_data <- dplyr::tbl(sc_dvprod_connection, dbplyr::in_schema("social_care_2", "homecare_snapshot")) %>%
    dplyr::select(
      "sending_location",
      "sending_location_name",
      "social_care_id",
      "hc_service_start_date",
      "hc_service_end_date",
      "period",
      "financial_year",
      "financial_quarter",
      "hc_service",
      "hc_service_provider",
      "reablement",
      "hc_hours_derived",
      "total_staff_home_care_hours",
      "multistaff_input",
      "hc_start_date_after_end_date"
    ) %>%
    # fix 2017
    dplyr::mutate(financial_quarter = dplyr::if_else(.data$financial_year == 2017 & is.na(.data$financial_quarter), 4, .data$financial_quarter)) %>%
    dplyr::mutate(period = dplyr::if_else(.data$period == "2017", "2017Q4", .data$period)) %>%
    # drop rows start date after end date
    dplyr::filter(.data$hc_start_date_after_end_date == 0) %>%
    dplyr::collect()

  return(home_care_data)
}
