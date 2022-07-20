#####################################################
# Costs - Care Home
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Tables from CHC publication
# Description - Lookup for costs for Care Homes
#
# Get the Care Home Census tables
# Estimated Average Gross Weekly Charge for Long Stay Residents in Care Homes
# for Older People in Scotland.
# https://publichealthscotland.scot/publications/care-home-census-for-adults-in-scotland/
# Check and add any new years to 'CH_Costs.xlsx'
#
#####################################################

# Load packages

library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(createslf)

# Read in data---------------------------------------

## Make a copy of the existing file
fs::file_copy(get_ch_costs_path(),
  get_ch_costs_path(update = latest_update()),
  overwrite = TRUE
)

## Read costs from the CHC Open data
ch_costs_data <-
  phsopendata::get_resource(
    res_id = "4ee7dc84-ca65-455c-9e76-b614091f389f",
    col_select = c("Date", "KeyStatistic", "CA", "Value")
  ) %>%
  janitor::clean_names() %>%
  # Dates are at end of the fin year
  # so cost are for the fin year to that date.
  mutate(year = createslf::convert_year_to_fyyear((date %/% 10000) - 1)) %>%
  filter(year >= "1617") %>%
  mutate(funding_source = stringr::str_extract(key_statistic, "((:?All)|(:?Self)|(:?Publicly))")) %>%
  mutate(nursing_care_provision = if_else(stringr::str_detect(key_statistic, "Without"), 1, 0)) %>%
  select(year,
    ca,
    funding_source,
    nursing_care_provision,
    cost_per_week = value
  )


# Data cleaning ---------------------------------------
ch_costs_scot <-
  ch_costs_data %>%
  filter(ca == "S92000003") %>%
  filter(funding_source == "All") %>%
  select(year, nursing_care_provision, cost_per_week) %>%
  # cost per day
  mutate(cost_per_day = cost_per_week / 7) %>%
  select(-cost_per_week) %>%
  # Compute mean cost for unknown nursing care
  bind_rows(
    group_by(., year) %>%
      summarise(
        nursing_care_provision = NA_real_,
        cost_per_day = mean(cost_per_day)
      )
  )

# Interpolate any missing years (e.g. 2019/20)
ch_costs <- ch_costs_scot %>%
  group_by(nursing_care_provision) %>%
  mutate(cost_per_day = if_else(
    is.na(cost_per_day),
    (lag(cost_per_day, order_by = year) + lead(cost_per_day, order_by = year)) / 2,
    cost_per_day
  )) %>%
  ungroup()

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
old_costs <- readr::read_rds(get_ch_costs_path(update = latest_update())) %>%
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

ggplot(
  data = matched_costs_data,
  aes(
    x = year,
    y = cost_per_day,
    colour = as.factor(nursing_care_provision),
    group = as.factor(nursing_care_provision)
  )
) +
  geom_step() +
  geom_step(aes(y = cost_old), linetype = "dotdash") +
  geom_vline(xintercept = latest_cost_year, linetype = "dashed") +
  scale_y_continuous(labels = scales::label_dollar(prefix = "£")) +
  scale_colour_discrete() +
  labs(y = "Cost per day", color = "Nursing Care provision")


## save outfile ---------------------------------------
ch_costs_uplifted %>%
  # .zsav
  write_sav(get_ch_costs_path(ext = "zsav", check_mode = "write")) %>%
  # .rds file
  write_rds(get_ch_costs_path(check_mode = "write"))

## End of Script ---------------------------------------
