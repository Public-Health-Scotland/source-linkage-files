
#####################################################
# Draft DEATHS Extract Processing Code
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Takes IT extract of Deaths data.
#               Creates new death date variable,
#               uses NRS death date as death date if avaliable.
#               Saves outputted flagged dataset.
#####################################################


## packages ##

library(dplyr)
library(stringr)
library(readr)

## Read data in ##
deaths_file <- read_csv(
  file = get_it_deaths_path(),
  col_type = cols(
    `PATIENT_UPI [C]` = col_character(),
    `PATIENT DoD DATE (NRS)` = col_date(format = "%d-%m-%Y"),
    `PATIENT DoD DATE (CHI)` = col_date(format = "%d-%m-%Y")
  )
)

names(deaths_file) <- str_replace_all(names(deaths_file), " ", "_")

# rename variables
deaths_file <- deaths_file %>%
  rename(
    chi = "PATIENT_UPI_[C]",
    death_date_nrs = "PATIENT_DoD_DATE_(NRS)",
    death_date_chi = "PATIENT_DoD_DATE_(CHI)"
  )

## one record per chi ##
deaths_file <- deaths_file %>%
  dplyr::arrange(desc(death_date_nrs), desc(death_date_chi)) %>%
  dplyr::distinct(chi, .keep_all = TRUE) %>%
  # Use the NRS deathdate unless it isn't there
  mutate(death_date = dplyr::coalesce(death_date_nrs, death_date_chi))

## Save file - //stats/hscdiip/SLF_extracts/Deaths/ ##
# .zsav file
haven::write_sav(deaths_file, get_slf_deaths_path(), compress = TRUE)

# .rds file
readr::write_rds(deaths_file, get_slf_deaths_path(), compress = "gz")

## End of Script ##
