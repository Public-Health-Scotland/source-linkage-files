#' Read A&E extract
#'
#' @inherit read_extract_acute
#'
#' @export
#'
read_extract_ae <- function(year,
                            denodo_connect,
                            BYOC_MODE = FALSE) {

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  extract_ae <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_ae2_episode_level_source")
  ) %>%
    dplyr::filter(costs_financial_year == !!c_year) %>% # (Assuming the column name in Denodo is 'costs_financial_year')

    dplyr::select(
      record_keydate1 = "arrival_date",
      record_keydate2 = "dat_date",
      keytime1 = "arrival_time",
      keytime2 = "dat_time",
      chi = "patient_chi", # following the logic from Zihao's refactor-mat
      gender = "patient_sex",
      dob = "patient_dob",
      gpprac = "gp_practice_code",
      lca = "council_area_code",
      hscp = "hscp_of_residence_code_curr",
      location = "treatment_location_code",
      hbrescode = "nhs_board_of_residence_code_curr",
      hbtreatcode = "treatment_nhs_board_code_curr",
      diag1 = "disease_1_code",
      diag2 = "disease_2_code",
      diag3 = "disease_3_code",
      ae_arrivalmode = "arrival_mode_code",
      refsource = "referral_source_code",
      sigfac = "significant_facility_code",
      ae_attendcat = "attendance_category_code",
      ae_disdest = "discharge_destination_code",
      ae_patflow = "patient_flow_code",
      ae_placeinc = "place_of_incident_code",
      ae_reasonwait = "reason_for_wait_code",
      ae_bodyloc = "bodily_location_of_injury_code",
      ae_alcohol = "alcohol_involved_code",
      alcohol_adm = "alcohol_related_admission",
      submis_adm = "substance_misuse_related_admission",
      falls_adm = "falls_related_admission",
      selfharm_adm = "self_harm_related_admission",
      cost_total_net = "total_net_cost",
      age = "age_at_midpoint_of_financial_year"
      # case_ref_number = "case_reference_number",
      # postcode_epi = "postcode_epi",
      # postcode_chi = "postcode_chi",
      # commhosp = "community_hospital_flag"
    ) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  return(extract_ae)
}

# Note arrival financial year
