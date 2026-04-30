

get_sdl_raw_names <- function(type) {
  sdl_name <- dplyr::case_match( ### TODO: change to recode_values  ###
    type,
    "acute" ~ "sdl_acute_source",
    "ae" ~ "sdl_ae2_episode_level_source",
    "chi_deaths" ~ "sdl_chi_deaths_source",
    "gp_ooh_consultations" ~ "sdl_gp_ooh_consultation_source",
    "gp_ooh_diagnosis" ~ "sdl_gp_ooh_diagnosis_source",
    "gp_ooh_outcomes" ~ "sdl_gp_ooh_outcome_source",
    "homelessness" ~ "sdl_homelessness_source",
    "ltcs" ~ "sdl_long_term_condition_source",
    "maternity" ~ "sdl_maternity_episode_source",
    "mental_health" ~ "sdl_mental_health_episode_source",
    "nrs_deaths" ~ "sdl_nrs_deaths_source",
    "outpatients" ~ "sdl_outpatients_source",
    "sparra" ~ "sdl_sparra_source"
  )

  return(sdl_name)
}



get_sdl_processed_data <- function(type,
                                   year,
                                   denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                   BYOC_MODE){


  if (BYOC_MODE) {
  sdl_name <- dplyr::case_match( ### TODO: change to recode_values ###
    type,
    "acute_processed" ~ "sdl_acute_processed",
    "ae_processed" ~ "sdl_ae2_processed",
    "chi_deaths_processed" ~ "sdl_chi_deaths_processed",
    "gp_ooh_consultations_processed" ~ "sdl_gp_ooh_consultation_processed",
    "gp_ooh_diagnosis_processed" ~ "sdl_gp_ooh_diagnosis_processed",
    "gp_ooh_outcomes_processed" ~ "sdl_gp_ooh_outcome_processed",
    "homelessness_processed" ~ "sdl_homelessness_processed",
    "ltcs_processed" ~ "sdl_long_term_condition_processed",
    "maternity_processed" ~ "sdl_maternity_episode_processed",
    "mental_health_processed" ~ "sdl_mental_health_episode_processed",
    "nrs_deaths_processed" ~ "sdl_nrs_deaths_processed",
    "outpatients_processed" ~ "sdl_outpatients_processed",
    "sparra_processed" ~ "sdl_sparra_processed"
  )

  sdl_table <- dplyr::tbl(denodo_connect, dbplyr::in_schema("sdl", sdl_name)) %>%
    collect()

  }else{
    sdl_name <- dplyr::case_match( ### TODO: change to recode_values ###
      type,
      "acute_processed" ~ get_source_extract_path(type = "acute", year = year,BYOC_MODE = BYOC_MODE),
      "sc_ch_all" ~ get_sc_ch_episodes_path())
  }
}
