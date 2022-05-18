#####################################################
# Care Home
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################


# Load packages
library(dplyr)
library(dbplyr)
library(createslf)
library(phsmethods)
library(lubridate)


fyyear <- check_year_format("1920")


## Care Home Lookup ##

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

ch_name_lookup_outfile <- ch_names %>%
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

ch_name_lookup_outfile %>%
  # .zsav
  haven::write_sav(get_ch_name_lookup_path(fyyear, ext = "zsav")) %>%
  # .rds file
  readr:write_rds(get_ch_name_lookup_path(fyyear, ext = "rds"))


# ----------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------

## Source Care Homes ##

## Source Care Homes ##


# Read in data---------------------------------------

source_ch_data <- haven::read_sav(get_sc_ch_episodes_path()) %>%
  # select episodes for FY
  filter(record_keydate1 %in% range(start_fy(year), end_fy(year)) |
    (record_keydate1 <= end_fy(year) & record_keydate2 >= start_fy(year) | is.na(record_keydate2))) %>%
  # remove any episodes where the latest submission was before the current year
  filter(convert_fyyear_to_year(year) > substr(sc_latest_submission, 1, 4))


# Match on Client Data ---------------------------------------

# read client data in
client_data <- readr::read_rds(get_source_extract_path(year, type = "Client", ext = "rds"))

# match to client data
matched_data <- source_ch_data %>%
  left_join(client_data, by = c("sending_location", "social_care_id"))


# Data Cleaning ---------------------------------------

source_ch_clean <- matched_data %>%
  # create variables
  mutate(
    year = convert_fyyear_to_year(fyyear),
    recid = "CH",
    SMRType = "Care-Home"
  ) %>%
  # compute age variable
  compute_age(fyyear, dob) %>%
  # compute lca variable from sending_location
  mutate(lca = convert_sending_location_to_lca(sending_location)) %>%
  # bed days
  # create dummy end where blank
  mutate(dummy_discharge = if_else(is.na(record_keydate2), end_fy(fyyear) + days(1), record_keydate2)) %>%
  create_monthly_beddays(year, record_keydate1, dummy_discharge) %>%
  # year stay
  mutate(yearstay = rowSums(across(ends_with("_beddays")))) %>%
  # total length of stay
  mutate(stay = as.period(interval(start_fy(fyyear), record_keydate1))$day +
    yearstay +
    as.period(interval(end_fy(fyyear), dummy_discharge))$day)


# Costs  ---------------------------------------

# read in CH Costs Lookup
ch_costs <- haven::read_sav(get_ch_costs_path()) %>%
  rename(
    year = "Year",
    ch_nursing = "nursing_care_provision"
  )


# match costs
matched_costs <- source_ch_clean %>%
  left_join(ch_costs, by = c("year", "ch_nursing"))


costs <- matched_costs %>%
  # monthly costs
  create_monthly_costs(yearstay, cost_per_day) %>%
  # cost total net
  mutate(cost_total_net = rowSums(across(ends_with("_cost"))))


# Outfile  ---------------------------------------

outfile <- costs %>%
  arrange(chi, record_keydate1, record_keydate2) %>%
  select(
    year,
    recid,
    SMRType,
    chi,
    person_id,
    dob,
    age,
    gender,
    postcode,
    lca,
    record_keydate1,
    record_keydate2,
    sc_latest_submission,
    starts_with("ch_"),
    yearstay,
    stay,
    cost_total_net,
    ends_with("_beddays"),
    ends_with("_cost"),
    starts_with("sc_")
  )


outfile %>%
  # .zsav
  write_sav(get_source_extract_path(fyyear, type = "CH", ext = "zsav")) %>%
  # .rds file
  write_rds(get_source_extract_path(fyyear, type = "CH", ext = "rds"))



# End of Script #
