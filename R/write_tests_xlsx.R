#' Write tests as an xlsx workbook
#'
#' @param comparison_data produced by \code{\link{produce_test_comparison}}
#' @param name of dataset tests
#'
#' @return source_tests_path to the xlsx file location
#'
#' @export
#'
write_tests_xlsx <- function(comparison_data, name) {
  source_tests_path <- fs::path(get_slf_dir(), "Tests", glue::glue(latest_update(), "_tests.xlsx"))

  if (fs::file_exists(source_tests_path)) {
    # Load excel workbook
    wb <- openxlsx::loadWorkbook(source_tests_path)
  } else {
    # create excelworkbook
    wb <- openxlsx::createWorkbook()
  }

  # add a new sheet for tests
  openxlsx::addWorksheet(wb, name)
  # write comparison output to new sheet
  openxlsx::writeData(
    wb,
    name,
    comparison_data
  )
  # save output
  openxlsx::saveWorkbook(wb,
    source_tests_path,
    overwrite = TRUE
  )

  return(source_tests_path)
}
