#' Process PC (postcode) Lookup tests
#'
#' @inheritParams process_tests_acute
#' @param update The update to compare the lookup to, defaults to
#' [previous_update()].
#'
#' @description This script takes the processed acute extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_lookup_pc <- function(data, update = previous_update()) {
  comparison <- produce_test_comparison(
    old_data = produce_slf_postcode_tests(
      read_file(get_slf_postcode_path(update = update))
    ),
    new_data = produce_slf_postcode_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "source_pc_lookup")

  return(comparison)
}

#' SLF Postcode Lookup Tests
#'
#' @description Produce the tests for the SLF Postcode Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_postcode_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family slf test functions
#' @seealso [create_hb_test_flags()] and
#' [create_hscp_test_flags()] for creating test flags
produce_slf_postcode_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$hb2019) %>%
    create_hscp_test_flags(.data$hscp2019) %>%
    # create other test flags
    dplyr::mutate(n_postcode = 1L) %>%
    # remove variables that are not test flags
    dplyr::select(c(.data$NHS_Ayrshire_and_Arran:.data$n_postcode)) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
