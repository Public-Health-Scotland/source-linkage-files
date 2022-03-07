#####################################################
# Social Care Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Social Care Client data from Platform
# Description - Get the client extract from DVPROD / social_care_2
#####################################################

## packages ##
library(dplyr)
library(dbplyr)
library(tidyr)


## data ##

######################################################
# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")
###################################################

## year of interest ##
latest_year <- 1920

# read in data - social care 2 client
sc <- tbl(db_connection, in_schema("social_care_2", "client")) %>%
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
  collect() %>%
  filter(financial_year == convert_fyyear_to_year(latest_year)) %>%
  arrange(
    sending_location,
    social_care_id,
    financial_year,
    financial_quarter
  )


# flags as numeric
sc <-
  sc %>%
  mutate(
    dementia = as.numeric(dementia),
    mental_health_problems = as.numeric(mental_health_problems),
    learning_disability = as.numeric(learning_disability),
    physical_and_sensory_disability = as.numeric(physical_and_sensory_disability),
    drugs = as.numeric(drugs),
    alcohol = as.numeric(alcohol),
    palliative_care = as.numeric(palliative_care),
    carer = as.numeric(carer),
    elderly_frail = as.numeric(elderly_frail),
    neurological_condition = as.numeric(neurological_condition),
    autism = as.numeric(autism),
    other_vulnerable_groups = as.numeric(other_vulnerable_groups),
    living_alone = as.numeric(living_alone),
    support_from_unpaid_carer = as.numeric(support_from_unpaid_carer),
    social_worker = as.numeric(social_worker),
    type_of_housing = as.numeric(type_of_housing),
    meals = as.numeric(meals),
    day_care = as.numeric(day_care)
  )


## create outfile ##
outfile <-
  sc %>%
  # sort
  arrange(sending_location, social_care_id) %>%
  # group
  group_by(sending_location, social_care_id) %>%
  # summarise to take last submission
  summarise(
    dementia = last(dementia),
    mental_health_problems = last(mental_health_problems),
    learning_disability = last(learning_disability),
    physical_and_sensory_disability = last(physical_and_sensory_disability),
    drugs = last(drugs),
    alcohol = last(alcohol),
    palliative_care = last(palliative_care),
    carer = last(carer),
    elderly_frail = last(elderly_frail),
    neurological_condition = last(neurological_condition),
    autism = last(autism),
    other_vulnerable_groups = last(other_vulnerable_groups),
    living_alone = last(living_alone),
    support_from_unpaid_carer = last(support_from_unpaid_carer),
    social_worker = last(social_worker),
    type_of_housing = last(type_of_housing),
    meals = last(meals),
    day_care = last(day_care)
  )


# recode missing with values
outfile <-
  outfile %>%
  mutate(
    across(.cols = c("support_from_unpaid_carer",
                     "social_worker",
                     "meals",
                     "living_alone",
                     "day_care"),
           .x = replace_na(.x, 9))
  ) %>%
  mutate(
    type_of_housing = replace_na(type_of_housing, 6))


# factor labels
outfile <-
  outfile %>%
  mutate(across(
    c(
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
      other_vulnerable_groups
    ),
    factor,
    levels = c(0, 1),
    labels = c("No", "Yes")
  ),
  across(
    c(
      living_alone,
      support_from_unpaid_carer,
      social_worker,
      meals,
      day_care
    ),
    factor,
    levels = c(0, 1, 9),
    labels = c("No", "Yes", "Not Known")
  ),
  type_of_housing = factor(type_of_housing,
                           levels = c(1:6),
                           labels = c(
                             "Mainstream", "Supported", "Long Stay Care Home",
                             "Hospital or other medical establishment", "Other",
                             "Not Known"
                           ))
  )


# rename variables
outfile <-
  outfile %>%
  rename_with(
    .cols = -c(sending_location, social_care_id),
    ~paste0("sc_", .x))


## save outfile ##

outfile <-
  outfile %>%
  # reorder
  select(
    sending_location,
    social_care_id,
    sc_living_alone,
    sc_support_from_unpaid_carer,
    sc_social_worker,
    sc_type_of_housing,
    sc_meals,
    sc_day_care
  )



# .zsav
haven::write_sav(outfile,
  paste0(
    get_year_dir(year = convert_year_to_fyyear(latest_year)),
    "/Client_for_Source-20",
    convert_year_to_fyyear(year), ".zsav"
  ),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  paste0(
    get_year_dir(year = convert_year_to_fyyear(latest_year)),
    "/Client_for_Source-20", convert_year_to_fyyear(year), ".rds"
  ),
  compress = "gz"
)
