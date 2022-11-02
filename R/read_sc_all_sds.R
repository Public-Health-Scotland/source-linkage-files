#' Read Social Care SDS data
#'
#' @param sc_dvprod_connection Connection to the SC platform
#'
#' @return an extract of the data as a [tibble][tibble::tibble-package].
#'
read_sc_all_sds <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {

  # Read in data---------------------------------------
  sds_full_data <- dplyr::tbl(sc_dvprod_connection, dbplyr::in_schema("social_care_2", "sds_snapshot")) %>%
    dplyr::select(
      "sending_location",
      "social_care_id",
      "period",
      "sds_start_date",
      "sds_end_date",
      "sds_option_1",
      "sds_option_2",
      "sds_option_3"
    ) %>%
    dplyr::collect()

  return(sds_full_data)

}
