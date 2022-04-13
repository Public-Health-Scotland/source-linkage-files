#####################################################
# Draft pre processing code for Gp Out of Hours - Diagnosis
# Author: Jennifer Thom
# Date: April 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - GP-OoH-
#         # consultations-extract-.csv
#         # diagnosis-extract-.csv
#         # outcomes-extract-.csv
#
# Description - Preprocessing of GP out of hours raw BOXI file.
#              Tidy up file in line with SLF format
#              prior to processing.
#####################################################

# Load Packages
library(readr)
library(dplyr)
library(tidyverse)
library(createslf)


## Load Read code lookup----------------------------

## TODO - Put into function##
read_code_lookup <- haven::read_sav(
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "ReadCodeLookup.zsav"
)) %>%
  rename(
    readcode = "ReadCode",
    description = "Description")

## Load extract file---------------------------------

year <- "1920"

diagnosis_file <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-d"),
  col_type = cols(
    `GUID`= col_character(),
    `Diagnosis Code` = col_character(),
    `Diagnosis Description` = col_character()
  )) %>%
  # rename variables
  rename(
    guid = `GUID`,
    readcode = `Diagnosis Code`,
    description = `Diagnosis Description`
  )


## Join with Read Codes --------------------------

matched_data <- diagnosis_file %>%
  # Sort for matching
  arrange(readcode, description) %>%
  # create a new column for identifying files
  mutate(full_match = 1) %>%
  left_join(read_code_lookup, by = 'readcode')


## Data Cleaning ---------------------------------





## Save outfile----------------------------------------

outfile <- outcome_clean %>%
  select()

# TEMP zsav file
haven::write_sav(
  paste0(
    get_year_dir(year = year),
    "/gp-outcomes-data-20",
    year, ".zsav"
  )
)

# TEMP rds file
readr::write_rds(
  paste0(
    get_year_dir(year = year),
    "/gp-outcomes-data-20",
    year, ".rds"
  )
)

# End of Script #





