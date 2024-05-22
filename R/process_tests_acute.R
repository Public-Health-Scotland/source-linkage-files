#' Process Acute tests
#'
#' @description Takes the processed Acute extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @param data a [tibble][tibble::tibble-package] of the processed data extract.
#' @param year the financial year of the extract in the format '1718'.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_acute <- function(data, year) {

  data <- data %>%
    slfhelper::get_chi()

  old_data <- get_existing_data_for_tests(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_extract_tests(old_data),
    new_data = produce_source_extract_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "01b", year, workbook_name = "extract")

  return(comparison)
}
