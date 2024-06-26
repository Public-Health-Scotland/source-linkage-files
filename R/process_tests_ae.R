#' Process A&E tests
#'
#' @description This script takes the processed A&E extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_ae <- function(data, year) {
  data <- data %>%
    slfhelper::get_chi()

  old_data <- get_existing_data_for_tests(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_extract_tests(old_data,
      sum_mean_vars = "cost",
      max_min_vars = c("record_keydate1", "record_keydate2", "cost_total_net")
    ),
    new_data = produce_source_extract_tests(data,
      sum_mean_vars = "cost",
      max_min_vars = c("record_keydate1", "record_keydate2", "cost_total_net")
    )
  ) %>%
    write_tests_xlsx(sheet_name = "ae2", year, workbook_name = "extract")

  return(comparison)
}
