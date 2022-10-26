####################################################
# Name of file - extract_district_nursing_tests.R
# Original Authors - Zihao Li
# Original Date - October 2022
# Written/run on - RStudio Server
# Version of R - 3.6.1
# Description - Produce tests for district nursing:
#               district nursing processed file.
#####################################################

# Load packages
library(createslf)


# Read in Data-----------------------------------------

year <- check_year_format("1920")

# Read new data file
# new_data <- readr::read_rds(get_source_extract_path(year, "DN"))
new_data <-
  haven::read_spss("/conf/sourcedev/Source_Linkage_File_Updates/1920/DN_for_source-201920.zsav") %>%
  dplyr::rename(year = Year)

# Read current SLF episode file and filter for CH
existing_data <- get_existing_data_for_tests(new_data = new_data)


# Produce comparison-------------------------------------
# Compare new file with existing slf data
comparison <- produce_test_comparison(
  produce_source_dn_tests(existing_data),
  produce_source_dn_tests(new_data)
)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "DN", year)


## END OF SCRIPT ##
