#' Get sdl view name for data - either from source, snapshot or processed.
#'
#' @description Returns the Denodo SDL table name for the extract
#' corresponding to a given dataset type.
#'
#' @param dataset Character. Dataset id (e.g. "acute", "ae", etc.)
#' @param version Character. Version (e.g. "snapshot", "source", "processed")
#'
#' @return Character string of SDL table name
#'
#' @export
#' @family file path functions
get_sdl_names <- function(dataset, version) {

  version <- match.arg(version, c("source", "snapshot", "processed"))

  sdl_names <- tibble::tribble(
    ~type, ~source, ~snapshot, ~processed,
    # Acute
    "acute", "sdl_acute_source", "sdl_acute_snapshot", "sdl_acute_processed",
    "acute_cup", "sdl_acute_cup_source", "sdl_acute_cup_snapshot", NA_character_,

    # A&E
    "ae", "sdl_ae2_episode_level_source", "sdl_ae2_episode_level_snapshot", "sdl_ae_processed",
    "ae_cup", "sdl_ae_ucd_cup_source", "sdl_ae_ucd_cup_snapshot", NA_character_,

    # Costs
    "ch_cost_lookup", "sdl_carehomecostopendata_source", NA_character_, "sdl_ch_cost_lookup_processed",
    "dn_cost_lookup", "sdl_dn_cost_lookup_source", NA_character_, "sdl_dn_cost_lookup_processed",
    "hc_cost_lookup", "sdl_hc_cost_lookup_source", NA_character_, "sdl_hc_cost_lookup_processed",
    "ooh_cost_lookup", "sdl_ooh_cost_lookup_source", NA_character_, NA_character_,

    # CMH
    "cmh", "sdl_cmh_source", NA_character_, "sdl_cmh_processed",

    # Deaths
    "chi_deaths", "sdl_chi_deaths_source", "sdl_chi_deaths_snapshot", "sdl_chi_deaths_processed",
    "combined_deaths", NA_character_, NA_character_, "sdl_combined_deaths_processed",
    "nrs_deaths", "sdl_nrs_deaths_source", "sdl_nrs_deaths_snapshot", "sdl_nrs_deaths_processed",

    # Delayed discharges
    "dd", "sdl_dd_source", NA_character_, "sdl_dd_processed",

    # District nursing
    "dn", "sdl_dn_source", NA_character_, "sdl_dn_processed",
    "dn_contact_lookup", "sdl_dn_contacts_source", NA_character_, NA_character_,

    # GP out of hours
    "gp_ooh_consultation", "sdl_gp_ooh_consultation_source", "sdl_gp_ooh_consultation_snapshot", NA_character_,
    "gp_ooh_cup", "sdl_gp_ooh_cup_source", "sdl_gp_ooh_cup_snapshot", NA_character_,
    "gp_ooh_diagnosis", "sdl_gp_ooh_diagnosis_source", "sdl_gp_ooh_diagnosis_snapshot", NA_character_,
    "gp_ooh_outcome", "sdl_gp_ooh_outcome_source", "sdl_gp_ooh_outcome_snapshot", NA_character_,
    "gp_ooh", NA_character_, NA_character_, "sdl_gp_ooh_processed",

    # Lookups
    "la_lookup", "sdl_laopendatalookup_source", NA_character_, NA_character_,
    "datazone_pop", "sdl_datazone_population_source", NA_character_, NA_character_,
    "readcode_lookup", "sdl_read_code_lookup_source", NA_character_, NA_character_,
    "hscp_locality", "sdl_hscp_localities_source", NA_character_, NA_character_,
    "hscp_pop_lookup", "sdl_hscp_population_source", NA_character_, NA_character_,
    "simd", "sdl_simd_source", NA_character_, NA_character_,
    "spd", "sdl_spd_source", NA_character_, NA_character_,
    "geog_labels", "sdl_geography_labels_source", NA_character_, NA_character_,
    "gpprac_cluster", "sdl_gpprac_cluster_source", NA_character_, NA_character_,
    "gpprac_ref_data", "sdl_gpprac_ref_source", NA_character_, NA_character_,
    "ch_name_lookup", "sdl_ch_name_lookup_source", NA_character_, NA_character_,
    "uk_postcode", "sdl_uk_postcode_list_source", NA_character_, NA_character_,
    "gpprac_lookup", NA_character_, NA_character_, "sdl_gpprac_lookup_processed",
    "postcode_lookup", NA_character_, NA_character_, "sdl_postcode_lookup_processed",

    # Homelessness
    "homelessness", "sdl_homelessness_source", "sdl_homelessness_snapshot", "sdl_homelessness_processed",
    "homelessness_completeness", "sdl_homelessness_completeness_source", NA_character_, "sdl_homelessness_completeness_processed",

    # HHG
    "hhg", "sdl_hhg_source", NA_character_, NA_character_,

    # Long term conditions
    "ltc", "sdl_long_term_condition_source", "sdl_long_term_condition_snapshot", "sdl_ltc_processed",

    # Maternity
    "maternity", "sdl_maternity_episode_source", "sdl_maternity_episode_snapshot", "sdl_maternity_processed",

    # Mental health
    "mh", "sdl_mental_health_episode_source", "sdl_mental_health_episode_snapshot", "sdl_mh_processed",

    # NSU
    "nsu", "sdl_nsu_source", NA_character_, NA_character_,

    # Outpatients
    "outpatients", "sdl_outpatients_source", NA_character_, "sdl_outpatients_processed",

    # Prescribing
    "pis", "sdl_pis_static", NA_character_, "sdl_pis_processed",

    # Social care
    "at", "sdl_sc_alarmtelecare_source", NA_character_, "sdl_sc_at_fy_processed",
    "ch", "sdl_sc_carehome_source", NA_character_, "sdl_sc_ch_fy_processed",
    "hc", "sdl_sc_homecare_source", NA_character_, "sdl_sc_hc_fy_processed",
    "sc_demog_lookup", "sdl_sc_demographic_source", NA_character_, "sdl_demographics_processed",
    "sds", "sdl_sc_sds_source", NA_character_, "sdl_sc_sds_fy_processed",
    "sc_all_at", NA_character_, NA_character_, "sdl_sc_at_processed",
    "sc_all_ch", NA_character_, NA_character_, "sdl_sc_ch_processed",
    "sc_all_hc", NA_character_, NA_character_, "sdl_sc_hc_processed",
    "sc_all_sds", NA_character_, NA_character_, "sdl_sc_sds_processed",
    "client_fy", "sdl_sc_client_fy_source", NA_character_, NA_character_,
    "client_qtr", "sdl_sc_client_qtr_source", NA_character_, NA_character_,
    "client", NA_character_, NA_character_, "sdl_client_fy_processed",

    # SPARRA
    "sparra", "sdl_sparra_source", NA_character_, NA_character_
  )

  result <- sdl_names %>%
    dplyr::filter(type == dataset) %>%
    dplyr::pull(dplyr::all_of(version))

  if (length(result) == 0) {
    stop("Unknown dataset type: ", dataset)
  }

  if (is.na(result)) {
    stop(
      "Version '", version,
      "' is not available for dataset '", dataset, "'."
    )
  }

  return(result)
}
