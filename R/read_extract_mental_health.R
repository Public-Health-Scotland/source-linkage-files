#' Read Mental Health extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_mental_health <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  file_path = get_boxi_extract_path(year = year, type = "mh", BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read BOXI extract
  logger::log_info("Read mental health data from Denodo")
  extract_mental_health <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_mental_health_episode_source")
  ) %>%
    dplyr::filter(
      .data$costs_financial_year == c_year,
      .data$duplicate_record_flag != "Y"
    ) %>%
    # rename variables
    dplyr::select(
      costsfy = "costs_financial_year",
      costmonthnum = "costs_financial_month_number",
      record_keydate1 = "date_of_admission",
      record_keydate2 = "date_of_discharge",
      chi = "patient_chi",
      gender = "patient_sex",
      dob = "patient_dob",
      gpprac = "practice_location_code",
      hbpraccode = "practice_nhs_board_code_curr",
      postcode = "geo_postcode",
      hbrescode = "nhs_board_of_residence_code_curr",
      lca = "geo_council_area_code",
      hscp = "geo_hscp_of_residence_code_curr",
      location = "treatment_location_code",
      hbtreatcode = "treatment_nhs_board_code_curr",
      yearstay = "occupied_bed_days",
      spec = "specialty_classification_code",
      sigfac = "significant_facility_code",
      conc = "lead_consultant_hcp_code",
      mpat = "management_of_patient_code",
      cat = "patient_category_code",
      tadm = "admission_type_code",
      adtf = "admitted_trans_from_code",
      admloc = "location_admitted_trans_from_code",
      disch = "discharge_type_code",
      dischto = "discharge_trans_to_code",
      dischloc = "location_discharge_trans_to_code",
      diag1 = "diagnosis_1_code",
      diag2 = "diagnosis_2_code",
      diag3 = "diagnosis_3_code",
      diag4 = "diagnosis_4_code",
      diag5 = "diagnosis_5_code",
      diag6 = "diagnosis_6_code",
      stadm = "status_on_admission_code",
      adcon1 = "admission_diagnosis_1_code",
      adcon2 = "admission_diagnosis_2_code",
      adcon3 = "admission_diagnosis_3_code",
      adcon4 = "admission_diagnosis_4_code",
      age = "age_at_midpoint_of_financial_year",
      cij_marker = "continuous_inpatient_journey_marker",
      cij_pattype_code = "cij_planned_admission_code",
      cij_inpatient = "cij_inpatient_day_case_identifier_code",
      cij_admtype = "cij_type_of_admission_code",
      cij_adm_spec = "cij_admission_specialty_code",
      cij_dis_spec = "cij_discharge_specialty_code",
      cij_start_date = "cij_start_date",
      cij_end_date = "cij_end_date",
      cost_total_net = "total_net_cost",
      alcohol_adm = "alcohol_related_admission",
      submis_adm = "substance_misuse_related_admission",
      falls_adm = "falls_related_admission",
      selfharm_adm = "self_harm_related_admission",
      duplicate = "duplicate_record_flag",
      nhshosp = "nhs_hospital_flag",
      commhosp = "community_hospital_flag",
      uri = "unique_record_id"
    ) %>%
    dplyr::collect() %>%
    # replace NA in cost_total_net by 0
    dplyr::mutate(
      cost_total_net = tidyr::replace_na(.data[["cost_total_net"]], 0.0)
    ) %>%
    slfhelper::get_anon_chi("chi") %>%
    # TODO: remove data type modification after UAT passed
    dplyr::mutate(
      costsfy = as.double(.data$costsfy),
      costmonthnum = as.double(.data$costmonthnum),
      uri = as.character(.data$uri)
    )

  return(extract_mental_health)
}
