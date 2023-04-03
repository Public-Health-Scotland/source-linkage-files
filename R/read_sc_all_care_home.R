#' Read Social Care - Care Home data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_care_home <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {
  # Read in data---------------------------------------

  ## read in data - social care 2 demographic
  ch_data <- dplyr::tbl(
    sc_dvprod_connection,
    dbplyr::in_schema("social_care_2", "carehome_snapshot")
  ) %>%
    dplyr::select(
      "ch_name",
      "ch_postcode",
      "sending_location",
      "social_care_id",
      "financial_year",
      "financial_quarter",
      "period",
      "ch_provider",
      "reason_for_admission",
      "type_of_admission",
      "nursing_care_provision",
      "ch_admission_date",
      "ch_discharge_date",
      "age"
    ) %>%
    # Correct FY 2017
    dplyr::mutate(
      financial_quarter = dplyr::if_else(
        .data$financial_year == 2017L & is.na(.data$financial_quarter),
        4L,
        .data$financial_quarter
      ),
      period = dplyr::if_else(
        .data$financial_year == 2017L & .data$financial_quarter == 4L,
        "2017Q4",
        .data$period
      )
    ) %>%
    dplyr::collect()

  return(ch_data)
}
