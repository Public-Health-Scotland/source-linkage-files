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
    "acute", "sdl_acute_source", "sdl_acute_snapshot", NA_character_,
    "acute_cup", "sdl_acute_cup_source", "sdl_acute_cup_snapshot", NA_character_,

    # A&E
    "ae", "sdl_ae2_episode_level_source", "sdl_ae2_episode_level_snapshot", "sdl_byoc_ae_processed",
    "ae_cup", "sdl_ae_ucd_cup_source", "sdl_ae_ucd_cup_snapshot", NA_character_,

    # Costs
    "ch_cost", "sdl_carehomecostopendata_source", NA_character_, NA_character_,
    "dn_cost", "sdl_dn_cost_lookup_source", NA_character_, NA_character_,
    "hc_cost", "sdl_hc_cost_lookup_source", NA_character_, NA_character_,
    "ooh_costs", "sdl_ooh_cost_lookup_source", NA_character_, NA_character_,

    # CMH
    "cmh", "sdl_cmh_source", NA_character_, NA_character_,

    # Deaths
    "chi_deaths", "sdl_chi_deaths_source", "sdl_chi_deaths_snapshot", NA_character_,
    "nrs_deaths", "sdl_nrs_deaths_source", "sdl_nrs_deaths_snapshot", NA_character_,

    # Delayed discharges
    "dd", "sdl_dd_source", NA_character_, "sdl_byoc_dd_processed",

    # District nursing
    "dn", "sdl_dn_source", NA_character_, NA_character_,
    "dn_contacts", "sdl_dn_contacts_source", NA_character_, NA_character_,

    # GP out of hours
    "gp_ooh_consultation", "sdl_gp_ooh_consultation_source", "sdl_gp_ooh_consultation_snapshot", NA_character_,
    "gp_ooh_cup", "sdl_gp_ooh_cup_source", "sdl_gp_ooh_cup_snapshot", NA_character_,
    "gp_ooh_diagnosis", "sdl_gp_ooh_diagnosis_source", "sdl_gp_ooh_diagnosis_snapshot", NA_character_,
    "gp_ooh_outcome", "sdl_gp_ooh_outcome_source", "sdl_gp_ooh_outcome_snapshot", NA_character_,

    # Lookups
    "dz_pop", "sdl_datazone_population_source", NA_character_, NA_character_,
    "readcode", "sdl_read_code_lookup_source", NA_character_, NA_character_,
    "hscp_localities", "sdl_hscp_localities_source", NA_character_, NA_character_,
    "hscp_pop", "sdl_hscp_population_source", NA_character_, NA_character_,
    "simd", "sdl_simd_source", NA_character_, NA_character_,
    "spd", "sdl_spd_source", NA_character_, NA_character_,

    # Homelessness
    "homelessness", "sdl_homelessness_source", "sdl_homelessness_snapshot", "sdl_byoc_homelessness_processed",
    "homelessness_completeness", "sdl_homelessness_completeness_source", NA_character_, "sdl_byoc_homelessness_completeness_processed",

    # HHG
    "hhg", "sdl_hhg_source", NA_character_, NA_character_,

    # Long term conditions
    "ltc", "sdl_long_term_condition_source", "sdl_long_term_condition_snapshot", "sdl_byoc_ltc_processed",

    # Maternity
    "maternity", "sdl_maternity_episode_source", "sdl_maternity_episode_snapshot", NA_character_,

    # Mental health
    "mh", "sdl_mental_health_episode_source", "sdl_mental_health_episode_snapshot", NA_character_,

    # NSU
    "nsu", "sdl_nsu_source", NA_character_, NA_character_,

    # Outpatients
    "outpatients", "sdl_outpatients_source", NA_character_, "sdl_byoc_outpatients_processed",

    # Social care
    "at", "sdl_sc_alarmtelecare_source", NA_character_, NA_character_,
    "hc", "sdl_sc_homecare_source", NA_character_, NA_character_,
    "sc_demog", "sdl_sc_demographic_source", NA_character_, NA_character_,
    "sds", "sdl_sc_sds_source", NA_character_, NA_character_,

    # SPARRA
    "sparra", "sdl_sparra_source", NA_character_, NA_character_
  )

  result <- sdl_names  %>%
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


#' Get SDL Processed Data
#'
#' @description A switchboard function that retrieves processed datasets. If `BYOC_MODE`
#' is TRUE, it collects data from Denodo. Otherwise, it sources data locally.
#'
#' @param type Name of dataset (e.g. "acute").
#' @param year Financial year.
#' @param denodo_connect A Denodo connection object.
#' @param BYOC_MODE Logical. TRUE or FALSE.
#'
#' @return data
#'
#' @export
#' @family file path functions
get_sdl_processed_data <- function(
  type,
  year,
  denodo_connect = NULL,
  BYOC_MODE
) {
  non_year_specific_types <- c(
    "care_home_lookup",
    "postcode_lookup",
    "sc_demog_lookup",
    "sc_all_alarms_telecare",
    "sc_all_care_homes",
    "sc_all_home_care",
    "sc_all_self_directed_support",
    "chi_deaths",
    "nrs_deaths"
  )

  sdl_name <- get_sdl_processed_name(type)

  if (isTRUE(BYOC_MODE)) {
    denodo_connect <- get_denodo_connection(BYOC_MODE = BYOC_MODE)
    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    sdl_tbl <- dplyr::tbl(denodo_connect, dbplyr::in_schema("sdl", sdl_name))

    if (!(type %in% non_year_specific_types)) {
      sdl_tbl <- sdl_tbl %>%
        dplyr::filter(as.character(rlang::.data$year) == as.character(year))
    }

    return(dplyr::collect(sdl_tbl))
  }

  sdl_data <- switch(type,
    "acute" = read_file(get_source_extract_path("acute", year = year, BYOC_MODE = BYOC_MODE)),
    "ae" = read_file(get_source_extract_path("ae", year = year, BYOC_MODE = BYOC_MODE)),
    "at" = read_file(get_source_extract_path("at", year = year, BYOC_MODE = BYOC_MODE)),
    "ch" = read_file(get_source_extract_path("ch", year = year, BYOC_MODE = BYOC_MODE)),
    "hc" = read_file(get_source_extract_path("hc", year = year, BYOC_MODE = BYOC_MODE)),
    "sds" = read_file(get_source_extract_path("sds", year = year, BYOC_MODE = BYOC_MODE)),
    "client" = read_file(get_source_extract_path("client", year = year, BYOC_MODE = BYOC_MODE)),
    "cmh" = read_file(get_source_extract_path("cmh", year = year, BYOC_MODE = BYOC_MODE)),
    "dd" = read_file(get_source_extract_path("dd", year = year, BYOC_MODE = BYOC_MODE)),
    "dn" = read_file(get_source_extract_path("dn", year = year, BYOC_MODE = BYOC_MODE)),
    "gp_ooh" = read_file(get_source_extract_path("gp_ooh", year = year, BYOC_MODE = BYOC_MODE)),
    "homelessness" = read_file(get_source_extract_path("homelessness", year = year, BYOC_MODE = BYOC_MODE)),
    "maternity" = read_file(get_source_extract_path("maternity", year = year, BYOC_MODE = BYOC_MODE)),
    "mh" = read_file(get_source_extract_path("mh", year = year, BYOC_MODE = BYOC_MODE)),
    "outpatients" = read_file(get_source_extract_path("outpatients", year = year, BYOC_MODE = BYOC_MODE)),
    "pis" = read_file(get_source_extract_path("pis", year = year, BYOC_MODE = BYOC_MODE)),
    "homelessness_lookup" = create_homelessness_lookup(year = year),
    "homelessness_completeness" = read_file(get_homelessness_completeness_path(year = year, BYOC_MODE = BYOC_MODE)),
    "ltc" = read_file(get_ltcs_path(year = year, BYOC_MODE = BYOC_MODE)),
    "sparra" = read_file(get_sparra_path(year = year, BYOC_MODE = BYOC_MODE)),
    "chi_deaths" = read_file(get_slf_chi_deaths_path(BYOC_MODE = BYOC_MODE)),
    "nrs_deaths" = read_file(get_combined_slf_deaths_lookup_path(BYOC_MODE = BYOC_MODE)),
    "refined_death" = read_file(get_slf_deaths_lookup_path(year = year, BYOC_MODE = BYOC_MODE)),
    "hhg" = read_file(get_hhg_path(year = year, BYOC_MODE = BYOC_MODE)),
    "care_home_lookup" = read_file(get_slf_ch_name_lookup_path(BYOC_MODE = BYOC_MODE)),
    "postcode_lookup" = read_file(get_slf_postcode_path(BYOC_MODE = BYOC_MODE)),
    "gpprac_lookup" = read_file(get_slf_gpprac_path(BYOC_MODE = BYOC_MODE)),
    "sc_demog_lookup" = read_file(get_sc_demog_lookup_path(BYOC_MODE = BYOC_MODE)),
    "sc_all_alarms_telecare" = read_file(get_sc_at_episodes_path(BYOC_MODE = BYOC_MODE)),
    "sc_all_care_homes" = read_file(get_sc_ch_episodes_path(BYOC_MODE = BYOC_MODE)),
    "sc_all_home_care" = read_file(get_sc_hc_episodes_path(BYOC_MODE = BYOC_MODE)),
    "sc_all_self_directed_support" = read_file(get_sc_sds_episodes_path(BYOC_MODE = BYOC_MODE)),
    "ch_cost_lookup" = read_file(get_ch_costs_path(BYOC_MODE = BYOC_MODE)),
    "dn_cost_lookup" = read_file(get_dn_costs_path(BYOC_MODE = BYOC_MODE)),
    "hc_cost_lookup" = read_file(get_hc_costs_path(BYOC_MODE = BYOC_MODE)),
    "ooh_cost_lookup" = read_file(get_gp_ooh_costs_path(BYOC_MODE = BYOC_MODE)),
    stop("Unknown dataset type: ", type)
  )

  return(sdl_data)
}
