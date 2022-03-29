#####################################################
# A&E Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process A & E extract
#####################################################

# Load packages
library(dplyr)
library(tidyr)
library(ggplot2)
library(createslf)
library(slfhelper)
library(readr)

# Read in data---------------------------------------

# Specify year
year <- 1920

## get data ##
ae_cup_extract <- readr::read_csv(
  file =
    paste0(
      get_year_dir(year = latest_year),
      "/Extracts/A&E-UCD-CUP-extract-20",
      latest_year,
      ".csv.gz"
    )
) %>%
  # rename
  rename(
    record_keydate1 = "ED Arrival Date",
    keyTime1 = "ED Arrival Time",
    case_ref_number = "ED Case Reference Number [C]",
    cup_marker = "CUP Marker",
    cup_pathway = "CUP Pathway Name"
  ) %>%
  # date type
  mutate(
    record_keydate1 = as.Date(record_keydate1)
  )


## sort for linking onto data extract ##
# remove any duplicates
ae_cup_extract <-
  ae_cup_extract %>%
  arrange(record_keydate1, keyTime1, case_ref_number) %>%
  group_by(record_keydate1, keyTime1, case_ref_number) %>%
  mutate(
    cup_marker = first(cup_marker),
    cup_pathway = first(cup_pathway)
  ) %>%
  ungroup()


## match files ##
matched_data <-
  outfile %>%
  full_join(ae_cup_extract, by = c("record_keydate1", "keyTime1", "case_ref_number")) %>%
  arrange(chi, record_keydate1, keyTime1, record_keydate2, keyTime2)


## save outfile ##
outfile <-
  matched_data %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    keyTime1,
    keyTime2,
    chi,
    gender,
    dob,
    gpprac,
    postcode,
    lca,
    hscp,
    location,
    hbrescode,
    hbtreatcode,
    diag1,
    diag2,
    diag3,
    ae_arrivalmode,
    refsource,
    sigfac,
    ae_attendcat,
    ae_disdest,
    ae_patflow,
    ae_placeinc,
    ae_reasonwait,
    ae_bodyloc,
    ae_alcohol,
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    cost_total_net,
    age,
    apr_cost,
    may_cost,
    jun_cost,
    jul_cost,
    aug_cost,
    sep_cost,
    oct_cost,
    nov_cost,
    dec_cost,
    jan_cost,
    feb_cost,
    mar_cost,
    cup_marker,
    cup_pathway
  )


# .zsav
haven::write_sav(outfile,
                 paste0(
                   get_year_dir(year = latest_year),
                   "/a&e_for_source-20",
                   latest_year, ".zsav"
                 ),
                 compress = TRUE
)

# .rds file
readr::write_rds(outfile,
                 paste0(
                   get_year_dir(year = latest_year),
                   "/a&e_for_source-20",
                   latest_year, ".zsav"
                 ),
                 compress = "gz"
)


# End of Script ##
