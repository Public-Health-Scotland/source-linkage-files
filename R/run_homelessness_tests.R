#' Run homelessness tests
#'
#' @param data
#' @param year
#'
#' @return
#' @export
#'
#' @examples
run_homelessness_tests <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_slf_homelessness_tests(data),
    new_data = produce_slf_homelessness_tests(old_data)
  ) %>%
    write_tests_xlsx(sheet_name = "homelessness")
}
