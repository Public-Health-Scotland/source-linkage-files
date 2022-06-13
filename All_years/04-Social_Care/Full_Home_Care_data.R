####################################################
# Home Care Data
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
library(lubridate)


latest_update <- "Jun_2022"


# Read in data---------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 home care
home_care_data <- tbl(db_connection, in_schema("social_care_2", "homecare_snapshot")) %>%
  select(
    sending_location,
    sending_location_name,
    social_care_id,
    hc_service_start_date,
    hc_service_end_date,
    period,
    financial_year,
    financial_quarter,
    hc_service,
    hc_service_provider,
    reablement,
    hc_hours_derived,
    total_staff_home_care_hours,
    multistaff_input,
    hc_start_date_after_end_date
  ) %>%
  # fix 2017
  mutate(financial_quarter = if_else(financial_year == 2017 & is.na(financial_quarter), 4, financial_quarter)) %>%
  mutate(period = if_else(period == "2017", "2017Q4", period)) %>%
  # drop rows start date after end date
  filter(hc_start_date_after_end_date == 0) %>%
  collect()


# Match on demographic data ---------------------------------------

# read in demographic data
sc_demog <- haven::read_sav(get_sc_demog_lookup_path(ext = "zsav")) # remaining here until .rds file ready
sc_demog <- readr::read_rds(get_sc_demog_lookup_path())

matched_hc_data <- home_care_data %>%
  left_join(sc_demog, by = c("sending_location", "social_care_id"))


# Data Cleaning ---------------------------------------

# period start and end dates
period_dates <- matched_hc_data %>%
  distinct(period) %>%
  mutate(
    record_date = yq(period) %m+% period(6, "months") %m-% days(1),
    qtr_start = yq(period) %m+% period(3, "months")
  )


home_care_clean <- matched_hc_data %>%
  # set reablement values == 9 to NA
  mutate(reablement = na_if(reablement, "9")) %>%
  # fix NA hc_service
  mutate(hc_service = tidyr::replace_na(hc_service, "0")) %>%
  # join with dates
  left_join(period_dates, by = c("period")) %>%
  # Replace missing start dates with the start of the quarter
  mutate(hc_service_start_date = if_else(is.na(hc_service_start_date), qtr_start, hc_service_start_date)) %>%
  # Replace really early start dates with start of the quarter
  mutate(hc_service_end_date = if_else(hc_service_start_date < as.Date("1989-01-01"), qtr_start, hc_service_start_date)) %>%
  # when multiple social_care_id from sending_location for single CHI
  # replace social_care_id with latest
  group_by(sending_location, social_care_id) %>%
  mutate(latest_sc_id = last(social_care_id)) %>%
  # count changed social_care_id
  mutate(
    changed_sc_id = if_else(!is.na(chi) & social_care_id != latest_sc_id, 1, 0),
    social_care_id = if_else(!is.na(chi) & social_care_id != latest_sc_id,
                             latest_sc_id, social_care_id
    )) %>%
  ungroup() %>%
  # fill reablement when missing but present in group
  group_by(sending_location, social_care_id, hc_service_start_date) %>%
  tidyr::fill(reablement, .direction = "updown") %>%
  ungroup() %>%
  # Only keep records which have some time in the quarter in which they were submitted
  mutate(
    end_before_qtr = qtr_start > hc_service_end_date & !is.na(hc_service_end_date),
    start_after_quarter = record_date < hc_service_start_date,
    # Need to check - as we are potentialsly introducing bad start dates above
    start_after_end = hc_service_start_date > hc_service_end_date & !is.na(hc_service_end_date)
  ) %>%
  filter(!end_before_qtr,
         !start_after_quarter,
         !start_after_end)


# count changed social_care_id
home_care_clean %>% count(changed_sc_id)



# Home Care Hours ---------------------------------------


home_care_hours <- home_care_clean %>%
  mutate(days_in_quarter = time_length(interval(
        pmax(qtr_start, hc_service_start_date), pmin(record_date, hc_service_end_date, na.rm = TRUE)),"days") + 1,
    hc_hours = case_when(
      # For A&B 2020/21, use multistaff (min = 1) * staff hours
      sending_location_name == "Argyll and Bute" & stringr::str_starts(period, "2020") & is.na(hc_hours_derived)
      ~ pmax(1, multistaff_input) * total_staff_home_care_hours,
      # Angus submit hourly daily instead of weekly hours
      sending_location_name == "Angus" & period %in% c("2018Q3", "2018Q4", "2019Q1", "2019Q2", "2019Q3")
      ~ (hc_hours_derived / 7) * days_in_quarter,
      TRUE ~ hc_hours_derived
    )
  )


# Home Care Costs ---------------------------------------

home_care_costs <- readr::read_rds(get_hc_costs_path())


matched_costs <- home_care_hours %>%
  left_join(home_care_costs, by = c("sending_location_name" = "ca_name", "financial_year" = "year")) %>%
  mutate(hc_cost = hc_hours * hourly_cost)


pivotted_hours <- matched_costs %>%
  # Create a copy of the period then pivot the hours on it
  # This creates a new variable per quarter
  # with the hours for that quarter for every record
  mutate(hours_submission_quarter = period) %>%
  tidyr::pivot_wider(
    names_from = hours_submission_quarter,
    values_from = c(hc_hours, hc_cost),
    values_fn = sum,
    values_fill = 0,
    names_sort = TRUE,
    names_glue = "{.value}_{hours_submission_quarter}"
  ) %>%
  # Add in hour variables for the 2017 quarters we don't have
  mutate(
    hc_hours_2017Q1 = NA,
    hc_hours_2017Q2 = NA,
    hc_hours_2017Q3 = NA,
    .before = hc_hours_2017Q4
  ) %>%
  mutate(
    hc_cost_2017Q1 = NA,
    hc_cost_2017Q2 = NA,
    hc_cost_2017Q3 = NA,
    .before = hc_cost_2017Q4
  ) %>%
  full_join(
    # Create the columns we don't have as NA
    tibble(
      # Create columns for the latest year
      hours_submission_quarter = paste0(max(home_care_data$financial_year), "Q", 1:4),
      hc_hours = NA,
      hc_cost = NA
    ) %>%
      # Pivot them to the same format as the rest of the data
      tidyr::pivot_wider(
        names_from = hours_submission_quarter,
        values_from = c(hc_hours, hc_cost),
        names_glue = "{.value}_{hours_submission_quarter}"
      )
  )


# Outfile ---------------------------------------

outfile <- pivotted_hours %>%
  # group the data to be merged
  group_by(
    chi,
    sending_location_name,
    sending_location,
    social_care_id,
    hc_service_start_date,
    hc_service,
    hc_service_provider,
    reablement
  ) %>%
  arrange(period) %>%
  summarise(
    # Take the latest submitted value
    across(c(hc_service_end_date, record_date), last),
    # Store the period for the latest submitted record
    sc_latest_submission = last(period),
    # Sum the (quarterly) hours
    across(starts_with("hc_hours_20"), sum),
    across(starts_with("hc_cost_20"), sum),
    # Shouldn't matter as these are all the same
    across(c(gender, dob, postcode), first)
  ) %>%
  ungroup()



outfile %>%
  # .zsav
  write_sav(get_sc_hc_episodes_path(latest_update)) %>%
  # .rds file
  write_rds(get_sc_hc_episodes_path(latest_update))


# End of Script #
