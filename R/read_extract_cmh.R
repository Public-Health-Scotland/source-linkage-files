#' Read CMH extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_cmh <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "cmh", year = year)

  # Check and convert to calendar year
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Create dates to filter by calendar year
  # TODO: Check logic and whether this is the correct year column.
  start_date <- as.Date(paste0(substr(c_year, 1, 4), "-03-31"))
  end_date <- as.Date(paste0(as.integer(substr(c_year, 1, 4)) + 1, "-04-01"))

  # Specify years available for running
  if (!check_year_valid(year, type = "cmh")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  extract_cmh <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_cmh_source")
  ) %>%
    # Filter by calendar year
    # TODO: Check logic and whether this is the correct year column.
    dplyr::filter(
      .data$contact_date > start_date,
      .data$contact_date < end_date
    ) %>%
    # Rename variables
    dplyr::select(
      anon_chi = "patient_chi", # TODO: Check we will always get anon_chi
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
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "cmh", year = year)

  return(extract_cmh)
}
