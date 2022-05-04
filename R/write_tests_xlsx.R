#' Write tests as an xlsx workbook
#'
#' @param comparison_data produced by \code{\link{produce_test_comparison}}
#' @param sheet_name the name of the dataset - this will be used as the sheet name
#'
#' @return source_tests_path to the xlsx file location
#'
#' @export
write_tests_xlsx <- function(comparison_data, sheet_name) {
  source_tests_path <- fs::path(get_slf_dir(), "Tests", glue::glue(latest_update(), "_tests.xlsx"))

  if (fs::file_exists(source_tests_path)) {
    # Load excel workbook
    wb <- openxlsx::loadWorkbook(source_tests_path)
  } else {
    # create excelworkbook
    wb <- openxlsx::createWorkbook()
  }

  sheet_name_dated <- paste0(sheet_name, "-", format(Sys.Date(), "%d %b"))

  # add a new sheet for tests
  openxlsx::addWorksheet(wb, sheet_name_dated)
  # write comparison output to new sheet
  openxlsx::writeData(
    wb,
    sheet_name_dated,
    comparison_data
  )
  # save output
  openxlsx::saveWorkbook(wb,
    source_tests_path,
    overwrite = TRUE
  )

  return(source_tests_path)
}
