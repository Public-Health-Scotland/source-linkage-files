#' Read SC demographics
#'
#' @param sc_dvprod_connection Connection to the sc platform
#' @param BYOC_MODE BYOC_MODE
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
read_lookup_sc_demographics <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD"), BYOC_MODE) {
  log_slf_event(stage = "read", status = "start", type = "sc_demog", year = "all")

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  sc_demog <- dplyr::tbl(
    sc_dvprod_connection,
    dbplyr::in_schema("social_care_2", "demographic_snapshot") # TODO: update SDL table
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
    slfhelper::get_anon_chi(chi_var = "chi_upi") %>%
    dplyr::mutate(
      dplyr::across(c(
        "latest_record_flag",
        "sending_location",
        "chi_gender_code"
      ), as.integer)
    ) %>%
    dplyr::distinct()

  log_slf_event(stage = "read", status = "complete", type = "sc_demog", year = "all")

  return(sc_demog)
}
