#' Process Acute tests
#'
#' @description Takes the processed Acute extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @param data a [tibble][tibble::tibble-package] of the processed data extract.
#' @param year the financial year of the extract in the format '1718'.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_acute <- function(data,
                                year,
                                BYOC_MODE,
                                benchmark_run_id = NA,
                                run_id = NA,
                                run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "acute", year = year)

  old_data <- get_existing_data_for_tests(data)

  data <- apply_cost_uplift(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_extract_tests(old_data),
    new_data = produce_source_extract_tests(data)
  ) %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode",
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "acute",
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
    ) %>% write_tests_xlsx(sheet_name = "01b", year, workbook_name = "extract", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "acute", year = year)

  return(comparison)
}
