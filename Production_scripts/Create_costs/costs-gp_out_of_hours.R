#####################################################
# Costs - GP Out of Hours
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Attendances taken from 2018 Primary Care Out of Hours Report
# https://publichealthscotland.scot/publications/out-of-hours-primary-care-services-in-scotland/

# Costs taken from R520 (Costbook) report for 2015/16
# https://beta.isdscotland.org/topics/finance/costs/ (R520)

# The above should be checked / added to the Excel file
#' OOH_Costs.xlsx' before running this syntax.
#####################################################

# Packages #

library(dplyr)
library(ggplot2)
library(createslf)
library(tidyr)
library(purrr)

# Copy existing file-----------------------------------

## Make a copy of the existing file
fs::file_copy(get_gp_ooh_costs_path(),
  get_gp_ooh_costs_path(update = latest_update()),
  overwrite = TRUE
)


# Read in data---------------------------------------

# Costs spreadsheet
gp_ooh_data <- readxl::read_xlsx(paste0(
  get_slf_dir(),
  "/Costs/OOH_Costs.xlsx"
))


# Data Cleaning ---------------------------------------

## data - wide to long ##
gp_ooh_costs <-
  gp_ooh_data %>%
  pivot_longer(c(ends_with("_Consultations"), ends_with("_Cost")),
    names_to = c("year", ".value"),
    names_pattern = "(\\d{4})_(.+)"
  ) %>%
  ## create cost per consultation ##
  mutate(
    cost_per_consultation = Cost * 1000 / Consultations
  ) %>%
  select(
    year,
    HB2019,
    Board_Name,
    cost_per_consultation
  )

## add in years by copying the most recent year ##
latest_cost_year <- max(gp_ooh_costs$year)

## increase by 1% for every year after the latest ##
gp_ooh_costs_uplifted <-
  bind_rows(
    gp_ooh_costs,
    map(1:5, ~
      gp_ooh_costs %>%
        filter(year == latest_cost_year) %>%
        group_by(year, HB2019, Board_Name) %>%
        summarise(
          cost_per_consultation = cost_per_consultation * (1.01)^.x,
          .groups = "drop"
        ) %>%
        mutate(year = (as.numeric(convert_fyyear_to_year(year)) + .x) %>%
          convert_year_to_fyyear()))
  ) %>%
  arrange(year, HB2019, Board_Name)

## match files - to make sure costs haven't changed radically ##
old_costs <- haven::read_sav(get_gp_ooh_costs_path(update = latest_update())) %>%
  # rename lookup variables to match
  rename(
    cost_old = "cost_per_consultation",
    HB2019 = "TreatmentNHSBoardCode",
    year = "Year"
  )

# match files
matched_costs_data <- gp_ooh_costs_uplifted %>%
  full_join(old_costs, by = c("HB2019", "year")) %>%
  # compute difference
  mutate(
    difference = cost_per_consultation - cost_old,
    pct_diff = difference / cost_old * 100
  )

# Create charts ---------------------------------------

# plot difference
matched_costs_data %>%
  filter(difference > 0) %>%
  ggplot(aes(x = year, y = difference, fill = Board_Name)) +
  geom_col(position = "dodge") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = scales::label_number()) +
  labs(fill = "NHS Board", x = "Year", y = "Real difference")


# plot pct_diff
matched_costs_data %>%
  filter(pct_diff > 0) %>%
  ggplot(aes(x = year, y = pct_diff, fill = Board_Name)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::label_percent()) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "NHS Board", x = "Year", y = "% difference")


## Plot to check for obviously wrong looking costs ##

ggplot(data = matched_costs_data, aes(x = year, y = cost_per_consultation)) +
  geom_line(aes(group = Board_Name, color = Board_Name)) +
  scale_y_continuous(labels = scales::label_dollar(prefix = "£")) +
  labs(y = "Cost Per Consultation", color = "NHS Board")


## save outfile ---------------------------------------
gp_ooh_costs_uplifted %>%
  rename(TreatmentNHSBoardCode = "HB2019") %>%
  # .zsav
  write_sav(get_gp_ooh_costs_path(ext = "zsav", check_mode = "write")) %>%
  # .rds file
  write_rds(get_gp_ooh_costs_path(check_mode = "write"))

## End of Script ---------------------------------------
