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
years <- convert_year_to_fyyear(as.character(2017)) %>%
  purrr::set_names()


------------------------------------------------------
# Process Lookups
------------------------------------------------------
# Lookups/costs
process_lookups <- run_process_lookups()


------------------------------------------------------
# Process Social Care data
------------------------------------------------------
# Social Care
  # sc lookups
  # all files
process_social_care <- run_process_social_care()

------------------------------------------------------
# Process extracts
------------------------------------------------------
# Process data---------------------------------------

# Process data extracts and tests.
# Currently, this is set up to write to disk (we may not need this)
process_extracts<- run_process_extracts(years)

------------------------------------------------------
# Create Episode file
------------------------------------------------------

process_ep_file <- run_process_ep_file(years)

------------------------------------------------------
# Create Individual file
------------------------------------------------------


------------------------------------------------------
# Calculate Anon CHI
------------------------------------------------------
