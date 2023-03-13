#' Process prescribing tests
#'
#' @description This script takes the processed prescribing extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_prescribing <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_pis_tests(old_data),
    new_data = produce_source_pis_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "PIS", year)

  return(comparison)
}

#' Source PIS Tests
#'
#' @description Produce a set of tests which can be used by most
#' of the extracts.
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbtreatcode`
#' It will also produce various summary statistics for beddays, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' for creating test flags
#' @seealso calculate_measures
produce_source_pis_tests <- function(data) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    dplyr::mutate(n_episodes = 1L) %>%
    # keep variables for comparison
    dplyr::select(c("valid_chi":dplyr::last_col())) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  all_measures <- data %>%
    calculate_measures(
      vars = c(
        "cost",
        "no_paid_items"
      ),
      measure = "all"
    )

  join_output <- list(
    test_flags,
    all_measures
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}

