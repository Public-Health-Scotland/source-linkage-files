####################################################
# Name of file - extract_prescribing_tests.R
# Original Authors - Jennifer Thom
# Original Date - July 2022
# Written/run on - RStudio Server
# Version of R - 3.6.1
# Description - Produce tests for source linkage files:
#               PIS processed file.
#####################################################

# Load packages
library(createslf)


# Read in Data-----------------------------------------

year <- check_year_format("1920")

# Read new data file
new_data <- readr::read_rds(get_source_extract_path(year, "PIS"))

# Read current SLF episode file and filter for the prescribing (PIS) records
existing_data <- get_existing_data_for_tests(new_data = new_data)


# Produce comparison-------------------------------------
# Compare new file with existing slf data
comparison <- produce_test_comparison(
  produce_source_pis_tests(existing_data),
  produce_source_pis_tests(new_data)
)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "PIS_extract")


## END OF SCRIPT ##
