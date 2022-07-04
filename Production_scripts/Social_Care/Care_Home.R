#####################################################
# Care Home Data
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Care Home Data from Platform
# Description - Cleans the data and matches on demographic,
# cleans Care Home names and postcodes
# merges records to a single row per person
# compares to Deaths data
# continuous Care Home Stays marker
#####################################################


# Load packages
library(dplyr)
library(dbplyr)
library(createslf)
library(lubridate)
library(tidyr)
library(phsmethods)



# Read in data---------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 care home
ch_data <- tbl(db_connection, in_schema("social_care_2", "carehome_snapshot")) %>%
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
  # correct FY 2017
  mutate(financial_quarter = if_else(financial_year == 2017 & is.na(financial_quarter), 4, financial_quarter)) %>%
  mutate(period = if_else(financial_year == 2017 & financial_quarter == 4, "2017Q4", period)) %>%
  # filter missing admission dates
  filter(!is.na(ch_admission_date)) %>%
  collect()


# Data Cleaning ---------------------------------------

# period start and end dates
period_dates <- ch_data %>%
  distinct(period) %>%
  mutate(
    record_date = yq(period) %m+% period(6, "months") %m-% days(1),
    qtr_start = yq(period) %m+% period(3, "months")
  )

ch_clean <- ch_data %>%
  left_join(period_dates, by = c("period")) %>%
  # filter out any episodes where discharge is before admission
  mutate(dis_before_adm = ch_admission_date > ch_discharge_date & !is.na(ch_discharge_date)) %>%
  filter(dis_before_adm == FALSE) %>%
  # sort data
  arrange(sending_location, social_care_id, period, ch_admission_date, ch_discharge_date)


# Match with demographics data  ---------------------------------------

# read in demographic data
sc_demog <- readr::read_rds(get_sc_demog_lookup_path())

matched_ch_data <- ch_clean %>%
  left_join(sc_demog, by = c("sending_location", "social_care_id"))%>%
  # correct postcode formatting
  mutate(across(contains("postcode"), .x = format_postcode(.x)))


# postcode lookup
valid_spd_postcodes <- haven::read_sav(get_slf_postcode_path(ext = "zsav")) %>%
  pull(postcode)


# Care Home Name lookup
ch_name_lookup <- readxl::read_xlsx(get_slf_ch_name_lookup_path()) %>%
  rename(
    ch_postcode = "AccomPostCodeNo",
    ch_name_lookup = "ServiceName"
  ) %>%
  select(
    ch_postcode,
    ch_name_lookup,
    DateReg,
    DateCanx
  ) %>%
  # format postcode and CH name
  mutate(ch_postcode = format_postcode(ch_postcode),
         ch_name_lookup = toupper(ch_name_lookup))


name_postcode_clean <- matched_ch_clean %>%
  # deal with capitalisation of CH names
  mutate(ch_name = stringr::str_to_title(ch_name)) %>%
  # deal with punctuation in the CH names
  mutate(ch_name = stringr::str_replace_all(ch_name, "[[:punct:]]", " ")) %>%
  # replace invalid postcode with NA
  mutate(ch_postcode = na_if(ch_postcode, ch_postcode %in% valid_spd_postcodes)) %>%
  # where there is only a single Care Home at the Postcode, use that name
  group_by(ch_postcode) %>%
  # fill in names where NA but has a name in another record
  fill(ch_name, .direction = "downup") %>%
  # change name if CH name does not match previous name
  mutate(ch_name_change_counter = pmax(ch_name != lag(ch_name) & !is.na(ch_name), FALSE, na.rm = TRUE)) %>%
  mutate(ch_name = if_else(ch_name_change_counter == 1, last(ch_name), ch_name)) %>%
  ungroup() %>%
  # match CH names with CH lookup
  left_join(ch_lookup, by = c("ch_postcode")) %>%
  # check CH name matches the lookup name
  mutate(name_match = if_else(ch_name != ch_name_lookup | is.na(ch_name_lookup), 0, 1)) %>%
  # replace ch name with lookup name if not a match
  mutate(ch_name = if_else(name_match == 0 & !is.na(ch_name_lookup), ch_name_lookup, ch_name)) %>%
  # check admission date within CH dates
  mutate(date_check = if_else(is.na(DateReg) | is.na(DateCanx) | ch_admission_date %in% range(DateReg, DateCanx), TRUE, FALSE))


# Data Cleaning Care Home Data ---------------------------------------

ch_data_clean <- matched_ch_data %>%
  # sort data
  arrange(sending_location, social_care_id, ch_admission_date, period) %>%
  group_by(sending_location, social_care_id, ch_admission_date) %>%
  # fill in nursing care provision when missing but present in the following entry
  fill(nursing_care_provision) %>%
  # tidy up ch_provider using "6" when disagreeing values
  fill(ch_provider) %>%
  mutate(
    min_ch_provider = min(ch_provider),
    max_ch_provider = max(ch_provider)
  ) %>%
  mutate(ch_provider = if_else(min_ch_provider != max_ch_provider, "6", ch_provider)) %>%
  select(-c(min_ch_provider, max_ch_provider)) %>%
  # when multiple social_care_id from sending_location for single CHI
  # replace social_care_id with latest
  mutate(latest_sc_id = last(social_care_id)) %>%
  # count changed social_care_id
  mutate(
    changed_sc_id = if_else(!is.na(chi) & social_care_id != latest_sc_id, 1, 0),
    social_care_id = if_else(!is.na(chi) & social_care_id != latest_sc_id,
      latest_sc_id, social_care_id
    )) %>%
  # remove any duplicate records
  distinct() %>%
  # counter for split episodes
  mutate(split_episode_counter = pmax(nursing_care_provision != lag(nursing_care_provision), FALSE, na.rm = TRUE) %>%
  cumsum()) %>%
  ungroup()

# count changed social_care_id
ch_data_clean %>% count(changed_sc_id)


# Merge Records ---------------------------------------

# to a single row per episode where admission the same
ch_episode <- ch_data_clean %>%
  # when nursing_care_provision is different on records within the episode, split the episode at this point
  group_by(chi, sending_location, social_care_id, ch_admission_date, nursing_care_provision, split_episode_counter) %>%
  summarise(
    ch_discharge_date = last(ch_discharge_date),
    ch_provider = max(ch_provider),
    record_date = max(record_date),
    qtr_start = max(qtr_start),
    sc_latest_submission = max(period),
    ch_name = last(ch_name),
    ch_postcode = last(ch_postcode),
    reason_for_admission = last(reason_for_admission),
    gender = first(gender),
    dob = first(dob),
    postcode = first(postcode)
  ) %>%
  ungroup() %>%
  # Amend dates for split episodes
  # Change the start and end date as appropriate when an episode is split, using the start / end date of the submission quarter
  group_by(chi, sending_location, social_care_id, ch_admission_date) %>%
  # counter for latest submission
  mutate(latest_submission_counter = pmax(sc_latest_submission != lag(sc_latest_submission), FALSE, na.rm = TRUE)) %>%
  mutate(sum_latest_submission = cumsum(latest_submission_counter)) %>%
  mutate(
  # If it's the first episode(s) then keep the admission date(s), otherwise use the start of the quarter
    ch_admission_date = if_else(sum_latest_submission == min(sum_latest_submission), ch_admission_date, qtr_start),
      # If it's the last episode(s) then keep the discharge date(s), otherwise use the end of the quarter
    ch_discharge_date = if_else(sum_latest_submission == max(sum_latest_submission), ch_discharge_date, record_date)
  ) %>%
  ungroup()


# Compare to Deaths Data ---------------------------------------

deaths_data <- haven::read_sav(get_slf_deaths_path()) # remaining here until .rds file saved
deaths_data <- readr::read_rds(get_slf_deaths_path())


# match ch_episode data with deaths data
matched_deaths_data <- ch_episode %>%
  left_join(deaths_data, by = "chi") %>%
  # compare discharge date with NRS and CHI death date
  # if either of the dates are 5 or fewer days before discharge
  # adjust the discharge date to the date of death
  # corrects most cases of ‘discharge after death’
  mutate(
    dis_after_death = ymd(death_date) <= ymd(ch_discharge_date) - days(5),
    dis_after_death = replace_na(dis_after_death, FALSE)
  ) %>%
  mutate(ch_discharge_date = if_else(dis_after_death, death_date, ch_discharge_date)) %>%
  # remove any episodes where discharge is now before admission, i.e. death was before admission
  mutate(
    dis_before_adm = replace_na(ch_discharge_date < ch_admission_date, FALSE)
  ) %>%
  filter(!dis_before_adm) %>%
  ungroup()


# Continuous Care Home Stays ---------------------------------------

# stay will be continuous as long as the admission date is the next day or earlier than the previous discharge date

ch_markers <- matched_deaths_data %>%
  # ch_chi_cis
  group_by(chi, sending_location, social_care_id) %>%
  mutate(continuous_stay_chi = pmax(ch_admission_date >= lag(ch_discharge_date) + days(1), FALSE, na.rm = TRUE)) %>%
  mutate(ch_chi_cis = cumsum(continuous_stay_chi) + 1) %>%
  ungroup() %>%
  # ch_sc_id_cis
  # uses the social care id and sending location so can be used for episodes that are not attached to a CHI number
  # This will restrict continuous stays to each Local Authority
  group_by(social_care_id, sending_location) %>%
  mutate(continuous_stay_sc = pmax(ch_admission_date >= lag(ch_discharge_date) + days(1), FALSE, na.rm = TRUE)) %>%
  mutate(ch_sc_id_cis = cumsum(continuous_stay_sc) + 1) %>%
  ungroup()


# Outfile ---------------------------------------

outfile <- ch_markers %>%
  create_person_id() %>%
  rename(
    record_keydate1 = ch_admission_date,
    record_keydate2 = ch_discharge_date,
    ch_adm_reason = reason_for_admission,
    ch_nursing = nursing_care_provision
  ) %>%
  arrange(
    sending_location,
    social_care_id,
    chi,
    record_keydate1,
    record_keydate2
  ) %>%
  select(
    chi,
    person_id,
    gender,
    dob,
    postcode,
    sending_location,
    social_care_id,
    ch_name,
    ch_postcode,
    record_keydate1,
    record_keydate2,
    ch_chi_cis,
    ch_sc_id_cis,
    ch_provider,
    ch_nursing,
    ch_adm_reason,
    sc_latest_submission
  )


outfile %>%
  # .zsav
  write_sav(get_sc_ch_episodes_path(latest_update)) %>%
  # .rds file
  write_rds(get_sc_ch_episodes_path(latest_update))


# End of Script #
