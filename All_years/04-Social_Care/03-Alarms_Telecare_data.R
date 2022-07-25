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
library(fs)
library(haven)

# Set up------------------------------------------------------------------

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
  # fix bad period (2017, 2020 & 2021)
  # TODO - ask SC team as last meeting they said to look at extract date - these dont relate.
  # e.g. extract date later than period
  mutate(period = if_else(period == "2017", "2017Q4", period),
         period = if_else(period == "2020", "2020Q4", period),
         period = if_else(period == "2021", "2021Q4", period)
         ) %>%
  # order
  arrange(sending_location, social_care_id) %>%
  collect()


# Data Cleaning-----------------------------------------------------


----------------------------------------------------------------
# assign start of FY

# Work out the start fY for each period
# CHECK - do we need 2017 as the start of FY?
# CHECK - do we need start of Quarter?
# CHECK - do we remove these records? - 11,575 are missing
# CHECK - period = 2020 what do we change this to?
#pre_compute_record_dates <- at_full_data %>%
#  distinct(period) %>%
#  mutate(
 #   year = substr(period, 1, 4),
 #   start_fy = as.Date(paste0(year, "-04-01"))
#  )

#replaced_start_dates <- at_full_data %>%
  # Replace missing start dates with the start of the fy
  #left_join(pre_compute_record_dates, by = "period") %>%
  #tidylog::mutate(
   # start_date_missing = is.na(service_start_date),
   # at_service_start_date = if_else(
   #   start_date_missing,
   #  start_fy,
   #   service_start_date
   #   )
#)

------------------------------------------------------------

# Work out the dates for each period
# Record date is the last day of the quarter
# qtr_start is the first day of the quarter
pre_compute_record_dates <- at_full_data %>%
  distinct(period) %>%
  mutate(
    record_date = yq(period) %m+% period(6, "months") %m-% days(1),
    qtr_start = yq(period) %m+% period(3, "months")
  )

replaced_start_dates <- at_full_data %>%
  # Replace missing start dates with the start of the quarter
  left_join(pre_compute_record_dates, by = "period") %>%
  tidylog::mutate(
    start_date_missing = is.na(service_start_date),
    service_start_date = if_else(
      start_date_missing,
      qtr_start,
      service_start_date
    )
  )

at_full_clean <- replaced_start_dates %>%
  # Match on demographics data (chi, gender, dob and postcode)
  left_join(sc_demographics, by = c("sending_location", "social_care_id")) %>%
  # rename for matching source variables
  rename(
    record_keydate1 = service_start_date,
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
  ) %>%
  # rename period as sc_latest_submission variable
  rename(
    sc_latest_submission = period
  )

# WIP from here onwards

check <- at_full_clean %>%
  group_by(sending_location, social_care_id, smrtype) %>%
  arrange(sc_latest_submission, record_keydate1, .by_group = TRUE) %>%
  mutate(flag = (record_keydate1 > lag(record_keydate2)) %>%
           replace_na(TRUE),
         episode_counter = cumsum(flag)
  )

last <- check %>%
  # possibly do an ungroup and then group by(sending_location, social_care_id, sds_option)
  group_by(episode_counter, .add = TRUE) %>%
  summarise(record_keydate1 = min(record_keydate1),
            across(everything(), last)




# Save outfile------------------------------------------------

at_full_clean %>%
  # save rds file
  readr::write_rds(path(social_care_dir, str_glue("all_at_episodes_{latest_update}.rds")),
    compress = "gz"
  ) %>%
  # save sav file
  haven::write_sav(path(social_care_dir, str_glue("all_at_episodes_{latest_update}.zsav")),
    compress = TRUE
  )
