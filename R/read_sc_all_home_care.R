#' Read Social Care Home Care data
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
read_sc_all_home_care <- function() {

  # Read in data---------------------------------------

  # set-up conection to platform
  db_connection <- phs_db_connection(dsn = "DVPROD")

  # read in data - social care 2 home care
  home_care_data <- dplyr::tbl(db_connection, dbplyr::in_schema("social_care_2", "homecare_snapshot")) %>%
    dplyr::select(
      .data$sending_location,
      .data$sending_location_name,
      .data$social_care_id,
      .data$hc_service_start_date,
      .data$hc_service_end_date,
      .data$period,
      .data$financial_year,
      .data$financial_quarter,
      .data$hc_service,
      .data$hc_service_provider,
      .data$reablement,
      .data$hc_hours_derived,
      .data$total_staff_home_care_hours,
      .data$multistaff_input,
      .data$hc_start_date_after_end_date
    ) %>%
    # fix 2017
    dplyr::mutate(financial_quarter = dplyr::if_else(.data$financial_year == 2017 & is.na(.data$financial_quarter), 4, .data$financial_quarter)) %>%
    dplyr::mutate(period = dplyr::if_else(.data$period == "2017", "2017Q4", .data$period)) %>%
    # drop rows start date after end date
    dplyr::filter(.data$hc_start_date_after_end_date == 0) %>%
    dplyr::collect()

  return(home_care_data)
}
