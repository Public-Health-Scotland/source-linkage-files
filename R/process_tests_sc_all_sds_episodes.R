#' Process Social Care SDS all episodes tests
#'
#' @param data The processed SDS all episode data produced by
#' [process_sc_all_sds()].
#'
#' @description This script takes the processed all SDS file and produces
#' a test comparison with the previous data.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_sc_all_sds_episodes <- function(data,
                                              BYOC_MODE,
                                              benchmark_run_id = NA,
                                              run_id = NA,
                                              run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "sc_sds_ep", year = "all")

  comparison <- produce_test_comparison(
    old_data = produce_sc_all_episodes_tests(
      read_file(get_sc_sds_episodes_path(update = previous_update()))
    ),
    new_data = produce_sc_all_episodes_tests(
      data
    )
  )

  comparison %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode",
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "sc_sds_ep",
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
    write_tests_xlsx(sheet_name = "all_sds_episodes", year, workbook_name = "lookup", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "sc_sds_ep", year = "all")

  return(comparison)
}
