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
# Create new and old dataframes with measures for testing
new_tests <- produce_sc_demog_lookup_tests(haven::read_sav(get_sc_demog_lookup_path()))
old_tests <- produce_sc_demog_lookup_tests(haven::read_sav(get_sc_demog_lookup_path(update = previous_update())))

####################################################
# create tests
comparison <- produce_test_comparison(old_tests, new_tests)

# Save output as zsav for now
# Eventually change this to rds when we have more R scripts
haven::write_sav(comparison,
                 path = glue::glue("/conf/hscdiip/SLF_Extracts/Social_care/sc_demographics_lookup_{latest_update()}_tests.zsav",
                                   compress = TRUE)
)

# END OF SCRIPT
####################################################
