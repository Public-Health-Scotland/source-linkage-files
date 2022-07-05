#' SLF GP Practice Lookup Tests
#'
#' @description Produce the tests for the SLF GP Practice Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_gpprac_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#' @family slf test functions
#' @seealso [create_hb_test_flags()] and
#' [create_hscp_test_flags()] for creating test flags
produce_slf_gpprac_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$hbpraccode) %>%
    create_hscp_test_flags(.data$hscp2018) %>%
    # create other test flags
    dplyr::mutate(n_gpprac = 1) %>%
    # remove variables that won't be summed
    dplyr::select(-c(
      .data$gpprac, .data$pc7, .data$pc8, .data$cluster,
      .data$hbpraccode, .data$hscp2018, .data$ca2018,
      .data$lca
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
