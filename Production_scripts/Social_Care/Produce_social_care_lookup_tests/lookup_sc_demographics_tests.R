####################################################

# Name of file - Lookup-05-Social_Care_Demographics-tests.R
# Original Authors - Jennifer Thom
# Original Date - January 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for social care demographic lookup file.

####################################################

# Packages
library(createslf)
library(openxlsx)


# Read in Data---------------------------------------

# Create new and old dataframes with measures for testing
new_tests <- produce_sc_demog_lookup_tests(readr::read_rds(get_sc_demog_lookup_path()))
old_tests <- produce_sc_demog_lookup_tests(readr::read_rds(get_sc_demog_lookup_path(update = previous_update())))


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "sc_demographics")

## END OF SCRIPT ##
