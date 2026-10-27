#' Process CMH tests
#'
#' @description This script takes the processed CMH extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_cmh <- function(data,
                              year,
                              BYOC_MODE,
                              benchmark_comparison_type = "episode",
                              benchmark_run_id = NA,
                              run_id = NA,
                              run_date_time = NA) {
  log_slf_event(stage = "test", status = "start", type = "cmh", year = year)

  type <- "cmh"
  workbook <- "extract"

  # Deal with years where we have no data
  if (identical(data, tibble::tibble())) {
    return(data)
  }

  # Get previous data to compare to
  old_data <- get_existing_data_for_tests(
    new_data = data,
    type = type,
    year = year,
    workbook = workbook,
    benchmark_run_id = benchmark_run_id,
    file_version = benchmark_comparison_type,
    file_location = "denodo",
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE = BYOC_MODE
  )

  # Rename HSCP
  data <- rename_hscp(data)

  # Produce comparison
  comparison <- produce_test_comparison(
    old_data = produce_source_cmh_tests(old_data),
    new_data = produce_source_cmh_tests(data)
  ) %>%
    dplyr::mutate(
      benchmark_comparison_type = benchmark_comparison_type,
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = type,
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
    # Write tests
    write_tests_xlsx(sheet_name = type, year, workbook_name = workbook, BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = "cmh", year = year)

  return(comparison)
}

#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by the CMH extract
#'
#' This will produce counts of various demographics.
#' It will also produce various summary statistics for episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' @seealso [calculate_measures()]
produce_source_cmh_tests <- function(data) {
  test_flags <- data %>%
    # create test flags
    create_demog_test_flags() %>%
    create_hb_test_flags(hb_var = .data$hbrescode) %>%
    dplyr::mutate(n_episodes = 1L) %>%
    # keep variables for comparison
    dplyr::select("unique_anon_chi":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max <- data %>%
    calculate_measures(
      vars = c("record_keydate1", "record_keydate2"),
      measure = "min-max"
    )

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
