#Demographic Lookup tests
#Required functions:
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
#Get demographic lookup data
new_demog_lookup <- read_demog_lookup(file)
old_demog_lookup <- read_demog_lookup(file, update = previous_update())

####################################################
#Create new and old dataframes with measures for testing
new_tests <- demog_lookup_tests(new_demog_lookup)
old_tests <- demog_lookup_tests(old_demog_lookup)

####################################################
#create tests
comparison <- compare_tests(old_tests, new_tests)

#END OF SCRIPT
####################################################
