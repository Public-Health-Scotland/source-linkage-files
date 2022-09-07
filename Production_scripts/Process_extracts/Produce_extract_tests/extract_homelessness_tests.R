####################################################
# Name of file - extract_homelessness_tests.R
# Original Authors - Bateman McBride
# Original Date - July 2022
# Written/run on - RStudio Server
# Version of R - 3.6.1
# Description - Produce tests for source linkage files:
#               homelessness processed file.
#####################################################

# Load packages
library(createslf)

# Read in Data-----------------------------------------

year <- "1920"

# Read new data file
new_data <- readr::read_rds(get_source_extract_path(year, "Homelessness"))

# Read current SLF episode file and filter for homelessness records (recid HL1)
existing_data <- get_existing_data_for_tests(new_data = new_data)

# Produce comparison-------------------------------------
# Compare new file with existing slf data

comparison <- produce_test_comparison(
  produce_slf_homelessness_tests(existing_data),
  produce_slf_homelessness_tests(new_data)
)

# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "HL1")


## END OF SCRIPT ##
