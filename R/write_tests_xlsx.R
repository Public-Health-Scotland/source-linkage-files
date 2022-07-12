#' Write out Tests
#'
#' @description Write test output as an xlsx workbook, specific sheet for each extract
#'
#' @param comparison_data produced by [produce_test_comparison()]
#' @param sheet_name the name of the dataset - this will be used as the sheet name
#'
#' @return source_tests_path to the xlsx file location
#'
#' @export
#'
#' @family test functions
#' @seealso produce_test_comparison
write_tests_xlsx <- function(comparison_data, sheet_name) {
  source_tests_path <- fs::path(get_slf_dir(), "Tests", glue::glue(latest_update(), "_tests.xlsx"))

  if (fs::file_exists(source_tests_path)) {
    # Load the data from the existing workbook
    wb <- openxlsx::loadWorkbook(source_tests_path)
  } else {
    # Create a blank workbook object
    wb <- openxlsx::createWorkbook()

    # Create a dummy file
    fs::file_touch(path = source_tests_path)
    # Set the correct permissions
    fs::file_chmod(path = source_tests_path, mode = "660")
  }

  # add a new sheet for tests
  sheet_name_dated <- paste0(sheet_name, "-", format(Sys.Date(), "%d %b"))
  openxlsx::addWorksheet(wb, sheet_name_dated)

  # write test comparison output to the new sheet
  openxlsx::writeData(
    wb,
    sheet_name_dated,
    comparison_data
  )

  # Write the data to the workbook on disk
  openxlsx::saveWorkbook(wb,
    source_tests_path,
    overwrite = TRUE
  )

  return(source_tests_path)
}
