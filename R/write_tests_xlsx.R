#' Write out Tests
#'
#' @description Write test output as an xlsx workbook, with a specific sheet
#' for each extract. The extract sheet will be dated with the current month and
#' day, which allows us to run the tests multiple times in the same update.
#'
#' @param comparison_data produced by [produce_test_comparison()]
#' @param sheet_name the name of the dataset, which will be used to create
#' the sheet name
#' @param year If applicable, the financial year of the data in '1920' format
#' this will be prepended to the sheet name. The default is `NULL`.
#'
#' @return the path to the xlsx file location
#'
#' @export
#'
#' @family test functions
#' @seealso produce_test_comparison
write_tests_xlsx <- function(comparison_data, sheet_name, year = NULL) {
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
  date_today <- format(Sys.Date(), "%d_%b")
  sheet_name_dated <- ifelse(
    is.null(year),
    glue::glue("{sheet_name}_{date_today}"),
    glue::glue("{year}_{sheet_name}_{date_today}")
  )

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
  pct_change_col <- which(names(comparison_data) == "pct_change")
  issue_col <- which(names(comparison_data) == "issue")
  numeric_cols <- which(names(comparison_data) %in% c("value_old", "value_new", "diff"))

  # Format the pct_chnange column as a percentage
  openxlsx::addStyle(
    wb = wb,
    sheet = sheet_name_dated,
    style = openxlsx::createStyle(numFmt = "0.0%"),
    cols = pct_change_col,
    rows = 2L:(nrow(comparison_data) + 1L),
    gridExpand = TRUE
  )

  # Format the numeric columns with commas
  openxlsx::addStyle(
    wb = wb,
    sheet = sheet_name_dated,
    style = openxlsx::createStyle(numFmt = "#,##0"),
    cols = numeric_cols,
    rows = 2L:(nrow(comparison_data) + 1L),
    gridExpand = TRUE
  )

  # Set the column widths - wider for the first (measure)
  openxlsx::setColWidths(
    wb = wb,
    sheet = sheet_name_dated,
    cols = 1L,
    widths = 40L
  )

  openxlsx::setColWidths(
    wb = wb,
    sheet = sheet_name_dated,
    cols = 2L:ncol(comparison_data),
    widths = 15L
  )

  # Apply conditional formatting to highlight issues
  openxlsx::conditionalFormatting(
    wb = wb,
    sheet = sheet_name_dated,
    cols = issue_col,
    rows = 2L:(nrow(comparison_data) + 1L),
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