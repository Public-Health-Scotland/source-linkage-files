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
library(lubridate)
library(tidyr)
library(createslf)


# Read in data---------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 care home
ch_data <-
  tbl(
    db_connection,
    dbplyr::in_schema("social_care_2", "carehome_snapshot")
  ) %>%
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
  mutate(financial_quarter = if_else(
    financial_year == 2017 &
      is.na(financial_quarter),
    4,
    financial_quarter
  )) %>%
  mutate(period = if_else(financial_year == 2017 &
    financial_quarter == 4, "2017Q4", period)) %>%
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
  mutate(across(
    c(
      ch_provider,
      reason_for_admission,
      type_of_admission,
      nursing_care_provision
    ),
    as.integer
  )) %>%
  left_join(period_dates, by = c("period")) %>%
  # Set missing admission date to start of the submitted quarter
  mutate(ch_admission_date = if_else(is.na(ch_admission_date), qtr_start, ch_admission_date)) %>%
  # If the dis date is before admission, remove the dis date
  mutate(
    ch_discharge_date = if_else(
      ch_admission_date > ch_discharge_date,
      NA_Date_,
      ch_discharge_date
    )
  )


# Match with demographics data  ---------------------------------------

# read in demographic data
sc_demog <- readr::read_rds(get_sc_demog_lookup_path())

# Get a list of confirmed valid Scottish postcodes from the SPD
valid_spd_postcodes <- readr::read_rds(get_spd_path()) %>%
  pull(pc7)

matched_ch_data <- ch_clean %>%
  left_join(sc_demog, by = c("sending_location", "social_care_id")) %>%
  # Make the care home name more uniform
  mutate(ch_name = clean_up_free_text(ch_name)) %>%
  # correct postcode formatting
  mutate(across(contains("postcode"), phsmethods::format_postcode),
    # replace invalid postcode with NA
    ch_postcode = na_if(ch_postcode, ch_postcode %in% valid_spd_postcodes)
  )


# Care Home Name lookup
ch_name_lookup <-
  # Care Home name lookup from the Care Inspectorate
  # Previous contact Al Scrougal - Al.Scougal@careinspectorate.gov.scot
  readxl::read_xlsx(get_slf_ch_name_lookup_path()) %>%
  # Drop any Care Homes that were closed before 2017/18
  filter(is.na(DateCanx) | DateCanx >= start_fy("1718")) %>%
  rename(
    ch_postcode = "AccomPostCodeNo",
    ch_name_validated = "ServiceName"
  ) %>%
  select(
    ch_postcode,
    ch_name_validated,
    DateReg,
    DateCanx
  ) %>%
  # Standardise the postcode and CH name
  mutate(
    ch_postcode = phsmethods::format_postcode(ch_postcode),
    ch_name_validated = clean_up_free_text(ch_name_validated)
  ) %>%
  # Merge any duplicates, and get the interval each CH name was active
  group_by(ch_postcode, ch_name_validated) %>%
  summarise(open_interval = interval(min(DateReg), replace_na(max(DateCanx), Sys.Date()))) %>%
  # Find the latest date for each CH name
  mutate(latest_close_date = max(int_end(open_interval))) %>%
  ungroup() %>%
  arrange(open_interval)

# Generate some metrics for how the submitted names connect to the valid names
ch_name_match_metrics <- matched_ch_data %>%
  distinct(ch_postcode, ch_name) %>%
  left_join(ch_name_lookup, by = c("ch_postcode")) %>%
  drop_na() %>%
  # Work out string distances between names for each postcode
  mutate(
    match_distance_jaccard = stringdist::stringdist(ch_name, ch_name_validated, method = "jaccard"),
    match_distance_cosine = stringdist::stringdist(ch_name, ch_name_validated, method = "cosine"),
    match_mean = (match_distance_jaccard + match_distance_cosine) / 2
  ) %>%
  # Drop any name matches which aren't very close
  filter(match_distance_jaccard <= 0.25 | match_distance_cosine <= 0.3) %>%
  group_by(ch_postcode, ch_name) %>%
  # Identify the closest match in case there are multiple close matches
  mutate(
    min_jaccard = min(match_distance_jaccard, na.rm = TRUE),
    min_cosine = min(match_distance_cosine, na.rm = TRUE),
    min_match_mean = min(match_mean, na.rm = TRUE)
  ) %>%
  ungroup()

no_postcode_match <- matched_ch_data %>%
  anti_join(ch_name_lookup, by = "ch_postcode")

name_postcode_clean <- matched_ch_data %>%
  # Remove records with no matching postcode, we'll add them back later
  semi_join(ch_name_lookup, by = "ch_postcode") %>%
  # Create a unique ID per row so we can get rid of duplicates later
  mutate(ch_record_id = row_number()) %>%
  # Match CH names with the generated metrics and the lookup. This will create
  # duplicates which should be filtered out as we identify matches
  left_join(ch_name_match_metrics, by = c("ch_postcode", "ch_name")) %>%
  mutate(
    # Work out the duration of the stay
    # If the end date is missing set this to the end of the quarter
    stay_interval = interval(
      ch_admission_date,
      min(ch_discharge_date, record_date, na.rm = TRUE)
    ),
    # Highlight which stays overlap with an open care home name
    stay_overlaps_open = int_overlaps(stay_interval, open_interval) & (int_start(stay_interval) >= int_start(open_interval)),
    # Hightlight which names seem to be good matches
    name_match = case_when(
      # Exact match
      ch_name == ch_name_validated ~ TRUE,
      # Submitted name is missing and stay dates are valid for the CH
      is.na(ch_name) & stay_overlaps_open ~ TRUE,
      # This name had the closest 'jaccard' distance of all possibilities
      (min_jaccard == match_distance_jaccard) & match_distance_jaccard <= 0.25 ~ TRUE,
      # This name had the closest 'cosine' distance of all possibilities
      (min_cosine == match_distance_cosine) & match_distance_cosine <= 0.3 ~ TRUE,
      # This name had the closest 'mean' distance (used when the above disagree)
      (min_match_mean == match_mean) & match_mean <= 0.25 ~ TRUE,
      # No good match
      TRUE ~ FALSE
    )
  ) %>%
  # Group by record (There will be duplicate rows per record if there multiple 'options' for the possible CH name)
  group_by(ch_record_id) %>%
  mutate(
    # Highlight where the record has no matches out of any of the options
    no_name_matches = all(!name_match),
    # Highlight where the record has no overlaps (in dates) with any of the options
    no_overlaps = all(!stay_overlaps_open)
  ) %>%
  # Keep a record if:
  # 1) It's name matches `name_match`
  # Or either 2)a) None of the option's names match AND this option overlaps in dates (e.g. the submitted name is missing but the dates match)
  # or 2)b) None of the option's names match AND none of the dates overlap (i.e. we don't have any idea what name to use)
  filter(n() == 1 | sum(name_match) == 1 | all(!name_match)) %>%
  # For the records which still have multiple options (usually multiple names matched)
  filter(n() == 1 | int_end(open_interval) == latest_close_date) %>%
  filter(n() == 1 | match_mean == min_match_mean) %>%
  ungroup() %>%
  # Bring back to single record with no duplicates introduce by the lookup
  distinct(ch_record_id, .keep_all = TRUE) %>%
  # Replace the ch name with our best guess at the proper name from the lookup
  mutate(
    ch_name_old = ch_name,
    ch_name = dplyr::if_else(is.na(ch_name_validated), ch_name, ch_name_validated)
  ) %>%
  # Bring back the records which had no postcode match
  bind_rows(no_postcode_match)

(check_names <- name_postcode_clean %>%
  count(ch_name_old, ch_name, sort = TRUE))

# Data Cleaning Care Home Data ---------------------------------------

ch_data_clean <- name_postcode_clean %>%
  # sort data
  arrange(sending_location, social_care_id, ch_admission_date, period) %>%
  mutate(
    min_ch_provider = min(ch_provider),
    max_ch_provider = max(ch_provider)
  ) %>%
  mutate(ch_provider = if_else(min_ch_provider != max_ch_provider, 6L, ch_provider)) %>%
  select(-c(min_ch_provider, max_ch_provider)) %>%
  # when multiple social_care_id from sending_location for single CHI
  # replace social_care_id with latest
  group_by(sending_location, chi) %>%
  mutate(latest_sc_id = last(social_care_id)) %>%
  # count changed social_care_id
  mutate(
    changed_sc_id = !is.na(chi) & social_care_id != latest_sc_id,
    social_care_id = if_else(changed_sc_id, latest_sc_id, social_care_id)
  ) %>%
  ungroup() %>%
  group_by(sending_location, social_care_id, ch_admission_date) %>%
  # fill in nursing care provision when missing but present in the following entry
  mutate(nursing_care_provision = na_if(nursing_care_provision, 9)) %>%
  fill(nursing_care_provision, .direction = "downup") %>%
  # tidy up ch_provider using 6 when disagreeing values
  fill(ch_provider, .direction = "downup") %>%
  # remove any duplicate records before merging for speed and simplicity
  distinct() %>%
  # counter for split episodes
  mutate(
    split_episode = replace_na(nursing_care_provision != lag(nursing_care_provision), TRUE),
    split_episode_counter = cumsum(split_episode)
  ) %>%
  ungroup()


# count changed social_care_id
ch_data_clean %>% count(changed_sc_id)


# Merge Records ---------------------------------------

# to a single row per episode where admission the same
ch_episode <- ch_data_clean %>%
  # when nursing_care_provision is different on records within the episode, split the episode at this point
  group_by(
    chi,
    sending_location,
    social_care_id,
    ch_admission_date,
    nursing_care_provision,
    split_episode_counter
  ) %>%
  summarise(
    across(
      c(
        ch_discharge_date,
        ch_provider,
        record_date,
        qtr_start,
        sc_latest_submission,
        ch_name,
        ch_postcode,
        reason_for_admission
      ),
      last
    ),
    across(c(gender, dob, postcode), first)
  ) %>%
  ungroup() %>%
  # Amend dates for split episodes
  # Change the start and end date as appropriate when an episode is split, using the start / end date of the submission quarter
  group_by(chi, sending_location, social_care_id, ch_admission_date) %>%
  # counter for latest submission
  # TODO check if this is the same as split_episode_counter?
  mutate(
    latest_submission_counter = replace_na(sc_latest_submission != lag(sc_latest_submission), TRUE),
    sum_latest_submission = cumsum(latest_submission_counter)
  ) %>%
  # TODO double check this works
  mutate(
    # If it's the first episode(s) then keep the admission date(s), otherwise use the start of the quarter
    ch_admission_date = if_else(
      sum_latest_submission == min(sum_latest_submission),
      ch_admission_date,
      qtr_start
    ),
    # If it's the last episode(s) then keep the discharge date(s), otherwise use the end of the quarter
    ch_discharge_date = if_else(
      sum_latest_submission == max(sum_latest_submission),
      ch_discharge_date,
      record_date
    )
  ) %>%
  ungroup()


# Compare to Deaths Data ---------------------------------------

deaths_data <- readr::read_rds(get_slf_deaths_path())


# match ch_episode data with deaths data
matched_deaths_data <- ch_episode %>%
  left_join(deaths_data, by = "chi") %>%
  # compare discharge date with NRS and CHI death date
  # if either of the dates are 5 or fewer days before discharge
  # adjust the discharge date to the date of death
  # corrects most cases of ‘discharge after death’
  mutate(
    dis_after_death = replace_na(
      death_date > (ch_discharge_date - days(5)) &
        death_date < ch_discharge_date,
      FALSE
    )
  ) %>%
  mutate(ch_discharge_date = if_else(dis_after_death, death_date, ch_discharge_date)) %>%
  ungroup() %>%
  # remove any episodes where discharge is now before admission, i.e. death was before admission
  filter(!replace_na(ch_discharge_date < ch_admission_date, FALSE))


# Continuous Care Home Stays ---------------------------------------

# stay will be continuous as long as the admission date is the next day or earlier than the previous discharge date

ch_markers <- matched_deaths_data %>%
  # ch_chi_cis
  group_by(chi) %>%
  mutate(
    continuous_stay_chi = replace_na(ch_admission_date <= lag(ch_discharge_date) + days(1), TRUE),
    ch_chi_cis = cumsum(continuous_stay_chi)
  ) %>%
  ungroup() %>%
  # ch_sc_id_cis
  # uses the social care id and sending location so can be used for episodes that are not attached to a CHI number
  # This will restrict continuous stays to each Local Authority
  group_by(social_care_id, sending_location) %>%
  mutate(
    continuous_stay_sc = replace_na(ch_admission_date <= lag(ch_discharge_date) + days(1), TRUE),
    ch_sc_id_cis = cumsum(continuous_stay_sc)
  ) %>%
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
  write_sav(get_sc_ch_episodes_path(ext = "zsav", check_mode = "write")) %>%
  # .rds file
  write_rds(get_sc_ch_episodes_path(check_mode = "write"))


# End of Script #
