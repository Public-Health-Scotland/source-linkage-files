#####################################################
# Draft pre processing code for Gp Out of Hours - Outcomes
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
library(tidyr)


## Load extract file---------------------------------

year <- "1920"

outcome_file <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-o"),
  col_type = cols(
    `GUID`= col_character(),
    `Case Outcome` = col_character()
  )) %>%
  # rename variables
  rename(
    guid = `GUID`,
    outcome = `Case Outcome`
  )


## Data Cleaning -----------------------------------

outcome_clean <- outcome_file %>%
  # Remove blank outcomes
  filter(outcome != "") %>%
  # Recode outcome
  mutate(
    outcome = recode(outcome,
              "DEATH" = "00",
              "999/AMBULANCE" = "01",
              "EMERGENCY ADMISSION" = "02",
              "ADVISED TO CONTACT OWN GP SURGERY/GP TO CONTACT PATIENT" = "03",
              "TREATMENT COMPLETED AT OOH/DISCHARGED/NO FOLLOW-UP" = "98",
              "REFERRED TO A&E" = "21",
              "REFERRED TO CPN/DISTRICT NURSE/MIDWIFE" = "22",
              "REFERRED TO MIU" = "21",
              "REFERRED TO SOCIAL SERVICES" = "24",
              "OTHER HC REFERRAL/ADVISED TO CONTACT OTHER HCP (NON-EMERGENCY)" = "29",
              "OTHER" = "99")
  ) %>%
  # Sort for identifying duplicates
  arrange(guid, outcome) %>%
  # Flag duplicates
  # CHECK here - top row returns NA
  mutate(duplicate = if_else(guid == lag(guid) & outcome == lag(outcome), 1, 0)) %>%
  # Remove duplicates
  filter(duplicate == 0) %>%
  # group for getting row order
  group_by(guid) %>%
  mutate(row_order = row_number()) %>%
  # use row order to pivot outcomes
  pivot_wider(
    id_cols = guid,
    names_from = row_order,
    names_prefix = "outcome_",
    values_from = outcome
  ) %>%
  ungroup()


## Save outfile----------------------------------------

outfile <- outcome_clean %>%
  select(
    guid,
    outcome_1,
    outcome_2,
    outcome_3,
    outcome_4
  )

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
