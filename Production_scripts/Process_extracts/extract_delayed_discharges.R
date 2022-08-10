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
library(tidyr)
library(dplyr)
library(readr)
library(createslf)
library(janitor)


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

dd_clean <- dd_file %>%
  # Drop any records with obviously bad dates
  filter(
    keydate1_dateformat <= keydate2_dateformat | keydate2_dateformat == ymd("1900, 1, 1")
  ) %>%
  # set up variables
  mutate(
    recid = "DD",
    smrtype = "DelayedDis",
    year = year
  ) %>%
  # recode the local authority to match source coding
  mutate(
    primary_delay_reason = na_if(primary_delay_reason, ""),
    secondary_delay_reason = na_if(secondary_delay_reason, "")
  )
