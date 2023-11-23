#' Social care client lookup tests
#'
#' @description This script takes the processed social care client lookup and
#' produces a test comparison with the previous data. This is written to
#' disk in the tests workbook.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_sc_client_lookup <- function(data, year) {
  comparison <- produce_test_comparison(
    old_data = produce_tests_sc_client_lookup(
      read_file(get_sc_client_lookup_path(year, update = previous_update()))
    ),
    new_data = produce_tests_sc_client_lookup(data)
  )

  comparison %>%
    write_tests_xlsx(sheet_name = "sc_client", year, workbook_name = "lookup")

  return(comparison)
}


#' Social care Client lookup Tests
#'
#' @description Produce the test for the social care Client all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#' @param max_min_vars variables used when selecting 'min-max' from [calculate_measures()]
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_tests_sc_client_lookup <- function(data) {
  test_flags <- data %>%
    # create test flags
    create_sending_location_test_flags(.data$sending_location) %>%
    dplyr::arrange(.data$sending_location, .data$social_care_id) %>%
    dplyr::mutate(
      unique_sc_id = dplyr::lag(.data$social_care_id) != .data$social_care_id,
      n_sc_living_alone_yes = .data$sc_living_alone == "Yes",
      n_sc_living_alone_no = .data$sc_living_alone == "No",
      n_sc_living_alone_not_known = .data$sc_living_alone == "Not Known",
      n_sc_support_from_unpaid_carer_yes = .data$sc_support_from_unpaid_carer == "Yes",
      n_sc_support_from_unpaid_carer_no = .data$sc_support_from_unpaid_carer == "No",
      n_sc_support_from_unpaid_carer_not_known = .data$sc_support_from_unpaid_carer == "Not Known",
      n_sc_social_worker_yes = .data$sc_social_worker == "Yes",
      n_sc_social_worker_no = .data$sc_social_worker == "No",
      n_sc_social_worker_not_known = .data$sc_social_worker == "Not Known",
      n_sc_meals_yes = .data$sc_meals == "Yes",
      n_sc_meals_no = .data$sc_meals == "No",
      n_sc_meals_not_known = .data$sc_meals == "Not Known",
      n_sc_day_care_yes = .data$sc_day_care == "Yes",
      n_sc_day_care_no = .data$sc_day_care == "No",
      n_sc_day_care_not_known = .data$sc_day_care == "Not Known",
    ) %>%
    # remove variables that won't be summed
    dplyr::select("Aberdeen_City":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  return(test_flags)
}
