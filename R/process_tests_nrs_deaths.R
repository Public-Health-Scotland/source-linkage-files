#' Process National Records of Scotland (NRS) deaths tests
#'
#' @description This script takes the processed NRS deaths extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_nrs_deaths <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_nrs_tests(old_data),
    new_data = produce_source_nrs_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "NRS", year, workbook_name = "extract")

  return(comparison)
}

#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by the death (NRS) extract
#'
#' This will produce counts of various demographics.
#' It will also produce various summary statistics for episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' @seealso [calculate_measures()]
produce_source_nrs_tests <- function(data) {
  test_flags <- data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(n_deaths = 1L) %>%
    # keep variables for comparison
    dplyr::select("valid_chi":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max <- data %>%
    calculate_measures(
      vars = c("record_keydate1", "record_keydate2"),
      measure = "min-max"
    )

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
