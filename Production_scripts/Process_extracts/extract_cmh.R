#####################################################
# Community Mental Health Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process Community Mental Health Extract
#####################################################


# Load packages
library(dplyr)
library(readr)
library(createslf)



# Read in data ---------------------------------------


# Specify year
year <- check_year_format("1920")


# Read BOXI extract
cmh_extract <- get_boxi_extract_path(
  year = year,
  type = "CMH"
) %>%
  readr::read_csv(
    col_types = cols_only(
      "UPI Number [C]" = col_character(),
      "Patient DoB Date [C]" = col_date(format = "%Y/%m/%d %T"),
      "Gender" = col_double(),
      "Patient Postcode [C]" = col_character(),
      "NHS Board of Residence Code 9" = col_character(),
      "Patient HSCP Code - current" = col_character(),
      "Practice Code" = col_character(),
      "Treatment NHS Board Code 9" = col_character(),
      "Contact Date" = col_date(format = "%Y/%m/%d %T"),
      "Contact Start Time" = col_time(format = "%T"),
      "Duration of Contact" = col_time(format = "%M"),
      "Location of Contact" = col_character(),
      "Main Aim of Contact" = col_character(),
      "Other Aim of Contact (1)" = col_character(),
      "Other Aim of Contact (2)" = col_character(),
      "Other Aim of Contact (3)" = col_character(),
      "Other Aim of Contact (4)" = col_character()
    )
  ) %>%
  # rename
  rename(
    chi = "UPI Number [C]",
    dob = "Patient DoB Date [C]",
    gender = "Gender",
    postcode = "Patient Postcode [C]",
    hbrescode = "NHS Board of Residence Code 9",
    hscp = "Patient HSCP Code - current",
    gpprac = "Practice Code",
    hbtreatcode = "Treatment NHS Board Code 9",
    record_keydate1 = "Contact Date",
    keyTime1 = "Contact Start Time",
    duration = "Duration of Contact",
    location = "Location of Contact",
    diag1 = "Main Aim of Contact",
    diag2 = "Other Aim of Contact (1)",
    diag3 = "Other Aim of Contact (2)",
    diag4 = "Other Aim of Contact (3)",
    diag5 = "Other Aim of Contact (4)"
  )


# Data Cleaning  ---------------------------------------


cmh_clean <- cmh_extract %>%
  # create recid, year, SMRType variables
  mutate(
    recid = "CMH",
    SMRType = "Comm-MH",
    year = year
  ) %>%
  # contact end time
  mutate(
    keyTime1 = lubridate::hms(keyTime1),
    duration = lubridate::hms(duration)
  ) %>%
  mutate(keyTime2 = keyTime1 + duration) %>%
  # record key date 2
  mutate(record_keydate2 = record_keydate1) %>%
  # create blank diag 6
  mutate(diag6 = NA) %>%
  # numeric keydate
  mutate(
    record_keydate1 = lubridate::month(record_keydate1) + 100 * lubridate::month(record_keydate1) + 10000 * lubridate::year(record_keydate1),
    record_keydate2 = lubridate::month(record_keydate2) + 100 * lubridate::month(record_keydate2) + 10000 * lubridate::year(record_keydate2)
  )



# Outfile --------------------------------------------

outfile <- cmh_clean %>%
  arrange(chi, record_keydate1, keyTime1) %>%
  select(
    recid,
    record_keydate1,
    record_keydate2,
    keyTime1,
    keyTime2,
    SMRType,
    chi,
    gender,
    dob,
    gpprac,
    postcode,
    hbrescode,
    hscp,
    location,
    hbtreatcode,
    diag1,
    diag2,
    diag3,
    diag4,
    diag5,
    diag6
  )


outfile %>%
  # Save as zsav file
  write_sav(get_source_extract_path(year, "CMH", ext = "zsav")) %>%
  # Save as rds file
  write_rds(get_source_extract_path(year, "CMH", ext = "rds"))



# End of Script #
