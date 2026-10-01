#' Process Social Care, Care Home all episodes tests
#'
#' @param data The processed Care Home all episode data produced by
#' [process_extract_care_home()].
#'
#' @description This script takes the processed all Care Home file and produces
#' a test comparison with the previous data.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_sc_all_ch_episodes <- function(data,
                                             BYOC_MODE,
                                             update = previous_update(),
                                             benchmark_run_id = NA,
                                             run_id = NA,
                                             run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "sc_ch_ep", year = "all")

  comparison <- produce_test_comparison(
    old_data = produce_sc_all_episodes_tests(
      read_file(get_sc_ch_episodes_path(update = previous_update())) # TODO: Use get_sdl_processed_data
    ),
    new_data = produce_sc_all_episodes_tests(
      data
    )
  )

  comparison %>%
    dplyr::mutate(
      benchmark_comparison_type = "episode", # TODO: Is this correct?
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = "sc_ch_ep",
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
    write_tests_xlsx(sheet_name = "all_ch_episodes", year, workbook_name = "lookup", BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "sc_ch_ep", year = "all")

  return(comparison)
}
