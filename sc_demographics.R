
#####################################################
# Convert Social Care Demographics
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################


## output ##
output <- haven::read_sav(file = "/conf/hscdiip/SLF_Extracts/Social_care/sc_demographics_lookup_Dec_2021.zsav")



## load packages ##
library(readr)
library(odbc)
library(dplyr)
library(stringr)
library(dbplyr)
library(phsmethods)



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


## clean up data ##
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
  )


## postcode ##
# clean-up
sc_demog <- sc_demog %>%
  mutate(
    # remove any postcodes with length < 5
    submitted_postcode = na_if(submitted_postcode, str_length(submitted_postcode) < 5 | str_length(submitted_postcode) == 5),
    chi_postcode = na_if(chi_postcode, str_length(chi_postcode) < 5 | str_length(chi_postcode) == 5)
  ) %>%
  mutate(
    # remove spaces
    submitted_postcode = str_replace_all(submitted_postcode, fixed(" "), ""),
    chi_postcode = str_replace_all(chi_postcode, fixed(" "), "")
  ) %>%
  mutate(
    # remove postcodes with length 8 or longer
    submitted_postcode = na_if(submitted_postcode, str_length(submitted_postcode) > 8 | str_length(submitted_postcode) == 8),
    chi_postcode = na_if(chi_postcode, str_length(chi_postcode) > 8 | str_length(chi_postcode) == 8)
  )


# format postcodes using `phsmethods`
sc_demog <-
  sc_demog %>%
  mutate(across(contains("postcode"), ~postcode(.x, format = "pc7")))


# count number of na postcodes
na_postcodes <-
  sc_demog %>%
  count(across(contains("postcode"), ~is.na(.x)))

# UK postcode regex
uk_pc_regexp <- "([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\\s?[0-9][A-Za-z]{2})"

sc_demog <-
  sc_demog %>%
  mutate(
    # remove dummy postcodes "NK1 0AA" and "NK1 1AB" and invalid postcodes missed by regex check
    across(ends_with("_postcode"),
           ~na_if(.x, c("NK1 0AA", "NF1 1AB", "PR2 5AL", "M16 0GS", "DY103DJ")))
  ) %>%
  mutate(
    # comparing with regex UK postcode
    across(ends_with("_postcode"),
           ~na_if(.x, !str_detect(.x, uk_pc_regexp)))
  )


## postcode type ##
pc_lookup <- readr::read_rds(read_spd_file()) %>%
  select(pc7)


sc_demog <-
  sc_demog %>%
  select(
    latest_record_flag, extract_date, sending_location, social_care_id, upi, gender, dob,
    submitted_postcode, chi_postcode
  ) %>%
  # check if submitted_postcode matches with postcode lookup
  mutate(valid_pc = if_else(submitted_postcode %in% pc_lookup, 1, 0))


# use submitted_postcode if valid, otherwise use chi_postcode
sc_demog <-
  sc_demog %>%
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
  count(across(ends_with("_postcode"), ~is.na(.x)))

na_replaced_postcodes
na_postcodes


## outfile ##
outfile <-
  sc_demog %>%
  # group by sending location and ID
  group_by(sending_location, social_care_id) %>%
  # arranage so lastest submissions are last
  arrange(sending_location,
          social_care_id,
          latest_record_flag,
          extract_date
          ) %>%
  # summarise so select last submission
  summarise(chi = last(upi),
            gender = last(gender),
            dob = last(dob),
            postcode = last(postcode)
            )


## save file ##
# .zsav file
haven::write_sav(outfile, get_sc_demog_lookup_path(), compress = TRUE)

# .rds file
readr::write_rds(outfile, get_sc_demog_lookup_path(), compress = "gz")
