#' Write tests as an xlsx workbook
#'
#' @param comparison_data produced by \code{\link{produce_test_comparison}}
#' @param name of dataset tests
#'
#' @return a workbook containing comparison tests with each dataset with a new tab
#' @export
#'
write_tests_xlsx <- function(comparison_data, name) {
  if (fs::file_exists(get_source_tests_path())) {
    # Load excel workbook
    wb <- loadWorkbook(get_source_tests_path())
  } else {
    if (!fs::file_exists(get_source_tests_path())) {
    # create excelworkbook
    wb <- createWorkbook()
  }}

  # add a new sheet for tests
  addWorksheet(wb, name) %>%
    # write comparison output to new sheet
    writeData(
      wb,
      name,
      comparison_data
    ) %>%
    # save output
    saveWorkbook(wb,
      get_source_tests_path(),
      overwrite = TRUE
    )
}
