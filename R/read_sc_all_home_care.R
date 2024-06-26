#' Read Social Care Home Care data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_home_care <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {
  home_care_data <- dplyr::tbl(
    sc_dvprod_connection,
    dbplyr::in_schema("social_care_2", "homecare_snapshot")
  ) %>% dplyr::collect()

  home_care_data <- home_care_data %>%
    dplyr::select(
      "sending_location",
      "sending_location_name",
      "social_care_id",
      "hc_service_start_date",
      "hc_service_end_date",
      "period",
      "hc_period_start_date",
      "hc_period_end_date",
      "financial_year",
      "hc_service",
      "hc_service_provider",
      "reablement",
      "hc_hours_derived",
      "total_staff_home_care_hours",
      "multistaff_input",
      "hc_start_date_after_end_date",
      "hc_start_date_after_period_end_date"
    ) %>%
    dplyr::mutate(
      hc_period_start_date = dplyr::if_else(
        .data$period == "2017",
        lubridate::as_date("2018-01-01"),
        .data$hc_period_start_date
      )
    ) %>%
    # fix 2017
    dplyr::mutate(period = dplyr::if_else(
      .data$period == "2017",
      "2017Q4",
      .data$period
    )) %>%
    # drop rows start date after end date
    dplyr::distinct()

  if (!fs::file_exists(get_sandpit_extract_path(type = "hc"))) {
    home_care_data %>%
      write_file(get_sandpit_extract_path(type = "hc"))

    home_care_data %>%
      process_tests_sc_sandpit(type = "hc")
  } else {
    home_care_data <- home_care_data
  }

  home_care_data <- home_care_data %>%
    dplyr::mutate(dplyr::across(c(
      "sending_location",
      "financial_year",
      "hc_service",
      "hc_service_provider",
      "reablement"
    ), as.integer))

  return(home_care_data)
}
