#####################################################
# Care Home Name Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - SLF Care Home Name Lookup
# Description - Cleans up Care Home Names
#####################################################


# Load packages
library(dplyr)
library(dbplyr)
library(createslf)
library(phsmethods)


year <- check_year_format("1920")


# Read in data---------------------------------------


ch_lookup <- readxl::read_xlsx(get_slf_ch_name_lookup_path())


# Data Cleaning---------------------------------------

ch_clean <- ch_lookup %>%
  # rename care home name
  rename(ch_name = "ServiceName") %>%
  mutate(
    # correct postcode formatting
    ch_postcode = postcode(AccomPostCodeNo),
    # format date types
    DateReg = as.Date(DateReg),
    DateCanx = as.Date(DateCanx)
  ) %>%
  # remove any old Care Homes which aren't of interest
  filter(DateReg >= start_fy("1718") | DateCanx >= start_fy("1718") | is.na(DateCanx)) %>%
  # clean up care home names
  group_by(
    ch_name,
    ch_postcode,
    Council_Area_Name
  ) %>%
  mutate(
    DateCanx = tidyr::replace_na(DateCanx, end_fy(year, format = "fyyear"))
  ) %>%
  mutate(
    DateReg = min(DateReg, start_fy(lubridate::year(DateReg), format = "alternate")),
    DateCanx = max(DateCanx, end_fy(lubridate::year(DateCanx), format = "alternate"))
  ) %>%
  summarise(
    DateReg = min(DateReg),
    DateCanx = max(DateCanx)
  ) %>%
  ungroup() %>%
  # add council codes
  mutate(council_area_code = convert_ca_to_lca(Council_Area_Name))


# Care Home Names ---------------------------------------

ch_names <- ch_clean %>%
  clean_up_free_text(ch_name, remove_punct = TRUE) %>%
  # check for duplicate in FY
  mutate(open_in_fy = is.na(DateCanx) | DateCanx > start_fy(convert_fyyear_to_year(year)))


# Outfile ---------------------------------------

outfile <- ch_names %>%
  group_by(ch_postcode) %>%
  mutate(
    ch_name = last(ch_name),
    council_area_code = last(council_area_code),
    n_in_fy = sum(open_in_fy),
    n_at_postcode = n()
  ) %>%
  select(ch_postcode, ch_name, council_area_code, n_in_fy, n_at_postcode) %>%
  ungroup() %>%
  arrange(ch_postcode, ch_name, council_area_code)


outfile %>%
  # .zsav
  write_sav(get_ch_name_lookup_path(year, ext = "zsav", check_mode = "write")) %>%
  # .rds file
  write_rds(get_ch_name_lookup_path(year, check_mode = "write"))


# End of Script #
