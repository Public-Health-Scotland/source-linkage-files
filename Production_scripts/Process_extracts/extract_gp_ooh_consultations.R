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

## Load extracts ------------------------------------

year <- "1920"

# Diagnosis data
diagnosis_file <- haven::read_sav(
  paste0(
    get_year_dir(year = year),
    "/gp-diagnosis-data-",
    year, ".zsav"
  )
)

# Outcomes data
outcomes_file <- haven::read_sav(
  paste0(
    get_year_dir(year = year),
    "/gp-outcomes-data-",
    year, ".zsav"
  )
)

# OOH cost lookup
ooh_cost_lookup <- haven::read_sav(get_gp_ooh_costs_path()) %>%
  rename(
    hbtreatcode = TreatmentNHSBoardCode,
    year = Year
  )


## Load extract file---------------------------------

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


# Join data ----------------------------------------

matched_data <- consultations_clean %>%
  left_join(diagnosis_file, by = "guid") %>%
  left_join(outcomes_file, by = "guid")

# Deal with costs -----------------------------

ooh_costs <- matched_data %>%
  mutate(
    hbtreatcode = case_when(
      # Recode Fife and Tayside so they match the cost lookup.
      hbtreatcode == "S08000018" ~ "S08000029",
      hbtreatcode == "S08000027" ~ "S08000030",
      # Recode Greater Glasgow & Clyde and Lanarkshire so they
      # match the costs lookup (2018 > 2019 HB codes).
      hbtreatcode == "S08000021" ~ "S08000031",
      hbtreatcode == "S08000023" ~ "S08000032",
      TRUE ~ hbtreatcode
    ),
    year = year
  ) %>%
  arrange(hbtreatcode, year) %>%
  # Match to cost lookup
  left_join(ooh_cost_lookup, by = c("hbtreatcode", "year")) %>%
  rename(
    cost_total_net = cost_per_consultation
  ) %>%
  create_day_episode_costs(record_keydate1, cost_total_net)


# Data Cleaning--------------------------------------

ooh_clean <- ooh_costs %>%
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
    smrtype = case_when(
      smrtype == "DISTRICT NURSE" ~ "OOH-DN",
      smrtype == "DOCTOR ADVICE/NURSE ADVICE" ~ "OOH-Advice",
      smrtype == "HOME VISIT" ~ "OOH-HomeV",
      smrtype == "NHS 24 NURSE ADVICE" ~ "OOH-NHS24",
      smrtype == "PCEC/PCC" ~ "OOH-PCC",
      TRUE ~ "OOH-Other"
    ),
    kis_accessed = case_when(
      kis_accessed == "Y" ~ 1,
      kis_accessed == "N" ~ 0,
      TRUE ~ 9
    )
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
  mutate(
    row_order = row_number(),
    ooh_cc = 0,
    ooh_cc = case_when(
      ooh_cc == 0 & row_order == 1 | chi != lag(chi, default = first(chi)) ~ 1,
      ooh_cc == 0 & guid != lag(guid) ~ lag(ooh_cc, default = first(ooh_cc)) + 1,
      ooh_cc == 0 ~ lag(ooh_cc, default = first(ooh_cc))
    )
  )


## Save Outfile -------------------------------------

outfile <- ooh_clean %>%
  arrange(
    chi,
    record_keydate1,
    key_time1
  )
select(
  year,
  recid,
  smrtype,
  record_keydate1,
  record_keydate2,
  key_time1,
  key_time2,
  chi,
  gender,
  dob,
  age,
  gpprac,
  postcode,
  hbrescode,
  datazone,
  hscp,
  hbtreatcode,
  location,
  attendance_status,
  kis_Accessed,
  refsource,
  contains("diag"),
  contains("ooh_outcome"),
  cost_total_net,
  apr_cost,
  may_cost,
  jun_cost,
  jul_cost,
  aug_cost,
  sep_cost,
  oct_cost,
  nov_cost,
  dec_cost,
  jan_cost,
  feb_cost,
  mar_cost,
  ooh_CC
)


# End of Script #
