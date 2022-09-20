#####################################################
# District Nursing Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process District Nursing Extract
#####################################################

# Load packages
library(dplyr)
library(readr)
library(createslf)


# Read in data ---------------------------------------

# Specify year
year <- check_year_format("1920")

# Read BOXI extract
dn_extract <- get_boxi_extract_path(
  year = year,
  type = "DN"
) %>%
  read_csv(col_types = cols_only(
    `Treatment NHS Board Code 9` = col_character(),
    `Age at Contact Date` = col_integer(),
    `Contact Date` = col_date(format = "%Y/%m/%d %T"),
    `Primary Intervention Category` = col_character(),
    `Other Intervention Category (1)` = col_character(),
    `Other Intervention Category (2)` = col_character(),
    `Other Intervention Category (3)` = col_character(),
    `Other Intervention Category (4)` = col_character(),
    `UPI Number [C]` = col_character(),
    `Patient DoB Date [C]` = col_date(format = "%Y/%m/%d %T"),
    `Patient Postcode [C] (Contact)` = col_character(),
    `Duration of Contact (measure)` = col_double(),
    Gender = col_double(),
    `Location of Contact` = col_double(),
    `Practice NHS Board Code 9 (Contact)` = col_character(),
    `Patient Council Area Code (Contact)` = col_character(),
    `Practice Code (Contact)` = col_character(),
    `NHS Board of Residence Code 9 (Contact)` = col_character(),
    `HSCP of Residence Code (Contact)` = col_character(),
    `Patient Data Zone 2011 (Contact)` = col_character()
  )) %>%
  # rename
  rename(
    age = "Age at Contact Date",
    dob = "Patient DoB Date [C]",
    gender = "Gender",
    hscp = "HSCP of Residence Code (Contact)",
    hbrescode = "NHS Board of Residence Code 9 (Contact)",
    lca = "Patient Council Area Code (Contact)",
    postcode = "Patient Postcode [C] (Contact)",
    gpprac = "Practice Code (Contact)",
    datazone = "Patient Data Zone 2011 (Contact)",
    hbpraccode = "Practice NHS Board Code 9 (Contact)",
    hbtreatcode = "Treatment NHS Board Code 9",
    chi = "UPI Number [C]",
    record_keydate1 = "Contact Date",
    primary_intervention = "Primary Intervention Category",
    intervention_1 = "Other Intervention Category (1)",
    intervention_2 = "Other Intervention Category (2)",
    duration_contact = "Duration of Contact (measure)",
    location_contact = "Location of Contact"
  )


# Data Cleaning  ---------------------------------------

dn_clean <- dn_extract %>%
  # filter for valid chi only
  filter(phsmethods::chi_check(chi) == "Valid CHI") %>%
  # add variables
  mutate(
    year = year,
    recid = "DN",
    smrtype = add_smr_type(recid = "DN")
  ) %>%
  # deal with gpprac
  convert_eng_gpprac_to_dummy(gpprac)


# Costs  ---------------------------------------

# Recode HB codes to HB2019 so they match the cost lookup
dn_costs <- dn_clean %>%
  mutate(hbtreatcode = recode(hbtreatcode,
    "S08000018" = "S08000029",
    "S08000027" = "S08000030",
    "S08000021" = "S08000031",
    "S08000023" = "S08000032"
  )) %>%
  # match files with DN Cost Lookup
  left_join(readr::read_rds(get_dn_costs_path()),
    by = c("hbtreatcode", "year" = "Year")
  ) %>%
  # costs are rough estimates we round them to the nearest pound
  mutate(cost_total_net = janitor::round_half_up(cost_total_net)) %>%
  # Create monthly cost vars
  create_day_episode_costs(record_keydate1, cost_total_net)


## Aggregate to episodes  ---------------------------------------

care_marker <- dn_costs %>%
  group_by(chi) %>%
  arrange(record_keydate1, .by_group = TRUE) %>%
  # Create ccm (Contiuous Care Marker) which will group contacts which occur less
  # than 7 days apart
  mutate(ccm = pmax((record_keydate1 - lag(record_keydate1)) > 7, FALSE, na.rm = TRUE) %>%
    cumsum())

dn_episodes <- care_marker %>%
  group_by(year, chi, ccm) %>%
  summarise(
    recid = first(recid),
    smrtype = first(smrtype),
    record_keydate1 = min(record_keydate1),
    record_keydate2 = max(record_keydate1),
    dob = last(dob),
    gender = last(gender),
    gpprac = last(gpprac),
    age = last(age),
    postcode = last(postcode),
    datazone = last(datazone),
    lca = last(lca),
    hscp = last(hscp),
    hbrescode = last(hbrescode),
    hbtreatcode = last(hbtreatcode),
    location = first(location_contact),
    diag1 = first(primary_intervention),
    diag2 = first(intervention_1),
    diag3 = first(intervention_2),
    diag4 = last(primary_intervention),
    diag5 = last(intervention_1),
    diag6 = last(intervention_2),
    cost_total_net = sum(cost_total_net),
    apr_cost = sum(apr_cost),
    may_cost = sum(may_cost),
    jun_cost = sum(jun_cost),
    jul_cost = sum(jul_cost),
    aug_cost = sum(aug_cost),
    sep_cost = sum(sep_cost),
    oct_cost = sum(oct_cost),
    nov_cost = sum(nov_cost),
    dec_cost = sum(dec_cost),
    jan_cost = sum(jan_cost),
    feb_cost = sum(feb_cost),
    mar_cost = sum(mar_cost)
  ) %>%
  ungroup()


# Save as rds file
dn_episodes %>%
  write_rds(get_source_extract_path(year, "DN", check_mode = "write"))


# End of Script #
