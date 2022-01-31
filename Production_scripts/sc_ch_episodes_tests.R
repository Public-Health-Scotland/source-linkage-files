# all ch episode tests
# Required functions:
# get_slf_dir
# latest_update
# previous_update
# read_demog_tests
# sum_flags
# demog_lookup_tests
# compare_tests

library(tidyselect)
library(dplyr)

####################################################
# Create new and old dataframes with measures for testing
new_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path()))
old_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path(update = previous_update())))

####################################################
# create tests
comparison <- produce_test_comparison(old_tests, new_tests)

# END OF SCRIPT
####################################################
