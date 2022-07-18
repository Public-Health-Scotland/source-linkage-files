#' Write out Tests
#'
#' @description Write test output as an xlsx workbook, with a specific sheet
#' for each extract. The extract sheet will be dated with the current month and
#' day, which allows us to run the tests multiple times in the same update.
#'
#' @param comparison_data produced by [produce_test_comparison()]
#' @param sheet_name the name of the dataset, which will be used to create
#' the sheet name
#'
#' @return the path to the xlsx file location
#'
#' @export
#'
#' @family test functions
#' @seealso produce_test_comparison
write_tests_xlsx <- function(comparison_data, sheet_name) {


  # Set up the workbook -----------------------------------------------------

  source_tests_path <- fs::path(
    get_slf_dir(),
    "Tests",
    glue::glue(latest_update(), "_tests.xlsx")
  )

  if (fs::file_exists(source_tests_path)) {
    # Load the data from the existing workbook
    wb <- openxlsx::loadWorkbook(source_tests_path)
  } else {
    # Create a blank workbook object
    wb <- openxlsx::createWorkbook()
  }

  # add a new sheet for tests
  sheet_name_dated <- paste0(sheet_name, format(Sys.Date(), "_%d_%b"))

  # If there has already been a sheet created today, append the time
  if (sheet_name_dated %in% names(wb)) {
    sheet_name_dated <- paste0(sheet_name_dated, format(Sys.time(), "_%H%M"))
  }

  openxlsx::addWorksheet(wb, sheet_name_dated)

  # write test comparison output to the new sheet
  # Style it as a Data table for nice formatting
  openxlsx::writeDataTable(
    wb = wb,
    sheet = sheet_name_dated,
    x = comparison_data,
    tableStyle = "TableStyleLight1",
    withFilter = FALSE
  )


  # Formatting --------------------------------------------------------------

  # Get the column numbers
  pct_change_col <- which(names(comparison) == "pct_change")
  issue_col <- which(names(comparison) == "issue")
  numeric_cols <- which(names(comparison) %in% c("value_old", "value_new", "diff"))

  # Format the pct_chnange column as a percentage
  openxlsx::addStyle(
    wb = wb,
    sheet = sheet_name_dated,
    style = openxlsx::createStyle(numFmt = "0.0%"),
    cols = pct_change_col,
    rows = 2:(nrow(comparison_data) + 1),
    gridExpand = TRUE
  )

  # Format the numeric columns with commas
  openxlsx::addStyle(
    wb = wb,
    sheet = sheet_name_dated,
    style = openxlsx::createStyle(numFmt = "#,##0"),
    cols = numeric_cols,
    rows = 2:(nrow(comparison_data) + 1),
    gridExpand = TRUE
  )

  # Set the column widths - wider for the first (measure)
  openxlsx::setColWidths(
    wb = wb,
    sheet = sheet_name_dated,
    cols = 1,
    widths = 40
  )

  openxlsx::setColWidths(
    wb = wb,
    sheet = sheet_name_dated,
    cols = 2:ncol(comparison_data),
    widths = 15
  )

  # Apply conditional formatting to highlight issues
  openxlsx::conditionalFormatting(
    wb = wb,
    sheet = sheet_name_dated,
    cols = issue_col,
    rows = 2:(nrow(comparison_data) + 1),
    rule = "TRUE",
    type = "contains"
  )


  # Write workbook to disk --------------------------------------------------

  # Write the data to the workbook on disk
  openxlsx::saveWorkbook(wb,
    source_tests_path,
    overwrite = TRUE
  )

  if (fs::file_info(source_tests_path)$user == Sys.getenv("USER")) {
    # Set the correct permissions
    fs::file_chmod(path = source_tests_path, mode = "660")
  }

  return(source_tests_path)
}
