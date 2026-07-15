#' Read Prescribing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_prescribing <- function(
    year,
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "pis", year = year)

  # Check and convert to calendar year
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (!check_year_valid(year, type = "pis")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  pis_file <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_prescribing_source") # TODO: Check table name.
  ) %>%
    # Filter by calendar year
    dplyr::filter(
      financial_year == c_year # TODO: Check year column name.
    ) %>%
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
    # Collect and get anonymous CHI
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi") %>%
    # Data type modification
    dplyr::mutate(
      dob = lubridate::as_date(.data$dob)
    )

  log_slf_event(stage = "read", status = "complete", type = "pis", year = year)

  return(pis_file)
}
