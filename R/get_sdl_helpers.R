#' Get SDL Raw Table Name
#'
#' @description Returns the Denodo SDL table name for the extract
#' corresponding to a given dataset type.
#'
#' @param type Character. Dataset id (e.g. "acute", "ae", etc.)
#'
#' @return Character string of SDL table name
#'
#' @export
#' @family file path functions
get_sdl_raw_names <- function(type) {
  sdl_name <- dplyr::recode_values(
    type,
    "acute"        = "sdl_acute_source",
    "ae"           = "sdl_ae2_episode_level_source",
    "gp_ooh"       = "sdl_gp_ooh_consultation_source",
    "homelessness" = "sdl_homelessness_source",
    "maternity"    = "sdl_maternity_episode_source",
    "mh"           = "sdl_mental_health_episode_source",
    "nrs_deaths"   = "sdl_nrs_deaths_source",

    # ---- DUMMY TABLES (to be updated later) ----

    "at"     = "sdl_alarms_telecare_source",        # dummy - needs real table
    "ch"     = "sdl_care_homes_source",             # dummy - needs real table
    "hc"     = "sdl_home_care_source",              # dummy - needs real table
    "sds"    = "sdl_self_directed_support_source",  # dummy - needs real table
    "client" = "sdl_client_information_source",     # dummy - needs real table
    "cmh"    = "sdl_cmh_source",                    # dummy - needs real table
    "dd"     = "sdl_delayed_discharge_source",      # dummy - needs real table
    "dn"     = "sdl_district_nursing_source",       # dummy - needs real table
    "hhg"    = "sdl_hhg_source",                    # dummy - needs real table
    "outpatients" = "sdl_outpatients_source",       # dummy - needs real table
    "pis"    = "sdl_prescribing_source",            # dummy - needs real table
    "care_home_lookup" = "sdl_care_home_lookup_source",     # dummy - needs real table
    "postcode_lookup"  = "sdl_postcode_lookup_source",      # dummy - needs real table
    "gpprac_lookup"    = "sdl_gp_practice_lookup_source",   # dummy - needs real table
    "sc_demog_lookup"  = "sdl_sc_demographics_source",      # dummy - needs real table
    "sc_all_alarms_telecare"       = "sdl_sc_at_source",    # dummy - needs real table
    "sc_all_care_homes"            = "sdl_sc_ch_source",    # dummy - needs real table
    "sc_all_home_care"             = "sdl_sc_hc_source",    # dummy - needs real table
    "sc_all_self_directed_support" = "sdl_sc_sds_source",   # dummy - needs real table
    "ch_cost_lookup"  = "sdl_ch_cost_source",   # dummy - needs real table
    "dn_cost_lookup"  = "sdl_dn_cost_source",   # dummy - needs real table
    "hc_cost_lookup"  = "sdl_hc_cost_source",   # dummy - needs real table
    "ooh_cost_lookup" = "sdl_gp_ooh_cost_source", # dummy - needs real table
    "refined_death" = "sdl_refined_death_source",   # dummy - needs real table
    "ltc"           = "sdl_ltc_source",             # dummy - needs real table
    "sparra"        = "sdl_sparra_source",          # dummy - needs real table
    "homelessness_lookup"     = "sdl_homelessness_lookup_source", # dummy - needs real table
    "homelessness_completeness" = "sdl_homelessness_completeness_source" # dummy - needs real table
  )

  if (is.na(sdl_name)) {
    stop("Unknown dataset type: ", type)
  }

  return(sdl_name)
}


#' Get SDL Processed Data
#'
#' @description A switchboard function that retrieves processed datasets. If `BYOC_MODE`
#' is TRUE, it collects data from Denodo. Otherwise, it sources data locally.
#'
#' @param type name of dataset (e.g. "acute_processed").
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
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

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

  if (BYOC_MODE) {
    sdl_name <- dplyr::recode_values(
      type,
      "acute"                        = "sdl_acute_processed",
      "ae"                           = "sdl_ae2_processed",
      "at"                           = "sdl_alarms_telecare_processed",
      "ch"                           = "sdl_care_homes_processed",
      "hc"                           = "sdl_home_care_processed",
      "sds"                          = "sdl_self_directed_support_processed",
      "chi_deaths"                   = "sdl_chi_deaths_processed",
      "client"                       = "sdl_client_information_processed",
      "cmh"                          = "sdl_cmh_processed",
      "dd"                           = "sdl_delayed_discharge_processed",
      "dn"                           = "sdl_district_nursing_processed",
      "gp_ooh"                       = "sdl_gp_ooh_processed",
      "hhg"                          = "sdl_hhg_processed",
      "homelessness"                 = "sdl_homelessness_processed",
      "care_home_lookup"             = "sdl_care_home_name_lookup_processed",
      "gpprac_lookup"                = "sdl_gp_practice_lookup_processed",
      "homelessness_lookup"          = "sdl_homelessness_lookup_processed",
      "homelessness_completeness"    = "sdl_homelessness_completeness_processed",
      "ltc"                          = "sdl_long_term_condition_processed",
      "maternity"                    = "sdl_maternity_processed",
      "mh"                           = "sdl_mental_health_processed",
      "nrs_deaths"                   = "sdl_nrs_deaths_processed",
      "outpatients"                  = "sdl_outpatients_processed",
      "pis"                          = "sdl_prescribing_processed",
      "postcode_lookup"              = "sdl_postcode_lookup_processed",
      "refined_death"                = "sdl_slf_deaths_lookup_processed",
      "sc_demog_lookup"              = "sdl_demographics_processed",
      "sc_all_alarms_telecare"       = "sdl_sc_all_alarms_telecare_processed",
      "sc_all_care_homes"            = "sdl_sc_all_care_homes_processed",
      "sc_all_home_care"             = "sdl_sc_all_home_care_processed",
      "sc_all_self_directed_support" = "sdl_sc_all_self_directed_support_processed",
      "sparra"                       = "sdl_sparra_processed",
      "ch_cost_lookup"               = "sdl_ch_cost_lookup_processed",
      "dn_cost_lookup"               = "sdl_dn_cost_lookup_processed",
      "hc_cost_lookup"               = "sdl_hc_cost_lookup_processed",
      "ooh_cost_lookup"              = "sdl_gp_ooh_cost_lookup_processed"
    )

    if (is.na(sdl_name)) {
      stop("Unknown dataset type: ", type)
    }

    sdl_tbl <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", sdl_name)
    )

    if (!(type %in% non_year_specific_types)) {
      sdl_tbl <- dplyr::filter(
        sdl_tbl,
        as.character(rlang::.data$year) == as.character(year)
      )
    }

    return(dplyr::collect(sdl_tbl))
  } else {
    sdl_data <- dplyr::recode_values(
      type,
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
      "sparra" = read_file(get_sparra_path(year = year, BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "chi_deaths" = read_file(get_slf_chi_deaths_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "nrs_deaths" = read_file(get_combined_slf_deaths_lookup_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "refined_death" = read_file(get_slf_deaths_lookup_path(year = year, BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "hhg" = read_file(get_hhg_path(year = year, BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "care_home_lookup" = read_file(get_slf_ch_name_lookup_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "postcode_lookup" = read_file(get_slf_postcode_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "gpprac_lookup" = read_file(get_slf_gpprac_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "sc_demog_lookup" = read_file(get_sc_demog_lookup_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "sc_all_alarms_telecare" = read_file(get_sc_at_episodes_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "sc_all_care_homes" = read_file(get_sc_ch_episodes_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "sc_all_home_care" = read_file(get_sc_hc_episodes_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "sc_all_self_directed_support" = read_file(get_sc_sds_episodes_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "ch_cost_lookup" = read_file(get_ch_costs_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "dn_cost_lookup" = read_file(get_dn_costs_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "hc_cost_lookup" = read_file(get_hc_costs_path(BYOC_MODE = BYOC_MODE)), # BYOC_MODE added in advance
      "ooh_cost_lookup" = read_file(get_gp_ooh_costs_path(BYOC_MODE = BYOC_MODE)) # BYOC_MODE added in advance
    )

    if (is.null(sdl_data) || (length(sdl_data) == 1 && is.na(sdl_data))) {
      stop("Unknown dataset type: ", type)
    }

    return(sdl_data)
  }
}
