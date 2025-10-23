#' Produce the Source Episode file
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
create_episode_file <- function(
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
  write_temp_to_disk = FALSE
) {
  cli::cli_alert_info("Create episode file function started at {Sys.time()}")

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
        social_care_id = NA,
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
        "social_care_id",
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
    correct_demographics(year) %>%
    write_temp_data(year, file_name = "ep_temp4", write_temp_to_disk) %>%
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
        ch_chi_cis = as.numeric(NA),
        ch_sc_id_cis = as.numeric(NA),
        ch_name = as.character(NA),
        ch_postcode = as.character(NA),
        ch_adm_reason = as.integer(NA),
        ch_provider = as.numeric(NA),
        ch_provider_description = as.character(NA),
        ch_nursing = as.numeric(NA),
        hc_hours_annual = as.numeric(NA),
        hc_hours_q1 = as.integer(NA),
        hc_hours_q2 = as.integer(NA),
        hc_hours_q3 = as.integer(NA),
        hc_hours_q4 = as.numeric(NA),
        hc_cost_q1 = as.integer(NA),
        hc_cost_q2 = as.integer(NA),
        hc_cost_q3 = as.integer(NA),
        hc_cost_q4 = as.numeric(NA),
        hc_provider = as.integer(NA),
        hc_reablement = as.integer(NA),
        person_id = as.character(NA),
        social_care_id = as.character(NA),
        sc_alcohol = as.factor(NA),
        sc_autism = as.factor(NA),
        sc_carer = as.factor(NA),
        sc_day_care = as.factor(NA),
        sc_dementia = as.factor(NA),
        sc_drugs = as.factor(NA),
        sc_elderly_frail = as.factor(NA),
        sc_latest_submission = as.character(NA),
        sc_learning_disability = as.factor(NA),
        sc_living_alone = as.factor(NA),
        sc_meals = as.factor(NA),
        sc_mental_health_disorders = as.factor(NA),
        sc_neurological_condition = as.factor(NA),
        sc_other_vulnerable_groups = as.factor(NA),
        sc_palliative_care = as.factor(NA),
        sc_physical_and_sensory_disability = as.factor(NA),
        sc_send_lca = as.character(NA),
        sc_social_worker = as.factor(NA),
        sc_support_from_unpaid_carer = as.factor(NA),
        sc_type_of_housing = as.factor(NA)
      )
  }

  if (!check_year_valid(year, type = "homelessness")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        hl1_12_months_post_app = as.Date(NA),
        hl1_12_months_pre_app = as.POSIXct(NA),
        hl1_6after_ep = as.numeric(NA),
        hl1_6before_ep = as.numeric(NA),
        hl1_application_ref = as.character(NA),
        hl1_completeness = as.numeric(NA),
        hl1_during_ep = as.numeric(NA),
        hl1_in_fy = as.integer(NA),
        hl1_property_type = as.character(NA),
        hl1_reason_ftm = as.character(NA),
        hl1_sending_lca = as.character(NA)
      )
  }

  if (!check_year_valid(year, type = "dd")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        cij_delay = NA,
        dd_quality = as.factor(NA),
        dd_responsible_lca = as.character(NA),
        delay_end_reason = as.integer(NA),
        primary_delay_reason = as.character(NA),
        secondary_delay_reason = as.character(NA),
      )
  }

  if (!check_year_valid(year, type = "cost_dna")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        cost_total_net_inc_dnas = as.numeric(NA)
      )
  }

  if (!check_year_valid(year, type = "dn")) {
    episode_file <- episode_file %>%
      dplyr::mutate(
        ccm = as.integer(NA),
        total_no_dn_contacts = as.integer(NA)
      )
  }

  # Ordering the episode file columns. If a new variable is added to the episode file or the
  # variable name changed, then the "order_ep_cols" function should be updated to reflect this.
  episode_file <- episode_file %>%
    order_ep_cols()

  if (write_to_disk) {
    write_file(episode_file, get_slf_episode_path(year, check_mode = "write"),
      group_id = 3356
    ) # sourcedev owner
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
      path = tempfile_path,
      group_id = 3356 # sourcedev owner
    )

  cli::cli_alert_info("Store episode file variables function finished at {Sys.time()}")

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

  cli::cli_alert_info("Load episode file variable function finished at {Sys.time()}")

  return(full_data)
}

#' Fill any missing CIJ markers for records that should have them
#'
#' @inheritParams store_ep_file_vars
#'
#' @return A data frame with CIJ markers filled in for those missing.
#' @family episode_file
fill_missing_cij_markers <- function(data) {
  fixable_data <- data %>%
    dplyr::filter(
      .data[["recid"]] %in% c("01B", "04B", "GLS", "02B", "DD") & !is.na(.data[["anon_chi"]])
    )

  non_fixable_data <- data %>%
    dplyr::filter(
      !(.data[["recid"]] %in% c("01B", "04B", "GLS", "02B", "DD")) | is.na(.data[["anon_chi"]])
    )

  fixed_data <- fixable_data %>%
    dplyr::group_by(.data$anon_chi) %>%
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
    dplyr::group_by(.data$anon_chi, .data$cij_marker) %>%
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

  cli::cli_alert_info("Fill missing cij markers function finished at {Sys.time()}")

  return(return_data)
}

#' Correct the CIJ variables
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data with CIJ variables corrected.
#' @family episode_file
correct_cij_vars <- function(data) {
  check_variables_exist(
    data,
    c("anon_chi", "recid", "cij_admtype", "cij_pattype_code")
  )

  data <- data %>%
    # Change some values of cij_pattype_code based on cij_admtype
    dplyr::mutate(
      cij_admtype = dplyr::if_else(
        .data[["cij_admtype"]] == "Unknown",
        "99",
        .data[["cij_admtype"]]
      ),
      cij_pattype_code = dplyr::if_else(
        !is.na(.data$anon_chi) & .data$recid %in% c("01B", "04B", "GLS", "02B"),
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

  cli::cli_alert_info("Correct cij variables function finished at {Sys.time()}")

  return(data)
}

#' Create cost total net inc DNA
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data with cost including dna.
#' @family episode_file
create_cost_inc_dna <- function(data) {
  check_variables_exist(data, c("cost_total_net", "attendance_status"))

  # Create cost including DNAs and modify costs
  # not including DNAs using cattend
  data <- data %>%
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

  cli::cli_alert_info("Create cost inc dna function finished at {Sys.time()}")

  return(data)
}

#' Create the cohort lookups
#'
#' @inheritParams store_ep_file_vars
#' @inheritParams create_demographic_cohorts
#'
#' @return The data unchanged (the cohorts are written to disk)
#' @family episode_file
create_cohort_lookups <- function(data, year, update = latest_update()) {
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

  cli::cli_alert_info("Create cohort lookups function finished at {Sys.time()}")

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
  ),
  service_use_cohort = read_file(
    get_service_use_cohorts_path(year, update),
    col_select = c("anon_chi", "service_use_cohort")
  )
) {
  join_cohort_lookups <- data %>%
    dplyr::left_join(
      demographic_cohort,
      by = "anon_chi"
    ) %>%
    dplyr::left_join(
      service_use_cohort,
      by = "anon_chi"
    )

  cli::cli_alert_info("Join cohort lookups function finished at {Sys.time()}")

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
                           sc_client = read_file(get_sc_client_lookup_path(year)),
                           file_type = c("episode", "individual")) {
  if (!check_year_valid(year, type = "client")) {
    data_file <- data
    return(data_file)
  }

  if (file_type == "episode") {
    # Match on client variables by chi
    # Step 1. Link/join ep with sc_client by anon_chi,
    #         excluding episodes are not joined. We get `data_file_chi_join`
    # Step 2. For the episodes are not joined in Step 1,
    #         join them with sc_client again by person_id,
    #         excluding those are not joined. We get `data_file_pi_join`
    # Step 3. Episodes that are non-joined, is `data_file_unjoined`
    # Step 4. bind rows together

    # Step 1
    data_sc <- data %>%
      dplyr::filter(.data$recid %in% c("AT", "HC", "CH", "SDS"))
    data_non_sc <- data %>%
      dplyr::filter(!(.data$recid %in% c("AT", "HC", "CH", "SDS")))

    data_file_chi_join <- data_sc %>%
      dplyr::inner_join(
        sc_client,
        by = "anon_chi",
        relationship = "many-to-one",
        suffix = c("", "_sc"),
        na_matches = "never"
      ) %>%
      dplyr::select(
        -dplyr::ends_with("_sc")
      )

    # Step 2
    data_file_pi_join <- data_sc %>%
      dplyr::filter(!(
        .data$ep_file_row_id %in% dplyr::pull(data_file_chi_join, .data$ep_file_row_id)
      )) %>%
      dplyr::inner_join(
        sc_client,
        by = "person_id",
        relationship = "many-to-one",
        suffix = c("", "_sc"),
        na_matches = "never"
      ) %>%
      dplyr::select(-dplyr::ends_with("_sc"))

    # Step 3
    data_file_unjoined <- data_sc %>%
      dplyr::filter(!(.data$ep_file_row_id %in% c(
        dplyr::pull(data_file_chi_join, .data$ep_file_row_id),
        dplyr::pull(data_file_pi_join, .data$ep_file_row_id)
      )))

    # Step 4
    data_file <- dplyr::bind_rows(
      data_file_chi_join,
      data_file_pi_join,
      data_file_unjoined,
      data_non_sc
    )
  } else {
    data_file <- data %>%
      dplyr::left_join(
        sc_client,
        by = c("anon_chi"),
        relationship = "one-to-one"
      )
  }

  cli::cli_alert_info("Join social care client function finished at {Sys.time()}")

  return(data_file)
}
