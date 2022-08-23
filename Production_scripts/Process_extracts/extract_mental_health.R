#####################################################
# Mental Health Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Mental Health BOXI extract
# Description - Process Mental Health Extract
#####################################################


# Load packages
library(dplyr)
library(createslf)
library(lubridate)


# Read in data ---------------------------------------


# Specify year
year <- check_year_format("1920")


# Read BOXI extract
mh_extract <- get_boxi_extract_path(
  year,
  type = "MH"
) %>%
  readr::read_csv(
    col_types = cols_only(
      "Costs Financial Year (04)" = col_integer(),
      "Costs Financial Month Number (04)" = col_integer(),
      "Date of Admission(04)" = col_date(format = "%Y/%m/%d %T"),
      "Date of Discharge(04)" = col_date(format = "%Y/%m/%d %T"),
      "Pat UPI" = col_character(),
      "Pat Gender Code" = col_integer(),
      "Pat Date Of Birth [C]" = col_date(format = "%Y/%m/%d %T"),
      "Practice Location Code" = col_character(),
      "Practice NHS Board Code - current" = col_character(),
      "Geo Postcode [C]" = col_character(),
      "NHS Board of Residence Code - current" = col_character(),
      "Geo Council Area Code" = col_integer(),
      "Geo HSCP of Residence Code - current" = col_character(),
      "Geo Data Zone 2011" = col_character(),
      "Treatment Location Code" = col_character(),
      "Treatment NHS Board Code - current" = col_character(),
      "Occupied Bed Days (04)" = col_double(),
      "Specialty Classificat. 1/4/97 Code" = col_character(),
      "Significant Facility Code" = col_character(),
      "Lead Consultant/HCP Code" = col_integer(),
      "Management of Patient Code" = col_integer(),
      "Patient Category Code" = col_integer(),
      "Admission Type Code" = col_integer(),
      "Admitted Trans From Code" = col_character(),
      "Location Admitted Trans From Code" = col_character(),
      "Discharge Type Code" = col_integer(),
      "Discharge Trans To Code" = col_character(),
      "Location Discharged Trans To Code" = col_character(),
      "Diagnosis 1 Code (6 char)" = col_character(),
      "Diagnosis 2 Code (6 char)" = col_character(),
      "Diagnosis 3 Code (6 char)" = col_character(),
      "Diagnosis 4 Code (6 char)" = col_character(),
      "Diagnosis 5 Code (6 char)" = col_character(),
      "Diagnosis 6 Code (6 char)" = col_character(),
      "Status on Admission Code" = col_integer(),
      "Admission Diagnosis 1 Code (6 char)" = col_character(),
      "Admission Diagnosis 2 Code (6 char)" = col_character(),
      "Admission Diagnosis 3 Code (6 char)" = col_character(),
      "Admission Diagnosis 4 Code (6 char)" = col_character(),
      "Age at Midpoint of Financial Year (04)" = col_integer(),
      "Continuous Inpatient Journey Marker (04)" = col_integer(),
      "CIJ Planned Admission Code (04)" = col_integer(),
      "CIJ Inpatient Day Case Identifier Code (04)" = col_character(),
      "CIJ Type of Admission Code (04)" = col_character(),
      "CIJ Admission Specialty Code (04)" = col_character(),
      "CIJ Discharge Specialty Code (04)" = col_character(),
      "CIJ Start Date (04)" = col_date(format = "%Y%m%d %T"),
      "CIJ End Date (04)" = col_date(format = "%Y%m%d %T"),
      "Total Net Costs (04)" = col_double(),
      "Alcohol Related Admission (04)" = col_factor(levels = c("Y", "N")),
      "Substance Misuse Related Admission (04)" = col_factor(levels = c("Y", "N")),
      "Falls Related Admission (04)" = col_factor(levels = c("Y", "N")),
      "Self Harm Related Admission (04)" = col_factor(levels = c("Y", "N")),
      "Duplicate Record Flag (04)" = col_factor(levels = c("Y", "N")),
      "NHS Hospital Flag (04)" = col_factor(levels = c("Y", "N")),
      "Community Hospital Flag (04)" = col_factor(levels = c("Y", "N")),
      "Unique Record Identifier" = col_integer()
    )
  ) %>%
  # rename variables
  rename(
    costsfy = "Costs Financial Year (04)",
    costmonthnum = "Costs Financial Month Number (04)",
    record_keydate1 = "Date of Admission(04)",
    record_keydate2 = "Date of Discharge(04)",
    chi = "Pat UPI",
    gender = "Pat Gender Code",
    dob = "Pat Date Of Birth [C]",
    gpprac = "Practice Location Code",
    hbpraccode = "Practice NHS Board Code - current",
    postcode = "Geo Postcode [C]",
    hbrescode = "NHS Board of Residence Code - current",
    lca = "Geo Council Area Code",
    hscp = "Geo HSCP of Residence Code - current",
    datazone = "Geo Data Zone 2011",
    location = "Treatment Location Code",
    hbtreatcode = "Treatment NHS Board Code - current",
    yearstay = "Occupied Bed Days (04)",
    spec = "Specialty Classificat. 1/4/97 Code",
    sigfac = "Significant Facility Code",
    conc = "Lead Consultant/HCP Code",
    mpat = "Management of Patient Code",
    cat = "Patient Category Code",
    tadm = "Admission Type Code",
    adtf = "Admitted Trans From Code",
    admloc = "Location Admitted Trans From Code",
    disch = "Discharge Type Code",
    dischto = "Discharge Trans To Code",
    dischloc = "Location Discharged Trans To Code",
    diag1 = "Diagnosis 1 Code (6 char)",
    diag2 = "Diagnosis 2 Code (6 char)",
    diag3 = "Diagnosis 3 Code (6 char)",
    diag4 = "Diagnosis 4 Code (6 char)",
    diag5 = "Diagnosis 5 Code (6 char)",
    diag6 = "Diagnosis 6 Code (6 char)",
    stadm = "Status on Admission Code",
    adcon1 = "Admission Diagnosis 1 Code (6 char)",
    adcon2 = "Admission Diagnosis 2 Code (6 char)",
    adcon3 = "Admission Diagnosis 3 Code (6 char)",
    adcon4 = "Admission Diagnosis 4 Code (6 char)",
    age = "Age at Midpoint of Financial Year (04)",
    cij_marker = "Continuous Inpatient Journey Marker (04)",
    cij_pattype_code = "CIJ Planned Admission Code (04)",
    cij_inpatient = "CIJ Inpatient Day Case Identifier Code (04)",
    cij_admtype = "CIJ Type of Admission Code (04)",
    cij_adm_spec = "CIJ Admission Specialty Code (04)",
    cij_dis_spec = "CIJ Discharge Specialty Code (04)",
    cij_start_date = "CIJ Start Date (04)",
    cij_end_date = "CIJ End Date (04)",
    cost_total_net = "Total Net Costs (04)",
    alcohol_adm = "Alcohol Related Admission (04)",
    submis_adm = "Substance Misuse Related Admission (04)",
    falls_adm = "Falls Related Admission (04)",
    selfharm_adm = "Self Harm Related Admission (04)",
    duplicate = "Duplicate Record Flag (04)",
    nhshosp = "NHS Hospital Flag (04)",
    commhosp = "Community Hospital Flag (04)",
    uri = "Unique Record Identifier"
  )



# Data Cleaning  ---------------------------------------

mh_clean <- mh_extract %>%
  # create year, recid, ipdc variables
  mutate(
    year = year,
    recid = "04B",
    ipdc = "I"
  ) %>%
  # deal with dummy / english variables
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # cij_ipdc
  mutate(
    cij_ipdc = if_else(cij_inpatient == "MH", "I", "NA"),
    cij_ipdc = na_if(cij_ipdc, "NA")
  ) %>%
  # cij_admtype recode unknown to 99
  mutate(cij_admtype = if_else(cij_admtype == "Unknown", "99", cij_admtype)) %>%
  # monthly beddays and costs
  convert_monthly_rows_to_vars(costmonthnum, cost_total_net, yearstay) %>%
  mutate(
    # yearstay
    yearstay = rowSums(across(ends_with("_beddays"))),
    # cost total net
    cost_total_net = rowSums(across(ends_with("_cost"))) %>%
  # total length of stay
    stay = calculate_stay(year, record_keydate1, record_keydate2)
  ) %>%
  # Add SMR type
  mutate(smrtype = add_smr_type(recid))


# Outfile  ---------------------------------------

outfile <- mh_clean %>%
  # numeric record_keydate
  mutate(
    record_keydate1 = lubridate::month(record_keydate1) + 100 * lubridate::month(record_keydate1) + 10000 * lubridate::year(record_keydate1),
    record_keydate2 = lubridate::month(record_keydate2) + 100 * lubridate::month(record_keydate2) + 10000 * lubridate::year(record_keydate2)
  ) %>%
  arrange(chi, record_keydate1) %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    smrtype,
    chi,
    gender,
    dob,
    gpprac,
    hbpraccode,
    postcode,
    hbrescode,
    lca,
    hscp,
    datazone,
    location,
    hbtreatcode,
    stay,
    yearstay,
    ipdc,
    spec,
    sigfac,
    conc,
    mpat,
    cat,
    tadm,
    adtf,
    admloc,
    disch,
    dischto,
    dischloc,
    starts_with("diag"),
    age,
    starts_with("cij_"),
    ends_with("_adm"),
    commhosp,
    cost_total_net,
    stadm,
    starts_with("adcon"),
    ends_with("_beddays"),
    ends_with("_cost"),
    uri
  )



outfile %>%
  # Save as zsav file
  write_sav(get_source_extract_path(year, "MH", ext = "zsav", check_mode = "write")) %>%
  # Save as rds file
  write_rds(get_source_extract_path(year, "MH", check_mode = "write"))
