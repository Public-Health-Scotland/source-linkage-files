#####################################################
# Costs - District Nursing
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Create Lookup for District Nursing Costs.
#
# Download latest costs file from Cost Book website
# http://www.isdscotland.org/Health-Topics/Finance/Costs/Detailed-Tables/index.asp
#
# Check and add costs to the Excel file 'DN_Costs.xlsx'. ##
#
# Extract numbers of contacts from the CHAD - District Nursing Datamart using
# the query: DN-Contacts-Numbers-for-Costs. This should be run/scheduled and downloaded as a .csv
# Check the numbers in this file as some data completeness issues may mean the numbers can't be used to create costs.
#
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

# write data to folder
# .zsav
haven::write_sav(current_file,
  paste0(get_slf_dir(), "/Costs/Cost_DN_Lookup_pre", latest_update(), ".zsav"),
  compress = TRUE
)


# Read in cost workbook ---------------------------------------

## data ##
dn_raw_costs <- readxl::read_excel(
  paste0(get_slf_dir(), "/Costs/DN_Costs.xlsx")
) %>%
  # change 1718 type to numeric - reads in as a character
  mutate(`1718_Cost` = as.numeric(`1718_Cost`)) %>%
  # pivot longer
  pivot_longer(
    ends_with("Cost"),
    names_to = "year_cost",
    values_to = "cost"
  ) %>%
  # create year variable
  mutate(year = substr(year_cost, 1, 4)) %>%
  # remove variable year_cost
  select(-year_cost) %>%
  # sort by year and HB2019
  arrange(year, HB2019)

# Read DN file extracted from BOXI -----------------------------

# contacts
dn_raw_costs_contacts <- readr::read_csv(
  paste0(get_slf_dir(), "/Costs/DN-Contacts-Numbers-for-Costs.csv")
) %>%
  # create year variable as fy
  mutate(year = convert_year_to_fyyear(`Contact Financial Year`)) %>%
  # rename TreatmentNHSBoardCode
  rename(
    HB2019 = "Treatment NHS Board Code 9",
    number_of_contacts = "Number of Contacts"
  ) %>%
  # sort by year and HB2019
  arrange(year, HB2019)

# Join files together ------------------------------------------

# match raw costs to contacts file
dn_raw_costs_contacts <-
  dn_raw_costs_contacts %>%
  full_join(dn_raw_costs, by = c("HB2019", "year"))


# Deal with population cost-------------------------------------


## Calculate population cost for NHS Highland with HSCP population ratio. ##
# Of the two HSCPs, Argyll and Bute provides the District Nursing data which is 27% of the population.

lookup <- haven::read_sav(paste0(get_lookups_dir(), "/Populations/Estimates/HSCP2019_pop_est_1981_2020.sav"))


# Select only the HSCPs for NHS Highland & years since 2015
lookup <-
  lookup %>%
  filter(HSCP2019 == "S37000004" | HSCP2019 == "S37000016") %>%
  filter(Year > 2015 | Year == 2015) %>%
  # Create year as FY = YYYY from CCYY.
  rename(calendar_year = Year) %>%
  mutate(year = convert_year_to_fyyear(calendar_year))


## outfile ##
outfile <-
  lookup %>%
  select(year, HSCP2019, Pop) %>%
  group_by(year, HSCP2019) %>%
  summarise(pop = sum(Pop)) %>%
  # HSCP name
  mutate(HSCPName = hscp_to_hscpnames(HSCP2019)) %>%
  # add Health Board code
  mutate(HB2019 = "S08000022") %>%
  # get total pop
  group_by(year, HB2019) %>%
  mutate(total_pop = sum(pop)) %>%
  ## compute proportion ##
  mutate(pop_proportion = pop / total_pop) %>%
  mutate(pop_pct = pop_proportion * 100) %>%
  ## Argyll and Bute is the only HSCP in NHS Highland that submits data ##
  filter(HSCPName == "Argyll and Bute")


# Join files -------------------------------------------

## match files ##

data <-
  outfile %>%
  full_join(dn_raw_costs_contacts, by = c("HB2019", "year")) %>%
  # recode NA pop_proportion with 1
  mutate(pop_proportion = replace_na(pop_proportion, 1)) %>%
  ## total net cost ##
  mutate(cost_total_net = ((cost * 1000) / (number_of_contacts / pop_proportion))) %>%
  # sort by HB2019
  arrange(HB2019) %>%
  # keep only records with cost
  filter(!is.na(cost_total_net))



# Fix incomplete submissions ------------------------------------------

# If a Partnership has abnormally low contacts this will affect the cost so use the
# previous year until we have a complete submission

# explore the trends

data <-
  data %>%
  group_by(Board_Name) %>%
  mutate(max_contacts = max(number_of_contacts)) %>%
  mutate(pct_of_max = number_of_contacts / max_contacts * 100)

# plot #
ggplot(data = data, aes(x = year, y = pct_of_max, group = Board_Name)) +
  geom_line(aes(color = Board_Name)) +
  labs(color = "NHS Board", x = "Year")


# Deal with costs ------------------------------------------

## upflift any 'copied' costs ##
data <-
  data %>%
  mutate(uplift = 0) %>%
  mutate(
    tempyear1 = case_when(
      Board_Name == "NHS Highland" & year == "1617" ~ "1819",
      Board_Name == "NHS Tayside" & year == "1617" ~ "1718",
      Board_Name == "NHS Forth Valley" & year == "1819" ~ "1920",
      Board_Name == "NHS Greater Glasgow & Clyde" & year == "1819" ~ "1920"
    ),
    tempyear2 = case_when(Board_Name == "NHS Highland" & year == "1617" ~ "1920")
  ) %>%
  mutate(
    uplift1 = case_when(
      Board_Name == "NHS Highland" & tempyear1 == "1819" ~ 2,
      Board_Name == "NHS Tayside" & tempyear1 == "1718" ~ 1,
      Board_Name == "NHS Forth Valley" & tempyear1 == "1920" ~ 1,
      Board_Name == "NHS Greater Glasgow & Clyde" & tempyear1 == "1920" ~ 1
    ),
    uplift2 = case_when(Board_Name == "NHS Highland" & tempyear2 == "1920" ~ 3)
  ) %>%
# data - wide to long
  pivot_longer(
    c("year", contains("tempyear")),
    values_to = "year",
    names_to = NULL
  ) %>%
  pivot_longer(
    contains("uplift"),
    values_to = "uplift",
    names_to = NULL
  ) %>%
  # cost total net
  mutate(cost_total_net = cost_total_net * (1.01 * exp(uplift)))


## Add in years by copying the most recent year we have ##
latest_year <- 1920
data <-
  bind_rows(
    data,
    map_df(1:5, ~
    data %>%
      filter(year == latest_year) %>%
      mutate(
        cost_total_net = cost_total_net * (1.01)^.x,
        year = convert_year_to_fyyear(as.numeric(convert_fyyear_to_year(year)) + .x)
      ))
  )


data <-
  data %>%
  ungroup() %>%
  rename(
    hbtreatcode = "HB2019",
    hbtreatname = "Treatment NHS Board Name"
  ) %>%
  select(year, hbtreatcode, hbtreatname, cost_total_net) %>%
  arrange(year, hbtreatcode)

## Check costs haven't changed radically ##
# using current_file - from above #

# rename cost
costs_lookup <-
  current_file %>%
  rename(
    cost_old = "cost_total_net",
    year = "Year"
  )

matched_data <-
  data %>%
  full_join(costs_lookup, by = c("year", "hbtreatcode", "hbtreatname")) %>%
  # compute difference
  mutate(difference = cost_total_net - cost_old) %>%
  mutate(pct_diff = difference / cost_old * 100)


# Create charts -----------------------------------------------

# plot difference
ggplot(data = matched_data, aes(x = year, y = difference, fill = hbtreatname)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "NHS Board", x = "Year")

# plot pct_diff
ggplot(data = matched_data, aes(x = year, y = pct_diff, fill = hbtreatname)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(fill = "NHS Board", x = "Year")


## save outfile ---------------------------------------
outfile <-
  matched_data %>%
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
