#' Read SC demographics
#'
#' @param sc_dvprod_connection Connection to the sc platform
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
read_lookup_sc_demographics <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")) {
  sc_demog <- dplyr::tbl(
    sc_dvprod_connection,
    dbplyr::in_schema("social_care_2", "demographic_snapshot")
  ) %>%
    dplyr::select(
      "latest_record_flag",
      "period",
      "sending_location",
      "sending_location_name",
      "social_care_id",
      "chi_upi",
      "chi_date_of_birth",
      "date_of_death",
      "chi_postcode",
      "submitted_postcode",
      "chi_gender_code",
      "extract_date"
    ) %>%
    dplyr::collect()

  latest_quarter <- sc_demog %>%
    dplyr::arrange(dplyr::desc(.data$period)) %>%
    dplyr::pull(.data$period) %>%
    utils::head(1)
  cli::cli_alert_info(stringr::str_glue("Demographics data is available up to {latest_quarter}."))

  sc_demog <- sc_demog %>%
    slfhelper::get_anon_chi(chi_var = "chi_upi")

  if (!fs::file_exists(get_sandpit_extract_path(type = "demographics"))) {
    sc_demog %>%
      write_file(get_sandpit_extract_path(type = "demographics"),
        group_id = 3206 # hscdiip owner
      )

    sc_demog %>%
      process_tests_sc_sandpit(type = "demographics")
  }

  sc_demog <- sc_demog %>%
    dplyr::mutate(
      dplyr::across(c(
        "latest_record_flag",
        "sending_location",
        "chi_gender_code"
      ), as.integer)
    ) %>%
    dplyr::distinct()

  return(sc_demog)
}
