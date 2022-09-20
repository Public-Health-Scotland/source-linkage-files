####################################################
# Name of file lookup_ltc_tests.R
# Original Authors - Zihao Li
# Original Date - September 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for source linkage files
# lookup ltc files
####################################################

# Packages
library(createslf)
library(openxlsx)

fyear <- "1920"


# Read in Data---------------------------------------

# Create new and old dataframes with measures for testing
new_tests <- produce_slf_ltc_tests(readr::read_rds(get_slf_ltc_path(fyear)))
old_tests <- produce_slf_ltc_tests(readr::read_rds(get_slf_ltc_path(update = previous_update()))) ## where is the old_update


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "all_deaths")

## END OF SCRIPT ##
