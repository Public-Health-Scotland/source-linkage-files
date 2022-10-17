#####################################################
# Draft production code for phase 2 processing
# Author: Jennifer Thom
# Date: August 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - homelessness.csv
# Description - production code for phase 2 processing.
#
#####################################################

# Load packages
library(createslf)

# Specify one year for testing
year <- "2021"

# Create a list of the years to run
years <- convert_year_to_fyyear(as.character(2020:2021)) %>%
  purrr::set_names()


------------------------------------------------------
# Process Lookups
------------------------------------------------------
# Lookups/costs
run_process_lookups(years)


------------------------------------------------------
# Process Social Care data
------------------------------------------------------
# Social Care
  # sc lookups
  # all files
run_process_social_care(years)

------------------------------------------------------
# Process extracts
------------------------------------------------------
# Process data---------------------------------------

# Process data extracts and tests.
# Currently, this is set up to write to disk (we may not need this)
run_process_extracts(years)

------------------------------------------------------
# Create Episode file
------------------------------------------------------

run_process_ep_file(years)

------------------------------------------------------
# Create Individual file
------------------------------------------------------


------------------------------------------------------
# PHASE 5 - Calculate Anon CHI
------------------------------------------------------
