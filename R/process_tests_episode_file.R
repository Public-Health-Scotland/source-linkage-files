#' Process Episode file tests
#'
#' @description Takes the processed episode file and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @param data a [tibble][tibble::tibble-package] of the episode file.
#' @param year the financial year of the extract in the format '1718'.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_episode_file <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_episode_file_tests(old_data),
    new_data = produce_episode_file_tests(data),
    recid = TRUE
  ) %>%
    dplyr::arrange(recid) %>%
    write_tests_xlsx(sheet_name = "ep_file", year)

  return(comparison)
}

#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by most
#' of the extracts.
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbtreatcode`
#' using [create_hb_test_flags()], a total cost for each `hbtreatcode` using
#' [create_hb_cost_test_flags()].
#' It will also produce various summary statistics for bedday, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#' @param sum_mean_vars variables used when selecting 'all' measures from [calculate_measures()]
#' @param max_min_vars variables used when selecting 'min-max' from [calculate_measures()]
#' @inheritParams calculate_measures
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' @seealso [create_hb_test_flags()],
#' [create_hscp_test_flags()] and [create_hb_cost_test_flags()]
#' for creating test flags
#' @seealso calculate_measures
produce_episode_file_tests <- function(data,
                                       sum_mean_vars = c("beddays", "cost", "yearstay"),
                                       max_min_vars = c(
                                         "record_keydate1", "record_keydate2",
                                         "cost_total_net", "yearstay"
                                       ),
                                       group_by = "recid") {
  test_flags <- data %>%
    dplyr::group_by(.data$recid) %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(.data$hbtreatcode, .data$cost_total_net) %>%
    # Flags to count stay types
    dplyr::mutate(
      cij_elective = if_else(cij_pattype == "Elective", 1, 0),
      cij_non_elective = if_else(cij_pattype == "Non-Elective", 1, 0),
      cij_maternity = if_else(cij_pattype == "Maternity", 1, 0),
      cij_other = if_else(cij_pattype == "Other", 1, 0)
    ) %>%
    # keep variables for comparison
    dplyr::select(c("valid_chi":dplyr::last_col())) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum", group_by = group_by)

  all_measures <- data %>%
    group_by(.data$recid) %>%
    calculate_measures(vars = {{ sum_mean_vars }}, measure = "all", group_by = TRUE)

  min_max <- data %>%
    group_by(.data$recid) %>%
    calculate_measures(vars = {{ max_min_vars }}, measure = "min-max", group_by = TRUE)

  join_output <- list(
    test_flags,
    all_measures,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("recid", "measure", "value"))

  return(join_output)
}
