####################################################
# Name of file - Lookup-02b-GP-practice-tests.R
# Original Authors - Jennifer Thom
# Original Date - January 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for source linkage files
# gp practice lookup file.
####################################################

# Packages
library(createslf)
library(openxlsx)


# Read in Data---------------------------------------

# Create new and old dataframes with measures for testing
new_tests <- produce_slf_gpprac_tests(haven::read_sav(get_slf_gpprac_path()))
old_tests <- produce_slf_gpprac_tests(haven::read_sav(get_slf_gpprac_path(update = previous_update())))


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "source_gpprac_lookup")

## END OF SCRIPT ##
