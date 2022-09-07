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

new_data <- readr::read_rds(get_sc_ch_episodes_path())
existing_data <- readr::read_rds(get_sc_ch_episodes_path(update = previous_update()))


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(
  produce_sc_ch_episodes_tests(new_data),
  produce_sc_ch_episodes_tests(existing_data)
)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "all_ch")


## END OF SCRIPT ##
