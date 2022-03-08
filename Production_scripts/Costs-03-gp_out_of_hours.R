#####################################################
# Costs - GP Out of Hours
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################


library(dplyr)
library(ggplot2)
library(createslf)
library(tidyr)
library(purrr)


## Make a copy of the existing file ##
fs::file_copy(get_gp_ooh_costs_path(), get_gp_ooh_costs_path(update = latest_update()))


# read data in
current_file <- haven::read_sav(get_gp_ooh_costs_path())

# write data to folder
# .zsav
haven::write_sav(current_file,
  paste0(get_slf_dir(), "/Costs/Cost_GPOoH_Lookup_pre", latest_update(), ".zsav"),
  compress = TRUE
)


# latest cost year
latest_cost_year <- 1920


## update file ##

## Attendances taken from 2018 Primary Care Out of Hours Report ##
# https://publichealthscotland.scot/publications/out-of-hours-primary-care-services-in-scotland/

## Costs taken from R520 (Costbook) report for 2015/16 ##
# https://beta.isdscotland.org/topics/finance/costs/ (R520)

## The above should be checked / added to the Excel file 'OOH_Costs.xlsx' before running this syntax.



## data ##
gp_out_of_hours <- readxl::read_xlsx(paste0(get_slf_dir(), "/Costs/OOH_Costs.xlsx"))


## data - wide to long ##
gp_out_of_hours <-
  gp_out_of_hours %>%
  pivot_longer(c(ends_with("_Consultations"), ends_with("_Cost")),
    names_to = c("year", ".value"),
    names_pattern = "(\\d{4})_(.+)"
  )

## create cost per consultation ##
gp_out_of_hours <-
  gp_out_of_hours %>%
  mutate(
    cost_per_consultation = Cost * 1000 / Consultations
  )


## add in years by copying the most recent year ##
## increase by 1% for every year after the latest ##
gp_out_of_hours <-
  map_df(1:5, ~
  gp_out_of_hours %>%
    group_by(HB2019, year) %>%
    arrange(HB2019, year) %>%
    mutate(
      cost_per_consultation = cost_per_consultation * (1.01)^.x,
      year = convert_year_to_fyyear(as.numeric(convert_fyyear_to_year(year)) + .x)
    )) %>%
  arrange(HB2019, year)



## match files - to make sure costs haven't changed radically ##
lookup <- haven::read_sav(
  find_latest_file(get_slf_dir(), regexp = "Cost_GPOoH_Lookup_pre.+?\\.sav")
)

# rename lookup variables to match
lookup <-
  lookup %>%
  rename(
    cost_old = "Cost_per_consultation",
    HB2019 = "TreatmentNHSBoardCode",
    year = "Year"
  )

# match
matched_data <-
  gp_out_of_hours %>%
  full_join(lookup, by = c("HB2019", "year"))


# compute difference
matched_data <-
  matched_data %>%
  mutate(difference = cost_per_consultation - cost_old) %>%
  mutate(pct_diff = difference / cost_old * 100)


# plot difference
ggplot(data = matched_data, aes(x = year, y = difference, fill = Board_Name)) +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "NHS Board", x = "Year")


# plot pct_diff
ggplot(data = matched_data, aes(x = year, y = pct_diff, fill = Board_Name)) +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "NHS Board", x = "Year")


## Plot to check for obviously wrong looking costs ##

ggplot(data = data, aes(x = year, y = cost_per_consultation, group = Board_Name)) +
  geom_line(aes(color = Board_Name)) +
  labs(y = "Cost Per Consultation", color = "NHS Board")


## save ##

outfile <-
  data %>%
  rename(TreatmentNHSBoardCode = "HB2019") %>%
  select(
    Year,
    TreatmentNHSBoardCode,
    cost_per_consultation
  )

# .zsav
haven::write_sav(outfile,
                 get_gp_ooh_costs_path(check_mode = "write"),
                 compress = TRUE
)

# .rds file
readr::write_rds(outfile,
                 get_gp_ooh_costs_path(check_mode = "write"),
                 compress = "gz"
)
