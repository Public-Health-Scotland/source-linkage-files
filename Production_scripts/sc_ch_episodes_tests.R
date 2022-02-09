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
# Create new and old dataframes with measures for testing
new_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path()))
old_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path(update = previous_update())))

####################################################
# create tests
comparison <- produce_test_comparison(old_tests, new_tests)

# END OF SCRIPT
####################################################
