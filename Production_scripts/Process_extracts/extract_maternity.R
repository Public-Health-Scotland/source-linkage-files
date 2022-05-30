#####################################################
# Draft pre processing code for Maternity
# Author: Jennifer Thom
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Maternity.csv from BOXI
# Description - Preprocessing of Maternity raw BOXI file.
#              Tidy up file in line with SLF format
#              prior to processing.
#####################################################

# Load Packages
library(readr)
library(dplyr)
library(tidyverse)
library(lubridate)
library(createslf)


## Load extract file---------------------------------

year <- check_year_format("1920")

maternity_file <- read_csv(
  file = get_boxi_extract_path(year, "Maternity"),
  col_type = cols(
    `Costs Financial Year` = col_double(),
    `Date of Admission Full Date` = col_date(format = "%Y/%m/%d %T"),
    `Date of Discharge Full Date` = col_date(format = "%Y/%m/%d %T"),
    `Pat UPI [C]` = col_character(),
    `Pat Date Of Birth [C]` = col_date(format = "%Y/%m/%d %T"),
    `Practice Location Code` = col_character(),
    `Practice NHS Board Code - current` = col_character(),
    `Geo Postcode [C]` = col_character(),
    `NHS Board of Residence Code - current` = col_character(),
    `HSCP of Residence Code - current` = col_character(),
    `Geo Council Area Code` = col_character(),
    `Treatment Location Code` = col_character(),
    `Treatment NHS Board Code - current` = col_character(),
    `Occupied Bed Days` = col_double(),
    `Specialty Classification 1/4/97 Code` = col_character(),
    `Significant Facility Code` = col_character(),
    `Consultant/HCP Code` = col_character(),
    `Management of Patient Code` = col_character(),
    `Admission Reason Code` = col_character(),
    `Admitted/Transfer from Code (new)` = col_character(),
    `Admitted/transfer from - Location Code` = col_character(),
    `Discharge Type Code` = col_character(),
    `Discharge/Transfer to Code (new)` = col_character(),
    `Discharged to - Location Code` = col_character(),
    `Condition On Discharge Code` = col_double(),
    `Continuous Inpatient Journey Marker` = col_double(),
    `CIJ Planned Admission Code` = col_double(),
    `CIJ Inpatient Day Case Identifier Code` = col_character(),
    `CIJ Type of Admission Code` = col_character(),
    `CIJ Admission Specialty Code` = col_character(),
    `CIJ Discharge Specialty Code` = col_character(),
    `CIJ Start Date` = col_date(format = "%Y/%m/%d %T"),
    `CIJ End Date` = col_date(format = "%Y/%m/%d %T"),
    `Total Net Costs` = col_double(),
    `Diagnosis 1 Discharge Code` = col_character(),
    `Diagnosis 2 Discharge Code` = col_character(),
    `Diagnosis 3 Discharge Code` = col_character(),
    `Diagnosis 4 Discharge Code` = col_character(),
    `Diagnosis 5 Discharge Code` = col_character(),
    `Diagnosis 6 Discharge Code` = col_character(),
    `Operation 1A Code` = col_character(),
    `Operation 2A Code` = col_character(),
    `Operation 3A Code` = col_character(),
    `Operation 4A Code` = col_character(),
    `Date of Main Operation Full Date` = col_date(format = "%Y/%m/%d %T"),
    `Age at Midpoint of Financial Year` = col_double(),
    `NHS Hospital Flag` = col_character(),
    `Community Hospital Flag` = col_character(),
    `Alcohol Related AdmissioN` = col_character(),
    `Substance Misuse Related Admission` = col_character(),
    `Falls Related Admission` = col_character(),
    `Self Harm Related Admission` = col_character(),
    `Maternity Unique Record Identifier [C]` = col_character()
  )
) %>%
  # Rename variables in line with SLF variable names
  rename(
    adtf = `Admitted/Transfer from Code (new)`,
    admloc = `Admitted/transfer from - Location Code`,
    record_keydate1 = `Date of Admission Full Date`,
    record_keydate2 = `Date of Discharge Full Date`,
    dateop1 = `Date of Main Operation Full Date`,
    dob = `Pat Date Of Birth [C]`,
    age = `Age at Midpoint of Financial Year`,
    alcohol_adm = `Alcohol Related AdmissioN`,
    cij_adm_spec = `CIJ Admission Specialty Code`,
    cij_dis_spec = `CIJ Discharge Specialty Code`,
    cij_end_date = `CIJ End Date`,
    cij_pattype_code = `CIJ Planned Admission Code`,
    cij_ipdc = `CIJ Inpatient Day Case Identifier Code`,
    cij_start_date = `CIJ Start Date`,
    cij_admtype = `CIJ Type of Admission Code`,
    commhosp = `Community Hospital Flag`,
    discondition = `Condition On Discharge Code`,
    conc = `Consultant/HCP Code`,
    cij_marker = `Continuous Inpatient Journey Marker`,
    costsfy = `Costs Financial Year`,
    diag1 = `Diagnosis 1 Discharge Code`,
    diag2 = `Diagnosis 2 Discharge Code`,
    diag3 = `Diagnosis 3 Discharge Code`,
    diag4 = `Diagnosis 4 Discharge Code`,
    diag5 = `Diagnosis 5 Discharge Code`,
    diag6 = `Diagnosis 6 Discharge Code`,
    dischto = `Discharge/Transfer to Code (new)`,
    disch = `Discharge Type Code`,
    dischloc = `Discharged to - Location Code`,
    falls_adm = `Falls Related Admission`,
    lca = `Geo Council Area Code`,
    postcode = `Geo Postcode [C]`,
    mpat = `Management of Patient Code`,
    hbrescode = `NHS Board of Residence Code - current`,
    hscp = `HSCP of Residence Code - current`,
    nhshosp = `NHS Hospital Flag`,
    yearstay = `Occupied Bed Days`,
    op1a = `Operation 1A Code`,
    op2a = `Operation 2A Code`,
    op3a = `Operation 3A Code`,
    op4a = `Operation 4A Code`,
    chi = `Pat UPI [C]`,
    gpprac = `Practice Location Code`,
    hbpraccode = `Practice NHS Board Code - current`,
    selfharm_adm = `Self Harm Related Admission`,
    sigfac = `Significant Facility Code`,
    spec = `Specialty Classification 1/4/97 Code`,
    submis_adm = `Substance Misuse Related Admission`,
    cost_total_net = `Total Net Costs`,
    location = `Treatment Location Code`,
    hbtreatcode = `Treatment NHS Board Code - current`,
    uri = `Maternity Unique Record Identifier [C]`
  )

## Data Cleaning------------------------------------------

maternity_clean <- maternity_file %>%
  # Create new columns for recid and gender
  mutate(
    year = year,
    recid = "02B",
    gender = 2
  ) %>%
  # Set IDPC marker for the cij
  mutate(cij_ipdc = case_when(
    cij_ipdc == "IP" ~ "I",
    cij_ipdc == "DC" ~ "D"
  )) %>%
  # Recode GP practice into 5 digit number
  # We assume that if it starts with a letter it's an English practice and so recode to 99995.
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # Calculate the total length of stay (for the entire episode, not just within the financial year).
  mutate(stay = difftime(record_keydate2, record_keydate1, units = "days")) %>%
  # Calculate beddays
  create_monthly_beddays(year, record_keydate1, record_keydate2) %>%
  # Calculate costs
  create_monthly_costs() %>%
  # Add discondition as a factor
  mutate(
    discondition = factor(discondition,
      levels = c(1:5, 8)
    )
  )


# Save outfile------------------------------------------------

outfile <- maternity_clean %>%
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
    hscp,
    location,
    hbtreatcode,
    stay,
    yearstay,
    spec,
    sigfac,
    conc,
    mpat,
    adtf,
    admloc,
    starts_with("disch"),
    starts_with("diag"),
    matches("(date)?op[1-4][ab]?"),
    age,
    discondition,
    starts_with("cij"),
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    commhosp,
    nhshosp,
    cost_total_net,
    ends_with("_beddays"),
    ends_with("_cost"),
    uri
  ) %>%
  arrange(chi, record_keydate1)

outfile %>%
  # Save as zsav file
  write_sav(get_source_extract_path(year, "Maternity", ext = "zsav", check_mode = "write")) %>%
  # Save as rds file
  write_rds(get_source_extract_path(year, "Maternity", check_mode = "write"))

# End of Script #
