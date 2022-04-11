#####################################################
# Prescribing Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process Prescribing Extract
#####################################################

library(dplyr)
library(createslf)
library(readr)
library(phsmethods)


# Read in data ---------------------------------------

# latest year
year <- "1920"

pis_file <- readr::read_csv(
  get_it_prescribing_path(year),
  col_type = cols_only(
    `Pat UPI [C]` = col_character(),
    `Pat DoB [C]` = col_date(format = "%d-%m-%Y"),
    `Pat Gender` = col_double(),
    `Pat Postcode [C]` = col_character(),
    `Practice Code` = col_character(),
    `Number of Dispensed Items` = col_double(),
    `DI Paid NIC excl. BB` = col_double()
  )
) %>%
  # Rename variables
  rename(
    chi = "Pat UPI [C]",
    dob = "Pat DoB [C]",
    gender = "Pat Gender",
    postcode = "Pat Postcode [C]",
    gpprac = "Practice Code",
    no_dispensed_items = "Number of Dispensed Items",
    cost_total_net = "DI Paid NIC excl. BB"
  )


# Data Cleaning--------------------------------------------------

pis_clean <- pis_file %>%
  # filter for chi NA
  filter(chi_check(chi) == "Valid CHI") %>%
  # create variables recid and year
  mutate(
    recid = "PIS",
    year = year
  ) %>%
  # Recode GP Practice into a 5 digit number
  # assume that if it starts with a letter it's an English practice and so recode to 99995
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # Set date to the end of the FY
  mutate(
    record_keydate1 = end_fy(year),
    record_keydate2 = record_keydate1
  ) %>%
  # sort by chi
  arrange(chi)

# Issue a warning if rows were removed
if (nrow(pis_clean) != nrow(pis_file)) {
  rlang::warn(message = c(
    "Rows were removed from the PIS extract because of the CHI number being invalid",
    "Please check the raw PIS extract"
  ))
}


# Save out ---------------------------------------
pis_clean %>%
  # Save as .zsav file
  haven::write_sav(get_source_extract_path(
    year = year,
    type = "PIS",
    ext = "zsav"
  ),
  compress = TRUE
  ) %>%
  # Save as .rds file
  readr::write_rds(get_source_extract_path(
    year = year,
    type = "PIS",
    ext = "rds"
  ),
  compress = "gz"
  )


# End of Script #
