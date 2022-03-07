#####################################################
# Costs - Care Home
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - COSLA Values
# Description - Lookup for costs for Care Homes
#####################################################

library(dplyr)
library(createslf)


## Make a copy of the existing file ##
fs::file_copy(get_ch_costs_path(), get_ch_costs_path(update = previous_update()))


## Get COSLA Value tables ##
# Estimated Average Gross Weekly Charge for Long Stay Residents in Care Homes for Older People in Scotland.
# https://publichealthscotland.scot/publications/care-home-census-for-adults-in-scotland/
# Check and add any new years to 'CH_Costs.xlsx'


## data ##
ch <- readxl::read_xlsx(
  paste0(get_slf_dir(), "/Costs/CH_Costs.xlsx")
)


ch <-
  ch %>%
  # rename
  rename(source_of_funding = "Source of Funding") %>%
  # select only the funding totals
  filter(source_of_funding %in% c("All Funding With Nursing Care", "All Funding Without Nursing Care"))


ch <-
  ch %>%
  pivot_longer(
    !contains("source"),
    names_to = "calendar_year",
    values_to = "cost_per_week"
  )


# create year as FY = YYYY from CCYY
ch <-
  ch %>%
  mutate(financial_year = convert_year_to_fyyear(calendar_year))



## create flag - nursing care provision ##
ch <-
  ch %>%
  mutate(nursing_care_provision = if_else(source_of_funding == "All Funding With Nursing Care", 1, 0))



## cost per day ##
ch <-
  ch %>%
  mutate(cost_per_day = cost_per_week / 7)



## unknown nursing variable ##
ch <-
  ch %>%
  mutate(unknown_nursing = "Unknown Source of Funding")



ch <-
  ch %>%
  pivot_longer(
    cols = any_of(c("source_of_funding", "unknown_nursing")),
    values_to = "source_of_funding",
    names_to = NULL
  )


# replace nursing care provision with NA
ch <-
  ch %>%
  mutate(nursing_care_provision = na_if(nursing_care_provision, source_of_funding == "Unknown Source of Funding"))


## outfile ##
outfile <-
  ch %>%
  group_by(financial_year, nursing_care_provision) %>%
  mutate(cost_per_day = mean(cost_per_day)) %>%
  select(financial_year, nursing_care_provision, cost_per_day)


## add in years by copying the most recent year ##
latest_year <- 2122

## increase by 1% for every year after the latest ##
outfile <-
  map_df(1:5, ~
  outfile %>%
    group_by(financial_year, nursing_care_provision) %>%
    arrange(financial_year, nursing_care_provision) %>%
    mutate(
      cost_per_day = cost_per_day * (1.01)^.x,
      financial_year = convert_year_to_fyyear(as.numeric(convert_fyyear_to_year(financial_year)) + .x)
    )) %>%
  arrange(financial_year, nursing_care_provision) %>%
  rename(year = "financial_year")



## match files - to make sure costs haven't changed radically ##
lookup <- haven::read_sav(
  find_latest_file(get_slf_dir(), regexp = "Cost_CH_Lookup_pre.+?\\.sav")
)

lookup <-
  lookup %>%
  rename(
    cost_old = "cost_per_day",
    year = "Year"
  ) %>%
  arrange(year, nursing_care_provision)


# match
data <-
  outfile %>%
  full_join(lookup, by = c("year", "nursing_care_provision"))



# compute difference
data <-
  data %>%
  mutate(pct_diff = (cost_per_day - cost_old) / cost_old * 100)


# count
data %>%
  count(pct_diff, year, nursing_care_provision) %>%
  spread(year, n)



## save outfile ##
outfile <-
  data %>%
  select(
    year,
    nursing_care_provision,
    cost_per_day
  )


# .zsav
haven::write_sav(outfile,
  get_ch_costs_path(),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  get_ch_costs_path(),
  compress = "gz"
)
