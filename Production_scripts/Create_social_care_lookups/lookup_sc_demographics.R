
#####################################################
# Convert Social Care Demographics
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Data from Social care database DVPROD
# Description - Get Demographics extract
#####################################################

## load packages ##

library(readr)
library(odbc)
library(dplyr)
library(stringr)
library(dbplyr)
library(phsmethods)
library(createslf)

# Read in data---------------------------------------

# set-up conection to platform
db_connection <- phs_db_connection(dsn = "DVPROD")

# read in data - social care 2 demographic
sc_demog <- tbl(db_connection, in_schema("social_care_2", "demographic")) %>%
  select(
    latest_record_flag, extract_date, sending_location, social_care_id, upi,
    chi_upi, submitted_postcode, chi_postcode, submitted_date_of_birth,
    chi_date_of_birth, submitted_gender, chi_gender_code
  ) %>%
  collect()

# variable types
sc_demog <- sc_demog %>%
  mutate(
    submitted_gender = as.numeric(submitted_gender),
    chi_gender_code = as.numeric(chi_gender_code)
  )


## Deal with postcodes---------------------------------------

# UK postcode regex - see https://ideal-postcodes.co.uk/guides/postcode-validation
uk_pc_regexp <- "^[a-z]{1,2}\\d[a-z\\d]?\\s*\\d[a-z]{2}$"

dummy_postcodes <- c("NK1 0AA", "NF1 1AB")
non_existant_postcodes <- c("PR2 5AL", "M16 0GS", "DY103DJ")

## postcode type ##
pc_lookup <- readr::read_rds(read_spd_file()) %>%
  select(pc7)


# Data Cleaning ---------------------------------------

sc_demog <- sc_demog %>%
  mutate(
    # use chi if upi is NA
    upi = coalesce(upi, chi_upi),
    # check gender code - replace code 99 with 9
    submitted_gender = replace(submitted_gender, submitted_gender == 99, 9)
  ) %>%
  mutate(
    # use chi gender if avaliable
    gender = if_else(is.na(chi_gender_code) | chi_gender_code == 9, submitted_gender, chi_gender_code),
    # use chi dob if avaliable
    dob = coalesce(chi_date_of_birth, submitted_date_of_birth)
  ) %>%
  # format postcodes using `phsmethods`
  mutate(across(contains("postcode"), ~ postcode(.x, format = "pc7")))


# count number of na postcodes
na_postcodes <-
  sc_demog %>%
  count(across(contains("postcode"), ~ is.na(.x)))


sc_demog <- sc_demog %>%
  # remove dummy postcodes invalid postcodes missed by regex check
  mutate(across(ends_with("_postcode"), ~ na_if(.x, .x %in% c(dummy_postcodes, non_existant_postcodes)))) %>%
  # comparing with regex UK postcode
  mutate(across(ends_with("_postcode"), ~ na_if(.x, !str_detect(.x, uk_pc_regexp)))) %>%
  select(
    latest_record_flag, extract_date, sending_location, social_care_id, upi, gender,
    dob, submitted_postcode, chi_postcode
  ) %>%
  # check if submitted_postcode matches with postcode lookup
  mutate(valid_pc = if_else(submitted_postcode %in% pc_lookup$pc7, 1, 0)) %>%
  # use submitted_postcode if valid, otherwise use chi_postcode
  mutate(postcode = case_when(
    (!is.na(submitted_postcode) & valid_pc == 1) ~ submitted_postcode,
    (is.na(submitted_postcode) & valid_pc == 0) ~ chi_postcode
  )) %>%
  mutate(postcode_type = case_when(
    (!is.na(submitted_postcode) & valid_pc == 1) ~ "submitted",
    (is.na(submitted_postcode) & valid_pc == 0) ~ "chi",
    (is.na(submitted_postcode) & is.na(chi_postcode)) ~ "missing"
  ))


# Check where the postcodes are coming from
sc_demog %>%
  count(postcode_type)


# count number of replaced postcode - compare with count above
na_replaced_postcodes <-
  sc_demog %>%
  count(across(ends_with("_postcode"), ~ is.na(.x)))


na_replaced_postcodes
na_postcodes


## save outfile ---------------------------------------
outfile <-
  sc_demog %>%
  # group by sending location and ID
  group_by(sending_location, social_care_id) %>%
  # arrange so lastest submissions are last
  arrange(
    sending_location,
    social_care_id,
    latest_record_flag,
    extract_date
  ) %>%
  # summarise to select the last (non NA) submission
  summarise(
    chi = last(upi),
    gender = last(gender),
    dob = last(dob),
    postcode = last(postcode)
  ) %>%
  ungroup()


## save file ##
outfile %>%
# .zsav file
write_sav(get_sc_demog_lookup_path()) %>%
# .rds file
write_rds(get_sc_demog_lookup_path())

## End of Script ---------------------------------------
