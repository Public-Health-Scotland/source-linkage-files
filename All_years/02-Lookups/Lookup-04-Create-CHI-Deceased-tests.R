#Demographic Lookup tests
#Required functions:
# get_slf_dir
# latest_update
# previous_update
# read_deaths_file
# sum_flags
# demog_lookup_tests
# compare_tests

library(tidyselect)
library(dplyr)

####################################################
#Get demographic lookup data
new_deaths_file <- read_deaths_file(file)
old_deaths_file <- read_deaths_file(file, update = previous_update())

####################################################
#Create new and old dataframes with measures for testing
new_tests <- deaths_file_tests(new_deaths_file)
old_tests <- deaths_file_tests(old_deaths_file)

####################################################
#create tests
comparison <- compare_tests(old_tests, new_tests)

#END OF SCRIPT
####################################################
