#' Read SC demographics
#'
#' @inherit read_sc_all_alarms_telecare
#'
#' @export
read_lookup_sc_demographics <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "sc_demog", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  sc_demog <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_sc_demographic_source")
  ) %>%
    # Rename variables
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
    # Collect
    dplyr::collect()

  latest_quarter <- sc_demog %>%
    dplyr::arrange(dplyr::desc(.data$period)) %>%
    dplyr::pull(.data$period) %>%
    utils::head(1)

  logger::log_info(stringr::str_glue("Demographics data is available up to {latest_quarter}."))

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
