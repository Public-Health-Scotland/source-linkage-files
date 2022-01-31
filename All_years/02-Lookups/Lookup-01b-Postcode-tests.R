# Postcode Lookup tests
# Required functions:
# get_slf_dir
# latest_update
# previous_update
# read_lookups_dir
# create_HB2019_flag
# create_HSCP2018_flag
# sum_flags
# gpprac_lookup_tests
# compare_tests

####################################################
# Create new and old dataframes with measures for testing
new_tests <- produce_slf_postcode_tests(haven::read_sav(get_slf_postcode_path()))
old_tests <- produce_slf_postcode_tests(haven::read_sav(get_slf_postcode_path(update = previous_update())))

####################################################
# create tests
comparison <- produce_test_comparison(old_tests, new_tests)

# END OF SCRIPT
####################################################
