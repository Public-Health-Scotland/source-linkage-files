#####################################################
# Costs - Care Home
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - COSLA Values
# Description - Lookup for costs for Care Homes
#
# Get COSLA Value tables
# Estimated Average Gross Weekly Charge for Long Stay Residents in Care Homes for Older People in Scotland.
# https://publichealthscotland.scot/publications/care-home-census-for-adults-in-scotland/
# Check and add any new years to 'CH_Costs.xlsx'
#
#####################################################

# Load packages

library(dplyr)
library(purrr)
library(tidyr)
library(createslf)

# Read in data---------------------------------------

## Make a copy of the existing file
fs::file_copy(get_ch_costs_path(),
  get_ch_costs_path(update = latest_update()),
  overwrite = TRUE
)

## Read excel data
ch_costs_data <- readxl::read_xlsx(
  paste0(get_slf_dir(), "/Costs/CH_Costs.xlsx")
)


# Data cleaning ---------------------------------------
ch_costs <-
  ch_costs_data %>%
  # rename
  rename(source_of_funding = "Source of Funding") %>%
  # select only the funding totals
  filter(source_of_funding %in% c("All Funding With Nursing Care", "All Funding Without Nursing Care")) %>%
  # restructure
  pivot_longer(
    -source_of_funding,
    names_to = "calendar_year",
    values_to = "cost_per_week"
  ) %>%
  # create year as FY = YYYY from CCYY
  mutate(year = convert_year_to_fyyear(calendar_year)) %>%
  # create flag - nursing care provision ##
  mutate(nursing_care_provision = if_else(source_of_funding == "All Funding With Nursing Care", 1, 0)) %>%
  # cost per day ##
  mutate(cost_per_day = cost_per_week / 7) %>%
  # Compute mean cost for unknown nursing care
  bind_rows(
    group_by(., year) %>%
      summarise(
        source_of_funding = "Unknown Source of Funding",
        cost_per_day = mean(cost_per_day)
      )
  ) %>%
  select(year, nursing_care_provision, cost_per_day)

## add in years by copying the most recent year ##
latest_cost_year <- max(ch_costs$year)

## increase by 1% for every year after the latest ##
ch_costs_uplifted <-
  bind_rows(
    ch_costs,
    map(1:5, ~
      ch_costs %>%
        filter(year == latest_cost_year) %>%
        group_by(year, nursing_care_provision) %>%
        summarise(
          cost_per_day = cost_per_day * (1.01)^.x,
          .groups = "drop"
        ) %>%
        mutate(year = (as.numeric(convert_fyyear_to_year(year)) + .x) %>%
          convert_year_to_fyyear()))
  ) %>%
  arrange(year, nursing_care_provision)


# Join data together  -----------------------------------------------------

# match files - to make sure costs haven't changed radically
old_costs <- haven::read_sav(
  get_ch_costs_path(update = latest_update())
) %>%
  rename(
    cost_old = "cost_per_day",
    year = "Year"
  )

matched_costs_data <-
  ch_costs_uplifted %>%
  arrange(year, nursing_care_provision) %>%
  # match to new costs
  full_join(old_costs, by = c("year", "nursing_care_provision")) %>%
  # compute difference
  mutate(pct_diff = (cost_per_day - cost_old) / cost_old * 100)


summary(matched_costs_data$pct_diff)

matched_costs_data %>%
  pivot_wider(
    id_cols = "year",
    names_from = "nursing_care_provision",
    values_from = "pct_diff"
  )


## save outfile ---------------------------------------
ch_costs_uplifted %>%
  # .zsav
  haven::write_sav(get_ch_costs_path(update = latest_update(), check_mode = "write"),
    compress = TRUE
  ) %>%
  # .rds file
  readr::write_rds(get_ch_costs_path(update = latest_update(), check_mode = "write"),
    compress = "gz"
  )

## End of Script ---------------------------------------
