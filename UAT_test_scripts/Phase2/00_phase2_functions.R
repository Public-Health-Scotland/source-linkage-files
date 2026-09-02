################################################################################
# Name of file - 00_phase2_functions.R
#
# Original Authors - Jennifer Thom
# Original Date - August 2026
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description: UAT test scrips - phase2 functions
#
#################################################################################

# set up phase 2 functions ---

##########################################

## Function for reading TEST file paths (June Update)

##########################################

get_slf_current_data_path <- function(year,
                                      type = c(
                                        "acute",
                                        "ae",
                                        "sc_alarms_tele",
                                        "sc_care_homes",
                                        "sc_client",
                                        "cmh",
                                        "delayed_discharges",
                                        "deaths",
                                        "dn",
                                        "gp_ooh",
                                        "sc_home_care",
                                        "homelessness",
                                        "maternity",
                                        "mental_health",
                                        "outpatients",
                                        "pis",
                                        "sc_sds"
                                      )) {
  file_path <- stringr::str_glue("/conf/hscdiip/June26 Update Files/{year}/")

  file_name <- dplyr::recode_values(
    type,
    "acute" ~ "anon-acute_for_source",
    "ae" ~ "anon-a_and_e_for_source",
    "sc_alarms_tele" ~ "anon-alarms-telecare-for-source",
    "sc_care_homes" ~ "anon-care_home_for_source",
    "cmh" ~ "anon-cmh_for_source",
    "sc_client" ~ "anon-client_for_source",
    "delayed_discharges" ~ "anon-delayed_discharge_for_source",
    "deaths" ~ "anon-deaths_for_source",
    "dn" ~ "anon-district_nursing_for_source",
    "gp_ooh" ~ "anon-gp_ooh_for_source",
    "sc_home_care" ~ "anon-home_care_for_source",
    "homelessness" ~ "anon-homelessness_for_source",
    "maternity" ~ "anon-maternity_for_source",
    "mental_health" ~ "anon-mental_health_for_source",
    "outpatients" ~ "anon-outpatients_for_source",
    "pis" ~ "anon-prescribing_file_for_source",
    "sc_sds" ~ "anon-sds-for-source"
  ) %>%
    stringr::str_glue("-20{year}.parquet")

  slf_current_path <- stringr::str_glue("{file_path}{file_name}")

  return(slf_current_path)
}


##########################################

## Main phase 2 function to create output

##########################################

create_phase2_output <- function(dataset_name, year, slf_current_data, sdl_wip_data) {
  ## Read data from June and SDL ------
  slf_current_cols <- tibble(
    date = Sys.Date(),
    dataset_name,
    year,
    cols = colnames(slf_current_data),
    origin_slf_current = "slf_current_data",
    slf_current_type = sapply(slf_current_data, function(z) class(z)[1]),
    total_cols_june = ncol(slf_current_data)
  )

  sdl_wip_cols <- tibble(
    date = Sys.Date(),
    dataset_name,
    year,
    cols = colnames(sdl_wip_data),
    origin_sdl_wip = "sdl_wip_data",
    sdl_wip_type = sapply(sdl_wip_data, function(z) class(z)[1]),
    total_cols_sdl = ncol(sdl_wip_data)
  )


  ## Compare outputs -------
  # Do a full join of both dataframes
  compare_output <- full_join(slf_current_cols, sdl_wip_cols, by = c("date", "dataset_name", "year", "cols")) %>%
    mutate(
      # How many columns match?
      cols_match = if_else(origin_slf_current == "slf_current_data" & origin_sdl_wip == "sdl_wip_data", 1, 0),
      # How many data types match?
      type_match = if_else(slf_current_type == sdl_wip_type, 1, 0),
      # How many new expected variables?
      # e.g. run_id and run_date_time
      expected_new_var = if_else(cols %in% c("run_id", "run_date_time"), 1, 0)
    ) %>%
    summarise(
      matching_cols = sum(cols_match, na.rm = TRUE),
      matching_datatypes = sum(type_match, na.rm = TRUE),
      expected_new_vars_in_sdl = sum(expected_new_var, na.rm = TRUE)
    )

  # Pivot to long format
  summary_long <- compare_output %>%
    pivot_longer(
      everything(),
      names_to = "measure",
      values_to = "value"
    ) %>%
    mutate(
      dataset = dataset_name,
      year = year
    ) %>%
    select(dataset, year, measure, value)


  ## Prepare June statistics --------
  slf_current_dataset <- slf_current_data %>%
    dplyr::mutate(n_records = 1L) %>%
    # Use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    # keep variables for comparison
    dplyr::select("n_records":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum") %>%
    # specify dataset name
    dplyr::mutate(
      dataset = dataset_name,
      year = year
    ) %>%
    relocate(c(dataset, year), .before = measure) %>%
    rbind(c(dataset = dataset_name, year = year, measure = "total_cols", value = ncol(slf_current_data))) %>%
    mutate(value = as.numeric(value))

  final_slf_current_data <- slf_current_dataset %>%
    bind_rows(summary_long) %>%
    rename(slf_current_value = value)


  ## Prepare SDL statistics ------
  sdl_wip_dataset <- sdl_wip_data %>%
    dplyr::mutate(n_records = 1L) %>%
    # Use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    # keep variables for comparison
    dplyr::select("n_records":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum") %>%
    # specify dataset name
    dplyr::mutate(
      dataset = dataset_name,
      year = year
    ) %>%
    relocate(c(dataset, year), .before = measure) %>%
    rbind(c(dataset = dataset_name, year = year, measure = "total_cols", value = ncol(sdl_wip_data))) %>%
    mutate(value = as.numeric(value))

  final_sdl_wip <- sdl_wip_dataset %>%
    bind_rows(summary_long) %>%
    rename(sdl_wip_value = value)


  ## Join statistics to create finalised dataframe ------
  join_datasets <- final_slf_current_data %>%
    left_join(final_sdl_wip, by = c("dataset", "year", "measure")) %>%
    dplyr::mutate(
      difference = round(sdl_wip_value - slf_current_value, digits = 2L),
      pct_change = (difference / slf_current_value),
      issue = !dplyr::between(.data$pct_change, -0.05, 0.05)
    )

  return(join_datasets)
}


##########################################

## Function for writing Phase 2 UAT tests to disk

##########################################

#### Function for writing uat tests to disk
write_phase2_tests <- function(phase2_uat_data, sheet_name, analyst) {
  tests_workbook_path <-
    stringr::str_glue("/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/4_dataset_testing/{analyst}/phase2_uat_tests.xlsx")

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
  sheet_name_dated <- substr(sheet_name_dated, 1, 31)

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
    cols = 2L:ncol(phase2_uat_data),
    widths = "auto"
  )

  status_col <- which(names(phase2_uat_data) == "issue")

  # # Apply conditional formatting to highlight issues
  openxlsx::conditionalFormatting(
    wb = wb,
    sheet = sheet_name_dated,
    cols = status_col,
    rows = 2L:(nrow(phase2_uat_data) + 1L),
    rule = "FALSE",
    type = "contains"
  )

  # Get the column numbers
  pct_change_col <- which(names(phase2_uat_data) == "pct_change")
  numeric_cols <- which(names(phase2_uat_data) %in% c("slf_current_value", "sdl_wip_value", "diff"))

  # Format the pct_change column as a percentage
  openxlsx::addStyle(
    wb = wb,
    sheet = sheet_name_dated,
    style = openxlsx::createStyle(numFmt = "0.0%"),
    cols = pct_change_col,
    rows = 2L:(nrow(phase2_uat_data) + 1L),
    gridExpand = TRUE
  )

  # Format the numeric columns with commas
  openxlsx::addStyle(
    wb = wb,
    sheet = sheet_name_dated,
    style = openxlsx::createStyle(numFmt = "#,##0"),
    cols = numeric_cols,
    rows = 2L:(nrow(phase2_uat_data) + 1L),
    gridExpand = TRUE
  )
  # write uat output to the new sheet
  openxlsx::writeDataTable(
    wb = wb,
    sheet = sheet_name_dated,
    x = phase2_uat_data,
    tableStyle = "TableStyleMedium19",
    withFilter = FALSE
  )

  # Reorder the sheets alphabetically
  sheet_names <- wb$sheet_names
  names(sheet_names) <- wb$sheetOrder

  openxlsx::worksheetOrder(wb) <- names(sort(sheet_names))

  # Write the data to the workbook on disk
  openxlsx::saveWorkbook(wb,
    tests_workbook_path,
    overwrite = TRUE
  )

  log_info(
    "UAT {dataset_name} written to {tests_workbook_path}"
  )

  if (fs::file_info(path = tests_workbook_path)$user == Sys.getenv("USER")) {
    # Set the correct permissions (read, write, execute)
    fs::file_chmod(path = tests_workbook_path, mode = "770")
    # change the owner so that hscdiip is the group owner.
    # use fs::group_ids() for checking
    fs::file_chown(path = tests_workbook_path, group_id = 3206)
  }
}
