#' Produce the Source Episode file
#'
#' @param processed_data_list containing data from processed extracts.
#' @param year The year to process, in FY format.
#' @param homelessness_lookup the lookup file for homelessness
#' @param sc_client scoial care lookup file
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param anon_chi_out (Default:TRUE) Should `anon_chi` be used in the output
#' (instead of chi)
#' @inheritParams add_nsu_cohort
#' @inheritParams fill_geographies
#' @inheritParams join_cohort_lookups
#' @inheritParams join_deaths_data
#' @inheritParams match_on_ltcs
#' @inheritParams link_delayed_discharge_eps
#'
#' @return a [tibble][tibble::tibble-package] containing the episode file
#' @export
create_episode_file <- function(
    processed_data_list,
    year,
    dd_data = read_file(get_source_extract_path(year, "dd")) %>% slfhelper::get_chi(),
    homelessness_lookup = create_homelessness_lookup(year),
    nsu_cohort = read_file(get_nsu_path(year)) %>% slfhelper::get_chi(),
    ltc_data = read_file(get_ltcs_path(year)) %>% slfhelper::get_chi(),
    slf_pc_lookup = read_file(get_slf_postcode_path()),
    slf_gpprac_lookup = read_file(
      get_slf_gpprac_path(),
      col_select = c("gpprac", "cluster", "hbpraccode")
    ),
    slf_deaths_lookup = read_file(get_slf_deaths_lookup_path(year)) %>% slfhelper::get_chi(),
    sc_client = read_file(get_sc_client_lookup_path(year)) %>% slfhelper::get_chi(),
    write_to_disk = TRUE,
    anon_chi_out = TRUE) {
  processed_data_list <- purrr::discard(processed_data_list, ~ is.null(.x) | identical(.x, tibble::tibble()))

  episode_file <- dplyr::bind_rows(processed_data_list) %>%
    slfhelper::get_chi() %>%
    create_cost_inc_dna() %>%
    apply_cost_uplift() %>%
    store_ep_file_vars(
      year = year,
      vars_to_keep = c(
        "year",
        "recid",
        "record_keydate1",
        "record_keydate2",
        "smrtype",
        "chi",
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
        "datazone2011",
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
    correct_cij_vars() %>%
    fill_missing_cij_markers() %>%
    add_homelessness_flag(year, lookup = homelessness_lookup) %>%
    add_homelessness_date_flags(year, lookup = homelessness_lookup) %>%
    add_ppa_flag() %>%
    link_delayed_discharge_eps(year, dd_data) %>%
    add_nsu_cohort(year, nsu_cohort) %>%
    match_on_ltcs(year, ltc_data) %>%
    correct_demographics(year) %>%
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
    add_activity_after_death_flag(year,
      deaths_data = read_file(get_combined_slf_deaths_lookup_path()) %>%
        slfhelper::get_chi()
    ) %>%
    load_ep_file_vars(year)

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

  if (anon_chi_out) {
    episode_file <- slfhelper::get_anon_chi(episode_file)
  }

  if (write_to_disk) {
    write_file(episode_file, get_slf_episode_path(year, check_mode = "write"))
  }

  return(episode_file)
}

#' Store the unneeded episode file variables
#'
#' @param data The in-progress episode file data.
#' @inheritParams create_episode_file
#' @param vars_to_keep a character vector of the variables to keep, all others
#' will be stored.
#'
#' @return `data` with only the `vars_to_keep` kept
store_ep_file_vars <- function(data, year, vars_to_keep) {
  cli::cli_alert_info("Store episode file variables function started at {Sys.time()}")

  tempfile_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("temp_ep_file_variable_store_{year}.parquet"),
    check_mode = "write",
    create = TRUE
  )

  check_variables_exist(data, vars_to_keep)

  data <- data %>%
    dplyr::mutate(ep_file_row_id = dplyr::row_number())

  vars_to_store <- c("ep_file_row_id", setdiff(names(data), vars_to_keep))

  dplyr::select(
    data,
    dplyr::all_of(vars_to_store)
  ) %>%
    write_file(
      path = tempfile_path
    )

  return(
    dplyr::select(
      data,
      dplyr::all_of(c("ep_file_row_id", vars_to_keep))
    )
  )
}

#' Load the unneeded episode file variables
#'
#' @inheritParams create_episode_file
#' @inheritParams store_ep_file_vars
#'
#' @return The full SLF data.
load_ep_file_vars <- function(data, year) {
  cli::cli_alert_info("Load episode file variable function started at {Sys.time()}")

  tempfile_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("temp_ep_file_variable_store_{year}.parquet"),
    check_mode = "write",
    create = TRUE
  )

  full_data <- data %>%
    dplyr::left_join(
      read_file(path = tempfile_path),
      by = "ep_file_row_id",
      unmatched = "error",
      relationship = "one-to-one"
    ) %>%
    dplyr::select(!"ep_file_row_id")

  fs::file_delete(tempfile_path)

  return(full_data)
}

#' Fill any missing CIJ markers for records that should have them
#'
#' @inheritParams store_ep_file_vars
#'
#' @return A data frame with CIJ markers filled in for those missing.
fill_missing_cij_markers <- function(data) {
  cli::cli_alert_info("Fill missing cij markers function started at {Sys.time()}")

  fixable_data <- data %>%
    dplyr::filter(
      .data[["recid"]] %in% c("01B", "04B", "GLS", "02B", "DD") & !is.na(.data[["chi"]])
    )

  non_fixable_data <- data %>%
    dplyr::filter(
      !(.data[["recid"]] %in% c("01B", "04B", "GLS", "02B", "DD")) | is.na(.data[["chi"]])
    )

  fixed_data <- fixable_data %>%
    dplyr::group_by(.data$chi) %>%
    # We want any NA cij_markers to be filled in, if they are the first in the
    # group and are NA. This is why we use this arrange() before the mutate()
    dplyr::arrange(dplyr::desc(is.na(.data$cij_marker)), .by_group = TRUE) %>%
    dplyr::mutate(cij_marker = dplyr::if_else(
      is.na(.data$cij_marker) & dplyr::row_number() == 1L,
      1L,
      .data$cij_marker
    )) %>%
    dplyr::ungroup() %>%
    # Tidy up cij_ipdc
    dplyr::mutate(cij_ipdc = dplyr::if_else(
      is_missing(.data$cij_ipdc),
      dplyr::case_when(
        .data$ipdc == "I" ~ "I",
        .data$recid == "01B" & .data$ipdc == "D" ~ "D",
        .default = .data$cij_ipdc
      ),
      .data$cij_ipdc
    )) %>%
    # Ensure every record with a CHI has a valid CIJ marker
    dplyr::group_by(.data$chi, .data$cij_marker) %>%
    dplyr::mutate(
      cij_ipdc = max(.data$cij_ipdc),
      cij_admtype = dplyr::first(.data$cij_admtype),
      cij_pattype_code = dplyr::first(.data$cij_pattype_code),
      cij_pattype = dplyr::first(.data$cij_pattype),
      cij_adm_spec = dplyr::first(.data$cij_adm_spec),
      cij_dis_spec = dplyr::last(.data$cij_dis_spec)
    ) %>%
    dplyr::ungroup()

  return_data <- dplyr::bind_rows(non_fixable_data, fixed_data)

  return(return_data)
}

#' Correct the CIJ variables
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data with CIJ variables corrected.
correct_cij_vars <- function(data) {
  cli::cli_alert_info("Correct cij variables function started at {Sys.time()}")

  check_variables_exist(
    data,
    c("chi", "recid", "cij_admtype", "cij_pattype_code")
  )

  data %>%
    # Change some values of cij_pattype_code based on cij_admtype
    dplyr::mutate(
      cij_admtype = dplyr::if_else(
        .data[["cij_admtype"]] == "Unknown",
        "99",
        .data[["cij_admtype"]]
      ),
      cij_pattype_code = dplyr::if_else(
        !is.na(.data$chi) & .data$recid %in% c("01B", "04B", "GLS", "02B"),
        dplyr::case_match(
          .data$cij_admtype,
          c("41", "42") ~ 2L,
          c("40", "48", "99") ~ 9L,
          "18" ~ 0L,
          .default = as.integer(.data$cij_pattype_code)
        ),
        .data$cij_pattype_code
      ),
      # Recode cij_pattype based on above
      cij_pattype = dplyr::case_match(
        .data$cij_pattype_code,
        0L ~ "Non-Elective",
        1L ~ "Elective",
        2L ~ "Maternity",
        9L ~ "Other"
      )
    )
}

#' Create cost total net inc DNA
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data with cost including dna.
create_cost_inc_dna <- function(data) {
  cli::cli_alert_info("Create cost inc dna function started at {Sys.time()}")

  check_variables_exist(data, c("cost_total_net", "attendance_status"))

  # Create cost including DNAs and modify costs
  # not including DNAs using cattend
  data %>%
    dplyr::mutate(
      cost_total_net_inc_dnas = .data$cost_total_net,
      # In the Cost_Total_Net column set the cost for
      # those with attendance status 5 or 8 (CNWs and DNAs)
      cost_total_net = dplyr::if_else(
        .data$attendance_status %in% c(5L, 8L),
        0.0,
        .data$cost_total_net
      )
    )
}

#' Create the cohort lookups
#'
#' @inheritParams store_ep_file_vars
#' @inheritParams create_demographic_cohorts
#'
#' @return The data unchanged (the cohorts are written to disk)
create_cohort_lookups <- function(data, year, update = latest_update()) {
  cli::cli_alert_info("Create cohort lookups function started at {Sys.time()}")

  create_demographic_cohorts(
    data,
    year,
    update,
    write_to_disk = TRUE
  )

  create_service_use_cohorts(
    data,
    year,
    update,
    write_to_disk = TRUE
  )


  return(data)
}

#' Join cohort lookups
#'
#' @inheritParams store_ep_file_vars
#' @inheritParams get_demographic_cohorts_path
#' @param demographic_cohort,service_use_cohort The cohort data
#'
#' @return The data including the Demographic and Service Use lookups.
join_cohort_lookups <- function(
    data,
    year,
    update = latest_update(),
    demographic_cohort = read_file(
      get_demographic_cohorts_path(year, update),
      col_select = c("anon_chi", "demographic_cohort")
    ) %>%
      slfhelper::get_chi(),
    service_use_cohort = read_file(
      get_service_use_cohorts_path(year, update),
      col_select = c("anon_chi", "service_use_cohort")
    ) %>%
      slfhelper::get_chi()) {
  cli::cli_alert_info("Join cohort lookups function started at {Sys.time()}")

  join_cohort_lookups <- data %>%
    dplyr::left_join(
      demographic_cohort,
      by = "chi"
    ) %>%
    dplyr::left_join(
      service_use_cohort,
      by = "chi"
    )

  return(join_cohort_lookups)
}


#' Join sc client variables onto episode file
#'
#' @description Match on sc client variables.
#'
#' @param data the processed individual file
#' @param year financial year.
#' @param sc_client SC client lookup
#' @param file_type episode or individual file
join_sc_client <- function(data,
                           year,
                           sc_client = read_file(get_sc_client_lookup_path(year)) %>% slfhelper::get_chi(),
                           file_type = c("episode", "individual")) {
  cli::cli_alert_info("Join social care client function started at {Sys.time()}")

  if (!check_year_valid(year, type = "client")) {
    data_file <- data
    return(data_file)
  }

  if (file_type == "episode") {
    # Match on client variables by chi
    data_file <- data %>%
      dplyr::left_join(
        sc_client,
        by = "chi",
        relationship = "many-to-one"
      )
  } else {
    data_file <- data %>%
      dplyr::left_join(
        sc_client,
        by = "chi",
        relationship = "one-to-one"
      )
  }

  return(data_file)
}
