#####################################################
# Social Care SDS Data
# Author: Jennifer Thom
# Date: July 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Data from Social care database DVPROD
# Description - Process SDS data
#####################################################

# Load packages

library(readr)
library(dplyr)
library(dbplyr)
library(phsmethods)
library(tidyverse)
library(lubridate)
library(fs)
library(haven)

# Set up------------------------------------------------------------------

latest_update <- "Jun_2022"

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
sds_full_data <- tbl(db_connection, in_schema("social_care_2", "sds_snapshot")) %>%
  select(
    sending_location,
    social_care_id,
    period,
    sds_start_date,
    sds_end_date,
    sds_option_1,
    sds_option_2,
    sds_option_3
  ) %>%
  collect()

# Data Cleaning-----------------------------------------------------

sds_full_clean <- sds_full_data %>%
  # Match on demographics data (chi, gender, dob and postcode)
  left_join(sc_demographics, by = c("sending_location", "social_care_id")) %>%
  # If sds start date is missing, assign start of FY
  mutate(
    start_fy = as.Date(paste0(period, "-04-01")),
    sds_start_date = if_else(is.na(sds_start_date), start_fy, sds_start_date)
  ) %>%
  # rename for matching source variables
  rename(
    record_keydate1 = sds_start_date,
    record_keydate2 = sds_end_date
  ) %>%
  # Pivot longer on sds option variables
  pivot_longer(
    cols = contains("sds_option_"),
    names_to = "sds_option",
    values_to = "received"
  ) %>%
  filter(received == "1") %>%
  # Include source variables
  mutate(
    recid = "SDS",
    sds_option = case_when(
      sds_option == "sds_option_1" ~ 1,
      sds_option == "sds_option_2" ~ 2,
      sds_option == "sds_option_3" ~ 3
    ),
    smrtype = case_when(
      sds_option == 1 ~ "SDS-1",
      sds_option == 2 ~ "SDS-2",
      sds_option == 3 ~ "SDS-3"
    ),
    mid_fy = as.Date(paste0(period, "-09-30")),
    # create age variable
    age = floor(time_length(interval(dob, mid_fy), "years")),
    # Create person id variable
    person_id = glue::glue("{sending_location}-{social_care_id}"),
    # Use function for creating sc send lca variables
    sc_send_lca = convert_sc_sl_to_lca(sending_location)
  )

# work out sds_option_4
sds_option_4 <- sds_full_clean %>%
  group_by(social_care_id) %>%
  summarise(n_packages = n())

# Match back onto data
outfile <- sds_full_clean %>%
  left_join(sds_option_4, by = "social_care_id") %>%
  mutate(
    sds_option_4 = if_else(n_packages >= 2, 1, 0)
  )


# Save outfile------------------------------------------------

outfile %>%
  # save rds file
  readr::write_rds(path(social_care_dir, str_glue("all_sds_episodes_{latest_update}.rds")),
    compress = "gz"
  ) %>%
  # save sav file
  haven::write_sav(path(social_care_dir, str_glue("all_sds_episodes_{latest_update}.zsav")),
    compress = TRUE
  )


# End of Script #
