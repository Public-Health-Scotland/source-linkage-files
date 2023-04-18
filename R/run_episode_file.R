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
  fixed_patient_types <- dplyr::bind_rows(processed_data_list) %>%
    # From C01 ----
    # Check chi is valid using phsmethods function
    # If the CHI is invalid for whatever reason, set the CHI to blank string
    dplyr::mutate(
      chi = dplyr::if_else(
        phsmethods::chi_check(.data$chi) != "Valid CHI",
        "",
        .data$chi
      ),
      gpprac = convert_eng_gpprac_to_dummy(.data[["gpprac"]])
    ) %>%
    # Change some values of cij_pattype_code based on cij_admtype
    dplyr::mutate(
      cij_admtype = dplyr::if_else(.data$cij_admtype == "Unknown", "99", .data$cij_admtype),
      cij_pattype_code = dplyr::case_when(
        !is_missing(.data$chi) &
          .data$recid %in% c("01B", "04B", "GLS", "02B") &
          .data$cij_admtype %in% c("41", "42") ~ 2,
        !is_missing(.data$chi) &
          .data$recid %in% c("01B", "04B", "GLS", "02B") &
          .data$cij_admtype %in% c("40", "48", "99") ~ 9,
        .data$cij_admtype %in% c("18") ~ 0,
        .default = .data$cij_pattype_code
      ),
      # Recode cij_pattype based on above
      cij_pattype = dplyr::case_when(
        .data$cij_pattype_code == 0 ~ "Non-Elective",
        .data$cij_pattype_code == 1 ~ "Elective",
        .data$cij_pattype_code == 2 ~ "Maternity",
        .data$cij_pattype_code == 9 ~ "Other"
      )
    )
  # Combine the CIJ-only records with the non-CIJ records

  ep_file <- dplyr::bind_rows(
    # Fill missing CIJ markers for those records that should have them
    fixed_patient_types %>%
      fill_missing_cij_markers(),
    # Bind the CIJ records with the non-cij records, determined by recid
    fixed_patient_types %>%
      dplyr::filter(!(.data$recid %in% c("01B", "04B", "GLS", "02B")))
  ) %>%
    # Create cost including DNAs and modify cost not including DNAs using cattend
    dplyr::mutate(
      cost_total_net_inc_dnas = .data$cost_total_net,
      # In the Cost_Total_Net column set the cost for
      # those with attendance status 5 or 8 (CNWs and DNAs)
      cost_total_net = dplyr::if_else(
        .data$attendance_status %in% c(5, 8),
        0.0,
        .data$cost_total_net
      )
    ) %>%
    # Add the flag for Potentially Preventable Admissions
    add_ppa_flag() %>%
    # From C02 - Link Delayed Discharge Episodes ----
    # Create Temp File 2
    # temp_file_2 <- temp_file_1

    # From C03 - Link Homelessness ----
    # Create Temp File 3
    # temp_file_3 <- temp_file_2

    # From C04 - Add NSU cohort ----
    add_nsu_cohort(year) %>%
    # From C05 - Match on LTCs ----
    # Create Temp File 5
    match_on_ltcs(year) %>%
    correct_demographics(year) %>%
    # From C07 - Calculate and write out pathways cohorts ----
    # create_demographic_cohorts(ep_file, year, write_to_disk = TRUE)
    # create_service_use_cohorts(ep_file, year, write_to_disk = TRUE)

    # From C09 - Match on postcode and gpprac variables ----
    fill_geographies()



  # From C08 - Match on CHI from Service Use cohort, Demographic cohort, SPARRA and HHG ----
  # Create Temp File 7

  return(ep_file)

  # From C10 - Final tidy-up (mostly variable labels) ----
  # Create Episode File

  # C10X - Create Tests? Possibly for a different function ----
  # Output tests

  if (write_to_disk == TRUE) {

  }
}

select_variables <- function(data, year, vars_to_keep) {
  check_variables_exist(data, vars_to_keep)

  vars_to_store <- setdiff(names(data), vars_to_keep)

  data <- data %>%
    dplyr::mutate(ep_file_row_id = dplyr::row_number()) %>%
    dplyr::select(
      data,
      dplyr::all_of(c("ep_file_row_id", vars_to_store))
    ) %>%
    arrow::write_parquet(
      sink = fs::path(
        get_year_dir(year),
        stringr::str_glue("temp_ep_file_variable_store_{year}.parquet")
      ),
      version = "latest",
      compression = "zstd"
    )

  return(
    dplyr::select(
      data,
      dplyr::all_of(c("ep_file_row_id", vars_to_keep))
    )
  )
}

load_variables <- function(data, year) {
  data %>%
    dplyr::left_join(
      arrow::read_parquet(
        file = fs::path(
          get_year_dir(year),
          stringr::str_glue("temp_ep_file_variable_store_{year}.parquet")
        )
      ),
      by = "ep_file_row_id",
      unmatched = "error",
      relationship = "one-to-one"
    )
}

#' Fill any missing CIJ markers for records that should have them
#'
#' @param data A data frame
#'
#' @return A data frame with CIJ markers filled in for those missing. Will not
#' fill CIJ markers for records with missing CHI
fill_missing_cij_markers <- function(data) {
  return_data <- data %>%
    # Get CIJ-only records
    dplyr::filter(.data$recid %in% c("01B", "04B", "GLS", "02B")) %>%
    dplyr::group_by(.data$chi) %>%
    # We want any NA cij_markers to be filled in, if they are the first in the group and
    # are NA. This is why we use this arrange() before the mutate()
    dplyr::arrange(dplyr::desc(is.na(.data$cij_marker)), .by_group = TRUE) %>%
    dplyr::mutate(cij_marker = dplyr::if_else(
      .data$chi != "" & is.na(.data$cij_marker) & dplyr::row_number() == 1L,
      1,
      .data$cij_marker
    )) %>%
    dplyr::ungroup() %>%
    # Tidy up cij_ipdc
    dplyr::mutate(cij_ipdc = dplyr::case_when(
      .data$chi != "" & is_missing(.data$cij_ipdc) & .data$ipdc == "I" ~ "I",
      .data$chi != "" & is_missing(.data$cij_ipdc) & .data$recid == "01B" & .data$ipdc == "D" ~ "D",
      TRUE ~ .data$cij_ipdc
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

  return(return_data)
}
