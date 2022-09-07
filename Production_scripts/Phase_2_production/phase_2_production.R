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
# PHASE 1 - process extracts
------------------------------------------------------
# Process data---------------------------------------

# Process data extracts and tests.
# Currently, this is set up to write to disk (we may not need this)
run_phase_1_processing(select_years_to_run)

------------------------------------------------------
# PHASE 2 - Create Episode file
------------------------------------------------------

run_phase_2_processing(select_years_to_run)

------------------------------------------------------
# PHASE 3 - Create Individual file
------------------------------------------------------


------------------------------------------------------
# PHASE 1 - Calculate Anon CHI
------------------------------------------------------
