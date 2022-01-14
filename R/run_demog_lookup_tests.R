#' Demographic Lookup tests
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with a count of each flag
#' @export
demog_lookup_tests <- function(data){

  data %>%
    #create test flags
    dplyr::mutate(n_sending_loc = if_else(is.na(sending_location), 0, 1),
             n_sc_id = if_else(is.na(social_care_id), 0, 1),
             n_chi = if_else(is.na(chi), 0, 1),
             n_postcode = if_else(is.na(postcode), 0, 1),
             n_males = if_else(gender == 1, 1, 0),
             n_females = if_else(gender == 2, 1, 0),
             missing_dob = if_else(is.na(dob), 1, 0)
      ) %>%
    #remove variables that won't be summed
    dplyr::select(-c(sending_location:postcode)) %>%
    #use function to sum new test flags
    sum_flags()
}
