#' Process Social Care Demographics tests
#'
#' @param data The processed demographic data produced by
#' [process_lookup_sc_demographics()].
#'
#' @description Take the processed demographics extract and produces
#' a test comparison with the previous data.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_sc_demographics <- function(data) {
  comparison <- produce_test_comparison(
    old_data = produce_sc_demog_lookup_tests(
      readr::read_rds(get_sc_demog_lookup_path(update = previous_update()))
    ),
    new_data = produce_sc_demog_lookup_tests(
      data
    )
  ) %>%
    write_tests_xlsx(sheet_name = "sc_demographics")

  return(comparison)
}

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
    # remove variables that won't be summed
    dplyr::select(
      -c(
        "sending_location",
        "social_care_id",
        "chi",
        "gender",
        "dob",
        "postcode"
      )
    ) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
