####################################################
# Name of file - extract_nrs_tests.R
# Original Authors - Bateman McBride
# Original Date - July 2022
# Written/run on - RStudio Server
# Version of R - 3.6.1
# Description - Produce tests for source linkage files:
#               acute processed file.
#####################################################

# Load packages
library(createslf)

# Read in Data-----------------------------------------

year <- "1920"

# Read new data file
new_data <- readr::read_rds(get_source_extract_path(year, "Deaths"))

# Read current SLF episode file and filter for 01B and GLS records
existing_data <- get_existing_data_for_tests(new_data = new_data)


# Produce comparison-------------------------------------
# Compare new file with existing slf data
comparison <- produce_test_comparison(
  produce_nrs_extract_tests(existing_data),
  produce_nrs_extract_tests(new_data)
)

# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "deaths_extract")


## END OF SCRIPT ##
