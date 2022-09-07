#' Run mental health tests
#'
#' @param data
#' @param year Year of extract
#'
#' @return
#' @export
#'
#' @examples
process_mental_health_tests <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_extract_tests(data),
    new_data = produce_source_extract_tests(old_data)
  ) %>%
    write_tests_xlsx(sheet_name = "04B", year)
}
