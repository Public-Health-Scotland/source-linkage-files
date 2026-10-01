#' Process Homelessness tests
#'
#' @description This script takes the processed homelessness extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_homelessness <- function(data,
                                       year,
                                       BYOC_MODE,
                                       benchmark_run_id = NA,
                                       run_id = NA,
                                       run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "homelessness", year = year)

  old_data <- get_existing_data_for_tests(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_slf_homelessness_tests(old_data),
    new_data = produce_slf_homelessness_tests(data)
  ) %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode",
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "homelessness",
      year = year
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
    write_tests_xlsx(sheet_name = "hl1", year, workbook_name = "extract", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "homelessness", year = year)

  return(comparison)
}

#' SLF Homelessness Extract Tests
#'
#' @param data The data for testing
#' @param max_min_vars Shouldn't need to change, currently specifies `record_keydate1`
#'  and `record_keydate2`
#'
#' @description Produce the tests for the SLF Homelessness Extract
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family slf test functions
produce_slf_homelessness_tests <- function(data,
                                           max_min_vars = c("record_keydate1", "record_keydate2")) {
  test_flags <- data %>%
    dplyr::arrange(.data$anon_chi) %>%
    # create test flags
    create_demog_test_flags() %>%
    create_lca_test_flags(.data$hl1_sending_lca) %>%
    # keep variables for comparison
    dplyr::select("unique_anon_chi":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  # Calculate the minimum and maximum of max_min_vars
  min_max <- data %>%
    calculate_measures(vars = {{ max_min_vars }}, measure = "min-max")

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
