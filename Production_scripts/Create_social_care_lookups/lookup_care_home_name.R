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
  # correct postcode formatting
  mutate(AccomPostCodeNo = postcode(AccomPostCodeNo)) %>%
  rename(ch_postcode = "AccomPostCodeNo") %>%
  mutate(
    DateReg = as.Date(DateReg),
    DateCanx = as.Date(DateCanx)
  ) %>%
  # clean up care home names
  group_by(
    ServiceName,
    ch_postcode,
    Council_Area_Name
  ) %>%
  summarise(
    DateReg = min(DateReg),
    DateCanx = max(DateCanx)
  ) %>%
  # remove any old Care Homes which aren't of interest
  filter(DateReg >= lubridate::ymd("2015-04-01") | DateCanx >= lubridate::ymd("2015-04-01")) %>%
  arrange(ch_postcode, Council_Area_Name, DateReg) %>%
  # when a Care Home changes name mid-year change to the start of the FY
  mutate(year_opened = lubridate::year(DateReg)) %>%
  mutate(change_reg_date = if_else(lubridate::month(DateReg) < 4, 1, 0)) %>%
  mutate(year_opened = if_else(change_reg_date == 1, year_opened - 1, year_opened)) %>%
  mutate(DateReg = if_else(change_reg_date == 1, as.Date(paste0(year_opened, "/04/01")), DateReg)) %>%
  arrange(ch_postcode, Council_Area_Name, desc(DateReg)) %>%
  mutate(change_canx_date = if_else(!is.na(DateCanx) |
                                      (ch_postcode == lag(ch_postcode) &
                                         Council_Area_Name == lag(Council_Area_Name) &
                                         lag(change_reg_date) == 1), 1, 0)) %>%
  mutate(change_canx_date = replace_na(change_canx_date, 0)) %>%
  mutate(DateCanx = if_else(change_canx_date == 1, as.Date(paste0(lubridate::year(DateReg), "/03/31")), DateCanx)) %>%
  arrange(ch_postcode, Council_Area_Name, DateReg) %>%
  ungroup() %>%
  # add council codes
  mutate(council_area_code = convert_ca_to_lca(Council_Area_Name))


# Care Home Names ---------------------------------------

ch_names <- ch_clean %>%
  rename(ch_name = "ServiceName") %>%
  # deal with capitalisation of CH names
  mutate(ch_name = stringr::str_to_title(ch_name)) %>%
  # deal with punctuation in the CH names
  mutate(ch_name = stringr::str_replace_all(ch_name, "[[:punct:]]", " ")) %>%
  # deal with whitespace at start and end and witihin
  mutate(
    ch_name = stringr::str_trim(ch_name, side = "both"),
    ch_name = stringr::str_squish(ch_name)
  ) %>%
  # check for duplicate in FY
  mutate(open_in_fy = if_else(is.na(DateCanx) | DateCanx > lubridate::ymd(paste0(convert_fyyear_to_year(year), "-04-01")), 1, 0))


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
