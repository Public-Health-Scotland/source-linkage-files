#' Care Home year specific Episodes Tests
#'
#' @description Produce the test for the Care Home
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag.
#'
#' @export
#' @family social care test functions
produce_slf_ch_year_specific_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    # remove variables that won't be summed
    dplyr::select(.data$valid_chi:.data$missing_dob)
    ) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
