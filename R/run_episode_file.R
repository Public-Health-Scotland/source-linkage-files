#' Produce the Source Episode file
#'
#' @param processed_data_list containing data from processed extracts.
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return a [tibble][tibble::tibble-package] containing the episode file
#' @export
#'
run_episode_file <- function(processed_data_list, year, write_to_disk = TRUE) {
  # Bring all the datasets together from Jen's process functions
  episode_file <- dplyr::bind_rows(processed_data_list) %>%
    select_variables(year, vars_to_keep = c(
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
      "yearstay",
      "ipdc",
      "spec",
      "sigfac",
      "mpat",
      "diag1",
      "diag2",
      "diag3",
      "diag4",
      "diag5",
      "diag6",
      "op1a",
      "op1b",
      "op2a",
      "op2b",
      "op3a",
      "op3b",
      "op4a",
      "op4b",
      "age",
      "cij_marker",
      "cij_pattype_code",
      "cij_ipdc",
      "cij_admtype",
      "cij_adm_spec",
      "cij_dis_spec",
      "cij_start_date",
      "cij_end_date",
      "cost_total_net",
      "apr_cost",
      "may_cost",
      "jun_cost",
      "jul_cost",
      "aug_cost",
      "sep_cost",
      "oct_cost",
      "nov_cost",
      "dec_cost",
      "jan_cost",
      "feb_cost",
      "mar_cost",
      "hscp",
      "datazone",
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
      "deathdiag11"
    )) %>%
    # From C01 ----
    # Check chi is valid using phsmethods function
    # If the CHI is invalid for whatever reason, set the CHI to blank string
    dplyr::mutate(
      chi = dplyr::if_else(
        phsmethods::chi_check(.data$chi) != "Valid CHI",
        NA_character_,
        .data$chi
      ),
      gpprac = convert_eng_gpprac_to_dummy(.data[["gpprac"]])
    ) %>%
    correct_cij_vars() %>%
    fill_missing_cij_markers() %>%
    create_cost_inc_dna() %>%
    # Add the flag for Potentially Preventable Admissions
    add_ppa_flag() %>%
    # TODO add Link Delayed Discharge here (From C02)
    add_nsu_cohort(year) %>%
    match_on_ltcs(year) %>%
    correct_demographics(year) %>%
    join_cohort_lookups(year) %>%
    # TODO match on SPARRA and HHG here
    # From C09 - Match on postcode and gpprac variables ----
    fill_geographies() %>%
    load_variables(year)

  if (write_to_disk == TRUE) {
    slf_path <- get_file_path(
      get_year_dir(year),
      stringr::str_glue(
        "source-episode-file-{year}.parquet"
      ),
      check_mode = "write"
    )

    write_file(episode_file, slf_path)
  }

  return(episode_file)
}

select_variables <- function(data, year, vars_to_keep) {
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

load_variables <- function(data, year) {
  tempfile_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("temp_ep_file_variable_store_{year}.parquet"),
    check_mode = "read"
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
#' @param ep_file_data A data frame containing only `recid %in% c("01B", "04B",
#' "GLS", "02B")` with a valid CHI number.
#'
#' @return A data frame with CIJ markers filled in for those missing.
fill_missing_cij_markers <- function(ep_file_data) {
  fixable_data <- ep_file_data %>%
    dplyr::filter(
      .data[["recid"]] %in% c("01B", "04B", "GLS", "02B") & !is.na(.data[["chi"]])
    )

  non_fixable_data <- ep_file_data %>%
    dplyr::filter(
      !(.data[["recid"]] %in% c("01B", "04B", "GLS", "02B")) | is.na(.data[["chi"]])
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
#' @param ep_file_data The episode file data in progress.
#'
#' @return The data with CIJ variables corrected.
correct_cij_vars <- function(ep_file_data) {
  check_variables_exist(
    ep_file_data,
    c("chi", "recid", "cij_admtype", "cij_pattype_code")
  )

  ep_file_data %>%
    # Change some values of cij_pattype_code based on cij_admtype
    dplyr::mutate(
      cij_admtype = dplyr::if_else(
        .data[["cij_admtype"]] == "Unknown",
        "99",
        .data[["cij_admtype"]]
      ),
      cij_pattype_code = dplyr::if_else(
        !is.na(.data$chi) & .data$recid %in% c("01B", "04B", "GLS", "02B"),
        dplyr::case_match(.data$cij_admtype,
          c("41", "42") ~ 2,
          c("40", "48", "99") ~ 9,
          "18" ~ 0,
          .default = .data$cij_pattype_code
        ),
        .data$cij_pattype_code
      ),
      # Recode cij_pattype based on above
      cij_pattype = dplyr::case_match(
        .data$cij_pattype_code,
        0 ~ "Non-Elective",
        1 ~ "Elective",
        2 ~ "Maternity",
        9 ~ "Other"
      )
    )
}

#' Create cost total net inc DNA
#'
#' @param ep_file_data The episode file data in progress.
#'
#' @return The data with cost including dna.
create_cost_inc_dna <- function(ep_file_data) {
  check_variables_exist(ep_file_data, c("cost_total_net", "attendance_status"))

  # Create cost including DNAs and modify costs
  # not including DNAs using cattend
  ep_file_data %>%
    dplyr::mutate(
      cost_total_net_inc_dnas = .data$cost_total_net,
      # In the Cost_Total_Net column set the cost for
      # those with attendance status 5 or 8 (CNWs and DNAs)
      cost_total_net = dplyr::if_else(
        .data$attendance_status %in% c(5, 8),
        0.0,
        .data$cost_total_net
      )
    )
}


#' Join cohort lookups
#'
#' @param ep_file_data Episode file data.
#' @param year financial year, e.g. '1920'
#'
#' @return The data including the demographic and service use lookups matched
#' on to the episode file.
#'
join_cohort_lookups <- function(ep_file_data, year) {
  demographic_cohorts <- create_demographic_cohorts(
    ep_file_data,
    year,
    write_to_disk = TRUE
  )
  service_use_cohorts <- create_service_use_cohorts(
    ep_file_data,
    year,
    write_to_disk = TRUE
  )

  join_cohort_lookups <- ep_file_data %>%
    dplyr::left_join(demographic_cohorts, by = "chi") %>%
    dplyr::left_join(service_use_cohorts, by = "chi")

  return(join_cohort_lookups)
}
