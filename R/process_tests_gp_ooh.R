#' Process GP OOH tests
#'
#' @description This script takes the processed GP OOH extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_gp_ooh <- function(data,
                                 year,
                                 BYOC_MODE,
                                 benchmark_run_id = NA,
                                 run_id = NA,
                                 run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "gpooh", year = year)

  old_data <- get_existing_data_for_tests(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_extract_tests(old_data,
      sum_mean_vars = "cost"
    ),
    new_data = produce_source_extract_tests(data,
      sum_mean_vars = "cost"
    )
  ) %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode",
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "gpooh",
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
    ) %>% write_tests_xlsx(sheet_name = "gpooh", year, workbook_name = "extract", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "gpooh", year = year)

  return(comparison)
}
