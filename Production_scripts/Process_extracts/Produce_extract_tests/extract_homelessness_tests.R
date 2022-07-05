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
library(openxlsx)
library(slfhelper)


# Read in Data-----------------------------------------

year <- "1920"

# Read new data file
new_data <- readr::read_rds(get_source_extract_path(year, "Homelessness", ext = "rds"))

# Read current SLF episode file and filter for 01B and GLS records
existing_data <- read_slf_episode(year, recid = "02B") %>%
  rename(chi = anon_chi)


# Produce comparison-------------------------------------
# Compare new file with existing slf data
comparison <- produce_test_comparison(
  produce_source_extract_tests(existing_data),
  produce_source_extract_tests(new_data)
)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "maternity_extract")


## END OF SCRIPT ##
