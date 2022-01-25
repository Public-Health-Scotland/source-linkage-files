#' GP Practice Lookup tests
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with a count of each flag
#' @export
#' @importFrom dplyr mutate select
produce_slf_gpprac_tests <- function(data){

  data %>%
    #use functions to create HB and partnership flags
    create_HB2019_flag() %>%
    create_HSCP2018_flag() %>%
    #create other test flags
    dplyr::mutate(n_gpprac = 1) %>%
    #remove variables that won't be summed
    dplyr::select(-c(.data$gpprac:.data$LCA)) %>%
    #use function to sum new test flags
    sum_test_flags()
}
