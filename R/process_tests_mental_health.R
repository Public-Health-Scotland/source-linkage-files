#' Process Mental Health tests
#'
#' @description This script takes the processed homelessness extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_mental_health <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  data <- apply_cost_uplift_extract(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_extract_tests(old_data),
    new_data = produce_source_extract_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "04b", year, workbook_name = "extract")

  return(comparison)
}
