#' Read Prescribing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_prescribing <- function(year,
                                     denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                     file_path = get_it_prescribing_path(year, BYOC_MODE),
                                     BYOC_MODE) {
  log_slf_event(stage = "read", status = "start", type = "pis", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year) # TODO: Check whether this is required

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  pis_file <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_prescribing_source")
  ) %>% # TODO: Placeholder. Replace with table name.
    filter(financial_year == c_year) %>% # TODO: Check whether this is required and year column name.
    # Rename variables
    dplyr::select(
      chi = "patient_chi",
      dob = "patient_dob",
      gender = "patient_sex",
      postcode = "patient_postcode",
      gpprac = "practice_code",
      no_paid_items = "no_of_paid_items",
      cost_total_net = "pd_paid_gic_excl"
    ) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi") %>%
    # Format prescribing
    dplyr::mutate(
      dob = lubridate::as_date(.data$dob)
    )

  log_slf_event(stage = "read", status = "complete", type = "pis", year = year)

  return(pis_file)
}
