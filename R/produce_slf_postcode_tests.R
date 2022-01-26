#' Postcode Lookup tests
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with a count of each flag
#' @export
#' @importFrom dplyr mutate select
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
