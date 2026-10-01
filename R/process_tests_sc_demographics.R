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
process_tests_sc_demographics <- function(data,
                                          BYOC_MODE,
                                          update = previous_update(),
                                          benchmark_run_id = NA,
                                          run_id = NA,
                                          run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "sc_demog", year = "all")

  comparison <- produce_test_comparison(
    old_data = produce_sc_demog_lookup_tests(
      read_file(get_sc_demog_lookup_path(update = previous_update())) # TODO: Use get_sdl_processed_data
    ),
    new_data = produce_sc_demog_lookup_tests(
      data
    )
  )

  comparison %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode", # TODO: Is this correct?
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "sc_demog",
      year = "all"
    ) %>%
    dplyr::select(
      "year",
      "dataset_name",
      "measure",
      "value_old",
      "value_new",
      "difference",
      "pct_change",
      "issue",
      "run_id",
      "run_date_time",
      "benchmark_comparison_type",
      "benchmark_run_id"
    ) %>%
    write_tests_xlsx(sheet_name = "sc_demographics", year, workbook_name = "lookup", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "sc_demog", year = "all")

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
