#' Process homelessness tests
#'
#' @description This script takes the processed homelessness extract and produces
#' a test comparison with the previous data. This is written to disk as a csv.
#'
#' @param data The processed data extract
#' @param year year of extract
#'
#' @return a csv document containing tests for extracts
#' @export
#'
process_tests_homelessness <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_slf_homelessness_tests(old_data),
    new_data = produce_slf_homelessness_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "HL1", year)
}
