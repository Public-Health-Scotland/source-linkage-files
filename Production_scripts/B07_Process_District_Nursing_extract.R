#####################################################
# Districy Nursing Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process District Nursing Extract
#####################################################

library(dplyr)
library(ggplot2)
library(createslf)
library(slfhelper)
library(phsmethods)
library(lubridate)


# Read in data ---------------------------------------

# latest year
latest_year <- 1920

dn_extract <- readr::read_csv(get_boxi_extract_path(year = latest_year,
                                                    type = "DN")
                              ) %>%
  # rename
  rename(age = "Age at Contact Date",
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
    record_keydate1 = as.Date(record_keydate1))


# Data Cleaning  ---------------------------------------

dn_extract <- dn_extract %>%
  # valid chi
  mutate(validity = chi_check(chi)) %>%
  # filter for valid chi only
  filter(validity == "Valid CHI") %>%
  # add variables
  mutate(
    recid = "DN",
    smr_type = "DN",
    year = latest_year) %>%
  # record key date
  mutate(record_keydate2 = record_keydate1) %>%
  # contact end time
  mutate(contact_end_time = hms::as_hms(contact_start_time + dminutes(duration_contact))) %>%
  # gpprac tidy
  mutate(gpprac = as.character(gpprac)) %>%
  eng_gp_to_dummy(gpprac)


# Costs  ---------------------------------------

# Recode HB codes so they match the cost lookup
dn_extract <- dn_extract %>%
  mutate(hbtreatcodes = case_when(hbtreatcode == "S08000018" & convert_fyyear_to_year(year) > 2018 ~ "S08000029",
                                  hbtreatcode == "S08000027" & convert_fyyear_to_year(year) > 2018 ~ "S08000030",
                                  hbtreatcode == "S08000021" & convert_fyyear_to_year(year) > 2019 ~ "S08000031",
                                  hbtreatcode == "S08000023" & convert_fyyear_to_year(year) > 2019 ~ "S08000032")
         ) %>%
  # sort by hbtreatcode
  arrange(hbtreatcode)


# match files with DN Cost Lookup
# read in DN cost lookup
dn_costs_lookup <- haven::read_sav(get_dn_costs_path())

dn_costs_lookup <- dn_costs_lookup %>%
  select(-hbtreatname) %>%
  rename(year = "Year") %>%
  mutate(year = as.numeric(year))

matched_dn_costs <- dn_extract %>%
  full_join(dn_costs_lookup, by = c("hbtreatcode", "year")) %>%
  # costs are rough estimates we round them to the nearest pound
  mutate(cost_total_net = round(cost_total_net, 0))


# difference between dates of contacts
matched_dn_costs <- matched_dn_costs %>%
  arrange(chi, record_keydate1) %>%
  group_by(chi) %>%
  mutate(date_1 = record_keydate1, date_2 = lead(record_keydate1), day_diff = as.numeric(date_2 - date_1)) %>%
  ungroup() %>%
  filter(!is.na(day_diff))


# continuous care marker
matched_dn_costs <- matched_dn_costs %>%
  tibble::add_column(ccm = 1) %>%
  group_by(chi) %>%
  mutate(ccm = if_else(day_diff < 7 | day_diff == 7, lead(ccm), lead(ccm) + 1)) %>%
  ungroup()


