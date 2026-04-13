#' Read Acute extract
#'
#' @param year Financial year for the BOXI extract.
#' @param file_path BOXI extract location
#'
#' @return a [tibble][tibble::tibble-package].
#'
#' @export
read_extract_acute <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  file_path = get_boxi_extract_path(year = year, type = "acute", BYOC_MODE),
  BYOC_MODE
) {
  # Read BOXI extract
  log_slf_event(stage = "read", status = "start", type = "acute", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  }

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read Extract
  extract_acute <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_acute_source")
  ) %>%
    # Filter to match BOXI extraction
    dplyr::filter(
      costs_financial_year == c_year,
      gls_record %in% c("Y", "N")
    ) %>%
    # Select and rename variables
    dplyr::select(
      costsfy = "costs_financial_year",
      case_reference_number = "case_reference_number",
      costmonthnum = "costmonthnum",
      GLS_record = "gls_record", # TO-DO: come back
      record_keydate1 = "date_of_admission",
      record_keydate2 = "date_of_discharge",
      chi = "patient_chi",
      gender = "patient_sex",
      dob = "patient_dob",
      gpprac = "practice_location_code",
      hbpraccode = "practice_nhs_board_code_curr",
      postcode = "geo_postcode",
      hbrescode = "nhs_board_of_residence_code_curr", # TO-DO: come back
      lca = "geo_council_area_code",
      hscp = "geo_hscp_of_residence_code_curr",
      geo_data_zone_2011 = "geo_data_zone_2011",
      location = "treatment_location_code",
      hbtreatcode = "treatment_nhs_board_code_curr",
      yearstay = "occupied_bed_days",
      ipdc = "inpatient_day_case_identifier_code",
      spec = "specialty_classification_code",
      sigfac = "significant_facility_code",
      conc = "lead_consultant",
      mpat = "management_of_patient_code",
      cat = "patient_category_code",
      tadm = "admission_type_code",
      adtf = "admitted_trans_from_code",
      admloc = "location_admitted_trans_from_code",
      oldtadm = "old_smrw_typeof_admission_code",
      disch = "discharge_type_code",
      dischto = "discharge_trans_to_code",
      dischloc = "location_discharge_trans_to_code",
      diag1 = "diagnosis_1_code",
      diag2 = "diagnosis_2_code",
      diag3 = "diagnosis_3_code",
      diag4 = "diagnosis_4_code",
      diag5 = "diagnosis_5_code",
      diag6 = "diagnosis_6_code",
      op1a = "operation_1a_code",
      op1b = "operation_1b_code",
      dateop1 = "date_of_operation_1",
      op2a = "operation_2a_code",
      op2b = "operation_2b_code",
      dateop2 = "date_of_operation_2",
      op3a = "operation_3a_code",
      op3b = "operation_3b_code",
      dateop3 = "date_of_operation_3",
      op4a = "operation_4a_code",
      op4b = "operation_4b_code",
      dateop4 = "date_of_operation_4",
      age = "age_at_midpoint_of_financial_year",
      smr01_cis_marker = "continuous_inpatient_stay",
      cij_marker = "continuous_inpatient_journey_marker",
      cij_pattype_code = "cij_planned_admission_code",
      cij_ipdc = "cij_inpatient_day_case_id_code",
      cij_admtype = "cij_type_of_admission_code",
      cij_adm_spec = "cij_admission_specialty_code",
      cij_dis_spec = "cij_discharge_spaciality_code",
      cij_start_date = "cij_start_date",
      cij_end_date = "cij_end_date",
      cost_total_net = "total_net_costs",
      nhshosp = "nhs_hospital_flag",
      commhosp = "community_hosp_flag",
      alcohol_adm = "alcohol_related_admission",
      submis_adm = "substance_misuse_related_admission",
      falls_adm = "falls_related_admission",
      selfharm_adm = "self_harm_related_admission",
      uri = "unique_record_id",
      lineno = "lineno"
    ) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  log_slf_event(stage = "read", status = "complete", type = "acute", year = year)

  return(extract_acute)
}
