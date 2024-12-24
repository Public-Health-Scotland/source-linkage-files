#'set up file names for tests
#' @param to_combine boolean type, whether to produce to-combine file path
#' @inheritParams write_tests_xlsx
setup_tests_file_name <- function(sheet_name,
                                  year = NULL,
                                  workbook_name = c("ep_file",
                                                    "indiv_file",
                                                    "lookup",
                                                    "extract",
                                                    "sandpit",
                                                    "cross_year"),
                                  to_combine = TRUE) {
  # Set up the workbook ----
  if (workbook_name == "ep_file") {
    tests_workbook_name <-
      stringr::str_glue(latest_update(), "_{year}_ep_file_tests")
  }
  if (workbook_name == "indiv_file") {
    tests_workbook_name <-
      stringr::str_glue(latest_update(), "_{year}_indiv_file_tests")
  }
  if (workbook_name == "lookup") {
    if (is.null(year)) {
      tests_workbook_name <-
        dplyr::if_else(
          to_combine,
          stringr::str_glue(
            latest_update(),
            "_lookups_tests_{sheet_name}_to_combine"
          ),
          stringr::str_glue(latest_update(), "_lookups_tests")
        )
    }
  }
  if (workbook_name == "sandpit") {
    tests_workbook_name <-
      stringr::str_glue(latest_update(), "_sandpit_extract_tests")
  }
  if (workbook_name == "cross_year") {
    if (is.null(year)) {
      tests_workbook_name <-
        stringr::str_glue(latest_update(), "_cross_year_tests")
    }
  }
  if (workbook_name == "extract") {
    tests_workbook_name <- dplyr::if_else(
      to_combine,
      stringr::str_glue(
        latest_update(),
        "_{year}_extract_tests_{sheet_name}_to_combine"
      ),
      stringr::str_glue(latest_update(), "_{year}_extract_tests")
    )
  }

  tests_to_combine = dplyr::if_else((workbook_name %in% c("extract", "lookup")) &
                                     to_combine,
                                   "to_combine",
                                   "")
  folder_path = fs::path(get_slf_dir(),
                         "Tests",
                         fy(),
                         qtr(),
                         tests_to_combine)
  if (!exists(folder_path)) {
    fs::dir_create(folder_path)
  }

  tests_workbook_path <- fs::path(folder_path,
                                  tests_workbook_name,
                                  ext = "xlsx")

  in_use_path <- fs::path(
    fs::path_dir(tests_workbook_path),
    stringr::str_glue("{tests_workbook_name}-IN-USE")
  )

  return(
    list(
      tests_workbook_name = tests_workbook_name,
      tests_workbook_path = tests_workbook_path,
      in_use_path = in_use_path
    )
  )
}

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
#' @param workbook_name Split up tests into 4 different workbooks for ease of
#' interpreting. Episode file, individual file, lookup and extract tests.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @family test functions
#' @seealso produce_test_comparison
write_tests_xlsx <- function(comparison_data,
                             sheet_name,
                             year = NULL,
                             workbook_name = c("ep_file",
                                               "indiv_file",
                                               "lookup",
                                               "extract",
                                               "sandpit",
                                               "cross_year")) {
  # Set up the workbook ----
  tests_file_name = setup_tests_file_name(sheet_name,
                                         year,
                                         workbook_name,
                                         to_combine = TRUE)

  tests_workbook_name = tests_file_name$tests_workbook_name
  tests_workbook_path = tests_file_name$tests_workbook_path
  in_use_path = tests_file_name$in_use_path

  # Check if the tests are in use (by another process)
  if (fs::file_exists(path = in_use_path)) {
    seconds <- 0L
    max_wait <- 300L

    cli::cli_progress_bar(type = "iterator",
                          format = "{cli::pb_spin} [{cli::pb_elapsed}] Waiting for {tests_workbook_name}...")
    while (fs::file_exists(path = in_use_path) &&
           seconds < max_wait) {
      # While the tests are in use (wait a random number of seconds from 1 to 30)
      cli::cli_progress_update()
      wait <- sample(x = 3L:15L, size = 1L)

      Sys.sleep(wait)
      seconds <- seconds + wait
    }
    cli::cli_progress_done()
  }

  # Final check to maybe avoid corrupting the workbook
  Sys.sleep(sample(x = 1L:3L, size = 1L))
  if (!fs::file_exists(path = in_use_path)) {
    fs::file_create(path = in_use_path)
  } else {
    cli::cli_abort(c(
      "i" = paste(
        "Did not write the ",
        ifelse(is.null(year), "", year),
        sheet_name,
        "tests to avoid corrupting the workbook."
      )
    ))
  }

  if (fs::file_exists(tests_workbook_path)) {
    # Load the data from the existing workbook
    wb <- openxlsx::loadWorkbook(tests_workbook_path)
  } else {
    # Create a blank workbook object
    wb <- openxlsx::createWorkbook()
  }

  # add a new sheet for tests
  date_today <- format(Sys.Date(), "%d_%b")

  date_today <- stringr::str_to_lower(date_today)

  sheet_name_dated <- ifelse(
    is.null(year),
    stringr::str_glue("{sheet_name}_{date_today}"),
    stringr::str_glue("{year}_{sheet_name}_{date_today}")
  )

  date_today <- stringr::str_to_lower(date_today)

  if (is.null(year)) {
    sheet_name_dated <- stringr::str_glue("{sheet_name}_{date_today}")
  } else {
    sheet_name_dated <-
      stringr::str_glue("{year}_{sheet_name}_{date_today}")
  }

  # If there has already been a sheet created today, append the time
  if (sheet_name_dated %in% names(wb)) {
    sheet_name_dated <-
      paste0(sheet_name_dated, format(Sys.time(), "_%H%M"))
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


  # Formatting ----

  # Get the column numbers
  pct_change_col <- which(names(comparison_data) == "pct_change")
  issue_col <- which(names(comparison_data) == "issue")
  numeric_cols <- which(names(comparison_data) %in% c("value_old", "value_new", "diff"))

  # Format the pct_change column as a percentage
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


  # Write workbook to disk ----

  # Reorder the sheets alphabetically
  sheet_names <- wb$sheet_names
  names(sheet_names) <- wb$sheetOrder

  openxlsx::worksheetOrder(wb) <- names(sort(sheet_names))

  # Write the data to the workbook on disk
  openxlsx::saveWorkbook(wb,
                         tests_workbook_path,
                         overwrite = TRUE)

  if (fs::file_info(path = tests_workbook_path)$user == Sys.getenv("USER")) {
    # Set the correct permissions
    fs::file_chmod(path = tests_workbook_path, mode = "660")
  }

  fs::file_delete(path = in_use_path)

  cli::cli_alert_success(
    "The tests for {year}{ifelse(is.null(year), '', '-')}{sheet_name} were written to {.file {fs::path_file(tests_workbook_path)}}"
  )

  return(comparison_data)
}

#' Combine split tests
#' @export
combine_tests <- function() {
  combine_lookup_tests()
  lapply(years_to_run(), combine_extracts_tests_year)
}


#' Combine lookup tests to one xlsx file
combine_lookup_tests <- function() {
  lookup_combined_path <- setup_tests_file_name(
    sheet_name = "",
    workbook_name = "lookup",
    to_combine = FALSE
  )$tests_workbook_path

  folder_path = setup_tests_file_name(
    sheet_name = "",
    workbook_name = "lookup",
    to_combine = TRUE
  )$tests_workbook_path %>%
    dirname()

  files <- list.files(path = folder_path,
                      pattern = "_to_combine.xlsx$",
                      full.names = TRUE)
  lookup_files <- files[grepl("lookup", files)]

  combine_multi_xlsx(file_list = lookup_files,
                     output_file = lookup_combined_path)
  cli::cli_alert_success(
    stringr::str_glue("Combined lookup tests successfully at {Sys.time()}")
  )
}

#' Combine year specific extract tests into one xlsx file by financial year
#' @param year specify which fyear to combine. Only allow one fyear.
combine_extracts_tests_year <- function(year){
  extract_combined_path = setup_tests_file_name(
    sheet_name = "",
    year = year,
    workbook_name = "extract",
    to_combine = FALSE
  )$tests_workbook_path

  folder_path = setup_tests_file_name(
    sheet_name = "",
    year = year,
    workbook_name = "extract",
    to_combine = TRUE
  )$tests_workbook_path %>%
    dirname()


  files <- list.files(path = folder_path,
                      pattern = "_to_combine.xlsx$",
                      full.names = TRUE)
  extract_files <- files[grepl("extract", files) &
                           grepl(year, files)]
  combine_multi_xlsx(file_list = extract_files,
                     output_file = extract_combined_path)
  cli::cli_alert_success(
    stringr::str_glue("Combined {year} extract tests successfully at {Sys.time()}")
  )

}

#' Combine xlsx files into one xlsx file
#' @param file_list a list of files path to combine
#' @param output_file a output file path
combine_multi_xlsx <- function(file_list, output_file) {
  wb <- openxlsx::createWorkbook()

  for (file in file_list) {
    sheet_names <- openxlsx::getSheetNames(file)
    for (sheet_name in sheet_names) {
      data <- openxlsx::read.xlsx(file, sheet = sheet_name)
      openxlsx::addWorksheet(wb, sheet_name)
      openxlsx::writeData(wb, sheet_name, data)
    }
    openxlsx::saveWorkbook(wb, output_file, overwrite = TRUE)
  }
}
