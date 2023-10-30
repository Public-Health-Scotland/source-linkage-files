#' Process GP OOH tests
#'
#' @description This script takes the processed GP OOH extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_gp_ooh <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  if ("hscp" %in% names(data)) {
    data <- data %>%
      dplyr::rename("hscp2018" = "hscp")
  } else {
    data <- data
  }

  comparison <- produce_test_comparison(
    old_data = produce_source_extract_tests(old_data,
      sum_mean_vars = "cost"
    ),
    new_data = produce_source_extract_tests(data,
      sum_mean_vars = "cost"
    )
  ) %>%
    write_tests_xlsx(sheet_name = "GPOoH", year, workbook_name = "extract")

  return(comparison)
}
