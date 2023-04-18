#' Read Social Care - Care Home data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_care_home <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {
  ch_data <- dplyr::tbl(
    sc_dvprod_connection,
    dbplyr::in_schema("social_care_2", "carehome_snapshot")
  ) %>%
    dplyr::select(
      "ch_name",
      "ch_postcode",
      "sending_location",
      "social_care_id",
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
    dplyr::mutate(period = dplyr::if_else(
      .data$period == "2017",
      "2017Q4",
      .data$period
    )) %>%
    dplyr::collect() %>%
    dplyr::mutate(
      dplyr::across(c(
        "sending_location",
        "ch_provider",
        "reason_for_admission",
        "type_of_admission",
        "nursing_care_provision"
      ), as.integer)
    )

  return(ch_data)
}
