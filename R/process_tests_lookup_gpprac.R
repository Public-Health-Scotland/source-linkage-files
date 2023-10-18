#' Process GP (gpprac) Lookup tests
#'
#' @description This script takes the processed gpprac lookup and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @inherit process_tests_lookup_pc
#'
#' @export
process_tests_lookup_gpprac <- function(data, update = previous_update()) {
  comparison <- produce_test_comparison(
    old_data = produce_slf_gpprac_tests(
      read_file(get_slf_gpprac_path(update = update))
    ),
    new_data = produce_slf_gpprac_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "source_gpprac_lookup", workbook_name = "lookup")

  return(comparison)
}

#' SLF GP Practice Lookup Tests
#'
#' @description Produce the tests for the SLF GP Practice Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_gpprac_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family slf test functions
#' @seealso [create_hb_test_flags()] and
#' [create_hscp_test_flags()] for creating test flags
produce_slf_gpprac_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$hbpraccode) %>%
    create_hscp_test_flags(.data$hscp2018) %>%
    # create other test flags
    dplyr::mutate(n_gpprac = 1L) %>%
    # remove variables that won't be summed
    dplyr::select(-c(
      "gpprac", "pc7", "pc8", "cluster",
      "hbpraccode", "hscp2018", "ca2018",
      "lca"
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
