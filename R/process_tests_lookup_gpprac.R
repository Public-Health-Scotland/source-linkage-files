#' Process GP (gpprac) Lookup tests
#'
#' @description This script takes the processed GPPrac Lookup and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_lookup_pc
#'
#' @export
process_tests_lookup_gpprac <- function(data,
                                        BYOC_MODE,
                                        update = previous_update(),
                                        benchmark_run_id = NA,
                                        run_id = NA,
                                        run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "gpprac_lookup", year = "all")

  comparison <- produce_test_comparison(
    old_data = produce_slf_gpprac_tests(
      read_file(get_slf_gpprac_path(update = update, BYOC_MODE = BYOC_MODE)) # TODO: Use get_sdl_processed_data
    ),
    new_data = produce_slf_gpprac_tests(data)
  ) %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode", # TODO: Is this correct?
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "gpprac_lookup",
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
    write_tests_xlsx(sheet_name = "gpprac_lookup", year, workbook_name = "lookup", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "gpprac_lookup", year = "all")

  return(comparison)
}

#' SLF GP Practice Lookup Tests
#'
#' @description Produce the tests for the SLF GP Practice Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_gpprac_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family slf test functions
#' @seealso [create_hb_test_flags()] and
#' [create_hscp_test_flags()] for creating test flags
produce_slf_gpprac_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$hbpraccode) %>%
    create_hscp_test_flags(.data$hscp2018) %>%
    # create other test flags
    dplyr::mutate(n_gpprac = 1L) %>%
    # remove variables that won't be summed
    dplyr::select(-c(
      "gpprac", "pc7", "pc8", "cluster",
      "hbpraccode", "hscp2018", "ca2018",
      "lca"
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
