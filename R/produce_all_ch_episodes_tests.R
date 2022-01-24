#' All care home episode tests
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with a count of each flag
#' @export
produce_all_ch_episodes_tests <- function(data){

  data %>%
    #create test flags
    dplyr::mutate(n_sending_loc = if_else(is.na(.data$sending_location)| .data$sending_location == "", 0, 1),
                  n_sc_id = if_else(is.na(.data$social_care_id)| .data$social_care_id == "", 0, 1),
                  n_chi = if_else(is.na(.data$chi)| .data$chi == "", 0, 1),
                  n_postcode = if_else(is.na(.data$postcode)| .data$postcode == "", 0, 1),
                  n_males = if_else(.data$gender == 1, 1, 0),
                  n_females = if_else(.data$gender == 2, 1, 0)
    ) %>%
    #remove variables that won't be summed
    dplyr::select(-c(.data$chi:.data$sc_latest_submission)) %>%
    #use function to sum new test flags
    sum_test_flags()
}
