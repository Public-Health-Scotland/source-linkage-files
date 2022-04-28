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

diagnosis_clean <- diagnosis_file %>%
  # Apply readcode changes
  tidylog::mutate(readcode = str_replace_all(readcode, "\\?", "\\.") %>%
    str_pad(5, "right", ".")) %>%
  # Join diagnosis to readcode lookup
  # Identify diagnosis descriptions which match the readcode lookup
  left_join(read_code_lookup %>%
    mutate(fullmatch1 = 1),
  by = c("readcode", "description")
  ) %>%
  # match on true description from readcode lookup
  left_join(read_code_lookup %>%
    rename(true_description = description),
  by = c("readcode")
  ) %>%
  # replace description with true description from readcode lookup if this is different
  mutate(description = if_else(is.na(fullmatch1) & !is.na(true_description),
    true_description, description
  )) %>%
  # Join to readcode lookup again to check
  left_join(read_code_lookup %>%
    mutate(full_match2 = 1),
  by = c("readcode", "description")
  ) %>%
  # Check the output for any dodgy Read codes and try and fix by adding exceptions
  mutate(readcode = case_when(
    full_match2 == 0 & readcode == "Xa1m." ~ "S349",
    full_match2 == 0 & readcode == "Xa1mz" ~ "S349",
    full_match2 == 0 & readcode == "HO6.." ~ "H06..",
    full_match2 == 0 & readcode == "zV6.." ~ "ZVz..",
    TRUE ~ readcode
  ))


## Data Cleaning ---------------------------------

diagnosis_clean <- diagnosis_clean %>%
  # Sort and restructure the data so it's ready to link to case IDs.
  arrange(guid, readcode) %>%
  # Remove duplicates (use a flag)
  mutate(
    duplicate = if_else(guid == lag(guid, default = first(guid)) & readcode == lag(readcode, default = first(readcode)), 1, 0)
  ) %>%
  filter(duplicate == 0) %>%
  # Base R way - not working
  # mutate(readcodelevel = gregexpr('[.]', readcode)[1])
  mutate(
    readcodelevel = str_locate(readcode, "[.]"),
    readcodelevel = replace_na(readcodelevel, 0)
  ) %>%
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
