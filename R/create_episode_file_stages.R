#' Produce the Source Episode file stage 1
#'
#' @param processed_data_list containing data from processed extracts.
#' @param year The year to process, in FY format.
#' @param homelessness_lookup the lookup file for homelessness
#' @param sc_client social care lookup file
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param write_temp_to_disk write intermediate data for investigation or debug
#' @inheritParams add_nsu_cohort
#' @inheritParams fill_geographies
#' @inheritParams join_cohort_lookups
#' @inheritParams join_deaths_data
#' @inheritParams match_on_ltcs
#' @inheritParams link_delayed_discharge_eps
#'
#' @return a [tibble][tibble::tibble-package] containing the episode file
#' @export
create_episode_file_stage_1 <- function(
    processed_data_list,
    year,
    dd_data = read_file(get_source_extract_path(year, "dd")),
    homelessness_lookup = create_homelessness_lookup(year),
    nsu_cohort = read_file(get_nsu_path(year)),
    ltc_data = read_file(get_ltcs_path(year)),
    slf_pc_lookup = read_file(get_slf_postcode_path()),
    slf_gpprac_lookup = read_file(
      get_slf_gpprac_path(),
      col_select = c("gpprac", "cluster", "hbpraccode")
    ),
    slf_deaths_lookup = read_file(get_slf_deaths_lookup_path(year)),
    sc_client = read_file(get_sc_client_lookup_path(year)),
    write_to_disk = TRUE,
    write_temp_to_disk = FALSE) {
  cli::cli_alert_info("Create episode file stage 1 function started at {Sys.time()}")

  processed_data_list <- purrr::discard(processed_data_list, ~ is.null(.x) | identical(.x, tibble::tibble()))

  episode_file <- dplyr::bind_rows(processed_data_list) %>%
    write_temp_data(year, file_name = "ep_temp1", write_temp_to_disk) %>%
    add_homelessness_flag(year, lookup = homelessness_lookup) %>%
    add_homelessness_date_flags(year, lookup = homelessness_lookup) %>%
    link_delayed_discharge_eps(year, dd_data) %>%
    write_temp_data(year, file_name = "ep_temp1-2", write_temp_to_disk) %>%
    add_nsu_cohort(year, nsu_cohort) %>%
    create_cost_inc_dna() %>%
    apply_cost_uplift()

  if (!check_year_valid(year, type = c("ch", "hc", "at", "sds"))) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        ch_name = NA,
        ch_postcode = NA,
        person_id = NA
      )
  }

  episode_file <- episode_file %>%
    store_ep_file_vars(
      year = year,
      vars_to_keep = c(
        "year",
        "recid",
        "record_keydate1",
        "record_keydate2",
        "keytime1",
        "keytime2",
        "smrtype",
        "anon_chi",
        "person_id",
        "gender",
        "dob",
        "gpprac",
        "hbpraccode",
        "postcode",
        "hbrescode",
        "lca",
        "location",
        "hbtreatcode",
        "ipdc",
        "spec",
        "sigfac",
        "diag1",
        "diag2",
        "diag3",
        "diag4",
        "diag5",
        "diag6",
        "op1a",
        "age",
        "ch_name",
        "ch_postcode",
        "cup_pathway",
        "cij_marker",
        "cij_start_date",
        "cij_end_date",
        "cij_pattype_code",
        "cij_ipdc",
        "cij_admtype",
        "cij_adm_spec",
        "cij_dis_spec",
        "cost_total_net",
        "hscp",
        "attendance_status",
        "deathdiag1",
        "deathdiag2",
        "deathdiag3",
        "deathdiag4",
        "deathdiag5",
        "deathdiag6",
        "deathdiag7",
        "deathdiag8",
        "deathdiag9",
        "deathdiag10",
        "deathdiag11",
        "yearstay",
        "apr_beddays",
        "may_beddays",
        "jun_beddays",
        "jul_beddays",
        "aug_beddays",
        "sep_beddays",
        "oct_beddays",
        "nov_beddays",
        "dec_beddays",
        "jan_beddays",
        "feb_beddays",
        "mar_beddays"
      )
    ) %>%
    # match on sc client variables
    join_sc_client(year, sc_client = sc_client, file_type = "episode") %>%
    # change to chi for phsmethods
    slfhelper::get_chi() %>%
    # Check chi is valid using phsmethods function
    # If the CHI is invalid for whatever reason, set the CHI to NA
    dplyr::mutate(
      chi = dplyr::if_else(
        phsmethods::chi_check(.data$chi) != "Valid CHI",
        NA_character_,
        .data$chi
      ),
      gpprac = convert_eng_gpprac_to_dummy(.data[["gpprac"]]),
      # PC8 format may still be used. Ensure here that all datasets are in PC7 format.
      postcode = phsmethods::format_postcode(.data$postcode, "pc7")
    ) %>%
    # change back to anon_chi
    slfhelper::get_anon_chi() %>%
    write_temp_data(year, file_name = "ep_temp2", write_temp_to_disk) %>%
    correct_cij_vars() %>%
    fill_missing_cij_markers() %>%
    add_ppa_flag() %>%
    write_temp_data(year, file_name = "ep_temp3", write_temp_to_disk) %>%
    match_on_ltcs(year, ltc_data) %>%
    correct_demographics(year)

  if (write_to_disk) {
    write_file(episode_file, get_slf_episode_stage_1_path(year, check_mode = "write"),
               group_id = 3356
    ) # sourcedev owner
  }


}


#' Produce the Source Episode file stage 2
#'
#' @param processed_data_list containing data from processed extracts.
#' @param year The year to process, in FY format.
#' @param homelessness_lookup the lookup file for homelessness
#' @param sc_client social care lookup file
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param write_temp_to_disk write intermediate data for investigation or debug
#' @inheritParams add_nsu_cohort
#' @inheritParams fill_geographies
#' @inheritParams join_cohort_lookups
#' @inheritParams join_deaths_data
#' @inheritParams match_on_ltcs
#' @inheritParams link_delayed_discharge_eps
#'
#' @return a [tibble][tibble::tibble-package] containing the episode file
#' @export
#'
create_episode_file_stage_2 <- function(
    processed_data_list,
    year,
    dd_data = read_file(get_source_extract_path(year, "dd")),
    homelessness_lookup = create_homelessness_lookup(year),
    nsu_cohort = read_file(get_nsu_path(year)),
    ltc_data = read_file(get_ltcs_path(year)),
    slf_pc_lookup = read_file(get_slf_postcode_path()),
    slf_gpprac_lookup = read_file(
      get_slf_gpprac_path(),
      col_select = c("gpprac", "cluster", "hbpraccode")
    ),
    slf_deaths_lookup = read_file(get_slf_deaths_lookup_path(year)),
    sc_client = read_file(get_sc_client_lookup_path(year)),
    write_to_disk = TRUE,
    write_temp_to_disk = FALSE) {
      cli::cli_alert_info("Create episode file function started at {Sys.time()}")

  episode_file <- read_file(get_slf_episode_stage_1_path(year)) %>%
    create_cohort_lookups(year) %>%
    join_cohort_lookups(year) %>%
    join_sparra_hhg(year) %>%
    fill_geographies(
      slf_pc_lookup,
      slf_gpprac_lookup
    ) %>%
    join_deaths_data(
      year,
      slf_deaths_lookup
    ) %>%
    write_temp_data(year, file_name = "ep_temp5", write_temp_to_disk) %>%
    add_activity_after_death_flag(year,
                                  deaths_data = read_file(get_combined_slf_deaths_lookup_path())
    ) %>%
    link_ch_with_adms() %>%
    load_ep_file_vars(year) %>%
    # temporary fix of extra column `fy`
    dplyr::select(-fy) %>%
    write_temp_data(year, file_name = "ep_temp6", write_temp_to_disk)

  if (!check_year_valid(year, type = c("ch", "hc", "at", "sds"))) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        ch_chi_cis = NA,
        ch_sc_id_cis = NA,
        ch_name = NA,
        ch_postcode = NA,
        ch_adm_reason = NA,
        ch_provider = NA,
        ch_nursing = NA,
        hc_hours_annual = NA,
        hc_hours_q1 = NA,
        hc_hours_q2 = NA,
        hc_hours_q3 = NA,
        hc_hours_q4 = NA,
        hc_cost_q1 = NA,
        hc_cost_q2 = NA,
        hc_cost_q3 = NA,
        hc_cost_q4 = NA,
        hc_provider = NA,
        hc_reablement = NA,
        person_id = NA,
        sc_latest_submission = NA,
        sc_send_lca = NA,
        sc_living_alone = NA,
        sc_support_from_unpaid_carer = NA,
        sc_social_worker = NA,
        sc_type_of_housing = NA,
        sc_meals = NA,
        sc_day_care = NA,
        social_care_id = NA,
        sc_dementia = NA,
        sc_learning_disability = NA,
        sc_mental_health_disorders = NA,
        sc_physical_and_sensory_disability = NA,
        sc_drugs = NA,
        sc_alcohol = NA,
        sc_palliative_care = NA,
        sc_carer = NA,
        sc_elderly_frail = NA,
        sc_neurological_condition = NA,
        sc_autism = NA,
        sc_other_vulnerable_groups = NA,
        ch_provider_description = NA
      )
  }

  if (!check_year_valid(year, type = "homelessness")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        hl1_12_months_post_app = NA,
        hl1_12_months_pre_app = NA,
        hl1_6after_ep = NA,
        hl1_6before_ep = NA,
        hl1_application_ref = NA,
        hl1_completeness = NA,
        hl1_during_ep = NA,
        hl1_in_fy = NA,
        hl1_property_type = NA,
        hl1_reason_ftm = NA,
        hl1_sending_lca = NA
      )
  }

  if (!check_year_valid(year, type = "dd")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        cij_delay = NA,
        dd_quality = NA,
        dd_responsible_lca = NA,
        delay_end_reason = NA,
        primary_delay_reason = NA,
        secondary_delay_reason = NA,
      )
  }

  if (!check_year_valid(year, type = "dn")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        ccm = NA,
        total_no_dn_contacts = NA
      )
  }

  if (!check_year_valid(year, type = "cost_dna")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        cost_total_net_inc_dnas = NA
      )
  }

  if (!check_year_valid(year, type = "dn")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        ccm = NA,
        total_no_dn_contacts = NA
      )
  }

  if (write_to_disk) {
    write_file(episode_file, get_slf_episode_path(year, check_mode = "write"),
               group_id = 3356
    ) # sourcedev owner
  }

  return(episode_file)
}


