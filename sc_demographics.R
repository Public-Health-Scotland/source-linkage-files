
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
# haven::read_sav(get_sc_demog_lookup_path())
output <- haven::read_sav(file = "/conf/hscdiip/SLF_Extracts/Social_care/sc_demographics_lookup_Dec_2021.zsav")



## load packages ##
library(readr)
library(odbc)
library(dplyr)
library(stringr)
library(dbplyr)



## data ##

# read in extract #
sc_demog <- readr::read_rds("/conf/hscdiip/SLF_Extracts/Social_care/temp-sc_demog_extract_Feb_2022.rds")
sc_demog <- sc_demog[, c(
  "latest_record_flag", "extract_date", "sending_location", "social_care_id",
  "upi", "chi_upi", "submitted_postcode", "chi_postcode", "submitted_date_of_birth",
  "chi_date_of_birth", "submitted_gender", "chi_gender_code"
)]


######################################################
# set-up conection to platform
db_connection <- odbc::dbConnect(
  odbc::odbc(),
  dsn = "DVPROD",
  uid = Sys.getenv("USER"),
  pwd = rstudioapi::askForPassword("password")
)

data <- tbl(db_connection, in_schema("social_care_2", "demographic")) %>%
  select(
    LATEST_RECORD_FLAG, EXTRACT_DATE, SENDING_LOCATION, SOCIAL_CARE_ID,
    UPI, CHI_UPI, SUBMITTED_POSTCODE, CHI_POSTCODE, SUBMITTED_DATE_OF_BIRTH,
    CHI_DATE_OF_BIRTH, SUBMITTED_GENDER, CHI_GENDER_CODE
  ) %>%
  collect()

###################################################

# variable types
sc_demog <- sc_demog %>%
  mutate(
    latest_record_flag = as.numeric(latest_record_flag),
    extract_date = as.Date(extract_date, format = "%d-%m-%Y"),
    sending_location = as.character(sending_location),
    social_care_id = as.character(social_care_id),
    upi = as.character(upi),
    chi_upi = as.character(chi_upi),
    submitted_postcode = as.character(submitted_postcode),
    chi_postcode = as.character(chi_postcode),
    submitted_date_of_birth = as.character(submitted_date_of_birth),
    chi_date_of_birth = as.character(chi_date_of_birth),
    submitted_gender = as.numeric(submitted_gender),
    chi_gender_code = as.numeric(chi_gender_code),

    # Create new variables which will hold the 'final' data
    postcode = as.character(NA),
    gender = as.numeric(NA),
    dob = as.Date(NA, format = "%d-%m-%Y")
  )


## clean up data ##
sc_demog <- sc_demog %>%
  mutate(
    # use chi if upi is NA
    upi = if_else(is.na(upi), chi_upi, upi),
    # check gender code - replace code 99 with 9
    submitted_gender = replace(submitted_gender, submitted_gender == 99, 9)
  ) %>%
  mutate(
    # use chi gender if avaliable
    gender = if_else(is.na(chi_gender_code) | chi_gender_code == 9, submitted_gender, chi_gender_code),
    # use chi dob if avaliable
    dob = if_else(is.na(chi_date_of_birth), submitted_date_of_birth, chi_date_of_birth)
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

sc_demog <-
  sc_demog %>%
  mutate(
    # add space to create length 7 postcode
    # length 5 postcode
    # submitted postcode
    submitted_postcode = if_else(str_length(submitted_postcode) == 5 & !is.na(submitted_postcode),
      paste0(substr(submitted_postcode, 1, 2), " ", substr(submitted_postcode, 3, 5)),
      submitted_postcode
    ),
    # chi postcode
    chi_postcode = if_else(str_length(chi_postcode) == 5 & !is.na(chi_postcode),
      paste0(substr(chi_postcode, 1, 2), " ", substr(chi_postcode, 3, 5)),
      chi_postcode
    )
  ) %>%
  mutate(
    # length 6 postcode
    # submitted postcode
    submitted_postcode = if_else(str_length(submitted_postcode) == 6 & !is.na(submitted_postcode),
      paste0(substr(submitted_postcode, 1, 3), " ", substr(submitted_postcode, 4, 6)),
      submitted_postcode
    ),
    # chi postcode
    chi_postcode = if_else(str_length(chi_postcode) == 6 & !is.na(chi_postcode),
      paste0(substr(chi_postcode, 1, 3), " ", substr(chi_postcode, 4, 6)),
      chi_postcode
    )
  )


# invalid postcodes
invalid_postcodes <- c(
  "DY103DJ",
  "EH191TR",
  "EH292EZ",
  "EH33TNZ",
  "G46 2NF",
  "G46 6FY",
  "G69 2YB",
  "G73 8NZ",
  "G74 7SN",
  "G75 1ZZ",
  "G75 6DF",
  "G77 3GT",
  "G78 6BU",
  "G78 ITE",
  "G79 8AJ",
  "IV178ED",
  "KA113FP",
  "KA28OBE",
  "KA5 1LQ",
  "KA71JUJ",
  "KA9 9FG",
  "KW152SE",
  "KY1 3DO",
  "KY13OPX",
  "L15 0PR",
  "M16 0GS",
  "ML3 0GS",
  "ML7 6AQ",
  "NK1 1AA",
  "NK1 1AB",
  "PA438JP",
  "PA494JS",
  "PR2 5AL",
  "TD8 8JD"
)

sc_demog <-
  sc_demog %>%
  mutate(
    # remove dummy postcodes "NK1 0AA" and "NK1 1AB"
    submitted_postcode = na_if(
      submitted_postcode,
      submitted_postcode == "NK1 0AA" | submitted_postcode == "NF1 1AB"
    ),
    chi_postcode = na_if(
      chi_postcode,
      chi_postcode == "NK1 0AA" | chi_postcode == "NF1 1AB"
    )
  ) %>%
  mutate(
    # comparing with regex UK postcode
    submitted_postcode = na_if(submitted_postcode, !str_detect(
      submitted_postcode,
      "([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\\s?[0-9][A-Za-z]{2})"
    )),
    chi_postcode = na_if(chi_postcode, !str_detect(
      chi_postcode,
      "([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\\s?[0-9][A-Za-z]{2})"
    ))
  ) %>%
  mutate(
    # na if postcode is in the invalid postcode vector
    submitted_postcode = na_if(submitted_postcode, submitted_postcode %in% invalid_postcodes),
    chi_postcode = na_if(chi_postcode, chi_postcode %in% chi_postcode)
  ) %>%
  # sort by submitted_postcode
  arrange(submitted_postcode)



## postcode type ##
postcode_lookup <- readr::read_rds(file = "/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2021_2.rds")

sc_demog <-
  sc_demog %>%
  select(
    latest_record_flag, extract_date, sending_location, social_care_id, upi, gender, dob, postcode,
    submitted_postcode, chi_postcode
  ) %>%
  # check if submitted_postcode matches with postcode lookup
  mutate(valid_pc = if_else(submitted_postcode %in% postcode_lookup$pc7, 1, 0))

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


## outfile ##
outfile <-
  sc_demog %>%
  # sort so latest submissions are last
  arrange(sending_location, social_care_id, latest_record_flag, extract_date) %>%
  ## Aggregate to create one row per sending_location / ID ##
  distinct(social_care_id, .keep_all = TRUE) %>%
  mutate(
    sending_location = coalesce(sending_location),
    chi = coalesce(upi),
    gender = coalesce(gender),
    dob = coalesce(dob),
    postcode = coalesce(postcode)
  ) %>%
  # select variables for outfile
  select(
    sending_location,
    social_care_id,
    chi,
    gender,
    dob,
    postcode
  )


## save file ##
# .zsav file
haven::write_sav(outfile, get_sc_demog_lookup_path(), compress = TRUE)

# .rds file
readr::write_rds(outfile, get_sc_demog_lookup_path(), compress = "gz")
