#####################################################
# Draft pre processing code for Acute
# Author: Jennifer Thom
# Date: September 2021
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Acute.csv from BOXI
# Description - Preprocessing of Acute raw BOXI file.
#              Tidy up file in line with SLF format
#              prior to processing.
#####################################################

# Load Packages #
library(tidyr)
library(dplyr)
library(readr)
library(createslf)


# Read in data---------------------------------------

# Set up for get_boxi_extract_path function
year <- "1920"

# Load extract file
acute_file <- readr::read_csv(
  file = get_boxi_extract_path(year, "Acute"),
  col_type = cols(
    `Costs Financial Year (01)` = col_integer(),
    `Costs Financial Month Number (01)` = col_double(),
    `GLS Record` = col_character(),
    `Date of Admission(01)` = col_date(format = "%Y/%m/%d %T"),
    `Date of Discharge(01)` = col_date(format = "%Y/%m/%d %T"),
    `Pat UPI` = col_character(),
    `Pat Gender Code` = col_double(),
    `Pat Date Of Birth [C]` = col_date(format = "%Y/%m/%d %T"),
    `Practice Location Code` = col_character(),
    `Practice NHS Board Code - current` = col_character(),
    `Geo Postcode [C]` = col_character(),
    `NHS Board of Residence Code - current` = col_character(),
    `Geo Council Area Code` = col_character(),
    `Geo HSCP of Residence Code - current` = col_character(),
    `Geo Data Zone 2011` = col_character(),
    `Treatment Location Code` = col_character(),
    `Treatment NHS Board Code - current` = col_character(),
    `Occupied Bed Days (01)` = col_double(),
    `Inpatient Day Case Identifier Code` = col_character(),
    `Specialty Classificat. 1/4/97 Code` = col_character(),
    `Significant Facility Code` = col_character(),
    `Lead Consultant/HCP Code` = col_character(),
    `Management of Patient Code` = col_character(),
    `Patient Category Code` = col_character(),
    `Admission Type Code` = col_character(),
    `Admitted Trans From Code` = col_character(),
    `Location Admitted Trans From Code` = col_character(),
    `Old SMR1 Type of Admission Code` = col_integer(),
    `Discharge Type Code` = col_character(),
    `Discharge Trans To Code` = col_character(),
    `Location Discharged Trans To Code` = col_character(),
    `Diagnosis 1 Code (6 char)` = col_character(),
    `Diagnosis 2 Code (6 char)` = col_character(),
    `Diagnosis 3 Code (6 char)` = col_character(),
    `Diagnosis 4 Code (6 char)` = col_character(),
    `Diagnosis 5 Code (6 char)` = col_character(),
    `Diagnosis 6 Code (6 char)` = col_character(),
    `Operation 1A Code (4 char)` = col_character(),
    `Operation 1B Code (4 char)` = col_character(),
    `Date of Operation 1 (01)` = col_date(format = "%Y/%m/%d %T"),
    `Operation 2A Code (4 char)` = col_character(),
    `Operation 2B Code (4 char)` = col_character(),
    `Date of Operation 2 (01)` = col_date(format = "%Y/%m/%d %T"),
    `Operation 3A Code (4 char)` = col_character(),
    `Operation 3B Code (4 char)` = col_character(),
    `Date of Operation 3 (01)` = col_date(format = "%Y/%m/%d %T"),
    `Operation 4A Code (4 char)` = col_character(),
    `Operation 4B Code (4 char)` = col_character(),
    `Date of Operation 4 (01)` = col_date(format = "%Y/%m/%d %T"),
    `Age at Midpoint of Financial Year (01)` = col_integer(),
    `Continuous Inpatient Stay(SMR01) (inc GLS)` = col_integer(),
    `Continuous Inpatient Journey Marker (01)` = col_character(),
    `CIJ Planned Admission Code (01)` = col_integer(),
    `CIJ Inpatient Day Case Identifier Code (01)` = col_character(),
    `CIJ Type of Admission Code (01)` = col_character(),
    `CIJ Admission Specialty Code (01)` = col_character(),
    `CIJ Discharge Specialty Code (01)` = col_character(),
    `CIJ Start Date (01)` = col_date(format = "%Y/%m/%d %T"),
    `CIJ End Date (01)` = col_date(format = "%Y/%m/%d %T"),
    `Total Net Costs (01)` = col_double(),
    `NHS Hospital Flag (01)` = col_character(),
    `Community Hospital Flag (01)` = col_character(),
    `Alcohol Related Admission (01)` = col_character(),
    `Substance Misuse Related Admission (01)` = col_character(),
    `Falls Related Admission (01)` = col_character(),
    `Self Harm Related Admission (01)` = col_character(),
    `Unique Record Identifier` = col_character(),
    `Line Number (01)` = col_character()
  )
) %>%
  # Rename variables
  rename(
    tadm = `Admission Type Code`,
    adtf = `Admitted Trans From Code`,
    age = `Age at Midpoint of Financial Year (01)`,
    alcohol_adm = `Alcohol Related Admission (01)`,
    cij_adm_spec = `CIJ Admission Specialty Code (01)`,
    cij_dis_spec = `CIJ Discharge Specialty Code (01)`,
    cij_end_date = `CIJ End Date (01)`,
    cij_pattype_code = `CIJ Planned Admission Code (01)`,
    cij_start_date = `CIJ Start Date (01)`,
    cij_admtype = `CIJ Type of Admission Code (01)`,
    commhosp = `Community Hospital Flag (01)`,
    cij_marker = `Continuous Inpatient Journey Marker (01)`,
    smr01_cis_marker = `Continuous Inpatient Stay(SMR01) (inc GLS)`,
    costmonthnum = `Costs Financial Month Number (01)`,
    costsfy = `Costs Financial Year (01)`,
    diag1 = `Diagnosis 1 Code (6 char)`,
    diag2 = `Diagnosis 2 Code (6 char)`,
    diag3 = `Diagnosis 3 Code (6 char)`,
    diag4 = `Diagnosis 4 Code (6 char)`,
    diag5 = `Diagnosis 5 Code (6 char)`,
    diag6 = `Diagnosis 6 Code (6 char)`,
    dischto = `Discharge Trans To Code`,
    disch = `Discharge Type Code`,
    falls_adm = `Falls Related Admission (01)`,
    lca = `Geo Council Area Code`,
    DataZone = `Geo Data Zone 2011`,
    postcode = `Geo Postcode [C]`,
    HSCP = `Geo HSCP of Residence Code - current`,
    conc = `Lead Consultant/HCP Code`,
    admloc = `Location Admitted Trans From Code`,
    dischloc = `Location Discharged Trans To Code`,
    mpat = `Management of Patient Code`,
    hbrescode = `NHS Board of Residence Code - current`,
    nhshosp = `NHS Hospital Flag (01)`,
    yearstay = `Occupied Bed Days (01)`,
    oldtadm = `Old SMR1 Type of Admission Code`,
    op1a = `Operation 1A Code (4 char)`,
    op1b = `Operation 1B Code (4 char)`,
    op2a = `Operation 2A Code (4 char)`,
    op2b = `Operation 2B Code (4 char)`,
    op3a = `Operation 3A Code (4 char)`,
    op3b = `Operation 3B Code (4 char)`,
    op4a = `Operation 4A Code (4 char)`,
    op4b = `Operation 4B Code (4 char)`,
    gender = `Pat Gender Code`,
    chi = `Pat UPI`,
    cat = `Patient Category Code`,
    gpprac = `Practice Location Code`,
    hbpraccode = `Practice NHS Board Code - current`,
    selfharm_adm = `Self Harm Related Admission (01)`,
    sigfac = `Significant Facility Code`,
    spec = `Specialty Classificat. 1/4/97 Code`,
    submis_adm = `Substance Misuse Related Admission (01)`,
    cost_total_net = `Total Net Costs (01)`,
    location = `Treatment Location Code`,
    hbtreatcode = `Treatment NHS Board Code - current`,
    uri = `Unique Record Identifier`,
    record_keydate1 = `Date of Admission(01)`,
    record_keydate2 = `Date of Discharge(01)`,
    dateop1 = `Date of Operation 1 (01)`,
    dateop2 = `Date of Operation 2 (01)`,
    dateop3 = `Date of Operation 3 (01)`,
    dateop4 = `Date of Operation 4 (01)`,
    dob = `Pat Date Of Birth [C]`,
    ipdc = `Inpatient Day Case Identifier Code`,
    cij_ipdc = `CIJ Inpatient Day Case Identifier Code (01)`,
    lineno = `Line Number (01)`,
    GLS_record = `GLS Record`
  )


# Data Cleaning ---------------------------------------

acute_clean <- acute_file %>%
  # Set year variable
  mutate(
    year = year,
    # Set recid as 01B and flag GLS records
    recid = if_else(GLS_record == "Y", "GLS", "01B"),
    # Set IDPC marker for the episode
    ipdc = case_when(
      ipdc == "IP" ~ "I",
      ipdc == "DC" ~ "D"
    ),
    # Set IDPC marker for the cij
    cij_ipdc = case_when(
      cij_ipdc == "IP" ~ "I",
      cij_ipdc == "DC" ~ "D"
    )
  ) %>%
  # Recode GP practice into 5 digit number
  # We assume that if it starts with a letter it's an English practice and so recode to 99995.
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # Calculate the total length of stay (for the entire episode, not just within the financial year).
  calculate_stay(year, record_keydate1, record_keydate2) %>%
  # create and populate SMRType
  mutate(
    SMRType = case_when(
      recid == "01B" & lineno != 330 ~ if_else(ipdc == "I", "Acute-IP", "Acute-DC"),
      lineno == 330 & ipdc == "I" ~ "GLS-IP",
      recid == "GLS" ~ "GLS-IP"
    )
  ) %>%
  # Apply new costs for C3 specialty, these are taken from the 2017/18 file
  fix_c3_costs(year) %>%
  # initialise monthly cost/beddays variables in a separate data frame for matching
  convert_monthly_rows_to_vars(costmonthnum, cost_total_net, yearstay) %>%
  # add yearstay and cost_total_net variables
  mutate(
    yearstay = rowSums(across(ends_with("_beddays"))),
    cost_total_net = rowSums(across(ends_with("_cost")))
  ) %>%
  # Add oldtadm as a factor with labels
  mutate(oldtadm = factor(oldtadm,
    levels = c(0:8)
  ))


## save outfile ---------------------------------------
outfile <- acute_clean %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    SMRType,
    chi,
    gender,
    dob,
    gpprac,
    hbpraccode,
    postcode,
    hbrescode,
    lca,
    HSCP,
    DataZone,
    location,
    hbtreatcode,
    yearstay,
    stay,
    ipdc,
    spec,
    sigfac,
    conc,
    mpat,
    cat,
    tadm,
    adtf,
    admloc,
    oldtadm,
    starts_with("disch"),
    starts_with("diag"),
    matches("(date)?op[1-4][ab]?"),
    smr01_cis_marker,
    age,
    starts_with("cij"),
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    commhosp,
    cost_total_net,
    ends_with("_beddays"),
    ends_with("_cost"),
    uri
  ) %>%
  arrange(chi, record_keydate1)

outfile %>%
  # Save as zsav file
  write_sav(get_source_extract_path(year, "Acute", ext = "zsav", check_mode = "write")) %>%
  # Save as rds file
  write_rds(get_source_extract_path(year, "Acute", check_mode = "write"))

## End of Script ##
