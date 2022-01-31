#' GP Practice Lookup tests
#'
#' @param data new or old data for testing summary flags (data is from \code{\link{get_slf_gpprac_path}})
#'
#' @return a dataframe with a count of each flag from \code{\link{sum_test_flags}}
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
#' @seealso \code{\link{create_hb_test_flags}} and \code{\link{create_hscp_test_flags}} for creating test flags
produce_slf_gpprac_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$hbpraccode) %>%
    create_hscp_test_flags(.data$HSCP2018) %>%
    # create other test flags
    dplyr::mutate(n_gpprac = 1) %>%
    # remove variables that won't be summed
    dplyr::select(-c(.data$gpprac:.data$LCA)) %>%
    # use function to sum new test flags
    sum_test_flags()
}
