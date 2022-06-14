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
  # clean up care home names
  group_by(
    ch_name,
    ch_postcode,
    Council_Area_Name
  ) %>%
  mutate(
    year_opened = format(DateReg, "%Y"),
    year_canx = format(DateCanx, "%Y")
  ) %>%
  mutate(
    fy_year_opened = convert_year_to_fyyear(year_opened),
    fy_year_canx = convert_year_to_fyyear(year_canx)
  ) %>%
  mutate(
    DateReg = min(DateReg, start_fy(fy_year_opened)),
    DateCanx = max(DateCanx, end_fy(fy_year_closed))
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
