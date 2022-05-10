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

# Load packages

library(dplyr)
library(stringr)
library(readr)

# Read data -------------------------------------------------------
deaths_file <- read_csv(
  file = get_it_deaths_path(),
  col_type = cols(
    `PATIENT_UPI [C]` = col_character(),
    `PATIENT DoD DATE (NRS)` = col_date(format = "%d-%m-%Y"),
    `PATIENT DoD DATE (CHI)` = col_date(format = "%d-%m-%Y")
  )
) %>%
  # rename variables
  rename(
    chi = `PATIENT_UPI [C]`,
    death_date_nrs = `PATIENT DoD DATE (NRS)`,
    death_date_chi = `PATIENT DoD DATE (CHI)`
  )


# Data Cleaning------------------------------------------------------

# One record per chi
outfile <- deaths_file %>%
  dplyr::arrange(desc(death_date_nrs), desc(death_date_chi)) %>%
  dplyr::distinct(chi, .keep_all = TRUE) %>%
  # Use the NRS deathdate unless it isn't there
  mutate(death_date = dplyr::coalesce(death_date_nrs, death_date_chi))


# Save Outfile--------------------------------------------------------

# .zsav file
haven::write_sav(outfile, get_slf_deaths_path(ext = "zsav", check_mode = "write"), compress = TRUE)

# .rds file
readr::write_rds(outfile, get_slf_deaths_path(check_mode = "write"), compress = "gz")


## End of Script ##
