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
  sdl_names <- tibble::tribble(
    ~type, ~source, ~snapshot, ~processed,
    # Acute
    "acute", "sdl_acute_source", "sdl_acute_snapshot", "sdl_acute_processed",
    "acute_cup", "sdl_acute_cup_source", "sdl_acute_cup_snapshot", NA_character_,

    # A&E
    "ae", "sdl_ae2_episode_level_source", "sdl_ae2_episode_level_snapshot", "sdl_ae_processed",
    "ae_cup", "sdl_ae_ucd_cup_source", "sdl_ae_ucd_cup_snapshot", NA_character_,

    # Costs
    "ch_cost", "sdl_carehomecostopendata_source", NA_character_, NA_character_,
    "dn_cost", "sdl_dn_cost_lookup_source", NA_character_, "sdl_dn_cost_lookup_processed",
    "hc_cost", "sdl_hc_cost_lookup_source", NA_character_, NA_character_,
    "ooh_costs", "sdl_ooh_cost_lookup_source", NA_character_, NA_character_,

    # CMH
    "cmh", "sdl_cmh_source", NA_character_, NA_character_,

    # Deaths
    "chi_deaths", "sdl_chi_deaths_source", "sdl_chi_deaths_snapshot", "sdl_chi_deaths_processed",
    "combined_deaths", NA_character_, NA_character_, "sdl_combined_deaths_processed",
    "nrs_deaths", "sdl_nrs_deaths_source", "sdl_nrs_deaths_snapshot", "sdl_nrs_deaths_processed",

    # Delayed discharges
    "dd", "sdl_dd_source", NA_character_, "sdl_dd_processed",

    # District nursing
    "dn", "sdl_dn_source", NA_character_, "sdl_dn_processed",
    "dn_contacts", "sdl_dn_contacts_source", NA_character_, NA_character_,

    # GP Practice
    "gp_geo_labels", "sdl_geography_labels_source", NA_character_, NA_character_,
    "gp_cluster", "sdl_gpprac_cluster_source", NA_character_, NA_character_,
    "gp_ref", "sdl_gpprac_ref_source", NA_character_, NA_character_,

    # GP out of hours
    "gp_ooh_consultation", "sdl_gp_ooh_consultation_source", "sdl_gp_ooh_consultation_snapshot", NA_character_,
    "gp_ooh_cup", "sdl_gp_ooh_cup_source", "sdl_gp_ooh_cup_snapshot", NA_character_,
    "gp_ooh_diagnosis", "sdl_gp_ooh_diagnosis_source", "sdl_gp_ooh_diagnosis_snapshot", NA_character_,
    "gp_ooh_outcome", "sdl_gp_ooh_outcome_source", "sdl_gp_ooh_outcome_snapshot", NA_character_,
    "gp_ooh", NA_character_, NA_character_, "sdl_gp_ooh_processed",

    # Lookups
    "la_lookup", "sdl_laopendatalookup_source", NA_character_, NA_character_,
    "dz_pop", "sdl_datazone_population_source", NA_character_, NA_character_,
    "readcode", "sdl_read_code_lookup_source", NA_character_, NA_character_,
    "hscp_localities", "sdl_hscp_localities_source", NA_character_, NA_character_,
    "hscp_pop", "sdl_hscp_population_source", NA_character_, NA_character_,
    "simd", "sdl_simd_source", NA_character_, NA_character_,
    "spd", "sdl_spd_source", NA_character_, NA_character_,
    # "slf_pc_lookup", #### TODO ####
    # "slf_gpprac_lookup", #### TODO ####


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

    # Social care - ALL views
    "sc_demog", "sdl_sc_demographic_source", NA_character_, NA_character_,
    "sc_client_fy", "sdl_sc_client_fy_source", NA_character_, NA_character_,
    "sc_client_qtr", "sdl_sc_client_qtr_source", NA_character_, NA_character_,
    "sc_at_all", "sdl_sc_alarmtelecare_source", NA_character_, "sdl_sc_at_processed",
    "sc_ch_all", "sdl_sc_carehome_source", NA_character_, "sdl_sc_ch_processed",
    "sc_hc_all", "sdl_sc_homecare_source", NA_character_, "sdl_sc_at_processed",
    "sc_sds_all", "sdl_sc_sds_source", NA_character_, "sdl_sc_at_processed",

    # Social care - FY views
    # "sc_at_fy", NA_character_, NA_character_, "sdl_sc_at_fy_processed",
    # "sc_ch_fy", NA_character_, NA_character_, "sdl_sc_ch_fy_processed",
    # "sc_hc_fy", NA_character_, NA_character_, "sdl_sc_hc_fy_processed",
    # "sc_sds_fy", NA_character_, NA_character_, "sdl_sc_sds_fy_processed",

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


#' Get SDL Processed Data for episode file
#'
#' @description A switchboard function that retrieves processed datasets. If `BYOC_MODE`
#' is TRUE, it collects data from Denodo. Otherwise, it sources data locally.
#'
#' @param year Financial year.
#' @param type Name of dataset (e.g. "acute").
#' @param denodo_connect A Denodo connection object.
#' @param BYOC_MODE Logical. TRUE or FALSE.
#'
#' @return data
#'
#' @export
#' @family file path functions
get_sdl_processed_data <- function(
    year,
    type,
    denodo_connect = get_denodo_connection(BYOC_MODE = FALSE),
    BYOC_MODE = BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = type, year = year)

  year <- check_year_format(year)

  # Read local files
  if (isFALSE(BYOC_MODE)) {
    if (type == "ltc") {
      data <- read_file(get_ltcs_path(year, BYOC_MODE = BYOC_MODE))
    } else if (type == "slf_pc_lookup") {
      data <- read_file(get_slf_postcode_path(BYOC_MODE = BYOC_MODE))
    } else if (type == "slf_gpprac_lookup") {
      data <- read_file(
        get_slf_gpprac_path(BYOC_MODE = BYOC_MODE),
        col_select = c("gpprac", "cluster", "hbpraccode")
      )
    } else if (type == "sc_client") {
      data <- read_file(get_sc_client_lookup_path(year, BYOC_MODE = BYOC_MODE))
    } else if (type == "combined_deaths") {
      data <- read_file(get_combined_slf_deaths_lookup_path(year, BYOC_MODE = BYOC_MODE))
    } else {
      data <- read_file(
        get_source_extract_path(
          year,
          type,
          BYOC_MODE = BYOC_MODE
        )
      )
    }

    # Read processed data from Denodo if BYOC_MODE == TRUE
  } else {
    # Disconnect from denodo
    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema(
        "sdl",
        get_sdl_names(
          dataset = type,
          version = "processed"
        )
      )
    ) %>%
      dplyr::collect()
  }

  return(data)
}


