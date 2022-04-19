#####################################################
# Draft pre processing code for Gp Out of Hours - Diagnosis
# Author: Jennifer Thom
# Date: April 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - GP-OoH-
#         # consultations-extract-.csv
#         # diagnosis-extract-.csv
#         # outcomes-extract-.csv
#
# Description - Preprocessing of GP out of hours raw BOXI file.
#              Tidy up file in line with SLF format
#              prior to processing.
#####################################################

# Load Packages
library(readr)
library(dplyr)
library(tidyverse)
library(createslf)
library(stringr)


## Load Read code lookup----------------------------

## TODO - Put into function##
read_code_lookup <- haven::read_sav(
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "ReadCodeLookup.zsav"
  )
) %>%
  rename(
    readcode = "ReadCode",
    description = "Description"
  )

## Load extract file---------------------------------

year <- "1920"

diagnosis_file <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-d"),
  col_type = cols(
    `GUID` = col_character(),
    `Diagnosis Code` = col_character(),
    `Diagnosis Description` = col_character()
  )
) %>%
  # rename variables
  rename(
    guid = `GUID`,
    readcode = `Diagnosis Code`,
    description = `Diagnosis Description`
  )


## Deal with Read Codes --------------------------

matched_data <- diagnosis_file %>%
  # Sort for matching
  arrange(readcode, description) %>%
  # match by read code
  left_join(read_code_lookup, by = "readcode") %>%
  # rename
  rename(
    "description" = "description.x",
    "true_description" = "description.y"
  ) %>%
  # replace NA string with blank
  mutate(true_description = replace_na(true_description, "")) %>%
  # identify matching descriptions
  mutate(full_match1 = if_else(description == true_description, 1, 0)) %>%
  # If we had a description in the lookup that matched a Read code, use that one now.
  mutate(description = if_else(full_match1 == 0 & true_description != "",
    true_description, description
  )) %>%
  # match by read code
  left_join(read_code_lookup, by = "readcode", "description") %>%
  # replace NA string with blank
  mutate(description.y = replace_na(description.y, "")) %>%
  # identify matching descriptions
  mutate(full_match2 = if_else(description.x == description.y, 1, 0)) %>%
  # rename
  rename(
    "description" = "description.x",
    "true_description2" = "description.y"
  ) %>%
  mutate(old_readcode = readcode) %>%
  # Check the output for any dodgy Read codes and try and fix by adding exceptions
  mutate(readcode = case_when(
    full_match2 == 0 & readcode == "Xa1m." ~ "S349",
    full_match2 == 0 & readcode == "Xa1mz" ~ "S349",
    full_match2 == 0 & readcode == "HO6.." ~ "H06..",
    full_match2 == 0 & readcode == "zV6.." ~ "ZVz..",
    full_match2 == 0 ~ str_replace_all(readcode, "\\?", "\\."),
    full_match2 == 0 ~ str_replace_all(readcode, "\\d{5}", "\\d{5}."),
    TRUE ~ readcode
  ))


## Data Cleaning ---------------------------------

dianosis_clean <- matched_data %>%
  # Sort and restructure the data so it's ready to link to case IDs.
  arrange(guid, readcode) %>%
  # Remove duplicates (use a flag)
  mutate(
    duplicate = if_else(guid == lag(guid, default = first(guid)) & readcode == lag(readcode, default = first(readcode)), 1, 0)
  ) %>%
  filter(duplicate == 0) %>%
  mutate(readcodelevel = str_locate(readcode, "[.]"))
         readcodelevel = replace_na(readcodelevel, 0)
         ) %>%
  group_by(guid, readcode) %>%
  # restructure data
  pivot_wider(
    id_cols = guid,
    names_from = readcodelevel,
    values_from = readcode
  )



## Save outfile----------------------------------------

outfile <- outcome_clean %>%
  select()

# TEMP zsav file
haven::write_sav(
  paste0(
    get_year_dir(year = year),
    "/gp-outcomes-data-20",
    year, ".zsav"
  )
)

# TEMP rds file
readr::write_rds(
  paste0(
    get_year_dir(year = year),
    "/gp-outcomes-data-20",
    year, ".rds"
  )
)

# End of Script #
