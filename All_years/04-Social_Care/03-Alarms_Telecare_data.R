#####################################################
# Social Care Alarms Telecare Data
# Author: Jennifer Thom
# Date: April 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Data from Social care database DVPROD
# Description - Get Alarms Telecare data
#####################################################

## load packages ##

library(readr)
library(dplyr)
library(dbplyr)
library(phsmethods)
library(tidyverse)
library(lubridate)

# Set up------------------------------------------------------------------

latest_validated_period <- "2021Q2"

latest_update <- "Mar_2022"

social_care_dir <- fs::path("/conf/hscdiip/SLF_Extracts/Social_care")


# Read Demographic file----------------------------------------------------

sc_demographics <- haven::read_sav(fs::path(
  social_care_dir,
  paste0("sc_demographics_lookup_", latest_update),
  ext = "zsav"
)) %>%
  arrange(sending_location, social_care_id)


# Query to database -------------------------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 demographic
at_full_data <- tbl(db_connection, in_schema("social_care_2", "equipment_snapshot")) %>%
  select(
    sending_location,
    social_care_id,
    period,
    service_type,
    service_start_date,
    service_end_date
  ) %>%
  # fix bad 2017 period
  mutate(period = if_else(period == "2017", "2017Q4", period)) %>%
  # Drop unvalidated data
  filter(period <= latest_validated_period) %>%
  # order
  arrange(sending_location, social_care_id) %>%
  collect()


# Data Cleaning-----------------------------------------------------

# Work out the start fY for each period
# CHECK - do we need 2017 as the start of FY?
# CHECK - do we need start of Quarter?
# CHECK - do we remove these records? - 11,575 are missing
# CHECK - period = 2020 what do we change this to?
pre_compute_record_dates <- at_full_data %>%
  distinct(period) %>%
  mutate(
    year = substr(period, 1, 4),
    start_fy = as.Date(paste0(year, "-04-01"))
  )

replaced_start_dates <- at_full_data %>%
  # Replace missing start dates with the start of the fy
  left_join(pre_compute_record_dates, by = "period") %>%
  tidylog::mutate(
    start_date_missing = is.na(service_start_date),
    at_service_start_date = if_else(
      start_date_missing,
      start_fy,
      service_start_date
    )
  )

at_full_clean <- replaced_start_dates %>%
  # Match on demographics data (chi, gender, dob and postcode)
  left_join(sc_demographics, by = c("sending_location", "social_care_id")) %>%
  # rename for matching source variables
  rename(
    record_keydate1 = at_service_start_date,
    record_keydate2 = service_end_date
  ) %>%
  # Include source variables
  mutate(
    recid = "AT",
    smrtype = case_when(
      service_type == 1 ~ "AT-Alarm",
      service_type == 2 ~ "AT-Tele"
    ),
    # Create person id variable
    person_id = glue::glue("{sending_location}-{social_care_id}"),
    # Use function for creating sc send lca variables
    sc_send_lca = convert_sc_sl_to_lca(sending_location)
  )


# Save outfile------------------------------------------------

outfile %>%
  # save rds file
  write_rds(path(social_care_dir, str_glue("all_at_episodes_{latest_update}.rds")),
    compress = "gz"
  ) %>%
  # save sav file
  write_sav(path(social_care_dir, str_glue("all_at_episodes_{latest_update}.zsav")),
    compress = TRUE
  )
