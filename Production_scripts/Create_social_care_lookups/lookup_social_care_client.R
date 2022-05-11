#####################################################
# Social Care Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Social Care Client data from Platform
# Description - Get the client extract from DVPROD / social_care_2
#####################################################

# Load packages
library(dplyr)
library(dbplyr)
library(tidyr)
library(createslf)


# Read in data---------------------------------------

# specify latest year
year <- "1920"
year_alt <- convert_fyyear_to_year(year)

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 client
client_data <- tbl(db_connection, in_schema("social_care_2", "client")) %>%
  select(
    sending_location,
    social_care_id,
    financial_year,
    financial_quarter,
    dementia,
    mental_health_problems,
    learning_disability,
    physical_and_sensory_disability,
    drugs,
    alcohol,
    palliative_care,
    carer,
    elderly_frail,
    neurological_condition,
    autism,
    other_vulnerable_groups,
    living_alone,
    support_from_unpaid_carer,
    social_worker,
    type_of_housing,
    meals,
    day_care
  ) %>%
  filter(financial_year == year_alt) %>%
  arrange(
    sending_location,
    social_care_id,
    financial_year,
    financial_quarter
  ) %>%
  collect()

# Data Cleaning ---------------------------------------

client_clean <-
  client_data %>%
  # group
  group_by(.data$sending_location, .data$social_care_id) %>%
  # summarise to take last submission
  summarise(across(
    c(
      .data$dementia,
      .data$mental_health_problems,
      .data$learning_disability,
      .data$physical_and_sensory_disability,
      .data$drugs,
      .data$alcohol,
      .data$palliative_care,
      .data$carer,
      .data$elderly_frail,
      .data$neurological_condition,
      .data$autism,
      .data$other_vulnerable_groups,
      .data$living_alone,
      .data$support_from_unpaid_carer,
      .data$social_worker,
      .data$type_of_housing,
      .data$meals,
      .data$day_care
    ),
    ~ as.numeric(last(.x))
  )) %>%
  ungroup() %>%
  # recode missing with values
  mutate(across(
    c(
      .data$support_from_unpaid_carer,
      .data$social_worker,
      .data$meals,
      .data$living_alone,
      .data$day_care
    ),
    replace_na, 9
  ),
  type_of_housing = replace_na(.data$type_of_housing, 6)
  ) %>%
  # factor labels
  mutate(across(
    c(
      .data$dementia,
      .data$mental_health_problems,
      .data$learning_disability,
      .data$physical_and_sensory_disability,
      .data$drugs,
      .data$alcohol,
      .data$palliative_care,
      .data$carer,
      .data$elderly_frail,
      .data$neurological_condition,
      .data$autism,
      .data$other_vulnerable_groups
    ),
    factor,
    levels = c(0, 1),
    labels = c("No", "Yes")
  ),
  across(
    c(
      .data$living_alone,
      .data$support_from_unpaid_carer,
      .data$social_worker,
      .data$meals,
      .data$day_care
    ),
    factor,
    levels = c(0, 1, 9),
    labels = c("No", "Yes", "Not Known")
  ),
  type_of_housing = factor(.data$type_of_housing,
    levels = c(1:6)
  )
  ) %>%
  # rename variables
  rename_with(
    .cols = -c(.data$sending_location, .data$social_care_id),
    .fn = ~ paste0("sc_", .x)
  )


## save outfile ---------------------------------------
outfile <-
  client_clean %>%
  # reorder
  select(
    .data$sending_location,
    .data$social_care_id,
    .data$sc_living_alone,
    .data$sc_support_from_unpaid_carer,
    .data$sc_social_worker,
    .data$sc_type_of_housing,
    .data$sc_meals,
    .data$sc_day_care
  )

outfile %>%
  # .zsav
  write_sav(get_source_extract_path(
    year = latest_year,
    type = "Client",
    ext = "zsav"
  )
  ) %>%
  # .rds file
  write_rds(get_source_extract_path(
    year = latest_year,
    type = "Client",
    ext = "rds"
  )
  )

## End of Script ---------------------------------------
