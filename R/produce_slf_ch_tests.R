#' Care Home All Episodes Tests
#'
#' @description Produce the test for the Care Home
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path(year, "CH")])
#'
#' @return a dataframe with a count of each flag.
#'
#' @export
#' @family social care test functions
produce_slf_ch_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    # remove variables that won't be summed
    dplyr::select(
      .data$valid_chi,
      .data$unique_chi,
      .data$n_missing_chi,
      .data$n_males,
      .data$n_females,
      .data$n_postcode,
      .data$n_missing_postcode,
      .data$missing_dob
    ) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
