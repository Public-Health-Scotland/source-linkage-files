#' Read Maternity extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_maternity <- function(year,
                                   denodo_connect,
                                   file_path = get_boxi_extract_path(year, type = "maternity", BYOC_MODE),
                                   BYOC_MODE) {
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  }

  # Read BOXI extract
  extract_maternity <- tibble::as_tibble(odbc::dbGetQuery(
    denodo_connect,
    stringr::str_glue(
      "select * from sdl.sdl_maternity_episode_source
        where costs_financial_year = {c_year}"
    )
  )) %>%
    # Rename variables in line with SLF variable names
    dplyr::select(
      admloc = "admitted_transfer_location_code",
      adtf = "admitted_transfer_from_code",
      age = "age_at_midpoint_financial_year",
      alcohol_adm = "alcohol_related_admission",
      chi = "patient_chi",
      cij_adm_spec = "cij_admission_specialty_code",
      cij_admtype = "cij_type_of_admission_code",
      cij_dis_spec = "cij_discharge_specialty_code",
      cij_end_date = "cij_end_date",
      cij_ipdc = "cij_inpatient_day_case_identifier_code",
      cij_marker = "continuous_inpatient_journey_marker",
      cij_pattype_code = "cij_planned_admission_code",
      cij_start_date = "cij_start_date",
      conc = "consultant_hcp_code",
      commhosp = "community_hospital_flag",
      cost_total_net = "total_net_cost",
      costsfy = "costs_financial_year",
      dateop1 = "date_of_main_operation",
      diag1 = "diagnosis_1_discharge_code",
      diag2 = "diagnosis_2_discharge_code",
      diag3 = "diagnosis_3_discharge_code",
      diag4 = "diagnosis_4_discharge_code",
      diag5 = "diagnosis_5_discharge_code",
      diag6 = "diagnosis_6_discharge_code",
      disch = "discharge_type_code",
      dischloc = "discharge_to_location_code",
      dischto = "discharge_transfer_to_code",
      discondition = "condition_on_discharge_code",
      dob = "patient_dob",
      falls_adm = "falls_related_admission",
      gpprac = "practice_location_code",
      hbpraccode = "practice_nhs_health_board_curr",
      hbrescode = "nhs_board_of_residence_code_curr",
      hbtreatcode = "treatment_nhs_board_code_curr",
      hscp = "hscp_of_residence_code_curr",
      lca = "geo_council_area_code",
      location = "treatment_location_code",
      mpat = "management_of_patient_code",
      nhshosp = "nhs_hospital_flag",
      op1a = "operation_1a_code",
      op2a = "operation_2a_code",
      op3a = "operation_3a_code",
      op4a = "operation_4a_code",
      postcode = "geo_postcode",
      record_keydate1 = "date_of_admission",
      record_keydate2 = "date_of_discharge",
      selfharm_adm = "self_harm_related_admission",
      sigfac = "significant_facility_code",
      spec = "specialty_classification_code",
      submis_adm = "substance_misuse_related_admission",
      uri = "maternity_unique_record_identifier",
      yearstay = "occupied_bed_days"
    ) %>%
    slfhelper::get_anon_chi("chi")


  return(extract_maternity)
}
