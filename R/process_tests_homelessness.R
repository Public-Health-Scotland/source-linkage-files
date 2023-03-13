#' Process Homelessness tests
#'
#' @description This script takes the processed homelessness extract and
#' produces a test comparison with the previous data. This is written to
#' disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_homelessness <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_slf_homelessness_tests(old_data),
    new_data = produce_slf_homelessness_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "HL1", year)

  return(comparison)
}

#' SLF Homelessness Extract Tests
#'
#' @param data The data for testing
#' @param max_min_vars Shouldn't need to change, currently specifies `record_keydate1`
#'  and `record_keydate2`
#'
#' @description Produce the tests for the SLF Homelessness Extract
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family slf test functions
produce_slf_homelessness_tests <- function(data,
                                           max_min_vars = c("record_keydate1", "record_keydate2")) {
  test_flags <- data %>%
    dplyr::arrange(.data$chi) %>%
    # create test flags
    create_demog_test_flags() %>%
    create_lca_test_flags(.data$hl1_sending_lca) %>%
    # keep variables for comparison
    dplyr::select(c("valid_chi":dplyr::last_col())) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  # Calculate the minimum and maximum of max_min_vars
  min_max <- data %>%
    calculate_measures(vars = {{ max_min_vars }}, measure = "min-max")

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}

