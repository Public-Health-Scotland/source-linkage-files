#####################################################
# Costs - Home Care
# Author: James McMahon
# Date: May 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - hc_costs.xlsx
# Description - Update the costs in hc_costs.xlsx first
# These came from Improvent Service
# Table: Cash Num-Den_Indi
# Columns: XQ-XS
# https://www.improvementservice.org.uk/benchmarking/explore-the-data
#####################################################

# Packages #

library(dplyr)
library(ggplot2)
library(tidyr)
library(purrr)

costs_dir <- fs::path("/conf/hscdiip/SLF_Extracts/Costs/")
hc_costs_path <- fs::path(costs_dir, "costs_hc_lookup.rds")
hc_costs_path_old <- fs::path(costs_dir, "costs_hc_lookup_pre-Jun_2022.rds")


# Copy existing file-----------------------------------

## Make a copy of the existing file
fs::file_copy(hc_costs_path,
  hc_costs_path_old,
  overwrite = TRUE
)


# Read in data---------------------------------------

# Costs spreadsheet
hc_costs_raw <- readxl::read_xlsx(fs::path(costs_dir, "hc_costs.xlsx")) %>%
  janitor::clean_names() %>%
  drop_na(gss_code)


# Data Cleaning ---------------------------------------

## data - wide to long ##
hc_costs <- hc_costs_raw %>%
  left_join(phsopendata::get_resource("967937c4-8d67-4f39-974f-fd58c4acfda5",
    col_select = c("CA", "CAName", "HBName")
  ),
  by = c("gss_code" = "CA")
  ) %>%
  select(ca_name = CAName, health_board = HBName, starts_with("sw1_")) %>%
  mutate(across(starts_with("sw1_"), as.numeric),
    ca_name = factor(ca_name)
  ) %>%
  pivot_longer(
    cols = starts_with("sw1_"),
    names_to = "year",
    names_prefix = "sw1_",
    names_transform = ~ sub("20(\\d\\d)_(\\d\\d)", "20\\1", .x),
    values_to = "hourly_cost"
  ) %>%
  mutate(year = as.integer(year))

## add in years by copying the most recent year ##
latest_cost_year <- max(hc_costs$year)

## increase by 1% for every year after the latest ##
hc_costs_uplifted <-
  bind_rows(
    hc_costs,
    map(1:5, ~
      hc_costs %>%
        filter(year == latest_cost_year) %>%
        group_by(year, ca_name, health_board) %>%
        summarise(
          hourly_cost = hourly_cost * (1.01)^.x,
          .groups = "drop"
        ) %>%
        mutate(year = year + .x))
  ) %>%
  arrange(year, ca_name)

# match files - to make sure costs haven't changed radically ##
old_costs <- readr::read_rds(hc_costs_path_old) %>%
  # rename lookup variables to match
  rename(
    hourly_cost_old = hourly_cost
  )

# match files
matched_costs_data <- hc_costs_uplifted %>%
  full_join(old_costs, by = c("ca_name", "year")) %>%
  # compute difference
  mutate(
    difference = hourly_cost - hourly_cost_old,
    pct_diff = difference / hourly_cost_old * 100
  )

# Create charts ---------------------------------------

# plot difference
matched_costs_data %>%
  filter(difference > 0) %>%
  ggplot(aes(x = year, y = difference, fill = ca_name)) +
  geom_col(position = "dodge") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = scales::label_number()) +
  labs(fill = "Local Authority", x = "Year", y = "Real difference")


# plot pct_diff
matched_costs_data %>%
  filter(pct_diff > 0) %>%
  ggplot(aes(x = year, y = pct_diff, fill = ca_name)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::label_percent()) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "Local Authority", x = "Year", y = "% difference")


## Plot to check for obviously wrong looking costs ##

ggplot(data = matched_costs_data, aes(x = year, y = hourly_cost)) +
  geom_line(aes(group = ca_name, color = ca_name)) +
  scale_y_continuous(labels = scales::label_dollar(prefix = "£")) +
  labs(y = "Hourly costs", color = "Local Authority") +
  facet_wrap(~health_board.x)


## save outfile ---------------------------------------
hc_costs_uplifted %>%
  select(-health_board) %>%
  # .rds file
  readr::write_rds(hc_costs_path, compress = "xz")

## End of Script ---------------------------------------
