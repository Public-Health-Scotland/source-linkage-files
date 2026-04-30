#' Read Outpatients extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_outpatients <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  file_path = get_boxi_extract_path(year, type = "outpatient", BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "outpatient", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read BOXI extract
  extract_outpatients <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_outpatients_source")) %>%
    # Filter by year
    dplyr::filter(
      .data$clinic_date_fin_year == c_year
      ) %>%
    # Rename variables
    dplyr::select(
      clinic_date_fy = "clinic_date_fin_year",
      record_keydate1 = "clinic_date",
      uri = "episode_record_key",
      chi = "patient_chi",
      gender = "patient_sex",
      dob = "patient_dob",
      gpprac = "practice_location_code",
      hbpraccode = "practice_nhs_board_code_curr",
      postcode = "geo_postcode",
      hbrescode = "nhs_board_of_residence_code_curr",
      lca = "geo_council_area_code",
      location = "treatment_location_code",
      hbtreatcode = "treatment_nhs_board_code_curr",
      op1a = "operation_1a_code",
      op1b = "operation_1b_code",
      dateop1 = "date_of_main_operation",
      op2a = "operation_2a_code",
      op2b = "operation_2b_code",
      dateop2 = "date_of_operation_2",
      spec = "specialty_classification_1_4_97_code",
      sigfac = "significant_facility_code",
      conc = "consultant_hcp_code",
      cat = "patient_category_code",
      refsource = "referral_source_code",
      reftype = "referral_type_code",
      clinic_type = "clinic_type_code",
      attendance_status = "clinic_attendance_code",
      age = "age_at_midpoint_of_financial_year",
      alcohol_adm = "alcohol_related_admission",
      submis_adm = "substance_misuse_related_admission",
      falls_adm = "falls_related_admission",
      selfharm_adm = "self_harm_related_admission",
      nhshosp = "nhs_hospital_flag",
      commhosp = "community_hospital_flag",
      cost_total_net = "total_net_cost"
    )  %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  log_slf_event(stage = "read", status = "complete", type = "outpatient", year = year)

  return(extract_outpatients)
}
