#' Social Care Demographic Lookup Tests
#'
#' @description Produce the tests for Social Care Demographic Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_demog_lookup_path()])
#'
#' @return a dataframe with a count of each flag.
#'
#' @export
#' @family social care test functions
produce_sc_demog_lookup_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_missing_sending_loc = dplyr::if_else(is_missing(.data$sending_location), 1, 0),
      n_missing_sc_id = dplyr::if_else(is_missing(.data$social_care_id), 1, 0)
    ) %>%
    # remove variables that won't be summed
    dplyr::select(
      -c(
        .data$sending_location,
        .data$social_care_id,
        .data$chi,
        .data$gender,
        .data$dob,
        .data$postcode
      )
    ) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
