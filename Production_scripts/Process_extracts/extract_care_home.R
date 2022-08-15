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
library(lubridate)

year <- check_year_format("1920")


# Read in data---------------------------------------
# TODO update this to use the rds version
source_ch_data <- haven::read_sav(get_sc_ch_episodes_path(ext = "zsav")) %>%
  # select episodes for FY
  filter(is_date_in_fyyear(year, record_keydate1, record_keydate2)) %>%
  # remove any episodes where the latest submission was before the current year
  filter(substr(sc_latest_submission, 1, 4) >= convert_fyyear_to_year(year))


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
    year = year,
    recid = "CH",
    SMRType = "Care-Home"
  ) %>%
  # compute lca variable from sending_location
  mutate(lca = convert_sending_location_to_lca(sending_location)) %>%
  # bed days
  # create dummy end where blank
  mutate(dummy_discharge = if_else(
    is.na(record_keydate2),
    end_fy(year) + days(1),
    record_keydate2
  )) %>%
  create_monthly_beddays(year, record_keydate1, dummy_discharge) %>%
  # year stay
  mutate(yearstay = rowSums(across(ends_with("_beddays")))) %>%
  # total length of stay
  mutate(stay = time_length(interval(record_keydate1, dummy_discharge),
    unit = "days"
  ))


# Costs  ---------------------------------------
# read in CH Costs Lookup
ch_costs <- readr::read_rds(get_ch_costs_path()) %>%
  rename(
    ch_nursing = nursing_care_provision
  )

# match costs
matched_costs <- source_ch_clean %>%
  left_join(ch_costs, by = c("year", "ch_nursing"))

monthly_costs <- matched_costs %>%
  # monthly costs
  create_monthly_costs(yearstay, cost_per_day * yearstay) %>%
  # cost total net
  mutate(cost_total_net = rowSums(across(ends_with("_cost"))))


# Outfile  ---------------------------------------

outfile <- monthly_costs %>%
  select(
    year,
    recid,
    SMRType,
    chi,
    person_id,
    dob,
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
  write_sav(get_source_extract_path(
    year,
    type = "CH",
    ext = "zsav",
    check_mode = "write"
  )) %>%
  # .rds file
  write_rds(get_source_extract_path(year, type = "CH", check_mode = "write"))


# End of Script #
