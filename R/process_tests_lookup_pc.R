#' Process PC (postcode) Lookup tests
#'
#' @inheritParams process_tests_acute
#' @param update The update to compare the lookup to, defaults to
#' [previous_update()].
#'
#' @description This script takes the processed Postcode Lookup and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_lookup_pc <- function(data,
                                    BYOC_MODE,
                                    update = previous_update(),
                                    benchmark_run_id = NA,
                                    run_id = NA,
                                    run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "pc_lookup", year = "all")

  comparison <- produce_test_comparison(
    old_data = produce_slf_postcode_tests(
      read_file(get_slf_postcode_path(update = update)) # TODO: Use get_sdl_processed_data
    ),
    new_data = produce_slf_postcode_tests(data)
  ) %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode", # TODO: Is this correct?
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "pc_lookup",
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
    write_tests_xlsx(sheet_name = "source_pc_lookup", year, workbook_name = "lookup", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "pc_lookup", year = "all")

  return(comparison)
}

#' SLF Postcode Lookup Tests
#'
#' @description Produce the tests for the SLF Postcode Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_postcode_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family slf test functions
#' @seealso [create_hb_test_flags()] and
#' [create_hscp_test_flags()] for creating test flags
produce_slf_postcode_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$hb2019) %>%
    create_hscp_test_flags(.data$hscp2019) %>%
    # create other test flags
    dplyr::mutate(n_postcode = 1L) %>%
    # remove variables that are not test flags
    dplyr::select("NHS_Ayrshire_and_Arran":"n_postcode") %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
