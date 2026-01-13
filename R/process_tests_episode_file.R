#' Process Episode file tests
#'
#' @description Takes the processed episode file and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_episode_file <- function(data, year) {
  data <- data %>%
    dplyr::select(
      "year",
      "anon_chi",
      "gender",
      "postcode",
      "hbtreatcode",
      "hscp2018",
      "dob",
      "recid",
      "yearstay",
      "record_keydate1",
      "record_keydate2",
      "social_care_id",
      "sc_send_lca",
      dplyr::contains(c("beddays", "cost", "cij")),
      slfhelper::ltc_vars,
      paste0(slfhelper::ltc_vars, "_date")
    )

  old_data <- slfhelper::read_slf_episode(year, col_select = dplyr::all_of(names(data)))

  comparison <- dplyr::bind_rows(
    produce_test_comparison(
      old_data = produce_episode_file_tests(old_data),
      new_data = produce_episode_file_tests(data),
      recid = TRUE
    ) %>%
      dplyr::arrange(.data[["recid"]]),
    produce_episode_file_ltc_tests(data, old_data, year)
  ) %>%
    write_tests_xlsx(
      sheet_name = stringr::str_glue({
        "ep_file_{year}"
      }),
      year = year,
      workbook_name = "ep_file"
    )

  return(comparison)
}

#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by most
#' of the extracts. Handles social care datasets separately to count
#' distinct clients per sending location instead of submissions.
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbtreatcode`
#' using [create_hb_test_flags()], a total cost for each `hbtreatcode` using
#' [create_hb_cost_test_flags()].
#' It will also produce various summary statistics for bedday, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#' @param sum_mean_vars variables used when selecting
#' 'all' measures from [calculate_measures()]
#' @param max_min_vars variables used when selecting
#' 'min-max' from [calculate_measures()]
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' @seealso [create_hb_test_flags()],
#' [create_hscp_test_flags()] and [create_hb_cost_test_flags()]
#' for creating test flags
#' @seealso calculate_measures
#' @export
produce_episode_file_tests <- function(data,
                                       sum_mean_vars = c("beddays", "cost", "yearstay"),
                                       max_min_vars = c(
                                         "record_keydate1",
                                         "record_keydate2",
                                         "cost_total_net",
                                         "yearstay"
                                       )) {
  # Split data into social care and non-social care datasets and process accordingly
  social_care_recids <- c("AT", "HC", "CH", "SDS")

  sc_data <- data %>%
    dplyr::filter(.data$recid %in% social_care_recids)

  non_sc_data <- data %>%
    dplyr::filter(!(.data$recid %in% social_care_recids))

  sc_tests <- produce_sc_episode_tests(sc_data, sum_mean_vars, max_min_vars)

  non_sc_tests <- produce_non_sc_episode_tests(non_sc_data, sum_mean_vars, max_min_vars)

  # Combine results
  join_output <- dplyr::bind_rows(sc_tests, non_sc_tests)

  return(join_output)
}

#' Produce Social Care Episode Tests
#'
#' @description Process social care datasets with distinct client counting
#'
#' @inheritParams produce_episode_file_tests
#'
#' @return a dataframe with test measures for social care datasets
#' @family extract test functions
produce_sc_episode_tests <- function(data,
                                     sum_mean_vars = c("beddays", "cost", "yearstay"),
                                     max_min_vars = c(
                                       "record_keydate1",
                                       "record_keydate2",
                                       "cost_total_net",
                                       "yearstay"
                                     )) {

  if (nrow(data) == 0) {
    return(tibble::tibble())
  }

  # Pre-calculate values before applying distinct count
  data_with_totals <- data %>%
    dplyr::group_by(.data$recid) %>%
    dplyr::mutate(
      n_missing_chi_total = sum(is.na(.data$anon_chi)),
      n_missing_dob_total = sum(is.na(.data$dob)),
      n_missing_postcode_total = sum(is.na(.data$postcode))
    )

  missing_totals <- data_with_totals %>%
    dplyr::group_by(.data$recid) %>%
    dplyr::summarise(
      n_missing_chi_total = dplyr::first(n_missing_chi_total),
      n_missing_dob_total = dplyr::first(n_missing_dob_total),
      n_missing_postcode_total = dplyr::first(n_missing_postcode_total),
      .groups = "drop"
    )

  # Apply distinct counting for clients per sending location
  test_flags <- data_with_totals %>%
    dplyr::arrange(.data$anon_chi) %>%
    dplyr::distinct(.data$anon_chi, .data$social_care_id, .keep_all = TRUE) %>%
    dplyr::group_by(.data$recid) %>%
    dplyr::mutate(n_records = 1L) %>%
    # Create test flags
    create_demog_test_flags() %>%
    create_lca_client_test_flags(.data$sc_send_lca) %>%
    # Keep variables for comparison
    dplyr::select("n_records":dplyr::last_col()) %>%
    # Sum test flags
    calculate_measures(measure = "sum", group_by = "recid") %>%
    dplyr::left_join(missing_totals, by = "recid") %>%
    dplyr::mutate(
      value = dplyr::case_when(
        measure == "n_missing_chi" ~ as.numeric(n_missing_chi_total),
        measure == "missing_dob" ~ as.numeric(n_missing_dob_total),
        measure == "n_missing_postcode" ~ as.numeric(n_missing_postcode_total),
        TRUE ~ value
      )
    ) %>%
    dplyr::select(-dplyr::ends_with("_total"))

  # Calculate all measures (mean, sum, etc.)
  all_measures <- data %>%
    dplyr::group_by(.data$recid) %>%
    calculate_measures(
      vars = {{ sum_mean_vars }},
      measure = "all",
      group_by = "recid"
    )

  # Calculate min-max measures
  min_max <- data %>%
    dplyr::group_by(.data$recid) %>%
    calculate_measures(
      vars = {{ max_min_vars }},
      measure = "min-max",
      group_by = "recid"
    )

  # Join all results
  join_output <- list(test_flags, all_measures, min_max) %>%
    purrr::reduce(dplyr::full_join, by = c("recid", "measure", "value"))

  return(join_output)
}

#' Produce Non-Social Care Episode Tests
#'
#' @description Process non-social care datasets with standard counting
#'
#' @inheritParams produce_episode_file_tests
#'
#' @return a dataframe with test measures for non-social care datasets
#' @family extract test functions
produce_non_sc_episode_tests <- function(data,
                                         sum_mean_vars = c("beddays", "cost", "yearstay"),
                                         max_min_vars = c(
                                           "record_keydate1",
                                           "record_keydate2",
                                           "cost_total_net",
                                           "yearstay"
                                         )) {

  if (nrow(data) == 0) {
    return(tibble::tibble())
  }

  # Standard processing - no distinct filtering
  test_flags <- data %>%
    dplyr::group_by(.data$recid) %>%
    dplyr::mutate(n_records = 1L) %>%
    # Use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(.data$hbtreatcode, .data$cost_total_net) %>%
    create_hscp_test_flags(.data$hscp2018) %>%
    # Flags to count stay types
    dplyr::mutate(
      cij_elective = dplyr::if_else(.data[["cij_pattype"]] == "Elective", 1L, 0L),
      cij_non_elective = dplyr::if_else(.data[["cij_pattype"]] == "Non-Elective", 1L, 0L),
      cij_maternity = dplyr::if_else(.data[["cij_pattype"]] == "Maternity", 1L, 0L),
      cij_other = dplyr::if_else(.data[["cij_pattype"]] == "Other", 1L, 0L)
    ) %>%
    # Keep variables for comparison
    dplyr::select("n_records":dplyr::last_col()) %>%
    # Sum test flags
    calculate_measures(measure = "sum", group_by = "recid")

  # Calculate all measures
  all_measures <- data %>%
    dplyr::group_by(.data$recid) %>%
    calculate_measures(
      vars = {{ sum_mean_vars }},
      measure = "all",
      group_by = "recid"
    )

  # Calculate min-max measures
  min_max <- data %>%
    dplyr::group_by(.data$recid) %>%
    calculate_measures(
      vars = {{ max_min_vars }},
      measure = "min-max",
      group_by = "recid"
    )

  # Join all results
  join_output <- list(test_flags, all_measures, min_max) %>%
    purrr::reduce(dplyr::full_join, by = c("recid", "measure", "value"))

  return(join_output)
}

#' Source Extract Tests
#'
#' @description Produce a LTCs test counting total number of each LTC flag
#' with distinct anon_chi.
#' @param old_data old episode file data
#' @inherit process_tests_episode_file
#' @return a dataframe with a count of total numbers of
#' LTCs flag.
#'
#' @family extract test functions
produce_episode_file_ltc_tests <- function(data,
                                           old_data = slfhelper::read_slf_episode(year, col_select = dplyr::all_of(ltc_col2)),
                                           year) {
  ltc_col <- c(slfhelper::ltc_vars, paste0(slfhelper::ltc_vars, "_date"))
  ltc_col2 <- c("anon_chi", ltc_col)

  old_data <- old_data %>%
    dplyr::select(dplyr::all_of(ltc_col2)) %>%
    dplyr::distinct()

  new_data <- data %>%
    dplyr::select(dplyr::all_of(ltc_col2)) %>%
    dplyr::distinct()

  comparison <- produce_test_comparison(
    old_data = produce_source_ltc_tests(old_data),
    new_data = produce_source_ltc_tests(new_data)
  )

  return(comparison)
}
