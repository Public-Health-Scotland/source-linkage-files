#####################################################
# Costs - GP Out of Hours
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################


## update file ##

## Attendances taken from 2018 Primary Care Out of Hours Report ##
# https://publichealthscotland.scot/publications/out-of-hours-primary-care-services-in-scotland/

## Costs taken from R520 (Costbook) report for 2015/16 ##
# https://beta.isdscotland.org/topics/finance/costs/ (R520)

## The above should be checked / added to the Excel file 'OOH_Costs.xlsx' before running this syntax.


library(dplyr)
library(ggplot2)


## data ##
gp_out_of_hours <- readxl::read_xlsx(paste0(get_slf_dir(), "/Costs/OOH_Costs.xlsx"))


## data - wide to long ##
gp_out_of_hours <-
  gp_out_of_hours %>%
  pivot_longer(
    contains("Consultations"),
    names_to = "Year_Consultations", values_to = "Consultations"
  ) %>%
  pivot_longer(
    contains("Cost"),
    names_to = "Year_Cost", values_to = "Cost"
  )


## create year variable ##
gp_out_of_hours <-
  gp_out_of_hours %>%
  mutate(Year = substr(Year_Consultations, 1, 4))


## create cost per consultation ##
gp_out_of_hours <-
  gp_out_of_hours %>%
  mutate(
    cost_per_consultation = Cost * 1000 / Consultations
  )


## add in years by copying the most recent year ##
year <- 1920

tempyear1 <- paste0(as.numeric(substr(year, 1, 2)) + 1, as.numeric(substr(year, 3, 4)) + 1)
tempyear2 <- paste0(as.numeric(substr(year, 1, 2)) + 2, as.numeric(substr(year, 3, 4)) + 2)



## increase by 1% for every year after the latest ##
gp_out_of_hours <-
  gp_out_of_hours %>%
  mutate(
    cost_per_consultation =
      if_else(Year > year,
        cost_per_consultation * 1.01,
        cost_per_consultation
      )
  ) %>%
  # arrange by HB2019 and year
  arrange(HB2019, Year)


## match files - to make sure costs haven't changed radically ##
lookup <- haven::read_sav(
  find_latest_file(get_slf_dir(), regexp = "Cost_GPOoH_Lookup_pre.+?\\.sav")
)

# rename lookup varialbles to match
lookup <-
  lookup %>%
  rename(
    cost_old = "Cost_per_consultation",
    HB2019 = "TreatmentNHSBoardCode"
  )

# match
data <-
  gp_out_of_hours %>%
  left_join(lookup, by = c("HB2019", "Year"))


# compute difference
data <-
  data %>%
  mutate(difference = cost_per_consultation - cost_old) %>%
  mutate(pct_diff = difference / cost_old * 100)

# count
pct_difference_table <-
  data %>%
  count(pct_diff, Year, HB2019) %>%
  spread(Year, n)

difference_table <-
  data %>%
  count(difference, HB2019, Year) %>%
  spread(Year, n)


## Plot to check for obviously wrong looking costs ##

ggplot(data = data, aes(x = Year, y = cost_per_consultation, group = Board_Name)) +
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
  paste0(get_slf_dir(), "/Costs/Cost_GPOoH_Lookup.sav"),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  paste0(get_slf_dir(), "/Costs/Cost_GPOoH_Lookup.sav"),
  compress = "gz"
)
