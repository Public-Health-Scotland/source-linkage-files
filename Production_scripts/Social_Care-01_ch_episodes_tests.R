####################################################

# Name of file - sc_ch_episodes_tests.R
# Original Authors - Jennifer Thom
# Original Date - January 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for social care - care home episodes file.

####################################################

# Packages
library(createslf)


# Read in Data---------------------------------------

# Create new and old dataframes with measures for testing
new_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path()))
old_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path(update = previous_update())))

# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save output as zsav for now
# Eventually change this to rds when we have more R scripts
haven::write_sav(comparison,
                 path(get_slf_dir(), "Social_care",
                      paste0("all_ch_episodes_", latest_update(), "_tests",
                             ext = ".zsav")
                 ),
                 compress = TRUE
)


## END OF SCRIPT ##
