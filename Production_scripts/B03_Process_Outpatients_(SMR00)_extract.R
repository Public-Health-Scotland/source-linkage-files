#####################################################
# Outpatient Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - episode extract csv file
# Description - Process Outpatients extract
#####################################################

# Load packages
library(dplyr)
library(tidyr)
library(createslf)
library(vroom)


# Read in data---------------------------------------

# Specify year
year <- 1920

# Read BOXI extract
outpatients_file <- readr::read_csv(
  file = get_boxi_extract_path(year, "Outpatient"),
  col_type = cols(
    `Clinic Date Fin Year` = col_double(),
    `Clinic Date (00)` = col_date(format = "%Y/%m/%d %T"),
    `Episode Record Key (SMR00) [C]` = col_character(),
    `Pat UPI` = col_character(),
    `Pat Gender Code` = col_double(),
    `Pat Date Of Birth [C]` = col_date(format = "%Y/%m/%d %T"),
    `Practice Location Code` = col_character(),
    `Practice NHS Board Code - current` = col_character(),
    `Geo Postcode [C]` = col_character(),
    `NHS Board of Residence Code - current` = col_character(),
    `Geo Council Area Code` = col_character(),
    `Treatment Location Code` = col_character(),
    `Treatment NHS Board Code - current` = col_character(),
    `Operation 1A Code (4 char)` = col_character(),
    `Operation 1B Code (4 char)` = col_character(),
    `Date of Main Operation(00)` = col_date(format = "%Y/%m/%d %T"),
    `Operation 2A Code (4 char)` = col_character(),
    `Operation 2B Code (4 char)` = col_character(),
    `Date of Operation 2 (00)` = col_date(format = "%Y/%m/%d %T"),
    `Specialty Classificat. 1/4/97 Code` = col_character(),
    `Significant Facility Code` = col_character(),
    `Consultant/HCP Code` = col_character(),
    `Patient Category Code` = col_character(),
    `Referral Source Code` = col_character(),
    `Referral Type Code` = col_double(),
    `Clinic Type Code` = col_double(),
    `Clinic Attendance (Status) Code` = col_double(),
    `Age at Midpoint of Financial Year` = col_double(),
    `Alcohol Related Admission` = col_character(),
    `Substance Misuse Related Admission` = col_character(),
    `Falls Related Admission` = col_character(),
    `Self Harm Related Admission` = col_character(),
    `NHS Hospital Flag` = col_character(),
    `Community Hospital Flag` = col_character(),
    `Total Net Costs` = col_double()
  )
) %>%
  # Rename variables
  rename(
    clinic_date_fy = "Clinic Date Fin Year",
    record_keydate1 = "Clinic Date (00)",
    dob = "Pat Date Of Birth [C]",
    age = "Age at Midpoint of Financial Year",
    alcohol_adm = "Alcohol Related Admission",
    attendance_status = "Clinic Attendance (Status) Code",
    clinic_type = "Clinic Type Code",
    commhosp = "Community Hospital Flag",
    conc = "Consultant/HCP Code",
    uri = "Episode Record Key (SMR00) [C]",
    falls_adm = "Falls Related Admission",
    lca = "Geo Council Area Code",
    postcode = "Geo Postcode [C]",
    hbrescode = "NHS Board of Residence Code - current",
    nhshosp = "NHS Hospital Flag",
    op1a = "Operation 1A Code (4 char)",
    op1b = "Operation 1B Code (4 char)",
    dateop1 = "Date of Main Operation(00)",
    op2a = "Operation 2A Code (4 char)",
    op2b = "Operation 2B Code (4 char)",
    dateop2 = "Date of Operation 2 (00)",
    gender = "Pat Gender Code",
    chi = "Pat UPI",
    cat = "Patient Category Code",
    gpprac = "Practice Location Code",
    hbpraccode = "Practice NHS Board Code - current",
    refsource = "Referral Source Code",
    reftype = "Referral Type Code",
    selfharm_adm = "Self Harm Related Admission",
    sigfac = "Significant Facility Code",
    spec = "Specialty Classificat. 1/4/97 Code",
    submis_adm = "Substance Misuse Related Admission",
    cost_total_net = "Total Net Costs",
    location = "Treatment Location Code",
    hbtreatcode = "Treatment NHS Board Code - current"
  )


# Data Cleaning--------------------------------------------

outpatients_clean <- outpatients_file %>%
  # Set year variable
  mutate(
    year = year,
    # Set recid variable
    recid = "00B"
  ) %>%
  # Recode GP Practice into a 5 digit number
  # assume that if it starts with a letter it's an English practice and so recode to 99995
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # compute record key date2
  mutate(record_keydate2 = record_keydate1) %>%
  # Allocate the costs to the correct month
  create_monthly_costs(record_keydate1, cost_total_net) %>%
  # sort by chi record_keydate1
  arrange(chi, record_keydate1)


# Add labels ---------------------------------------
outpatients_clean <- outpatients_clean %>%
  mutate(
    reftype = factor(reftype,
      levels = c(1:3),
      labels = c(
        "New Outpatient: Consultation and Management",
        "New Outpatient: Consultation only",
        "Follow-up/Return Outpatient"
      )
    ),
    clinic_type = factor(clinic_type,
      levels = c(1:4),
      labels = c(
        "Consultant",
        "Dentist",
        "Nurse PIN",
        "AHP"
      )
    )
  )


## save outfile ---------------------------------------

outfile <-
  outpatients_clean %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    chi,
    gender,
    dob,
    gpprac,
    hbpraccode,
    postcode,
    hbrescode,
    lca,
    location,
    hbtreatcode,
    op1a,
    op1b,
    dateop1,
    op2a,
    op2b,
    dateop2,
    spec,
    sigfac,
    conc,
    cat,
    age,
    refsource,
    reftype,
    attendance_status,
    clinic_type,
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    commhosp,
    nhshosp,
    cost_total_net,
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
    uri
  )

# Save as zsav file
outfile %>%
  readr::write_rds(get_source_extract_path(year, "Outpatient", ext = "zsav"))

# Save as rds file
outfile %>%
  readr::write_rds(get_source_extract_path(year, "Outpatients", ext = "rds"))


# End of Script #
