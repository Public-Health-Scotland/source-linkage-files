#' Read Social Care SDS data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
#' @export
#'
read_sc_all_sds <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {
  sds_full_data <- dplyr::tbl(
    sc_dvprod_connection,
    dbplyr::in_schema("social_care_2", "sds_snapshot")
  ) %>%
    dplyr::select(
      "sending_location",
      "social_care_id",
      "period",
      "sds_period_start_date",
      "sds_period_end_date",
      "sds_start_date",
      "sds_end_date",
      "sds_option_1",
      "sds_option_2",
      "sds_option_3",
      "sds_start_date_after_end_date",
      "sds_start_date_after_period_end_date",
      "sds_end_date_not_within_period"
    ) %>%
    dplyr::collect() %>%
    dplyr::distinct() %>%
    dplyr::mutate(dplyr::across(c(
      "sending_location",
      "sds_option_1",
      "sds_option_2",
      "sds_option_3"
    ), as.integer)) %>%
    dplyr::filter(.data$sds_start_date_after_period_end_date != 1)

  return(sds_full_data)
}
