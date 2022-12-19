#' Process Alarms Telecare tests
#'
#' @description This script takes the processed Alarms Telecare extract and produces
#' a test comparison with the previous data. This is written to disk as a csv.
#'
#' @param data The processed data extract
#' @param year year of extract
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#' @export
#'
process_tests_alarms_telecare <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_at_tests(old_data),
    new_data = produce_source_at_tests(data)
  )

  comparison %>%
    write_tests_xlsx(sheet_name = "AT", year)

  return(comparison)
}