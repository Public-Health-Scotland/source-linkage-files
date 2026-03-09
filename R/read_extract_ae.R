#' Read A&E extract
#'
#' @inherit read_extract_acute
#'
#' @export
#'
read_extract_ae <- function(year,
                            denodo_connect, # TO-DO: will be hardcoded to denodo_connect = get_denodo_connection()
                            file_path = get_boxi_extract_path(year = year, type = "ae", BYOC_MODE),
                            BYOC_MODE) {
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  }

  # Read Extract
  extract_ae <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_ae2_episode_level_source")
  ) %>%
    dplyr::filter(
      financial_year == !!c_year & # TO-DO: check assumption that arrival_financial_year == financial_year
        (significant_facility_code == "32" | is.na(significant_facility_code))
    ) %>%
    dplyr::select(
      record_keydate1 = "arrival_date",
      record_keydate2 = "dat_date",
      keytime1 = "arrival_time",
      keytime2 = "dat_time",
      chi = "patient_chi",
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
      age = "age_at_midpoint_of_financial_year",
      case_ref_number = "care_reference_number", # TO-DO: needs to be renamed by NSS from care to case?
      postcode_epi = "postcode_epi",
      postcode_chi = "postcode_chi",
      commhosp = "community_hospital_flag"
    ) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("chi")

  return(extract_ae)
}
