#' Process Delayed Discharges tests
#'
#' @description Takes the processed Delayed Discharges extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @param data a [tibble][tibble::tibble-package] of the processed data extract.
#' @param year the financial year of the extract in the format '1718'.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_delayed_discharges <- function(data, year) {

  data <- data %>%
    slfhelper::get_chi()

  old_data <- get_existing_data_for_tests(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_dd_tests(old_data),
    new_data = produce_source_dd_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "dd", year, workbook_name = "extract")

  return(comparison)
}

#' Delayed Discharges extract tests
#'
#' @description Produce tests for the delayed discharges extract.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' for creating test flags
#' @seealso calculate_measures
produce_source_dd_tests <- function(data) {
  test_flags <- data %>%
    dplyr::mutate(
      n_delay_episodes = 1L,
      code9_episodes = .data$primary_delay_reason == "9"
    ) %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    # keep variables for comparison
    dplyr::select(c("n_delay_episodes":dplyr::last_col())) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  return(test_flags)
}
