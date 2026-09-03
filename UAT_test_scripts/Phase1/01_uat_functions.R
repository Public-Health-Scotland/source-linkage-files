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

get_name_list_lookup <- function() {
  uat_dir <- fs::path("/", "conf", "sourcedev", "Source_Linkage_File_Updates", "uat_testing", "1_source_data_views", "Lookups")
  file_name <- "uat_names.xlsx"
  path <- stringr::str_glue("{uat_dir}/{file_name}")

  return(path)
}

# Path to the pivoted data for homelessness_completeness_cached file
get_sg_homelessness_pub_pivoted_path <- function(...) {
  path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Homelessness"),
    file_name = "2025.11.05 - PHS - Total assessment decisions by LA by Qtr_pivoted.xlsx",
    ...
  )
  return(path)
}

# Path to the pivoted data for ooh_costs_cached file
get_gp_ooh_raw_costs_pivoted_path <- function(...) {
  gp_ooh_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("ooh_costs_pivoted.xlsx"),
    ...
  )
  return(gp_ooh_raw_costs_path)
}

# Path to the pivoted data for hc_costs_cached file
get_hc_raw_costs_pivoted_path <- function(...) {
  hc_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("hc_costs_pivoted.xlsx"),
    ...
  )
  return(hc_raw_costs_path)
}

# Path to the pivoted data for dn_costs_cached file
get_dn_raw_costs_pivoted_path <- function(...) {
  dn_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("dn_costs_pivoted.xlsx"),
    ...
  )
  return(dn_raw_costs_path)
}

# Path to the dn_contacts file
get_dn_contacts_path <- function(...) {
  dn_contacts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("DN-Contacts-Numbers-for-Costs.csv"),
    ...
  )
  return(dn_contacts_path)
}

## Main function to create test output.
create_uat_output <- function(dataset_name, boxi_data, sdl_data, denodo_vars) {
  # Create a tibble containing info on boxi cols
  boxi_cols <- tibble(
    date = Sys.Date(),
    dataset_name,
    cols = colnames(boxi_data),
    origin_boxi = "boxi",
    boxi_type = sapply(boxi_data, function(z) class(z)[1]),
    total_cols_boxi = ncol(boxi_data)
  )

  check_vars <- full_join(boxi_cols, denodo_vars, by = "cols") %>%
    # Create a flag to check if there are unused variables in the boxi extract
    mutate(
      not_used_boxi_extract = if_else((!is.na(cols) & is.na(denodo_name)), 1, 0),
      # if no denodo name available, use boxi name - dont want to drop variables here
      # should be the unused variables flagged above
      denodo_name = if_else(is.na(denodo_name), cols, denodo_name),
      # count number of boxi cols
      count = 1L,
      total_cols_boxi = sum(count),
      # count number of boxi cols not used
      total_unused_cols_boxi = sum(not_used_boxi_extract)
    ) %>%
    select(c("date", "dataset_name", "denodo_name", "origin_boxi", "boxi_type", "total_cols_boxi", "not_used_boxi_extract")) %>%
    rename(cols = "denodo_name")

  boxi_cols <- check_vars

  # Create a tibble containing info on sdl cols
  sdl_cols <- tibble(
    date = Sys.Date(),
    dataset_name,
    cols = colnames(sdl_data),
    origin_sdl = "sdl",
    sdl_type = sapply(sdl_data, function(z) class(z)[1]),
    total_cols_sdl = ncol(sdl_data)
  )

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

# Path to the gpprac cluster open data
get_gpprac_cluster_opendata <- function() {
  gp_cluster_data <- phsopendata::get_dataset(
    "gp-practice-contact-details-and-list-sizes"
  ) %>%
    janitor::clean_names() %>%
    dplyr::select(
      practice_code,
      gp_practice_name,
      postcode,
      gp_cluster,
      hb,
      hscp
    )

  return(gp_cluster_data)
}

# Path to the geography labels open data
get_geography_labels_opendata <- function() {
  geography_labels <- phsopendata::get_resource(
    "944765d7-d0d9-46a0-b377-abb3de51d08e",
    col_select = c(
      "HSCP",
      "HSCPName",
      "HB",
      "HBName"
    )
  ) %>%
    janitor::clean_names() %>%
    dplyr::select(
      hscp,
      hscp_name,
      hb,
      hb_name
    )

  return(geography_labels)
}


get_ch_costs_open_data <- function() {
  ch_costs_data <- phsopendata::get_resource(
    res_id = "4ee7dc84-ca65-455c-9e76-b614091f389f",
    col_select = c("Date", "KeyStatistic", "CA", "Value")
  )

  return(ch_costs_data)
}

get_sc_client_fy <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")){
# extract fy client data
client_fy_extract <- dplyr::tbl(sc_dvprod_connection, dbplyr::in_schema("social_care_2", "client_fy_snapshot")) %>%
 # dplyr::filter(.data$financial_year == year) %>%
  dplyr::select(
    "sending_location",
    "social_care_id",
    "financial_year",
    "financial_quarter",
    "dementia",
    "mental_health_problems",
    "learning_disability",
    "physical_and_sensory_disability",
    "drugs",
    "alcohol",
    "palliative_care",
    "carer",
    "elder_frail",
    "neurological_condition",
    "autism",
    "other_vulnerable_groups",
    "living_alone",
    "support_from_unpaid_carer",
    "social_worker",
    "type_of_housing",
    "meals",
    "day_care"
  ) %>%
  dplyr::collect(n = 100)

return(client_fy_extract)
}

get_sc_client_qtr <- function(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")){
# extract qtr client data
client_qtr_extract <- dplyr::tbl(sc_dvprod_connection, dbplyr::in_schema("social_care_2", "client_qtr_snapshot")) %>%
  #dplyr::filter(.data$financial_year == year) %>%
  dplyr::select(
    "sending_location",
    "social_care_id",
    "financial_year",
    "financial_quarter",
    "dementia",
    "mental_health_problems",
    "learning_disability",
    "physical_and_sensory_disability",
    "drugs",
    "alcohol",
    "palliative_care",
    "carer",
    "elder_frail",
    "neurological_condition",
    "autism",
    "other_vulnerable_groups",
    "living_alone",
    "support_from_unpaid_carer",
    "social_worker",
    "type_of_housing",
    "meals",
    "day_care"
  ) %>%
  dplyr::collect(n = 100)
}
