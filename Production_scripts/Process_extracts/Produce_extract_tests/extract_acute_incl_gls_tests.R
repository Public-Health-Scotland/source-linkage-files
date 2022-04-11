####################################################

# Name of file - B01b-Acute-tests.R
# Original Authors - Jennifer Thom
# Original Date - March 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for source linkage files
# postcode lookup file.

#####################################################

# Load packages
library(createslf)
library(openxlsx)
library(slfhelper)


# Read in Data---------------------------------------

year <- "1920"

# Read current SLF episode file and filter for 01B and GLS records
slf_ep_1920 <- read_slf_episode("1920", recid = c("01B", "GLS")) %>%
  get_chi()


# Create new and old dataframes with measures for testing
# To compare new slf extract to current file in hscdiip
new_tests <- produce_source_acute_tests(readr::read_rds(get_source_extract_path(year, "Acute", ext = "rds")))

old_tests <- produce_source_acute_tests(slf_ep_1920)


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "acute_extract")


## END OF SCRIPT ##
