####################################################

# Name of file - Lookup-01b-Postcode-tests.R
# Original Authors - Jennifer Thom
# Original Date - January 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for source linkage files
# postcode lookup file.

####################################################

# Packages
library(createslf)
library(openxlsx)


# Read in Data---------------------------------------

# Create new and old dataframes with measures for testing
new_tests <- produce_slf_postcode_tests(haven::read_sav(get_slf_postcode_path()))
old_tests <- produce_slf_postcode_tests(haven::read_sav(get_slf_postcode_path(update = previous_update())))


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
# Save output as zsav
# This can be removed once confirmed excel workbook is okay
haven::write_sav(comparison,
                 path(
                   get_slf_dir(), "Lookups",
                   paste0("source_postcode_lookup_", latest_update(), "_tests",
                          ext = ".zsav"
                   )
                 ),
                 compress = TRUE
)
## END OF SCRIPT ##
