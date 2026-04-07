#' Read NRS Deaths extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_nrs_deaths <- function(
    year,
    denodo_connect = get_denodo_connect(BYOC_MODE = BYOC_MODE),
    file_path = get_boxi_extract_path(year, type = "deaths", BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  year = check_year_format(year, "fyyear")
  c_year = convert_fyyear_to_year(year)

  log_slf_event(
    stage = "read",
    status = "start",
    type = "deaths",
    year = year
  )

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  extract_nrs_deaths <- dplyr::tbl(
    denodo_connect,
    # TODO: check table name
    dbplyr::in_schema("sdl", "sdl_nrs_deaths_episodes")
  ) %>%
    dplyr::select(
      death_location_code = "death_location_code",
      lca = "geo_council_area_code",
      postcode = "geo_postcode",
      hscp = "geo_hscp_of_residence_code_curr",
      death_board_occurrence = "nhs_board_of_occurrence_code_curr",
      hbrescode = "nhs_board_of_residence_code_curr",
      dob = "patient_dob",
      record_keydate1 = "patient_dod",
      gender = "pat_gender_code",
      chi = "patient_chi",
      place_death_occurred = "place_death_occurred_code",
      post_mortem = "post_mortem_code",
      deathdiag1 = "primary_cause_of_death_code",
      deathdiag2 = "secondary_cause_of_death_0_code",
      deathdiag3 = "secondary_cause_of_death_1_code",
      deathdiag4 = "secondary_cause_of_death_2_code",
      deathdiag5 = "secondary_cause_of_death_3_code",
      deathdiag6 = "secondary_cause_of_death_4_code",
      deathdiag7 = "secondary_cause_of_death_5_code",
      deathdiag8 = "secondary_cause_of_death_6_code",
      deathdiag9 = "secondary_cause_of_death_7_code",
      deathdiag10 = "secondary_cause_of_death_8_code",
      deathdiag11 = "secondary_cause_of_death_9_code",
      uri = "unique_record_identifier",
      gpprac = "gp_practice_code",
      date_of_death_financial_year = "date_of_death_financial_year"
    ) %>%
    dplyr::filter(
      date_of_death_financial_year == c_year
    ) %>%
    dplyr::select(-"date_of_death_financial_year") %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi()

  log_slf_event(
    stage = "read",
    status = "complete",
    type = "deaths",
    year = year
  )

  return(extract_nrs_deaths)
}
