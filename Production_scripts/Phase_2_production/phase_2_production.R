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
# Use set_names so that any returned list will be named.
select_years_to_run <- convert_year_to_fyyear(as.character(2020:2021)) %>%
  purrr::set_names()


------------------------------------------------------
# PHASE 1a - Process Lookups
------------------------------------------------------
# Lookups/costs

run_process_1a_lookups(select_years_to_run)


------------------------------------------------------
  # PHASE 1b - Process Costs
------------------------------------------------------
run_process_1b_costs(select_years_to_run)


------------------------------------------------------
# PHASE 1c - Process Social Care data
------------------------------------------------------
# Social Care
  # sc lookups
  # all files
run_process_1c_social_care(select_years_to_run)

------------------------------------------------------
# PHASE 2 - process extracts
------------------------------------------------------
# Process data---------------------------------------

# Process data extracts and tests.
# Currently, this is set up to write to disk (we may not need this)
run_process_2_extracts(select_years_to_run)

------------------------------------------------------
# PHASE 3 - Create Episode file
------------------------------------------------------

run_phase_2_processing(select_years_to_run)

------------------------------------------------------
# PHASE 4 - Create Individual file
------------------------------------------------------


------------------------------------------------------
# PHASE 5 - Calculate Anon CHI
------------------------------------------------------
