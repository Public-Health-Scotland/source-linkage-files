#' Produce the Source Episode file
#'
#' @param processed_data_list containing data from processed extracts.
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param anon_chi_out (Default:TRUE) Should `anon_chi` be used in the output
#' (instead of chi)
#'
#' @return a [tibble][tibble::tibble-package] containing the episode file
#' @export
#'
run_episode_file <- function(
    processed_data_list,
    year,
    write_to_disk = TRUE,
    anon_chi_out = TRUE) {
  episode_file <- dplyr::bind_rows(processed_data_list) %>%
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
    add_ppa_flag() %>%
    link_delayed_discharge_eps(year) %>%
    add_nsu_cohort(year) %>%
    match_on_ltcs(year) %>%
    correct_demographics(year) %>%
    create_cohort_lookups(year) %>%
    join_cohort_lookups(year) %>%
    join_sparra_hhg(year) %>%
    fill_geographies() %>%
    join_deaths_data(year) %>%
    load_ep_file_vars(year)

  if (anon_chi_out) {
    episode_file <- slfhelper::get_anon_chi(episode_file)
  }

  if (write_to_disk) {
    # TODO make the slf_path a function
    slf_episode_path <- get_file_path(
      get_year_dir(year),
      stringr::str_glue(
        "source-episode-file-{year}.parquet"
      ),
      check_mode = "write"
    )

    write_file(episode_file, slf_episode_path)
  }

  return(episode_file)
}

#' Store the unneeded episode file variables
#'
#' @param data The in-progress episode file data.
#' @inheritParams run_episode_file
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
#' @inheritParams run_episode_file
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

  return(full_data)
}

#' Fill any missing CIJ markers for records that should have them
#'
#' @inheritParams store_ep_file_vars
#'
#' @return A data frame with CIJ markers filled in for those missing.
fill_missing_cij_markers <- function(data) {
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
#'
#' @return The data including the Demographic and Service Use lookups.
join_cohort_lookups <- function(data, year, update = latest_update()) {
  join_cohort_lookups <- data %>%
    dplyr::left_join(
      read_file(
        get_demographic_cohorts_path(year, update),
        col_select = c("chi", "demographic_cohort")
      ),
      by = "chi"
    ) %>%
    dplyr::left_join(
      read_file(
        get_service_use_cohorts_path(year, update),
        col_select = c("chi", "service_use_cohort")
      ),
      by = "chi"
    )

  return(join_cohort_lookups)
}
