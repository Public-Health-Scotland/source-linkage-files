#####################################################
# Care Home Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Social Care Care Home Episodes
# Description - Match on Client data and Costs data
#####################################################


# Load packages
library(dplyr)
library(createslf)
library(phsmethods)
library(lubridate)


fyyear <- check_year_format("1920")


# Read in data---------------------------------------

source_ch_data <- haven::read_sav(get_sc_ch_episodes_path(ext = "zsav")) %>%
  # select episodes for FY
  filter(is_date_in_year(record_keydate1, fyyear) |
    (record_keydate1 <= end_fy(fyyear) & record_keydate2 >= start_fy(fyyear) | is.na(record_keydate2))) %>%
  # remove any episodes where the latest submission was before the current year
  filter(convert_fyyear_to_year(fyyear) > substr(sc_latest_submission, 1, 4))


# Match on Client Data ---------------------------------------

# read client data in
client_data <- readr::read_rds(get_source_extract_path(year, type = "Client"))

# match to client data
matched_data <- source_ch_data %>%
  left_join(client_data, by = c("sending_location", "social_care_id"))


# Data Cleaning ---------------------------------------

source_ch_clean <- matched_data %>%
  # create variables
  mutate(
    year = convert_fyyear_to_year(fyyear),
    recid = "CH",
    SMRType = "Care-Home"
  ) %>%
  # compute age variable
  compute_mid_year_age(fyyear, dob) %>%
  # compute lca variable from sending_location
  mutate(lca = convert_sending_location_to_lca(sending_location)) %>%
  # bed days
  # create dummy end where blank
  mutate(dummy_discharge = if_else(is.na(record_keydate2), end_fy(fyyear) + days(1), record_keydate2)) %>%
  create_monthly_beddays(year, record_keydate1, dummy_discharge) %>%
  # year stay
  mutate(yearstay = rowSums(across(ends_with("_beddays")))) %>%
  # total length of stay
  mutate(stay = difftime(record_keydate2, record_keydate1, units = "days"))


# Costs  ---------------------------------------

# read in CH Costs Lookup
ch_costs <- haven::read_sav(get_ch_costs_path(ext = "sav")) %>%
  rename(
    year = "Year",
    ch_nursing = "nursing_care_provision"
  )


# match costs
matched_costs <- source_ch_clean %>%
  left_join(ch_costs, by = c("year", "ch_nursing"))


costs <- matched_costs %>%
  # monthly costs
  create_monthly_costs(yearstay, cost_per_day) %>%
  # cost total net
  mutate(cost_total_net = rowSums(across(ends_with("_cost"))))


# Outfile  ---------------------------------------

outfile <- costs %>%
  arrange(chi, record_keydate1, record_keydate2) %>%
  select(
    year,
    recid,
    SMRType,
    chi,
    person_id,
    dob,
    age,
    gender,
    postcode,
    lca,
    record_keydate1,
    record_keydate2,
    sc_latest_submission,
    starts_with("ch_"),
    yearstay,
    stay,
    cost_total_net,
    ends_with("_beddays"),
    ends_with("_cost"),
    starts_with("sc_")
  )


outfile %>%
  # .zsav
  write_sav(get_source_extract_path(fyyear, type = "CH", ext = "zsav")) %>%
  # .rds file
  write_rds(get_source_extract_path(fyyear, type = "CH", ext = "rds"))



# End of Script #
