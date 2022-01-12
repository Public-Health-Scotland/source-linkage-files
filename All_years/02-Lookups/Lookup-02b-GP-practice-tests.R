#GP Practice Lookup tests
#Required functions:
  # get_slf_dir
  # latest_update
  # previous_update
  # read_lookups_dir
  #create_HB2019_flag
  #create_HSCP2018_flag
  #sum_flags
  #gpprac_lookup_tests
  #compare_tests

####################################################
#Get GP practice lookup data
new_gpprac_lookup <- read_lookups_dir("gpprac")
old_gpprac_lookup <- read_lookups_dir("gpprac", update = previous_update())

####################################################
#Create new and old dataframes with measures for testing
new_tests <- gpprac_lookup_tests(new_gpprac_lookup)
old_tests <- gpprac_lookup_tests(old_gpprac_lookup)

####################################################
#create tests
comparison <- compare_tests(old_tests, new_tests)

#END OF SCRIPT
####################################################
