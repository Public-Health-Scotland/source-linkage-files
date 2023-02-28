#' Process Episode file tests
#'
#' @description Takes the processed episode file and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @param data a [tibble][tibble::tibble-package] of the episode file.
#' @param year the financial year of the extract in the format '1718'.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_episode_file <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  comparison <- produce_test_comparison(
    old_data = produce_episode_file_tests(old_data),
    new_data = produce_episode_file_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "ep_file", year)

  return(comparison)
}
