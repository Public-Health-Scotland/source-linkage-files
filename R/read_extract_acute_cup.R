#' Read Acute cup extract
#'
#' @inherit read_extract_acute
#'
#' @export
#'
read_extract_acute_cup <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  file_path = get_boxi_extract_path(year = year, type = "acute_cup", BYOC_MODE),
  BYOC_MODE
) {
  # Read BOXI extract
  log_slf_event(stage = "read", status = "start", type = "acute_cup", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path()) {
    return(tibble::tibble())
  }

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read Extract
  acute_cup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_acute_cup_source")
  ) %>%
    # Filter to match BOXI extraction
    dplyr::filter(
      acute_admission_financial_year >= c_year,
      acute_discharge_financial_year <= c_year
    ) %>%
    # Select and rename variables
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
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  log_slf_event(stage = "read", status = "complete", type = "acute_cup", year = year)

  return(extract_acute)
}
