#####################################################
# Social Care - Care Home Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
######################################################

# Load packages
library(dplyr)
library(createslf)
library(phsmethods)


year <- check_year_format("1920")


#######################################################

## Social Care Demographic ##

# Read in Social Care demographic data -----------------

sc_demog <- haven::read_sav(get_sc_demog_lookup_path())


#######################################################

## Care Home ##

# Read in CH lookup ---------------------------------------

ch_lookup <- readxl::read_xlsx(get_slf_ch_path()) %>%
  rename(ch_postcode = "AccomPostCodeNo")


# Data Cleaning ---------------------------------------

ch_clean <- ch_lookup %>%
  mutate(ch_postcode = postcode(ch_postcode))


# Read in CH data --------------------------------------

ch_data <- haven::read_sav(get_sc_ch_episodes_path())


# Match with demographic data  ------------------------

matched_ch_data <- ch_data %>%
  left_join(sc_demog, by = c("sending_location", "social_care_id", "chi", "gender", "dob", "postcode"))


# Data Cleaning ---------------------------------------

ch_clean <- matched_ch_data %>%
  # clean postcode
  mutate(across(contains("postcode"), .x = postcode(.x, format = "pc7"))) %>%
















#######################################################

# Read in CH lookup ---------------------------------------

ch_lookup <- readxl::read_xlsx(get_slf_ch_path())


# Data Cleaning ---------------------------------------

ch_lookup_clean <- ch_lookup %>%
  # rename
  rename(care_home_postcode = "AccomPostCodeNo") %>%
  # correct postcode formatting
  mutate(postcode(care_home_postcode), format = "pc7")


# Outfile ---------------------------------------

outfile <- ch_lookup_clean %>%
  group_by(ServiceName, care_home_postcode, Council_Area_Name) %>%
  mutate(DateReg = min(DateReg),
         DateCanx = max(DateCanx)) %>%
  ungroup() %>%
  # remove any old Care Homes
  filter(DateReg > as.Date("01-04-2015") | DateReg == as.Date("01-04-2015") |
           DateCanx > as.Date("01-04-2015") | DateCanx == as.Date("01-04-2015")) %>%
  # sort cases by CareHomePostcode Council_Area_Name DateReg
  arrange(care_home_postcode, Council_Area_Name, DateReg) %>%
  #  lca
  mutate(lca = ca_to_lca(Council_Area_Name))




# Read in Client data ---------------------------------------

# Specify year
year <- check_year_format("1920")

# Read in data that is within FY dates
ch_data <- haven::read_sav(get_sc_ch_episodes_path(update = latest_update())) %>%
  filter(record_keydate1 %in% range(start_fy(year), end_fy(year))) %>%
  # Remove any episodes where the latest submission was before the current year and the record started earlier with an open end date
  filter(!(year > as.numeric(substr(sc_latest_submission, 1, 4))))


# Match on Client Data ------------------------------

client_data <- sc_client <- haven::read_sav(fs::path(
  get_year_dir(year),
  paste0("Client_for_Source-20", year),
  ext = "zsav"
))

matched_data <- ch_data %>%
  left_join(client_data, by = c("sending_location", "social_care_id"))

