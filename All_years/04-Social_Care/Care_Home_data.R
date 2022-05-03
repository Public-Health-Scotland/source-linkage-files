#####################################################
# Care Home Data
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


latest_validated_period <- "2021Q2"

latest_update <- "Mar_2022"


# Read in data---------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 care home
ch_data <- tbl(db_connection, in_schema("social_care_2", "carehome")) %>%
  select(
    ch_name,
    ch_postcode,
    sending_location,
    social_care_id,
    financial_year,
    financial_quarter,
    period,
    ch_provider,
    reason_for_admission,
    type_of_admission,
    nursing_care_provision,
    ch_admission_date,
    ch_discharge_date,
    age
  ) %>%
  collect()


# Data Cleaning ---------------------------------------

ch_clean <- ch_data %>%
  # correct period 2017
  mutate(financial_quarter = if_else(financial_year == 2017 & is.na(financial_quarter), 4, financial_quarter)) %>%
  mutate(period = if_else(financial_year == 2017 & financial_quarter == 4, "2017Q4", period)) %>%
  # drop unvalidated records
  filter(period < latest_validated_period) %>%
  # create financial quarter end and start dates
  get_fq_dates(period) %>%
  # filter missing admission dates
  filter(!is.na(ch_admission_date)) %>%
  # filter out any episodes where discharge is before admission
  mutate(dis_before_adm = ch_admission_date > ch_discharge_date & !is.na(ch_discharge_date)) %>%
  filter(dis_before_adm == FALSE) %>%
  # sort data
  arrange(sending_location, social_care_id, period, ch_admission_date, ch_discharge_date)


# Match with demogrpahics data  ---------------------------------------

# Read in data---------------------------------------
sc_demog <- haven::read_sav(get_sc_demog_lookup_path())

matched_ch_data <- ch_clean %>%
  left_join(sc_demog, by = c("sending_location", "social_care_id"))


# Data Cleaning Care Home Name and Postcode ---------------------------------------
matched_ch_clean <- matched_ch_data %>%
  # correct postcode
  mutate(across(contains("postcode"), .x = postcode(.x)))


# Data Cleaning Care Home Data ---------------------------------------

ch_data_clean <- matched_ch_data %>%
  # sort data
  arrange(sending_location, social_care_id, period, ch_admission_date, period) %>%
  # fill in nursing care provision when missing but present in the following entry
  mutate(nursing_care_provision = if_else(is.na(nursing_care_provision) &
                                               !is.na(lead(nursing_care_provision)) &
                                               lead(sending_location) == sending_location &
                                               lead(social_care_id) == social_care_id &
                                               lead(ch_admission_date) == ch_admission_date,
                                             lead(nursing_care_provision),
                                          nursing_care_provision)) %>%
  # tidy up ch_provider using "6" when disagreeing values
  group_by(sending_location,
           social_care_id,
           ch_admission_date,
           nursing_care_provision) %>%
  mutate(first_ch_provider = first(ch_provider),
         last_ch_provider = last(ch_provider)) %>%
  mutate(ch_provider = if_else(first_ch_provider != last_ch_provider, "6", ch_provider)) %>%
  select(-c(first_ch_provider, last_ch_provider)) %>%
  ungroup() %>%
  # when multiple social_care_id from sending_location for single CHI
  # replace social_care_id with latest
  group_by(chi, sending_location) %>%
  mutate(latest_sc_id = last(social_care_id)) %>%
  # count changed
  mutate(changed_sc_id = if_else(!is.na(chi) & social_care_id != latest_sc_id, 1, 0),
         social_care_id = if_else(!is.na(chi) & social_care_id != latest_sc_id,
                                  latest_sc_id, social_care_id)) %>%
  ungroup() %>%
  # remove any duplicate records
  distinct()

# count changed social_care_id
ch_data_clean %>% count(changed_sc_id)


# Merge Records ---------------------------------------

# to a single row per episode where admission the same
ch_episode <- ch_data_clean %>%
  # sort
  arrange(sending_location, social_care_id, ch_admission_date) %>%
  # Where the ch_provider or nursing_care_provision is different on records within the episode, split the episode at this point.
  group_by(chi, sending_location, social_care_id, ch_admission_date, ch_provider, nursing_care_provision) %>%
  summarise(
    ch_discharge_date = last(ch_discharge_date),
    record_date = max(record_date),
    qtr_start = max(qtr_start),
    sc_latest_submission = max(period),
    ch_name = last(ch_name),
    ch_postcode = last(ch_postcode),
    gender = first(gender),
    dob = first(dob),
    postcode = first(postcode)) %>%
  # preserve open end dates
  mutate(dis_date_missing = is.na(ch_discharge_date)) %>%
  # Amend dates for split episodes
  # Change the start and end date as appropriate when an episode is split, using the end date of the submission quarter
  mutate(ch_discharge_date = if_else(is.na(ch_discharge_date) &
                                       !is.na(lead(ch_discharge_date)) &
                                       lead(ch_admission_date) == ch_admission_date &
                                       nursing_care_provision != ch_provider,
                                     record_date, ch_discharge_date)) %>%
  ungroup()

# count if any duplicate records
ch_episode %>% count(duplicated(.))


# Compare to Deaths Data ---------------------------------------

deaths_data <- haven::read_sav(get_slf_deaths_path())

# match with deaths data
matched_deaths_data <- ch_episode %>%
  left_join(deaths_data, by = "chi") %>%
  # compare discharge date with NRS and CHI death date
  # if either of the dates are 5 or fewer days before discharge
  # adjust the discharge date to the date of death
  # corrects most cases of ‘discharge after death’
  mutate(dis_after_death = death_date == ch_discharge_date - 5 | death_date < ch_discharge_date - 5) %>%
  mutate(ch_discharge_date = if_else(dis_after_death == TRUE, death_date, ch_discharge_date)) %>%
  # remove any episodes where discharge is now before admission, i.e. death was before admission
  filter(ch_admission_date < ch_discharge_date)


# Continuous Care Home Stays ---------------------------------------

# stay will be continuous as long as the admission date is the next day or earlier than the previous discharge date

ch_markers <- matched_deaths_data %>%
  # ch_chi_cis
  # uses the CHI number so will aggregate across continuous stays even if the data was provided by different local authorities
  group_by(chi) %>%
  mutate(date_1 = ch_admission_date,
         date_2 = lead(ch_discharge_date),
         day_diff = as.numeric(date_2 - date_1)) %>%
  mutate(ch_chi_cis = 1) %>%
  mutate(ch_chi_cis = if_else(day_diff < 1 | day_diff == 1, lead(ch_chi_cis), lead(ch_chi_cis) + 1)) %>%
  ungroup()


  # ch_sc_id_cis
  # uses the social care id and sending location so can be used for episodes that are not attached to a CHI number
  # This will restrict continuous stays to each Local Authority
  group_by




output <- haven::read_sav(get_sc_ch_episodes_path())
