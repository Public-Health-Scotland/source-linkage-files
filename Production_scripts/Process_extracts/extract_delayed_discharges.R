#####################################################
# Draft pre processing code for Delayed Discharges
# Author: Jennifer Thom
# Date: April 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Jul16_{latest dd period}DD_LinkageFile.zssav
# Description - Preprocessing of raw delayed discharges file.
#               Tidy up file in line with SLF format
#                prior to processing.
#####################################################

# Load Packages #
library(dplyr)
library(janitor)
library(lubridate)
library(createslf)


# Read in data---------------------------------------

year <- check_year_format("1920")

dd_file <- haven::read_sav(get_dd_path(ext = "zsav")) %>%
  clean_names() %>%
  # rename variables
  rename(
    keydate1_dateformat = rdd,
    keydate2_dateformat = delay_end_date
  )


# Data Cleaning---------------------------------------

# Specify MH specialties for dealing with correct DD dates
mh_spec <- c("CC", "G1", "G2", "G21", "G22", "G3", "G4", "G5", "G6", "G61", "G62", "G63")

dd_clean <- dd_file %>%
  # Use end of the month date for records with no end date (but we think have ended)
  # Create a flag for these records
  mutate(
    month_end = lubridate::ceiling_date(keydate1_dateformat, "month") - 1,
    ammended_dates = case_when(
      keydate2_dateformat == as.Date("1900-01-01") ~ TRUE,
      TRUE ~ FALSE
    ),
    keydate2_dateformat = if_else(ammended_dates, month_end, keydate2_dateformat)
  ) %>%
  # Drop any records with obviously bad dates
  filter(
    (keydate1_dateformat <= keydate2_dateformat) | is.na(keydate2_dateformat)
  ) %>%
  # set up variables
  mutate(
    recid = "DD",
    smrtype = "DelayedDis",
    year = year
  ) %>%
  # recode blanks to NA
  mutate(
    across(ends_with("delay_reason"), na_if, "")
  ) %>%
  # create flags for no_end_date and correct_dates
  mutate(
    # Flag records with no end date
    no_end_date = dplyr::if_else(is.na(.data$keydate2_dateformat) & (!(.data$spec %in% mh_spec)),
      TRUE,
      FALSE
    ),
    # Flag records with correct date
    correct_dates = dplyr::if_else(is_date_in_fyyear(year, .data$keydate1_dateformat) |
      is_date_in_fyyear(year, .data$keydate2_dateformat) |
      is.na(.data$keydate2_dateformat) & .data$spec %in% mh_spec,
    TRUE,
    FALSE
    )
  ) %>%
  # Keep only records which have an end date (except Mental Health) and fall within our dates.
  filter(correct_dates, !no_end_date == FALSE)


## save outfile ---------------------------------------
outfile <- dd_clean %>%
  select(
    year,
    recid,
    original_admission_date,
    keydate1_dateformat,
    keydate2_dateformat,
    smrtype,
    chi,
    postcode,
    delay_end_reason,
    primary_delay_reason,
    secondary_delay_reason,
    spec,
    location,
    hbtreatcode,
    dd_responsible_lca,
    monthflag,
    cennum
  )

outfile %>%
  # Save as zsav file
  write_sav(get_source_extract_path(year, "DD", ext = "zsav", check_mode = "write")) %>%
  # Save as rds file
  write_rds(get_source_extract_path(year, "DD", check_mode = "write"))

## End of Script ##
