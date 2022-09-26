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
#' @export
#' @family slf test functions
produce_slf_homelessness_tests <- function(data,
                                           max_min_vars = c("record_keydate1", "record_keydate2")) {
  test_flags <- data %>%
    dplyr::arrange(.data$chi) %>%
    # create test flags
    create_demog_test_flags() %>%
    create_lca_test_flags(.data$hl1_sending_lca) %>%
    # keep variables for comparison
    dplyr::select(c(.data$valid_chi:.data$West_Lothian)) %>%
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
