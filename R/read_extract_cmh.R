#' Read CMH extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_cmh <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  file_path = get_boxi_extract_path(year = year, type = "cmh", BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "cmh", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path()) {
    return(tibble::tibble())
  }

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read BOXI extract
  extract_cmh <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_cmh_source")
  ) %>% # TODO: Check table name.
    dplyr::filter(financial_year == c_year) %>% # TODO: Check year column.
    dplyr::select(
      chi = "patient_chi",
      dob = "patient_dob",
      gender = "gender",
      postcode = "patient_postcode",
      hbrescode = "nhs_board_of_residence_code_9",
      hscp = "patient_hscp_code_current",
      gpprac = "practice_code",
      hbtreatcode = "treatment_nhs_board_code_9",
      record_keydate1 = "contact_date",
      keytime1 = "contact_start_time",
      duration = "duration_of_contact",
      location = "location_of_contact",
      diag1 = "main_aim_of_contact",
      diag2 = "other_aim_of_contact_1",
      diag3 = "other_aim_of_contact_2",
      diag4 = "other_aim_of_contact_3",
      diag5 = "other_aim_of_contact_4"
    ) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  log_slf_event(stage = "read", status = "complete", type = "cmh", year = year)

  return(extract_cmh)
}
