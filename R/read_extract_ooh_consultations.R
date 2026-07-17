#' Read GP OOH Consultations extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Consultations extract data
read_extract_ooh_consultations <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "gp_ooh-c", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (!check_year_valid(year, type = "gpooh")) {
    return(tibble::tibble())
  }

  # Disconnect from Denodo
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read consultations data
  consultations_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gp_ooh_consultation_source")
  ) %>%
    # Filter to match BOXI extraction
    dplyr::filter(
      sc_start_financial_year == c_year,
      out_of_hours_services_flag == "Y"
    ) %>%
    # rename variables
    dplyr::select(
      chi = "patient_chi",
      dob = "patient_dob",
      gender = "gender",
      postcode = "patient_postcode",
      hbrescode = "patient_nhs_board_code_9_curr",
      hscp = "hscp_of_residence_code_curr",
      gpprac = "practice_code",
      ooh_case_id = "guid",
      attendance_status = "consultation_recorded",
      record_keydate1 = "consultation_start_date_time",
      record_keydate2 = "consultation_end_date_time",
      location = "treatement_location_code",
      location_description = "treatment_location_description",
      hbtreatcode = "treatment_nhs_board_code_9",
      kis_accessed = "kis_accessed",
      refsource = "referral_source",
      consultation_type = "consultation_type",
      consultation_type_unmapped = "consultation_type_unmapped"
    ) %>%
    dplyr::distinct() %>%
    dplyr::collect() %>%
    # Restore CHI leading zero
    dplyr::mutate(chi = phsmethods::chi_pad(.data$chi)) %>%
    # change back to anon_chi
    slfhelper::get_anon_chi()

  log_slf_event(stage = "read", status = "complete", type = "gp_ooh-c", year = year)

  return(consultations_extract)
}
