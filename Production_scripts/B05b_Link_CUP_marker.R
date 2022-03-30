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

ae_cup_file <- readr::read_csv(
  file = get_boxi_extract_path(year, "AE_CUP"), n_max = 2000,
  col_type = cols(
    `ED Arrival Date` = col_date(format = "%Y/%m/%d %T"),
    `ED Arrival Time` = col_time(""),
    `ED Case Reference Number [C]` = col_character(),
    `CUP Marker` = col_double(),
    `CUP Pathway Name` = col_character()
  )
) %>%
  # rename variables
  rename(
    record_keydate1 = "ED Arrival Date",
    keyTime1 = "ED Arrival Time",
    case_ref_number = "ED Case Reference Number [C]",
    cup_marker = "CUP Marker",
    cup_pathway = "CUP Pathway Name"
  ) %>%
  # Data Cleaning---------------------------------------

  # Sort for linking and remove any duplicates
  ae_cup_clean() <- ae_cup_file %>%
  arrange(record_keydate1, keyTime1, case_ref_number) %>%
  group_by(record_keydate1, keyTime1, case_ref_number) %>%
  mutate(
    cup_marker = first(cup_marker),
    cup_pathway = first(cup_pathway)
  ) %>%
  ungroup()


# Join data--------------------------------------------

# Read TEMP source A&E file
source_ae <- readr::read_rds(
  outfile,
  paste0(
    get_year_dir(year = latest_year),
    "/a&e_for_source-20",
    latest_year, ".rds"
  )
)

# Join data
matched_ae_data <- source_ae %>%
  full_join(ae_cup_file, by = c("record_keydate1", "keyTime1", "case_ref_number")) %>%
  arrange(chi, record_keydate1, keyTime1, record_keydate2, keyTime2)


# Save outfile----------------------------------------
outfile <- matched_ae_data %>%
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

# Save as zsav file
outfile %>%
  readr::write_rds(get_source_extract_path(year, "AE", ext = "zsav"))

# Save as rds file
outfile %>%
  readr::write_rds(get_source_extract_path(year, "AE", ext = "rds"))

# End of Script #
