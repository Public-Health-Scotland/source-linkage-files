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
      "sds_start_date_after_end_date", # get fixed
      "sds_start_date_after_period_end_date" # get removed
    ) %>%
    dplyr::distinct() %>%
    dplyr::collect()

  latest_quarter <- sds_full_data %>%
    dplyr::arrange(desc(period)) %>%
    dplyr::pull(period) %>%
    head(1)
  cli::cli_alert_info(stringr::str_glue("SDS data is up to {latest_quarter}."))

  if (!fs::file_exists(get_sandpit_extract_path(type = "sds"))) {
    sds_full_data %>%
      write_file(get_sandpit_extract_path(type = "sds"))

    sds_full_data %>%
      process_tests_sc_sandpit(type = "sds")
  } else {
    sds_full_data <- sds_full_data
  }

  sds_full_data <- sds_full_data %>%
    dplyr::mutate(dplyr::across(c(
      "sending_location",
      "sds_option_1",
      "sds_option_2",
      "sds_option_3"
    ), as.integer))

  return(sds_full_data)
}
