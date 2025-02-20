#' Process SDS tests
#'
#' @description This script takes the processed SDS extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_sds <- function(data, year) {
  if (check_year_valid(year, "sds")) {
    old_data <- get_existing_data_for_tests(data)

    data <- rename_hscp(data)

    comparison <- produce_test_comparison(
      old_data = produce_source_sds_tests(old_data),
      new_data = produce_source_sds_tests(data)
    ) %>%
      write_tests_xlsx(sheet_name = "sds", year, workbook_name = "extract")

    return(comparison)
  } else {
    return(NULL)
  }
}

#' SDS Episodes Tests
#'
#' @description Produce the test for the SDS all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_sds_episodes_path()])
#' @param max_min_vars variables used when selecting 'min-max'
#' from [calculate_measures()]
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_source_sds_tests <- function(data,
                                     max_min_vars = c("record_keydate1", "record_keydate2")) {
  test_flags <- data %>%
    # create test flags
    create_demog_test_flags() %>%
    create_lca_test_flags(.data$sc_send_lca) %>%
    # remove variables that won't be summed
    dplyr::select("unique_anon_chi":"West_Lothian") %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max_measures <- data %>%
    calculate_measures(vars = max_min_vars, measure = "min-max")

  join_output <- list(test_flags, min_max_measures) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
