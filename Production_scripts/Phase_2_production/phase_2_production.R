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

year <- "1920"

# Create a list of the years to run
# Use set_names so that any returned list will be named.
years_to_run <- convert_year_to_fyyear(as.character(2017:2021)) %>%
  purrr::set_names()

------------------------------------------------------
# PHASE 1 - process extracts
------------------------------------------------------
# Process data---------------------------------------
# Pass the data to process phase for data cleaning

# Only write to disk (for a standard SLF run)
purrr::walk(
  years_to_run,
  process_homelessness_extract
)

test <- process_data_extracts(year)

------------------------------------------------------
# PHASE 2 - Create Episode file
------------------------------------------------------



------------------------------------------------------
# PHASE 3 - Create Individual file
------------------------------------------------------


------------------------------------------------------
# PHASE 1 - Calculate Anon CHI
------------------------------------------------------
