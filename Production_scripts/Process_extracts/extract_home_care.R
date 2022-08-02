#####################################################
# Home Care Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Social Care Home Care Episodes
# Description - Process Home Care Extract
#####################################################

# Load packages
library(dplyr)
library(createslf)

year <- check_year_format("1920")


# Read in data---------------------------------------

source_hc_data <-
  readr::read_rds(get_sc_hc_episodes_path(update = latest_update())) %>%
  # select episodes for FY
  filter(is_date_in_fyyear(year, record_keydate1, record_keydate2)) %>%
  # remove any episodes where the latest submission was before the current year
  filter(substr(sc_latest_submission, 1, 4) >= convert_fyyear_to_year(year)) %>%
  # alter sending location type to allow match
  # TODO change the client script to use sending location as an integer
  mutate(sending_location = as.character(sending_location))


# Match on Client Data ---------------------------------------

# read client data in
client_data <-
  readr::read_rds(get_source_extract_path(year, type = "Client"))

# match to client data
matched_data <- source_hc_data %>%
  left_join(client_data, by = c("sending_location", "social_care_id"))


# Data Cleaning ---------------------------------------

source_hc_clean <- matched_data %>%
  # rename
  rename(
    record_keydate1 = "hc_service_start_date",
    record_keydate2 = "hc_service_end_date",
    hc_reablement = "reablement",
    hc_provider = "hc_service_provider"
  ) %>%
  # year / recid / SMRType variables
  mutate(
    year = year,
    recid = "HC",
    SMRType = case_when(
      hc_service == 1 ~ "HC-Non-Per",
      hc_service == 2 ~ "HC-Per",
      TRUE ~ "HC-Unknown"
    )
  ) %>%
  # person_id
  create_person_id(type = "SC") %>%
  # compute lca variable from sending_location
  mutate(lca = convert_sending_location_to_lca(sending_location))


# Home Care Hours ---------------------------------------

hc_hours <- source_hc_clean %>%
  # rename hours variables
  rename(
    hc_hours_q1 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q1"),
    hc_hours_q2 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q2"),
    hc_hours_q3 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q3"),
    hc_hours_q4 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q4")
  ) %>%
  # remove hours variables not from current year
  select(-(contains("hc_hours_2"))) %>%
  # create annual hours variable
  mutate(hc_hours_annual = rowSums(across(contains("hc_hours_q"))))


# Home Care Costs ---------------------------------------

hc_costs <- hc_hours %>%
  # rename costs variables
  rename(
    hc_costs_q1 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q1"),
    hc_costs_q2 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q2"),
    hc_costs_q3 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q3"),
    hc_costs_q4 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q4")
  ) %>%
  # remove cost variables not from current year
  select(-(contains("hc_cost_2"))) %>%
  # create cost total net
  mutate(cost_total_net = rowSums(across(contains("hc_cost_q"))))


# Outfile ---------------------------------------

outfile <- hc_costs %>%
  select(
    year,
    recid,
    SMRType,
    chi,
    dob,
    gender,
    postcode,
    lca,
    record_keydate1,
    record_keydate2,
    starts_with("hc_hours"),
    cost_total_net,
    starts_with("hc_cost"),
    hc_provider,
    hc_reablement,
    person_id,
    starts_with("sc_")
  )

outfile %>%
  # .zsav
  write_sav(get_source_extract_path(
    year,
    type = "HC",
    check_mode = "write",
    ext = "zsav"
  )) %>%
  # .rds file
  write_rds(get_source_extract_path(year, type = "HC", check_mode = "write"))

# End of Script #
