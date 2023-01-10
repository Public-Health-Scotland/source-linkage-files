#' Process Care Home tests
#'
#' @description This script takes the processed Care home extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_care_home <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_ch_tests(old_data),
    new_data = produce_source_ch_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "CH", year)

  return(comparison)
}
