####################################################
# Name of file - produce-outpatients-tests.R
# Original Authors - Jennifer Thom
# Original Date - May 2022
# Written/run on - RStudio Server
# Version of R - 3.6.1
# Description - Produce tests for source linkage files:
#               acute processed file.
#####################################################

# Load packages
library(createslf)
library(openxlsx)
library(slfhelper)


# Read in Data-----------------------------------------

year <- "1920"

# Read new data file
new_data <- haven::read_sav(get_source_extract_path(year, "Outpatients", ext = "zsav"))

# Read current SLF episode file and filter for 01B and GLS records
existing_data <- read_slf_episode("1920", recid = "00B", columns = c("anon_chi", names(new_data))) %>%
  rename(chi = anon_chi)


# Produce comparison-------------------------------------
# Compare new file with existing slf data
comparison <- produce_test_comparison(
  produce_source_acute_tests(existing_data),
  produce_source_acute_tests(new_data)
)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "outpatients_extract")


## END OF SCRIPT ##
