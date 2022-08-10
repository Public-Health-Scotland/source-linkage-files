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
  # PUT into function
  mutate(
    dd_responsible_lca = case_when(
      la == "Aberdeen City" ~ 01,
      la == "Aberdeenshire" ~ 02,
      la == "Angus" ~ 03,
      la == "Argyll & Bute" ~ 04,
      la == "Scottish Borders" ~ 05,
      la == "Clackmannanshire" ~ 06,
      la == "West Dunbartonshire" ~ 07,
      la == "Dumfries & Galloway" ~ 08,
      la == "Dundee City" ~ 09,
      la == "East Ayrshire" ~ 10,
      la == "East Dunbartonshire" ~ 11,
      la == "East Lothian" ~ 12,
      la == "East Renfrewshire" ~ 13,
      la == "City of Edinburgh" ~ 14,
      la == "Falkirk" ~ 15,
      la == "Fife" ~ 16,
      la == "Glasgow City" ~ 17,
      la == "Highland" ~ 18,
      la == "Inverclyde" ~ 19,
      la == "Midlothian" ~ 20,
      la == "Moray" ~ 21,
      la == "North Ayrshire" ~ 22,
      la == "North Lanarkshire" ~ 23,
      la == "Orkney" ~ 24,
      la == "Perth & Kinross" ~ 25,
      la == "Renfrewshire" ~ 26,
      la == "Shetland" ~ 27,
      la == "South Ayrshire" ~ 28,
      la == "South Lanarkshire" ~ 29,
      la == "Stirling" ~ 30,
      la == "West Lothian" ~ 31,
      la == "Comhairle nan Eilean Siar" ~ 32
    ),
    #  Recode the hb treat code to match source.
    hbtreatcode = case_when(
      hb == "NHS Ayrshire & Arran" ~ "S08000015",
      hb == "NHS Borders" ~ "S08000016",
      hb == "NHS Dumfries & Galloway" ~ "S08000017",
      hb == "NHS Fife" ~ "S08000018",
      hb == "NHS Forth Valley" ~ "S08000019",
      hb == "NHS Grampian" ~ "S08000020",
      hb == "NHS Greater Glasgow & Clyde" ~ "S08000021",
      hb == "NHS Highland" ~ "S08000022",
      hb == "NHS Lanarkshire" ~ "S08000023",
      hb == "NHS Lothian" ~ "S08000024",
      hb == "NHS Orkney" ~ "S08000025",
      hb == "NHS Shetland" ~ "S08000026",
      hb == "NHS Tayside" ~ "S08000027",
      hb == "NHS Western Isles" ~ "S08000028"
    ),
    primary_delay_reason = na_if(primary_delay_reason, ""),
    secondary_delay_reason = na_if(secondary_delay_reason, "")
  )
