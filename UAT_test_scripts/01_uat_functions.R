################################################################################
# Name of file - 01_uat_functions.R
#
# Original Authors - Jennifer Thom
# Original Date - January 2026
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description: Functions used to support the UAT test scrips.
#
################################################################################

# function for file path
get_slf_variable_lookup <- function() {
  uat_dir <- fs::path("/", "conf", "sourcedev", "Source_Linkage_File_Updates", "uat_testing", "1_source_data_views", "Lookups")
  file_name <- "SLF_variable_lookup.xlsx"
  path <- stringr::str_glue("{uat_dir}/{file_name}")

  return(path)
}


## Main function to create test output.
create_uat_output <- function(dataset_name, boxi_data, sdl_data, denodo_vars) {
  # Create a tibble containing info on boxi cols
  boxi_cols <- tibble(
    date = Sys.Date(),
    dataset_name,
    cols = colnames(boxi_data),
    origin_boxi = "boxi",
    boxi_type = sapply(boxi_data, class),
    total_cols_boxi = ncol(boxi_data)
  )

  check_vars <- full_join(boxi_cols, denodo_vars, by = "cols") %>%
    # create a flag to drop those not matched
    mutate(
      keep = if_else(!is.na(denodo_name), 1, 0),
      # drop those that are not in the boxi dataset
      keep = if_else(is.na(origin_boxi), 0, keep)
    ) %>%
    filter(keep == 1) %>%
    mutate(total_cols_boxi = sum(keep)) %>%
    select(c("date", "dataset_name", "denodo_name", "origin_boxi", "boxi_type", "total_cols_boxi")) %>%
    rename(cols = "denodo_name")

  boxi_cols <- check_vars

  # Create a tibble containing info on sdl cols
  sdl_cols <- tibble(
    date = Sys.Date(),
    dataset_name,
    cols = colnames(sdl_data),
    origin_sdl = "sdl",
    sdl_type = sapply(sdl_data, class),
    total_cols_sdl = ncol(sdl_data)
  )
  # ) %>%
  #   # Denodo is calling an integer 'integer64' - correct this
  #   mutate(
  #     sdl_type = if_else(sdl_type == "integer64", "integer", sdl_type)
  #   )

  # Do a full join of both dataframes
  test_output <- full_join(boxi_cols, sdl_cols, by = c("date", "dataset_name", "cols")) %>%
    mutate(
      # Check - do the data types match?
      type_match = boxi_type == sdl_type,
      # Check - are the boxi cols present in the sdl view?
      is_boxi_in_sdl = case_when(
        origin_boxi != origin_sdl ~ "Yes",
        (origin_boxi == "boxi" & is.na(origin_sdl)) ~ "No - boxi not in sdl",
        (is.na(origin_boxi) & origin_sdl == "sdl") ~ "No - sdl not in boxi",
        TRUE ~ "No"
      ),
      # Check if names match boxi/sdl
      names_expected_in_sdl = if_else((origin_boxi == "boxi" & origin_sdl == "sdl"), "Yes", "No"),
      # Flag mismatching variables
      mismatched_col = if_else((is_boxi_in_sdl == "No - boxi not in sdl" |
        is_boxi_in_sdl == "No - sdl not in boxi"),
      1L, 0L
      ),
      # Check status
      test_status = case_when(
        (is_boxi_in_sdl == "No - boxi not in sdl" & is.na(origin_sdl) & origin_boxi == "boxi") ~ "FAIL: Missing in sdl view",
        (is_boxi_in_sdl == "No - sdl not in boxi" & is.na(origin_boxi) & origin_sdl == "sdl") ~ "FAIL: Missing in boxi view",
        names_expected_in_sdl == "No" ~ "FAIL: SDL names not as expected",
        !type_match ~ "FAIL: Data Type does not match",
        TRUE ~ "PASS"
      )
    )

  return(test_output)
}


#### Function for writing uat tests to disk
write_uat_tests <- function(uat_data, sheet_name, analyst) {
  tests_workbook_path <-
    stringr::str_glue("/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/1_source_data_views/{analyst}/uat_tests.xlsx")

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
  sheet_name_dated <- stringr::str_glue("{sheet_name}_{date_today}")

  # If there has already been a sheet created today, append the time
  if (sheet_name_dated %in% names(wb)) {
    sheet_name_dated <-
      paste0(sheet_name_dated, format(Sys.time(), "_%H%M"))
  }

  # Add new sheet
  openxlsx::addWorksheet(wb, sheet_name_dated)

  openxlsx::setColWidths(
    wb = wb,
    sheet = sheet_name_dated,
    cols = 2L:ncol(uat_data),
    widths = "auto"
  )

  status_col <- which(names(uat_data) == "test_status")

  # Apply conditional formatting to highlight issues
  openxlsx::conditionalFormatting(
    wb = wb,
    sheet = sheet_name_dated,
    cols = status_col,
    rows = 2L:(nrow(uat_data) + 1L),
    rule = "FAIL",
    type = "contains"
  )

  # write uat output to the new sheet
  openxlsx::writeDataTable(
    wb = wb,
    sheet = sheet_name_dated,
    x = uat_data,
    tableStyle = "TableStyleMedium19",
    withFilter = FALSE
  )

  # Write the data to the workbook on disk
  openxlsx::saveWorkbook(wb,
    tests_workbook_path,
    overwrite = TRUE
  )

  if (fs::file_info(path = tests_workbook_path)$user == Sys.getenv("USER")) {
    # Set the correct permissions (read, write, execute)
    fs::file_chmod(path = tests_workbook_path, mode = "770")
    # change the owner so that hscdiip is the group owner.
    # use fs::group_ids() for checking
    fs::file_chown(path = tests_workbook_path, group_id = 3206)
  }
}
