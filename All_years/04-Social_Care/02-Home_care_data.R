library(haven)
library(fs)
library(dplyr)
library(stringr)
library(lubridate)
library(readr)
library(phsmethods)
library(tidyr)

source("All_years/04-Social_Care/02a-hc_functions.R")

sc_con <- phs_db_connection(dsn = "DVPROD")

demog_file_path <- get_demog_file_path(
  social_care_dir = path(
    "/conf/hscdiip",
    "SLF_Extracts/Social_care"
  ),
  latest_update = "Sep_2021"
)

hc_data <-
  tbl(sc_con, dbplyr::in_schema("social_care_2", "homecare")) %>%
  select(
    "sending_location",
    "sending_location_name",
    "period",
    "social_care_id",
    "financial_year",
    "financial_quarter",
    "hc_service_provider",
    "hc_service",
    "hc_service_start_date",
    "hc_service_end_date",
    "hc_period_start_date",
    "hc_period_end_date",
    "multistaff_input",
    "total_staff_home_care_hours",
    "reablement",
    "hc_hours_derived",
    "hc_start_date_after_end_date"
  ) %>%
  collect() %>%
  slice_sample(n = 10000) %>%
  left_join(read_rds(demog_file_path),
    by = c("sending_location", "social_care_id")
  ) %>%
  mutate(
    across(c(where(is_number_like), -chi), parse_number),
    across(where(is_integer_like), as.integer),
    across(where(is.character), zap_empty)
  )

bad_sc_id <- read_rds(demog_file_path) %>%
  mutate(sending_location = as.integer(sending_location)) %>%
  distinct(sending_location, chi, social_care_id) %>%
  filter(chi != "") %>%
  group_by(sending_location, chi) %>%
  filter(n_distinct(social_care_id) > 1) %>%
  left_join(distinct(hc_data, sending_location, sending_location_name),
    by = "sending_location"
  ) %>%
  mutate(last_sc_id = if_else(
    social_care_id != last(social_care_id),
    last(social_care_id),
    NA_character_
  ))

pre_compute_record_dates <- hc_data %>%
  filter(str_detect(period, "^\\d{4}Q\\d$")) %>%
  distinct(period) %>%
  mutate(
    record_date = yq(period) %m+% period(6, "months") %m-% days(1),
    qtr_start = yq(period) %m+% period(3, "months")
  )

# Output table of hc hours
hc_data %>%
  mutate() %>%
  group_by(financial_year, financial_quarter, sending_location_name) %>%
  summarise(
    all_records = n(),
    missing_derived_hours = sum(is.na(hc_hours_derived))
  ) %>%
  ungroup() %>%
  filter(missing_derived_hours >= 1) %>%
  mutate(pct_missing = scales::percent(missing_derived_hours / all_records, 0.1)) %>%
  gt::gt(groupname_col = "financial_year") %>%
  gt::gtsave("missing_derived_hours.html")

working_data <- hc_data %>%
  # Fix bad 2017 period
  tidylog::mutate(
    financial_quarter = if_else(
      period == "2017" &
        financial_quarter == 0 &
        financial_year == 2017,
      4L,
      financial_quarter
    )
  ) %>%
  tidylog::mutate(period = if_else(period == "2017", "2017Q4", period)) %>%
  left_join(pre_compute_record_dates, by = "period") %>%
  # Drop bad rows
  tidylog::filter(hc_start_date_after_end_date == 0) %>%
  # Replace missing start dates with the start of the quater
  tidylog::mutate(hc_service_start_date = if_else(
    !is.na(hc_service_start_date),
    qtr_start,
    hc_service_start_date
  )) %>%
  # Drop unvalidated (2020Q4 rows)
  tidylog::filter(period != "2020Q4") %>%
  # Set reablement 9 to NA for now
  mutate(reablement = na_if(reablement, 9L)) %>%
  select(
    sending_location,
    sending_location_name,
    chi,
    social_care_id,
    hc_service_start_date,
    hc_service_end_date,
    period,
    record_date,
    hc_service,
    hc_service_provider,
    reablement,
    hc_hours_derived,
    total_staff_home_care_hours,
    multistaff_input,
    gender,
    dob,
    postcode
  ) %>%
  arrange(sending_location, chi, record_date, hc_service_start_date) %>%
  # fix multiple sc_id per chi
  group_by(sending_location, chi) %>%
  mutate(replace_sc_id = !is.na(chi) &&
    social_care_id != last(social_care_id)) %>%
  tidylog::mutate(social_care_id = if_else(replace_sc_id, last(social_care_id), social_care_id)) %>%
  ungroup() %>%
  # Fix hours where derived hours are missing
  mutate(multistaff_input = min(1, multistaff_input))


working_data2 <- working_data %>%
  group_by(
    chi,
    sending_location_name,
    sending_location,
    social_care_id,
    hc_service_start_date,
    hc_service
  ) %>%
  arrange(period) %>%
  # If reablement is missing with the same start date and service fill in from later records
  tidylog::fill(reablement, .direction = "up") %>%
  # If still missing fill in from earlier records
  tidylog::fill(reablement, .direction = "down") %>%
  # If the hc_provider changes for the same start date and service set it to other
  ## TODO check if we should break by provider instead of this
  mutate(change_hc_provider = min(hc_service_provider) != max(hc_service_provider)) %>%
  tidylog::mutate(
    hc_service_provider = if_else(change_hc_provider, 5L, hc_service_provider)
  ) %>%
  group_by(period, .add = TRUE) %>%
  mutate(duplicate_submissions = n()) %>%
  ungroup(period) %>%
  arrange(period, reablement) %>%
  mutate(
    episode_counter = 1,
    episode_counter = case_when(
      duplicate_submissions > 1 &&
        lag(duplicate_submissions, 2) > 1 &&
        reablement == lag(reablement, 2) ~ lag(episode_counter, 2),
      duplicate_submissions > 1 |
        reablement != lag(reablement) ~ lag(episode_counter) + 1,
      TRUE ~ lag(episode_counter)
    )
  ) %>%
  ungroup() %>%
  mutate(hours_submission_quarter = period) %>%
  # Store the homecare hours with the sumbission month
  pivot_wider(
    names_from = hours_submission_quarter,
    values_from = hc_hours_derived,
    values_fn = sum,
    names_sort = TRUE,
    names_prefix = "hc_hours_"
  ) %>%
  # Group on reablement as well so that we can split records on it
  group_by(
    chi,
    sending_location_name,
    sending_location,
    social_care_id,
    hc_service_start_date,
    hc_service,
    reablement,
    episode_counter
  ) %>%
  summarise(
    across(
      c(
        hc_service_end_date,
        record_date,
        hc_service_provider
      ),
      last
    ),
    sc_latest_submission = last(period),
    across(starts_with("hc_hours_20"), sum, na.rm = TRUE),
    across(c(gender, dob, postcode), first)
  ) %>%
  # Highlight where episodes have been split and ammend start and end dates as required
  mutate(
    record_count = row_number(),
    change_start_date = record_count > min(record_count),
    change_end_date = record_count < max(record_count),
    hc_service_start_date = if_else(change_start_date, lag(record_date), hc_service_start_date),
    hc_service_end_date = if_else(change_end_date, record_date, hc_service_end_date)
  ) %>%
  ungroup() %>%
  replace_na(list(
    hc_service = 0L,
    reablement = 9L
  ))

# TODO - HC hours
# Weird hour summing
# Keep record of hours per submission (period)
