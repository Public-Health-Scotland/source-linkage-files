#####################################################
# Costs - District Nursing
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - DN_Costs.xlsx
# Description - Create Lookup for District Nursing Costs.
#
# Download latest costs file from Cost Book website
# http://www.isdscotland.org/Health-Topics/Finance/Costs/Detailed-Tables/index.asp
#
# Check and add costs to the Excel file 'DN_Costs.xlsx'. ##
#
# Extract numbers of contacts from the CHAD - District Nursing Datamart
# using the query: DN-Contacts-Numbers-for-Costs.
# This should be run/scheduled and downloaded as a .csv
# Check the numbers in this file as some data completeness issues
# may mean the numbers can't be used to create costs.
#####################################################

# Load packages #
library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(createslf)


# Copy existing file ---------------------------------------

# read data in
current_file <- haven::read_sav(get_dn_costs_path())

# Create a copy for comparison
fs::file_copy(
  get_dn_costs_path(),
  get_dn_costs_path(update = latest_update())
)

# Read in cost workbook ---------------------------------------

# latest year #
latest_year <- "1920"

## data ##
dn_raw_costs <- readxl::read_excel(
  fs::path(get_slf_dir(), "Costs", "DN_Costs.xlsx"),
  .name_repair = janitor::make_clean_names
) %>%
  # change 1718 type to numeric - reads in as a character
  mutate(across(ends_with("_cost"), as.numeric)) %>%
  # pivot longer
  pivot_longer(
    ends_with("_cost"),
    names_to = "year",
    names_pattern = "(\\d{4})_cost",
    values_to = "cost"
  )

# Read DN file extracted from BOXI -----------------------------

# contacts
dn_raw_contacts <- readr::read_csv(
  fs::path(get_slf_dir(), "Costs", "DN-Contacts-Numbers-for-Costs.csv"),
  name_repair = janitor::make_clean_names
) %>%
  # create year variable as fy
  mutate(year = convert_year_to_fyyear(contact_financial_year)) %>%
  # rename TreatmentNHSBoardCode
  rename(
    hb2019 = treatment_nhs_board_code_9,
    number_of_contacts = number_of_contacts
  )

# Join files together ------------------------------------------

# match raw costs to contacts file
dn_raw_costs_contacts <- full_join(dn_raw_contacts,
  dn_raw_costs,
  by = c("hb2019", "year")
)


# Deal with population cost-------------------------------------

## Calculate population cost for NHS Highland with HSCP population ratio. ##
# Of the two HSCPs, Argyll and Bute provides the
# District Nursing data which is 27% of the population.

population_lookup <- readr::read_rds(read_datazone_pop_file("HSCP2019_pop_est_1981_2020.rds")) %>%
  # Select only the HSCPs for NHS Highland & years since 2015
  filter(
    hscp2019 %in% c("S37000004", "S37000016"),
    year >= 2015
  ) %>%
  # Create year as FY = YYYY from CCYY.
  rename(calendar_year = year) %>%
  mutate(year = convert_year_to_fyyear(calendar_year)) %>%
  group_by(year, hscp2019name) %>%
  summarise(pop = sum(pop)) %>%
  mutate(total_pop = sum(pop)) %>%
  ungroup() %>%
  # add Health Board code
  mutate(hb2019 = "S08000022") %>%
  ## compute proportion ##
  mutate(
    pop_proportion = pop / total_pop,
    pop_pct = pop_proportion * 100
  ) %>%
  ## Argyll and Bute is the only HSCP in NHS Highland that submits data ##
  filter(hscp2019name == "Argyll and Bute")


# Join files -------------------------------------------

## match files ##

matched_data <- full_join(dn_raw_costs_contacts,
  population_lookup,
  by = c("hb2019", "year")
) %>%
  # recode NA pop_proportion with 1
  mutate(pop_proportion = replace_na(pop_proportion, 1)) %>%
  ## total net cost ##
  mutate(cost_total_net = ((cost * 1000) / (number_of_contacts / pop_proportion))) %>%
  # sort by HB2019 and year
  arrange(hb2019, year) %>%
  # keep only records with cost
  filter(!is.na(cost_total_net))


# Fix incomplete submissions ------------------------------------------

# If a Partnership has abnormally low contacts this will
# affect the cost so use the previous year
# until we have a complete submission

## explore the trends

matched_data <-
  matched_data %>%
  group_by(board_name) %>%
  mutate(max_contacts = max(number_of_contacts)) %>%
  mutate(pct_of_max = number_of_contacts / max_contacts * 100) %>%
  ungroup()

# plot #
ggplot(data = matched_data, aes(x = year, y = pct_of_max, group = board_name)) +
  geom_line(aes(color = board_name)) +
  labs(color = "NHS Board", x = "Year")


# Deal with costs ------------------------------------------

## costs with pct_of_max < 75 - uplift ##
uplift_data <-
  matched_data %>%
  mutate(cost_total_net = replace(cost_total_net, pct_of_max < 75, NA)) %>%
  group_by(board_name)


while(sum(is.na(uplift_data$cost_total_net)) != 0) {
      uplift_data$cost_total_net = if_else(is.na(uplift_data$cost_total_net),
                                           lag(uplift_data$cost_total_net, default = first(uplift_data$cost_total_net)) * 1.01,
                                           uplift_data$cost_total_net)
}

uplift_data <-
  uplift_data %>%
  ungroup()

# plot #
ggplot(data = uplift_data, aes(x = year, y = cost_total_net, group = board_name)) +
  geom_line(aes(color = board_name)) +
  labs(color = "NHS Board", x = "Year")


## Add in years by copying the most recent year we have ##

new_years_data <-
  bind_rows(
    uplift_data,
    map_df(1:5, ~
      uplift_data %>%
        filter(year == latest_year) %>%
        mutate(
          cost_total_net = cost_total_net * (1.01)^.x,
          year = convert_year_to_fyyear(as.numeric(convert_fyyear_to_year(year)) + .x)
        ))
  )

new_years_data <-
  new_years_data %>%
  rename(
    hbtreatcode = "hb2019",
    hbtreatname = "treatment_nhs_board_name"
  ) %>%
  select(year, hbtreatcode, hbtreatname, cost_total_net) %>%
  arrange(hbtreatcode, year)


## Check costs haven't changed radically ##
# using current_file - from above #

# rename cost
costs_lookup <-
  current_file %>%
  rename(
    cost_old = "cost_total_net",
    year = "Year"
  )

matched_data_costs <-
  new_years_data %>%
  full_join(costs_lookup, by = c("year", "hbtreatcode", "hbtreatname")) %>%
  # compute difference
  mutate(difference = cost_total_net - cost_old) %>%
  mutate(pct_diff = difference / cost_old * 100) %>%
  arrange(hbtreatname, year)


# Create charts -----------------------------------------------

# plot difference
matched_data_costs %>%
  filter(!is.na(difference)) %>%
  ggplot(aes(x = year, y = difference, fill = hbtreatname)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "NHS Board", x = "Year")

matched_data_costs %>%
  filter(!is.na(difference)) %>%
  ggplot(aes(x = year, y = difference, group = hbtreatname)) +
  geom_line(aes(color = hbtreatname)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(color = "NHS Board", x = "Year")


# plot pct_diff
matched_data_costs %>%
  filter(!is.na(pct_diff)) %>%
  ggplot(aes(x = year, y = pct_diff, fill = hbtreatname)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "NHS Board", x = "Year")

matched_data_costs %>%
  filter(!is.na(pct_diff)) %>%
  ggplot(aes(x = year, y = pct_diff, group = hbtreatname)) +
  geom_line(aes(color = hbtreatname)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(color = "NHS Board", x = "Year")


## save outfile ---------------------------------------
outfile <-
  matched_data_costs %>%
  select(
    year,
    hbtreatcode,
    hbtreatname,
    cost_total_net
  )

# .zsav
haven::write_sav(outfile,
  get_dn_costs_path(check_mode = "write"),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  get_gp_ooh_costs_path(ext = "rds", check_mode = "write"),
  compress = "gz"
)

## End of Script ---------------------------------------
