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
library(lubridate)
library(hms)


# Specify year
year <- "1920"


## Diagnosis data  ------------------------------------

# Load Read code lookup
read_code_lookup <- haven::read_sav(
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "ReadCodeLookup.zsav"
  )
) %>%
  rename(
    readcode = "ReadCode",
    description = "Description"
  )

# Load Diagnosis file
diagnosis_file <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-d"),
  col_type = cols(
    `GUID` = col_character(),
    `Diagnosis Code` = col_character(),
    `Diagnosis Description` = col_character()
  )
) %>%
  # rename variables
  rename(
    guid = `GUID`,
    readcode = `Diagnosis Code`,
    description = `Diagnosis Description`
  )

# Deal with Read Codes

matched_data <- diagnosis_file %>%
  # Sort for matching
  arrange(readcode, description) %>%
  # match by read code
  left_join(read_code_lookup, by = "readcode") %>%
  # rename
  rename(
    "description" = "description.x",
    "true_description" = "description.y"
  ) %>%
  # replace NA string with blank
  mutate(true_description = replace_na(true_description, "")) %>%
  # identify matching descriptions
  mutate(full_match1 = if_else(description == true_description, 1, 0)) %>%
  # If we had a description in the lookup that matched a Read code, use that one now.
  mutate(description = if_else(full_match1 == 0 & true_description != "",
                               true_description, description
  )) %>%
  # match by read code
  left_join(read_code_lookup, by = "readcode", "description") %>%
  # replace NA string with blank
  mutate(description.y = replace_na(description.y, "")) %>%
  # identify matching descriptions
  mutate(full_match2 = if_else(description.x == description.y, 1, 0)) %>%
  # rename
  rename(
    "description" = "description.x",
    "true_description2" = "description.y"
  ) %>%
  mutate(old_readcode = readcode) %>%
  # Check the output for any dodgy Read codes and try and fix by adding exceptions
  mutate(readcode = case_when(
    full_match2 == 0 & readcode == "Xa1m." ~ "S349",
    full_match2 == 0 & readcode == "Xa1mz" ~ "S349",
    full_match2 == 0 & readcode == "HO6.." ~ "H06..",
    full_match2 == 0 & readcode == "zV6.." ~ "ZVz..",
    full_match2 == 0 ~ str_replace_all(readcode, "\\?", "\\."),
    full_match2 == 0 ~ str_replace_all(readcode, "\\d{5}", "\\d{5}."),
    TRUE ~ readcode
  ))

# Data Cleaning

dianosis_clean <- matched_data %>%
  # Sort and restructure the data so it's ready to link to case IDs.
  arrange(guid, readcode) %>%
  # Remove duplicates (use a flag)
  mutate(
    duplicate = if_else(guid == lag(guid, default = first(guid)) & readcode == lag(readcode, default = first(readcode)), 1, 0)
  ) %>%
  filter(duplicate == 0) %>%
  mutate(readcodelevel = str_locate(readcode, "[.]"))
readcodelevel = replace_na(readcodelevel, 0) %>%
  group_by(guid, readcode) %>%
  # restructure data
  pivot_wider(
    id_cols = guid,
    names_from = readcodelevel,
    values_from = readcode
  )

## Outcomes data  ------------------------------------

# Load extract file
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

# Data Cleaning

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
  mutate(duplicate = if_else(guid == lag(guid, default = first(guid)) & outcome == lag(outcome, default = first(outcome)), 1, 0)) %>%
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

## Consultations data  ------------------------------------

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
    postcode = `Patient Postcode [C]`,
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


## Data Cleaning

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
      smrtype == lead(smrtype) & location == lead(location), 1, to_merge
  )) %>%
  # Create counters for unique consultations.
  arrange(guid, chi, record_keydate1, record_keydate2) %>%
  group_by(chi, guid) %>%
  mutate(
    counter = as.double(row_number())
  ) %>%
  # If we've identified them as duplicates needing merged set the counter to indicate this.
  mutate(counter = if_else(to_merge == 1, 0, counter)) %>%
  ungroup() %>%
  # Aggregate data
  group_by(
    guid,
    chi,
    attendance_status,
    hbtreatcode,
    location,
    location_description,
    kis_accessed,
    refsource,
    smrtype,
    counter
  ) %>%
  summarise(
    hbrescode = last(hbrescode),
    datazone = last(datazone),
    hscp = last(hscp),
    dob = last(dob),
    gender = last(gender),
    postcode = last(postcode),
    gpprac = last(gpprac),
    record_keydate1 = min(record_keydate1),
    record_keydate2 = max(record_keydate2)
  ) %>%
  ungroup()


# Join data

matched_data <- consultations_clean %>%
  left_join(diagnosis_file, by = "guid") %>%
  left_join(outcomes_file, by = "guid")


# Deal with costs

ooh_costs <- matched_data %>%
  mutate(hbtreatcode = case_when(
    # Recode Fife and Tayside so they match the cost lookup.
    hbtreatcode == "S08000018" ~ "S08000029",
    hbtreatcode == "S08000027" ~ "S08000030",
    # Recode Greater Glasgow & Clyde and Lanarkshire so they
    # match the costs lookup (2018 > 2019 HB codes).
    hbtreatcode == "S08000021" ~ "S08000031",
    hbtreatcode == "S08000023" ~ "S08000032",
    TRUE ~ hbtreatcode),
    year = year
  ) %>%
  arrange(hbtreatcode, year) %>%
  # Match to cost lookup
  left_join(ooh_cost_lookup, by = c("hbtreatcode", "year")) %>%
  rename(
    cost_total_net = cost_per_consultation
  ) %>%
  create_day_episode_costs(record_keydate1, cost_total_net)


# Data Cleaning

ooh_clean <- ooh_costs %>%
  #TO DO - test code from here. objects taking too long.
  # rename outcomes
  rename(
    ooh_outcome.1 = outcome.1,
    ooh_outcome.2 = outcome.2,
    ooh_outcome.3 = outcome.3,
    ooh_outcome.4 = outcome.4
  ) %>%
  mutate(
    # Replace location unknown with blank. Should this be NA?
    location = if_else(location == "UNKNOWN", "", location),
    recid = "OoH",
    smrtype = case_when(smrtype == "DISTRICT NURSE" ~ "OOH-DN",
                        smrtype == "DOCTOR ADVICE/NURSE ADVICE" ~ "OOH-Advice",
                        smrtype == "HOME VISIT" ~ "OOH-HomeV",
                        smrtype == "NHS 24 NURSE ADVICE" ~ "OOH-NHS24",
                        smrtype == "PCEC/PCC" ~ "OOH-PCC",
                        TRUE ~ "OOH-Other"
    ),
    kis_accessed = case_when(kis_accessed == "Y" ~ 1,
                             kis_accessed == "N" ~ 0,
                             TRUE ~ 9)
  ) %>%
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # split time from date
  mutate(
    key_time1 = as_hms(substr(record_keydate1, 12, 19)),
    key_time2 = as_hms(substr(record_keydate2, 12, 19)),
    record_keydate1 = substr(record_keydate1, 1, 10),
    record_keydate2 = substr(record_keydate2, 1, 10)
  )

# Keep the location descriptions as a lookup.
location_lookup <- ooh_clean %>%
  group_by(location) %>%
  summarise(
    location_description = first(location_description)
  ) %>%
  ungroup()

ooh_clean <- ooh_clean %>%
  arrange(guid, chi) %>%
  # group for getting row order
  group_by(guid, chi) %>%
  mutate(row_order = row_number(),
         ooh_cc = 0,
         ooh_cc = case_when(ooh_cc == 0 & row_order == 1 | chi != lag(chi, default = first(chi)) ~ 1,
                            ooh_cc == 0 & guid != lag(guid) ~ lag(ooh_cc, default = first(ooh_cc)) + 1,
                            ooh_cc == 0 ~ lag(ooh_cc, default = first(ooh_cc))
         ))



