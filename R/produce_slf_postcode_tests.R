#' Postcode Lookup tests
#'
#' @param data new or old data for testing summary flags (data is from \code{\link{get_slf_postcode_path}})
#'
#' @return a dataframe with a count of each flag from \code{\link{sum_test_flags}}
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
#' @seealso \code{\link{create_hb2019_flags}} and \code{\link{create_hscp2019_flags}} for creating test flags
produce_slf_postcode_tests <- function(data){

  data %>%
    #use functions to create HB and partnership flags
    create_hb2019_flags() %>%
    create_hscp2019_flags() %>%
    #create other test flags
    dplyr::mutate(n_postcode = 1) %>%
    #remove variables that won't be summed
    dplyr::select(-c(.data$postcode:.data$UR2_2016)) %>%
    #use function to sum new test flags
    sum_test_flags()
}
