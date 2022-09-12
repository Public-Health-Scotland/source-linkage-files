# Setup -------------------------------------------------------------------

library(haven)
library(fs)
library(dplyr)
library(stringr)
library(lubridate)
library(readr)
library(phsmethods)
library(tidyr)

source("All_years/04-Social_Care/00-Social_Care_functions.R")

# Open connection to DVPROD
sc_con <- phs_db_connection(dsn = "DVPROD")

# Read demographic file
# TODO replace the demographic file with R code
demog_file <- read_demog_file(
  social_care_dir = social_care_dir,
  latest_update = latest_update()
)

# Query to database -------------------------------------------------------

hc_query <-
  tbl(sc_con, dbplyr::in_schema("social_care_2", "homecare_snapshot")) %>%
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
  # Fix bad 2017 period
  mutate(
    financial_quarter = if_else(
      period == "2017" &
        # These used to be zero but are now missing
        is.na(financial_quarter) | financial_quarter == 0 &
        financial_year == 2017,
      4,
      financial_quarter
    ),
    period = if_else(period == "2017", "2017Q4", period)
  ) %>%
  # Set reablement 9 to NA for now
  mutate(reablement = na_if(reablement, 9L)) %>%
  # Fix any NA hc_service
  mutate(hc_service = if_else(is.na(hc_service), 0L, hc_service)) %>%
  # If the start is after the end, remove the end date
  mutate(hc_service_end_date = if_else(hc_service_start_date > hc_service_end_date, NA_Date_, hc_service_end_date))

# Extract the data --------------------------------------------------------

hc_full_data <- collect(hc_query) %>%
  # Clean up variable types
  mutate(
    # Use integer if applicable
    across(where(is_integer_like), as.integer),
    # Make empty strings NA
    across(where(is.character), zap_empty)
  ) %>%
  # Create factors out of the categorical string variables
  mutate(
    sending_location_name = factor(sending_location_name),
    period = ordered(period)
  ) %>%
  # Match on the demographic data
  # CHI + other vars
  left_join(demog_file,
    by = c("sending_location", "social_care_id")
  )

# Report tables -----------------------------------------------------------

# Output a report on the number of
# repeated social care IDs
bad_sc_id <- demog_file %>%
  distinct(sending_location, chi, social_care_id) %>%
  filter(!is.na(chi)) %>%
  group_by(sending_location, chi) %>%
  filter(n_distinct(social_care_id) > 1) %>%
  left_join(
    distinct(
      hc_full_data,
      sending_location,
      sending_location_name
    ),
    by = "sending_location"
  ) %>%
  mutate(last_sc_id = if_else(
    social_care_id != last(social_care_id),
    last(social_care_id),
    NA_character_
  ))

# Output table of hc hours for report
hc_full_data %>%
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

# Process and clean the data ----------------------------------------------

# Work out the dates for each period
# Record date is the last day of the quarter
# qtr_start is the first day of the quarter
pre_compute_record_dates <- hc_full_data %>%
  distinct(period) %>%
  mutate(
    record_date = yq(period) %m+% period(6, "months") %m-% days(1),
    qtr_start = yq(period) %m+% period(3, "months")
  )


replaced_start_dates <- hc_full_data %>%
  # Replace missing start dates with the start of the quarter
  left_join(pre_compute_record_dates, by = "period") %>%
  mutate(
    start_date_missing = is.na(hc_service_start_date),
    hc_service_start_date = if_else(
      start_date_missing,
      qtr_start,
      hc_service_start_date
    )
  ) %>%
  # Replace really early start dates with start of the quarter
  mutate(
    early_start_date = hc_service_start_date < as.Date("1989-01-01"),
    hc_service_start_date = if_else(
      early_start_date,
      qtr_start,
      hc_service_start_date
    )
  )

# Output table for DM / SC team on bad dates
bad_dates <- replaced_start_dates %>%
  mutate(
    end_before_qtr = qtr_start > hc_service_end_date & !is.na(hc_service_end_date),
    start_after_quarter = record_date < hc_service_start_date,
    # Need to check this as we are potentialsly introducing bad start dates above
    start_after_end = hc_service_start_date > hc_service_end_date & !is.na(hc_service_end_date)
  ) %>%
  filter(if_any(c(end_before_qtr, start_after_quarter, start_after_end))) %>%
  group_by(sending_location_name, period) %>%
  summarise(across(c(end_before_qtr, start_after_quarter, start_after_end), sum, na.rm = TRUE)) %>%
  janitor::adorn_totals(where = c("row", "col"))

# Only keep records which have some time in the
# quarter in which they were submitted (~140).
dropped_bad_dates <- replaced_start_dates %>%
  mutate(
    end_before_qtr = qtr_start > hc_service_end_date & !is.na(hc_service_end_date),
    start_after_quarter = record_date < hc_service_start_date,
    # Need to check this as we are potentialsly introducing bad start dates above
    start_after_end = hc_service_start_date > hc_service_end_date & !is.na(hc_service_end_date)
  ) %>%
  filter(
    !end_before_qtr,
    !start_after_quarter,
    !start_after_end
  )

fixed_sc_ids <- dropped_bad_dates %>%
  # Fix cases where a CHI has multiple sc_ids
  # Sort and take the latest sc_id
  arrange(sending_location, chi, record_date, hc_service_start_date) %>%
  group_by(sending_location, chi) %>%
  mutate(social_care_id = if_else(is.na(chi), social_care_id, last(social_care_id))) %>%
  ungroup()

fixed_reablement <- fixed_sc_ids %>%
  # Group across what will be the standard split
  # Same person, same start date, same service
  group_by(
    chi,
    sending_location_name,
    sending_location,
    social_care_id,
    hc_service_start_date,
    hc_service,
    hc_service_provider
  ) %>%
  # Sort so latest submitted records are last
  arrange(period,
    # .by_group will also sort it by the groups which makes the output easier to read
    .by_group = TRUE
  ) %>%
  # If reablement is missing fill in from later records (up)
  # If still missing fill in from earlier records (down)
  fill(reablement, .direction = "updown") %>%
  mutate(reablement = replace_na(reablement, 9L)) %>%
  ungroup()

fixed_hours <- fixed_reablement %>%
  mutate(
    days_in_quarter = time_length(
      interval(
        pmax(qtr_start, hc_service_start_date),
        pmin(record_date, hc_service_end_date, na.rm = TRUE)
      ),
      "days"
    ) + 1,
    hc_hours = case_when(
      # For A&B 2020/21, use multistaff (min = 1) * staff hours
      sending_location_name == "Argyll and Bute" &
        str_starts(period, "2020") &
        is.na(hc_hours_derived)
      ~ pmax(1, multistaff_input) * total_staff_home_care_hours,
      # Angus submit hourly daily instead of weekly hours
      sending_location_name == "Angus" &
        period %in% c("2018Q3", "2018Q4", "2019Q1", "2019Q2", "2019Q3")
      ~ (hc_hours_derived / 7) * days_in_quarter,
      TRUE ~ hc_hours_derived
    )
  )

hc_costs <- read_rds(path("/conf/hscdiip/SLF_Extracts/Costs", "costs_hc_lookup.rds"))

matched_costs <- fixed_hours %>%
  left_join(hc_costs,
                     by = c("sending_location_name" = "ca_name",
                            "financial_year" = "year")) %>%
  mutate(hc_cost = hc_hours * hourly_cost)

pivotted_hours <- matched_costs %>%
  # Create a copy of the period then pivot the hours on it
  # This creates a new variable per quarter
  # with the hours for that quarter for every record
  mutate(hours_submission_quarter = period) %>%
  pivot_wider(
    names_from = hours_submission_quarter,
    values_from = c(hc_hours, hc_cost),
    values_fn = sum,
    values_fill = 0,
    names_sort = TRUE,
    names_glue = "{.value}_{hours_submission_quarter}"
  ) %>%
  # Add in hour variables for the 2017 quarters we don't have
  mutate(
    hc_hours_2017Q1 = NA_real_,
    hc_hours_2017Q2 = NA_real_,
    hc_hours_2017Q3 = NA_real_,
    .before = hc_hours_2017Q4
  ) %>%
  mutate(
    hc_cost_2017Q1 = NA_real_,
    hc_cost_2017Q2 = NA_real_,
    hc_cost_2017Q3 = NA_real_,
    .before = hc_cost_2017Q4
  ) %>%
  # A full join will only add columns which are 'new'
  full_join(
    # Create the columns we don't have as NA
    tibble(
      # Create columns for the latest year
      hours_submission_quarter = paste0(max(hc_full_data$financial_year), "Q", 1:4),
      hc_hours = NA_real_,
      hc_cost = NA_real_
    ) %>%
      # Pivot them to the same format as the rest of the data
      pivot_wider(
        names_from = hours_submission_quarter,
        values_from = c(hc_hours, hc_cost),
        names_glue = "{.value}_{hours_submission_quarter}"
      )
  )

merged_data <- pivotted_hours %>%
  # Group the data to be merged
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
    across(
      c(hc_service_end_date, record_date),
      last
    ),
    # Store the period for the latest submitted record
    sc_latest_submission = last(period),
    # Sum the (quarterly) hours
    across(starts_with("hc_hours_20"), sum),
    across(starts_with("hc_cost_20"), sum),
    # Shouldn't matter as these are all the same
    across(c(gender, dob, postcode), first)
  ) %>%
  ungroup()


# Write data out ----------------------------------------------------------

merged_data %>%
  write_rds(path(social_care_dir, str_glue("all_hc_episodes_{latest_update()}.rds")),
    compress = "xz"
  ) %>%
  write_sav(path(social_care_dir, str_glue("all_hc_episodes_{latest_update()}.zsav")),
    compress = "zsav"
  )
