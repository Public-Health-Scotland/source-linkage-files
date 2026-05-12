#' Read district nursing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_district_nursing <- function(year,
                                          denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                          file_path = get_boxi_extract_path(year = year, type = "dn", BYOC_MODE),
                                          BYOC_MODE) {
  log_slf_event(stage = "read", status = "start", type = "dn", year = year)

  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  }

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read BOXI extract
  extract_district_nursing <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_district_nursing_source")) %>% # TODO: Check table name.
    # TODO: Check whether to filter by year.
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
      chi = "patient_chi",
      record_keydate1 = "contact_date",
      primary_intervention = "primary_intervention_category",
      intervention_1 = "other_intervention_category_1",
      intervention_2 = "other_intervention_category_2",
      duration_contact = "duration_of_contact",
      location_contact = "location_of_contact",
      `Patient Data Zone 2011 (Contact)` = "patient_data_zone_2011"
    ) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  log_slf_event(stage = "read", status = "complete", type = "dn", year = year)

  return(extract_district_nursing)
}
