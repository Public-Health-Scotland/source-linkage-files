#' Produce the Social Care Demographic Lookup tests
#'
#' @param data new or old data for testing summary flags (data is from \code{\link{get_sc_demog_lookup_path}})
#'
#' @return a dataframe with a count of each flag from \code{\link{sum_test_flags}} and \code{\link{create_demog_test_flags}}
#' @export
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
produce_sc_demog_lookup_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags %>%
    dplyr::mutate(
      n_missing_sending_loc = if_else(is.na(.data$sending_location) | .data$sending_location == "", 1, 0),
      n_missing_sc_id = if_else(is.na(.data$social_care_id) | .data$social_care_id == "", 1, 0)
    )%>%
    # remove variables that won't be summed
    dplyr::select(-c(.data$sending_location:.data$postcode)) %>%
    # use function to sum new test flags
    sum_test_flags()
}
