#' Social Care Demographic Lookup Tests
#'
#' @description Produce the tests for Social Care Demographic Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_demog_lookup_path()])
#'
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_sc_demog_lookup_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_missing_sending_loc = is.na(.data$sending_location),
      n_missing_sc_id = is.na(.data$social_care_id)
    ) %>%
    create_sending_location_test_flags(.data$sending_location) %>%
    # remove variables that won't be summed
    dplyr::select(
      -c(
        "sending_location",
        "social_care_id",
        "anon_chi",
        "gender",
        "dob",
        "postcode",
        "date_of_death",
        "extract_date",
        "linking_id",
        "financial_year",
        "consistent_quality"
      )
    ) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
