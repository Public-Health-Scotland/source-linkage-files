#####################################################
# Social Care Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################

## packages ##
library(dplyr)
library(dbplyr)
library(tidyr)




## data ##

######################################################
# set-up conection to platform
db_connection <- odbc::dbConnect(
  odbc::odbc(),
  dsn = "DVPROD",
  uid = Sys.getenv("USER"),
  pwd = rstudioapi::askForPassword("password")
)
###################################################
## year of interest ##
year <- 2019

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
  # filter data by year
  filter(financial_year == year) %>%
  arrange(
    sending_location,
    social_care_id,
    financial_year,
    financial_quarter
  ) %>%
  collect()


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
    support_from_unpaid_carer = replace(support_from_unpaid_carer, is.na(support_from_unpaid_carer), 9),
    social_worker = replace(social_worker, is.na(social_worker), 9),
    meals = replace(meals, is.na(meals), 9),
    living_alone = replace(living_alone, is.na(living_alone), 9),
    day_care = replace(day_care, is.na(day_care), 9),
    type_of_housing = replace(type_of_housing, is.na(type_of_housing), 6)
  )


# factor labels
outfile <-
  outfile %>%
  mutate(
    dementia = factor(dementia,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    mental_health_problems = factor(mental_health_problems,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    learning_disability = factor(learning_disability,
      levels = c(0, 1),
      labels = c("No", "Yes")
    ),
    physical_and_sensory_disability = factor(physical_and_sensory_disability,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    drugs = factor(drugs,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    alcohol = factor(alcohol,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    palliative_care = factor(palliative_care,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    carer = factor(carer,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    elderly_frail = factor(elderly_frail,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    neurological_condition = factor(neurological_condition,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    autism = factor(autism,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    other_vulnerable_groups = factor(other_vulnerable_groups,
      levels = c(0, 1), labels = c("No", "Yes")
    ),
    living_alone = factor(living_alone,
      levels = c(0, 1, 9), labels = c("No", "Yes", "Not Known")
    ),
    support_from_unpaid_carer = factor(support_from_unpaid_carer,
      levels = c(0, 1, 9), labels = c("No", "Yes", "Not Known")
    ),
    social_worker = factor(social_worker,
      levels = c(0, 1, 9), labels = c("No", "Yes", "Not Known")
    ),
    type_of_housing = factor(type_of_housing,
      levels = c(1:6),
      labels = c(
        "Mainstream", "Supported", "Long Stay Care Home",
        "Hospital or other medical establishment", "Other",
        "Not Known"
      )
    ),
    meals = factor(meals,
      levels = c(0, 1, 9), labels = c("No", "Yes", "Not Known")
    ),
    day_care = factor(day_care,
      levels = c(0, 1, 9), labels = c("No", "Yes", "Not Known")
    )
  )



# rename variables
outfile <-
  outfile %>%
  rename(
    sc_dementia = "dementia",
    sc_mental_health_problems = "mental_health_problems",
    sc_learning_disability = "learning_disability",
    sc_physical_and_sensory_disability = "physical_and_sensory_disability",
    sc_drugs = "drugs",
    sc_alcohol = "alcohol",
    sc_palliative_care = "palliative_care",
    sc_carer = "carer",
    sc_elderly_frail = "elderly_frail",
    sc_neurological_condition = "neurological_condition",
    sc_autism = "autism",
    sc_other_vulnerable_groups = "other_vulnerable_groups",
    sc_living_alone = "living_alone",
    sc_support_from_unpaid_carer = "support_from_unpaid_carer",
    sc_social_worker = "social_worker",
    sc_type_of_housing = "type_of_housing",
    sc_meals = "meals",
    sc_day_care = "day_care"
  )




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
    "/conf/sourcedev/Source_Linkage_File_Updates/", convert_year_to_fyyear(year),
    "/Client_for_Source-20", convert_year_to_fyyear(year), ".zsav"
  ),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  paste0(
    "/conf/sourcedev/Source_Linkage_File_Updates/", convert_year_to_fyyear(year),
    "/Client_for_Source-20", convert_year_to_fyyear(year), ".rds"
  ),
  compress = "gz"
)
