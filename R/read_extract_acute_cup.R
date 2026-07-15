#' Read Acute cup extract
#'
#' @inherit read_extract_acute
#'
#' @export
#'
read_extract_acute_cup <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE = BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "acute_cup", year = year)

  # Check and convert to calendar year
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (!check_year_valid(year, type = "acute_cup")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  extract_acute_cup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_acute_cup_source")
  ) %>%
    # Filter by calendar year
    dplyr::filter(
      acute_admission_financial_year >= c_year,
      acute_discharge_financial_year <= c_year
    ) %>%
    # Rename variables
    dplyr::select(
      chi = "patient_chi",
      case_reference_number = "case_reference_number",
      record_keydate1 = "acute_admission_date",
      record_keydate2 = "acute_discharge_date",
      tadm = "acute_admission_type_code",
      disch = "acute_discharge_type_code",
      cup_marker = "cup_marker",
      cup_pathway = "cup_pathway_name"
    ) %>%
    dplyr::distinct() %>%
    # Collect and get anonymous CHI
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  log_slf_event(stage = "read", status = "complete", type = "acute_cup", year = year)

  return(extract_acute_cup)
}
