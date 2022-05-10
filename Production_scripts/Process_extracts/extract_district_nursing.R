#####################################################
# District Nursing Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process District Nursing Extract
#####################################################

# Load packages
library(dplyr)
library(ggplot2)
library(createslf)
library(phsmethods)
library(lubridate)


# Read in data ---------------------------------------

# Specify year
year <- check_year_format("1920")

# Read BOXI extract
dn_extract <- readr::read_csv(get_boxi_extract_path(
  year = year,
  type = "DN"
)) %>%
  # rename
  rename(
    age = "Age at Contact Date",
    dob = "Patient DoB Date [C]",
    gender = "Gender",
    hscp = "HSCP of Residence Code (Contact)",
    hbrescode = "NHS Board of Residence Code 9 (Contact)",
    lca = "Patient Council Area Code (Contact)",
    postcode = "Patient Postcode [C] (Contact)",
    gpprac = "Practice Code (Contact)",
    datazone = "Patient Data Zone 2011 (Contact)",
    hbpraccode = "Practice NHS Board Code 9 (Contact)",
    hbtreatcode = "Treatment NHS Board Code 9",
    hbtreatname = "Treatment NHS Board Name",
    chi = "UPI Number [C]",
    episode_contact_number = "Episode Contact Number",
    contact_start_time = "Contact Start Time",
    contact_end_time = "Contact End Time",
    record_keydate1 = "Contact Date",
    intervention_1 = "Other Intervention Category (1)",
    intervention_2 = "Other Intervention Category (2)",
    intervention_3 = "Other Intervention Category (3)",
    intervention_4 = "Other Intervention Category (4)",
    intervention_sub_1 = "Other Intervention Subcategory (1)",
    intervention_sub_2 = "Other Intervention Subcategory (2)",
    intervention_sub_3 = "Other Intervention Subcategory (3)",
    intervention_sub_4 = "Other Intervention Subcategory (4)",
    primary_intervention = "Primary Intervention Category",
    primary_intervention_sub = "Primary Intervention Subcategory",
    duration_contact = "Duration of Contact (measure)",
    location_contact = "Location of Contact",
    patient_contact = "Patient Contact Category"
  ) %>%
  mutate(
    dob = as.Date(dob),
    record_keydate1 = as.Date(record_keydate1),
    gpprac = as.character(gpprac)
  )


# Data Cleaning  ---------------------------------------

dn_clean <- dn_extract %>%
  # valid chi
  mutate(validity = chi_check(chi)) %>%
  # filter for valid chi only
  filter(validity == "Valid CHI") %>%
  # add variables
  mutate(
    recid = "DN",
    smr_type = "DN",
    year = year
  ) %>%
  # record key date
  mutate(record_keydate2 = record_keydate1) %>%
  # contact end time
  mutate(contact_end_time = hms::as_hms(contact_start_time + dminutes(duration_contact))) %>%
  # deal with gpprac
  convert_eng_gpprac_to_dummy(gpprac)


# Costs  ---------------------------------------

# Recode HB codes so they match the cost lookup
dn_extract <- dn_extract %>%
  mutate(hbtreatcodes = case_when(
    hbtreatcode == "S08000018" & convert_fyyear_to_year(year) > 2018 ~ "S08000029",
    hbtreatcode == "S08000027" & convert_fyyear_to_year(year) > 2018 ~ "S08000030",
    hbtreatcode == "S08000021" & convert_fyyear_to_year(year) > 2019 ~ "S08000031",
    hbtreatcode == "S08000023" & convert_fyyear_to_year(year) > 2019 ~ "S08000032"
  ))



# read in DN cost lookup
dn_costs_lookup <- readr::read_rds(get_dn_costs_path(ext = "rds")) %>%
  select(-hbtreatname)

# match files with DN Cost Lookup
matched_dn_costs <- dn_clean %>%
  full_join(dn_costs_lookup, by = c("hbtreatcode", "year")) %>%
  # costs are rough estimates we round them to the nearest pound
  mutate(cost_total_net = round(cost_total_net, 0))


care_marker <- matched_dn_costs %>%
  arrange(chi, record_keydate1) %>%
  group_by(chi) %>%
  # difference between dates of contacts
  mutate(
    date_1 = record_keydate1,
    date_2 = lead(record_keydate1),
    day_diff = as.numeric(date_2 - date_1)
  ) %>%
  # continuous care marker
  mutate(ccm = 1) %>%
  mutate(ccm = if_else(day_diff <= 7, lead(ccm), lead(ccm) + 1)) %>%
  ungroup()


# costs per month
dn_monthly_costs <- care_marker %>%
  create_day_episode_costs(record_keydate1, cost_total_net)


## save outfile ---------------------------------------

outfile <- dn_monthly_costs %>%
  group_by(year, chi, recid, smr_type, ccm) %>%
  summarise(
    record_keydate1 = min(record_keydate1),
    record_keydate2 = max(record_keydate2),
    dob = last(dob),
    hbtreatcode = last(hbtreatcode),
    hbrescode = last(hbrescode),
    hscp = last(hscp),
    lca = last(lca),
    datazone = last(datazone),
    age = last(age),
    diag1 = first(primary_intervention),
    diag2 = first(intervention_1),
    diag3 = first(intervention_2),
    diag4 = last(primary_intervention),
    diag5 = last(intervention_1),
    diag6 = last(intervention_2),
    postcode = last(postcode),
    gender = first(gender),
    gpprac = first(gpprac),
    cost_total_net = sum(cost_total_net),
    location = first(location_contact),
    jan_cost = sum(jan_cost),
    feb_cost = sum(feb_cost),
    mar_cost = sum(mar_cost),
    apr_cost = sum(apr_cost),
    may_cost = sum(may_cost),
    jun_cost = sum(jun_cost),
    jul_cost = sum(jul_cost),
    aug_cost = sum(aug_cost),
    sep_cost = sum(sep_cost),
    oct_cost = sum(oct_cost),
    nov_cost = sum(nov_cost),
    dec_cost = sum(dec_cost)
  ) %>%
  ungroup()


# Save as zsav file
outfile %>%
  haven::write_sav(get_source_extract_path(year, "DN", ext = "zsav"))

# Save as rds file
outfile %>%
  readr::write_rds(get_source_extract_path(year, "DN", ext = "rds"))


# End of Script #
