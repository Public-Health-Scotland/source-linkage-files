#' Read district nursing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_district_nursing <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "dn", year = year)

  # Check and convert to calendar year
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Create dates to filter by calendar year
  # TODO: Check logic and whether this is the correct year column.
  start_date <- as.Date(paste0(substr(c_year, 1, 4), "-03-31"))
  end_date <- as.Date(paste0(as.integer(substr(c_year, 1, 4)) + 1, "-04-01"))

  # Specify years available for running
  if (!check_year_valid(year, type = "dn")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  extract_district_nursing <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_dn_source")
  ) %>%
    # Filter by calendar year
    # TODO: Check logic and whether this is the correct year column.
    dplyr::filter(
      .data$contact_date > start_date,
      .data$contact_date < end_date
    ) %>%
    # Rename variables
    dplyr::select(
      age = "age_at_contact_date",
      dob = "patient_dob_date",
      gender = "gender",
      hscp = "hscp_of_residence_code",
      hbrescode = "nhs_board_of_residence_9",
      lca = "patient_council_area",
      postcode = "patient_postcode",
      gpprac = "practice_code",
      hbpraccode = "practice_nhs_board_code_9",
      hbtreatcode = "treatment_nhs_board_code_9",
      anon_chi = "patient_chi",
      record_keydate1 = "contact_date",
      primary_intervention = "primary_intervention_category",
      intervention_1 = "other_intervention_category_1",
      intervention_2 = "other_intervention_category_2",
      duration_contact = "duration_of_contact",
      location_contact = "location_of_contact",
      `Patient Data Zone 2011 (Contact)` = "patient_data_zone_2011"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "dn", year = year)

  return(extract_district_nursing)
}
