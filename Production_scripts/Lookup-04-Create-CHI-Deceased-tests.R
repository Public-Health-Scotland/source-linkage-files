####################################################

# Name of file - Lookup-04-Create-CHI-Deceased-tests.R
# Original Authors - Jennifer Thom
# Original Date - January 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for source linkage files
# Deaths lookup file.


####################################################

# Packages
library(createslf)


# Read in Data---------------------------------------

# Create new and old dataframes with measures for testing
new_tests <- produce_slf_deaths_tests(haven::read_sav(get_slf_deaths_path()))
old_tests <- produce_slf_deaths_tests(haven::read_sav(get_slf_deaths_path(update = previous_update())))


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save output as zsav for now
# Eventually change this to rds when we have more R scripts
haven::write_sav(comparison,
                 path(get_slf_dir(), "Deaths",
                 paste0("all_deaths_", latest_update(), "_tests",
                 ext = ".zsav")
                 ),
                 compress = TRUE
)


## END OF SCRIPT ##
