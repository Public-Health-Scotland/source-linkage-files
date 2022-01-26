#' Demographic Lookup tests
#'
#' @param data new or old data for testing summary flags (data is from \code{\link{get_sc_demog_lookup_path}})
#'
#' @return a dataframe with a count of each flag from \code{\link{sum_test_flags}}
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
produce_sc_demog_lookup_tests <- function(data){

  data %>%
    #create test flags
    dplyr::mutate(n_sending_loc = if_else(is.na(.data$sending_location)| .data$sending_location == "", 0, 1),
             n_sc_id = if_else(is.na(.data$social_care_id)| .data$social_care_id == "", 0, 1),
             n_chi = if_else(is.na(.data$chi)| .data$chi == "", 0, 1),
             n_postcode = if_else(is.na(.data$postcode)| .data$postcode == "", 0, 1),
             n_males = if_else(.data$gender == 1, 1, 0),
             n_females = if_else(.data$gender == 2, 1, 0),
             missing_dob = if_else(is.na(.data$dob)| .data$dob == "", 1, 0)
      ) %>%
    #remove variables that won't be summed
    dplyr::select(-c(.data$sending_location:.data$postcode)) %>%
    #use function to sum new test flags
    sum_test_flags()
}
