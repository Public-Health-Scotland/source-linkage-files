#####################################################
# Draft pre processing code for Gp Out of Hours - Consultations
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
library(phsmethods)

## Load extracts ------------------------------------

# Diagnosis data
diagnosis_file <- readr::write_rds(
  paste0(
    get_year_dir(year = year),
    "/gp-diagnosis-data-20",
    year, ".rds"
  )
)

# Outcomes data
outcomes_file <- readr::read_rds(
  paste0(
    get_year_dir(year = year),
    "/gp-outcomes-data-20",
    year, ".rds"
  )
)


## Load extract file---------------------------------

year <- "1920"

# Read consultations data
consultations_file <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-c"),
  col_type = cols(
    `UPI Number [C]` = col_character(),
    `Patient DoB Date [C]` = col_date(format = "%Y/%m/%d %T"),
    `Gender` = col_double(),
    `Patient Postcode [C]` = col_character(),
    `Patient NHS Board Code 9 - current` = col_character(),
    `HSCP of Residence Code Current` = col_character(),
    `Patient Data Zone 2011` = col_character(),
    `Practice Code` = col_character(),
    `Practice NHS Board Code 9 - current` = col_character(),
    `GUID` = col_character(),
    `Consultation Recorded` = col_character(),
    `Consultation Start Date Time` = col_datetime(format = "%Y/%m/%d %H:%M:%S"),
    `Consultation End Date Time` = col_datetime(format = "%Y/%m/%d %H:%M:%S"),
    `Treatment Location Code` = col_character(),
    `Treatment Location Description` = col_character(),
    `Treatment NHS Board Code 9` = col_character(),
    `KIS Accessed` = col_character(),
    `Referral Source` = col_character(),
    `Consultation Type` = col_character()
  )
) %>%
  # rename variables
  rename(
    chi = `UPI Number [C]`,
    dob = `Patient DoB Date [C]`,
    gender = `Gender`,
    potcode = `Patient Postcode [C]`,
    hbrescode = `Patient NHS Board Code 9 - current`,
    hscp = `HSCP of Residence Code Current`,
    datazone = `Patient Data Zone 2011`,
    gpprac = `Practice Code`,
    guid = `GUID`,
    attendance_status = `Consultation Recorded`,
    record_keydate1 = `Consultation Start Date Time`,
    record_keydate2 = `Consultation End Date Time`,
    location = `Treatment Location Code`,
    location_description = `Treatment Location Description`,
    hbtreatcode = `Treatment NHS Board Code 9`,
    kis_accessed = `KIS Accessed`,
    refsource = `Referral Source`,
    smrtype = `Consultation Type`
  )


## Data Cleaning ------------------------------------

consultations_clean <- consultations_file %>%
  # Blank CHI is not useful for linkage - remove blanks
  filter(chi != "") %>%
  # Restore CHI leading zero
  mutate(chi = chi_pad(chi)) %>%
  # Some episodes are wrongly included.
  filter(record_keydate1 <= end_fy(year) & record_keydate2 >= start_fy(year)) %>%
  # Sort out any duplicates
  arrange(guid, chi, record_keydate1, record_keydate2) %>%
  # Flag duplicates and overlaps
  mutate(
    # Flag overlap
    overlap = if_else(record_keydate1 < lag(record_keydate2), 1, 0),
    # Flag duplicates
    duplicate = case_when(
      smrtype == lag(smrtype) & location == lag(location) ~ 1,
      record_keydate1 == lag(record_keydate1) & record_keydate2 == lag(record_keydate2) ~ 2,
      TRUE ~ 0
    )
  ) %>%
  # Get rid of obvious duplicates
  filter(duplicate != 2) %>%
  # Where it's a duplicate except for an overlapping time flag it.
  mutate(to_merge = if_else(overlap == 1 & duplicate == 1, 1, 0)) %>%
  # Repeat in the other direction so both records are flagged to be merged.
  #### CHECK HERE #### Is lead the right thing to do here in R to go the opposite direction?
  mutate(to_merge = if_else(
    guid == lead(guid) & chi == lead(chi) & record_keydate2 > record_keydate1 &
      smrtype == lead(smrtype) & location == lead(location), 1, to_merge)
    ) %>%
  # Create counters for unique consultations.
  arrange(guid, chi, record_keydate1, record_keydate2) %>%
  group_by(chi, guid) %>%
  mutate(
    counter = row_number()
  )



* Create counters for unique consultations.
sort cases by GUID CHI ConsultationStartDateTime ConsultationEndDateTime.

## Save Outfile -------------------------------------

outfile <- clean %>%
  select()

## Housekeeping -------------------------------------

# Delete TEMP files
# diagnosis
file.remove(paste0(
  get_year_dir(year = year),
  "/gp-diagnosis-data-20",
  year, ".rds"
))

# outcomes
file.remove(paste0(
  get_year_dir(year = year),
  "/gp-outcomes-data-20",
  year, ".rds"
))

# End of Script #
