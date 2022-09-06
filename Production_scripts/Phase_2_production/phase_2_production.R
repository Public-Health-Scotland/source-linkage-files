#####################################################
# Draft production code for phase 2 processing
# Author: Jennifer Thom
# Date: August 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - homelessness.csv
# Description - production code for phase 2 processing.
#
#####################################################

# Load packages
library(createslf)

year <- "2021"

# Below is from Homelessness processing
# Create a list of the years to run
# Use set_names so that any returned list will be named.
years_to_run <- convert_year_to_fyyear(as.character(2020:2021)) %>%
  purrr::set_names()

------------------------------------------------------
# PHASE 1 - process extracts
------------------------------------------------------
# Process data---------------------------------------
# Pass the data to process phase for data cleaning

# Below is from homelessness processing
# Only write to disk (for a standard SLF run)
#purrr::walk(
#  years_to_run,
#  process_data_extracts
#)

# Keep the data but don't write to disk (for testing)
test_data <- purrr::map(
  years_to_run,
  process_data_extracts
)

# Test with homelessness and mental health extracts - working
# This reads in the data and processes ready for SLF episode file
process_data_extracts(year)

------------------------------------------------------
# PHASE 2 - Create Episode file
------------------------------------------------------

read_cs

------------------------------------------------------
# PHASE 3 - Create Individual file
------------------------------------------------------

  data <- tibble(x = 1:10, y = 11:20)
test_data <- list(
  "1920" = list("homelessness" = data,
                "mental_health" = data),
  "2021" = list("homelessness" = data,
                "mental_health" = data)
)
run_homelessness_tests <- function(data, year) {
  old_data <- createslf::get_existing_data_for_tests(data)
  createslf::produce_test_comparison(
    old_data = createslf::produce_slf_homelessness_tests(data),
    new_data = createslf::produce_slf_homelessness_tests(old_data)
  ) %>%
    createslf::write_tests_xlsx(sheet_name = "homelessness", year = year)
}
run_tests <- function(data_list, year) {
  if (year > "2016") {
    run_homelessness_tests(data_list[["homelessness"]], year)
  }
  run_mental_health_tests(data_list[["mental_health"]], year)
}
purrr::iwalk(test_data, run_tests)
------------------------------------------------------
# PHASE 1 - Calculate Anon CHI
------------------------------------------------------
