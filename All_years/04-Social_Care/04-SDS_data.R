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
library(phsmethods)
library(lubridate)


# Set up------------------------------------------------------------------

source("All_years/04-Social_Care/00-Social_Care_functions.R")


# Read Demographic file----------------------------------------------------

sc_demographics <- haven::read_sav(fs::path(
  social_care_dir,
  paste0("sc_demographics_lookup_", latest_update()),
  ext = "zsav"
))


# Query to database -------------------------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 demographic
sds_full_data <- tbl(db_connection, dbplyr::in_schema("social_care_2", "sds_snapshot")) %>%
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
  # Deal with SDS option 4
  # First turn the option flags into a logical T/F
  mutate(across(starts_with("sds_option_"), ~ .x == "1")) %>%
  # SDS option 4 is derived when a person receives more than one option.
  # e.g. if a person has options 1 and 2 then option 4 will be derived
  mutate(
    sds_option_4 = rowSums(across(starts_with("sds_option_"))) > 1, .after = sds_option_3,
    # Fix sds option 4 cases where all 3 options are missing
    sds_option_4 = if_else(sds_option_1 == FALSE & sds_option_2 == FALSE & sds_option_3 == FALSE, TRUE, sds_option_4)
  ) %>%
  # Match on demographics data (chi, gender, dob and postcode)
  left_join(sc_demographics, by = c("sending_location", "social_care_id")) %>%
  # If sds start date is missing, assign start of FY
  mutate(sds_start_date = if_else(is.na(sds_start_date),
    start_fy(year = period, format = "alternate"),
    sds_start_date
  )) %>%
  # Fix sds_end_date is earlier than sds_start_date by setting end_date to be the end of fyear
  mutate(sds_end_date = if_else(
    sds_start_date >= sds_end_date,
    end_fy(year = period, "alternate"),
    sds_end_date
  )) %>%
  # rename for matching source variables
  rename(
    record_keydate1 = sds_start_date,
    record_keydate2 = sds_end_date
  ) %>%
  # Pivot longer on sds option variables
  tidyr::pivot_longer(
    cols = contains("sds_option_"),
    names_to = "sds_option",
    names_prefix = "sds_option_",
    names_transform = list(sds_option = ~ paste0("SDS-", .x)),
    values_to = "received"
  ) %>%
  # Only keep rows where they received a package and remove duplicates
  filter(received) %>%
  distinct() %>%
  # Include source variables
  mutate(
    smrtype = case_when(
      sds_option == "SDS-1" ~ "SDS-1",
      sds_option == "SDS-2" ~ "SDS-2",
      sds_option == "SDS-3" ~ "SDS-3",
      sds_option == "SDS-4" ~ "SDS-4"
    ),
    recid = "SDS",
    # Create person id variable
    person_id = glue::glue("{sending_location}-{social_care_id}"),
    # Use function for creating sc send lca variables
    sc_send_lca = convert_sc_sl_to_lca(sending_location)
  ) %>%
  # when multiple social_care_id from sending_location for single CHI
  # replace social_care_id with latest
  group_by(sending_location, chi) %>%
  mutate(latest_sc_id = last(social_care_id)) %>%
  # count changed social_care_id
  mutate(
    changed_sc_id = !is.na(chi) & social_care_id != latest_sc_id,
    social_care_id = if_else(changed_sc_id, latest_sc_id, social_care_id)
  ) %>%
  ungroup()


merge_eps <- sds_full_clean %>%
  # Use lazy_dt() for faster running of code
  dtplyr::lazy_dt() %>%
  group_by(sending_location, social_care_id, sds_option) %>%
  arrange(period, record_keydate1, .by_group = TRUE) %>%
  # Create a flag for episodes that are going to be merged
  # Create an episode counter
  mutate(
    distinct_episode = (record_keydate1 > lag(record_keydate2)) %>%
      replace_na(TRUE),
    episode_counter = cumsum(distinct_episode)
  ) %>%
  # Group by episode counter and merge episodes
  group_by(episode_counter, .add = TRUE) %>%
  summarise(
    sc_latest_submission = last(period),
    record_keydate1 = min(record_keydate1),
    record_keydate2 = max(record_keydate2),
    sending_location = last(sending_location),
    social_care_id = last(social_care_id),
    chi = last(chi),
    gender = last(gender),
    dob = last(dob),
    postcode = last(postcode),
    smrtype = last(smrtype),
    recid = last(recid),
    person_id = last(person_id),
    sc_send_lca = last(sc_send_lca)
  ) %>%
  # end of lazy_dt()
  as_tibble() %>%
  # Sort for running SPSS
  arrange(
    sending_location,
    social_care_id
  )


# Save outfile------------------------------------------------

merge_eps %>%
  # save rds file
  readr::write_rds(fs::path(social_care_dir, stringr::str_glue("all_sds_episodes_{latest_update()}.rds")),
    compress = "xz"
  ) %>%
  # save sav file
  haven::write_sav(fs::path(social_care_dir, stringr::str_glue("all_sds_episodes_{latest_update()}.zsav")),
    compress = "zsav"
  )


# End of Script #
