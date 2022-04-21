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

year <- "1920"

year_dir <- fs::path(glue::glue("/conf/sourcedev/Source_Linkage_File_Updates/{year}/"))


# Read lookups-------------------------------------------------------------

sc_demographics <- haven::read_sav(fs::path(
  social_care_dir,
  paste0("sc_demographics_lookup_", latest_update),
  ext = "zsav"
)) %>%
  arrange(sending_location, social_care_id)

sc_client <- haven::read_sav(fs::path(
  year_dir,
  paste0("Client_for_Source-20", year),
  ext = "zsav"
)) %>%
  arrange(sending_location, social_care_id)


# Query to database -------------------------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 demographic
at_full_data <- tbl(db_connection, in_schema("social_care_2", "equipment")) %>%
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

# Join data --------------------------------------------------------
matched_data <- at_full_data %>%
  # Match on demographics data (chi, gender, dob and postcode)
  left_join(sc_demographics, by = c("sending_location", "social_care_id")) %>%
  # Match on client data
  left_join(sc_client, by = c("sending_location", "social_care_id"))


# Data Cleaning-----------------------------------------------------

# Work out the start fY for each period
# CHECK - do we need 2017 as the start of 2017Q4??
pre_compute_record_dates <- matched_data %>%
  distinct(period) %>%
  mutate(
    year = substr(period, 1, 4),
    start_fy = as.Date(paste0(year, "-04-01"))
  )

replaced_start_dates <- matched_data %>%
  # Replace missing start dates with the start of the quarter
  left_join(pre_compute_record_dates, by = "period") %>%
  tidylog::mutate(
    start_date_missing = is.na(service_start_date),
    at_service_start_date = if_else(
      start_date_missing,
      start_fy,
      service_start_date
    )
  )

at_clean <- replaced_start_dates %>%
  rename(
    record_keydate1 = at_service_start_date,
    record_keydate2 = service_end_date
  ) %>%
  mutate(
    recid = "AT",
    smrtype = case_when(
      service_type == 1 ~ "AT-Alarm",
      service_type == 2 ~ "AT-Tele"
    ),
    mid_fy = as.Date(paste0(year, "-09-30")),
    age = difftime(mid_fy, dob, "years"),
    person_id = glue::glue("{sending_location}-{social_care_id}")
  )

# Save outfile--------------------------------------------
outfile <- at_clean %>%
  arrange(chi, record_keydate1, record_keydate2) %>%
  select(
    year,
    recid,
    smrtype,
    chi,
    dob,
    age,
    gender,
    postcode,
    sc_send_lca,
    record_keydate1,
    record_keydate2,
    person_id,
    sc_latest_submission,
    sc_living_alone,
    sc_support_from_unpaid_carer,
    sc_social_worker,
    sc_type_of_housing,
    sc_meals,
    sc_day_care
  )

outfile %>%
  # save rds file
  write_rds(path(social_care_dir, str_glue("all_at_episodes_{latest_update}.rds")),
    compress = "gz"
  ) %>%
  # save sav file
  write_sav(path(social_care_dir, str_glue("all_at_episodes_{latest_update}.zsav")),
    compress = TRUE
  )
