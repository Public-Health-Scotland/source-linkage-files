#####################################################
# NRS Deaths Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - NRS Deaths BOXI extract
# Description - Process NRS Deaths Extract
#####################################################


# Load packages
library(dplyr)
library(readr)
library(createslf)



# Read in data ---------------------------------------


# Specify year
year <- check_year_format("1920")


# Read BOXI extract

deaths_extract <- get_boxi_extract_path(
  year = year,
  type = "Deaths"
) %>%
  readr::read_csv(
    col_types = cols_only(
      "Death Location Code" = col_character(),
      "Geo Council Area Code" = col_character(),
      "Geo Data Zone 2011" = col_character(),
      "Geo Postcode [C]" = col_character(),
      "Geo HSCP of Residence Code - current" = col_character(),
      "NHS Board of Occurrence Code - current" = col_character(),
      "NHS Board of Residence Code - current" = col_character(),
      "Pat Date Of Birth [C]" = col_date(format = "%Y/%m/%d %T"),
      "Date of Death(99)" = col_date(format = "%Y/%m/%d %T"),
      "Pat Gender Code" = col_double(),
      "Pat UPI" = col_character(),
      "Place Death Occurred Code" = col_character(),
      "Post Mortem Code" = col_character(),
      "Prim Cause of Death Code (6 char)" = col_character(),
      "Sec Cause of Death 0 Code (6 char)" = col_character(),
      "Sec Cause of Death 1 Code (6 char)" = col_character(),
      "Sec Cause of Death 2 Code (6 char)" = col_character(),
      "Sec Cause of Death 3 Code (6 char)" = col_character(),
      "Sec Cause of Death 4 Code (6 char)" = col_character(),
      "Sec Cause of Death 5 Code (6 char)" = col_character(),
      "Sec Cause of Death 6 Code (6 char)" = col_character(),
      "Sec Cause of Death 7 Code (6 char)" = col_character(),
      "Sec Cause of Death 8 Code (6 char)" = col_character(),
      "Sec Cause of Death 9 Code (6 char)" = col_character(),
      "Unique Record Identifier" = col_character(),
      "GP practice code(99)" = col_character()
    )
  ) %>%
  # rename variables
  rename(
    death_location_code = "Death Location Code",
    lca = "Geo Council Area Code",
    datazone = "Geo Data Zone 2011",
    postcode = "Geo Postcode [C]",
    hscp = "Geo HSCP of Residence Code - current",
    death_board_occurrence = "NHS Board of Occurrence Code - current",
    hbrescode = "NHS Board of Residence Code - current",
    dob = "Pat Date Of Birth [C]",
    dod = "Date of Death(99)",
    gender = "Pat Gender Code",
    chi = "Pat UPI",
    place_death_occurred = "Place Death Occurred Code",
    post_mortem = "Post Mortem Code",
    deathdiag1 = "Prim Cause of Death Code (6 char)",
    deathdiag2 = "Sec Cause of Death 0 Code (6 char)",
    deathdiag3 = "Sec Cause of Death 1 Code (6 char)",
    deathdiag4 = "Sec Cause of Death 2 Code (6 char)",
    deathdiag5 = "Sec Cause of Death 3 Code (6 char)",
    deathdiag6 = "Sec Cause of Death 4 Code (6 char)",
    deathdiag7 = "Sec Cause of Death 5 Code (6 char)",
    deathdiag8 = "Sec Cause of Death 6 Code (6 char)",
    deathdiag9 = "Sec Cause of Death 7 Code (6 char)",
    deathdiag10 = "Sec Cause of Death 8 Code (6 char)",
    deathdiag11 = "Sec Cause of Death 9 Code (6 char)",
    uri = "Unique Record Identifier",
    gpprac = "GP practice code(99)"
  )



# Data Cleaning  ---------------------------------------


deaths_clean <- deaths_extract %>%
  # rename dod
  rename(record_keydate1 = "dod") %>%
  mutate(record_keydate2 = record_keydate1) %>%
  # create recid and year variables
  mutate(
    recid = "NRS",
    year = year
  ) %>%
  # fix dummy gpprac codes
  convert_eng_gpprac_to_dummy(gpprac)



# Outfile --------------------------------------------


outfile <- deaths_clean %>%
  arrange(chi)


outfile %>%
  # Save as zsav file
  write_sav(get_source_extract_path(year, "Deaths", ext = "zsav")) %>%
  # Save as rds file
  write_rds(get_source_extract_path(year, "Deaths", ext = "rds"))


# End of Script #
