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

# Packages
  library(readr)
  library(stringr)
  library(dplyr)
  library(tidyverse)
  library(lubridate)

year <- "1920"

## Load extract file---------------------------------

maternity_file <- read_csv(
  file = get_boxi_extract_path(year, "Maternity"), n_max = 20000,
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
    `Condition On Discharge Code` = col_character(),
    `Continuous Inpatient Journey Marker` = col_double(),
    `CIJ Planned Admission Code` = col_double(),
    `CIJ Inpatient Day Case Identifier Code` = col_character(),
    `CIJ Type of Admission Code` = col_double(),
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
    `Operation 2A Code` = col_character(),
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
)
names(maternity_file) <- str_replace_all(names(maternity_file), " ", "_")

# Rename variables in line with SLF variable names
maternity_file <- maternity_file %>%
  rename(
    adtf = `Admitted/Transfer_from_Code_(new)`,
    admloc = `Admitted/transfer_from_-_Location_Code`,
    record_keydate1 = Date_of_Admission_Full_Date,
    record_keydate2 = Date_of_Discharge_Full_Date,
    dateop1 = Date_of_Main_Operation_Full_Date,
    dob = `Pat_Date_Of_Birth_[C]`,
    age = Age_at_Midpoint_of_Financial_Year,
    alcohol_adm = Alcohol_Related_AdmissioN,
    cij_adm_spec = CIJ_Admission_Specialty_Code,
    cij_dis_spec = CIJ_Discharge_Specialty_Code,
    CIJ_end_date = CIJ_End_Date,
    cij_pattype_code = CIJ_Planned_Admission_Code,
    cij_ipdc = CIJ_Inpatient_Day_Case_Identifier_Code,
    CIJ_start_date = CIJ_Start_Date,
    cij_admtype = CIJ_Type_of_Admission_Code,
    commhosp = Community_Hospital_Flag,
    discondition = Condition_On_Discharge_Code,
    conc = `Consultant/HCP_Code`,
    cij_marker = Continuous_Inpatient_Journey_Marker,
    costsfy = Costs_Financial_Year,
    diag1 = Diagnosis_1_Discharge_Code,
    diag2 = Diagnosis_2_Discharge_Code,
    diag3 = Diagnosis_3_Discharge_Code,
    diag4 = Diagnosis_4_Discharge_Code,
    diag5 = Diagnosis_5_Discharge_Code,
    diag6 = Diagnosis_6_Discharge_Code,
    dischto = `Discharge/Transfer_to_Code_(new)`,
    disch = Discharge_Type_Code,
    dischloc = `Discharged_to_-_Location_Code`,
    falls_adm = Falls_Related_Admission,
    lca = Geo_Council_Area_Code,
    postcode = `Geo_Postcode_[C]`,
    mpat = Management_of_Patient_Code,
    hbrescode = `NHS_Board_of_Residence_Code_-_current`,
    hscp = `HSCP_of_Residence_Code_-_current`,
    nhshosp = NHS_Hospital_Flag,
    yearstay = Occupied_Bed_Days,
    op1a = Operation_1A_Code,
    op2a = Operation_2A_Code,
    op3a = Operation_3A_Code,
    op4a = Operation_4A_Code,
    chi = `Pat_UPI_[C]`,
    gpprac = Practice_Location_Code,
    hbpraccode = `Practice_NHS_Board_Code_-_current`,
    slefharm_adm = Self_Harm_Related_Admission,
    sigfac = Significant_Facility_Code,
    spec = `Specialty_Classification_1/4/97_Code`,
    submis_adm = Substance_Misuse_Related_Admission,
    cost_total_net = Total_Net_Costs,
    location = Treatment_Location_Code,
    hbtreatcode = `Treatment_NHS_Board_Code_-_current`,
    uri = `Maternity_Unique_Record_Identifier_[C]`
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
  eng_gp_to_dummy(gpprac) %>%
  # Calculate the total length of stay (for the entire episode, not just within the financial year).
  mutate(stay = difftime(record_keydate2, record_keydate1, units = "days"))

# Calculate beddays
#work out cost month

beddays<- maternity_clean %>%
  mutate(month_number =  month(record_keydate2,label = FALSE),
         quarter = quarter(record_keydate2, fiscal_start = 4),
         month_start = floor_date(ymd(record_keydate2), 'month'),
         month_end = ceiling_date(ymd(record_keydate2), 'month') - days (1)) %>%
  mutate(fy_month = case_when(month_number == 4 ~ 1,
                              month_number == 5 ~ 2,
                              month_number == 6 ~ 3,
                              month_number == 7 ~ 4,
                              month_number == 8 ~ 5,
                              month_number == 9 ~ 6,
                              month_number == 10 ~ 7,
                              month_number == 11 ~ 8,
                              month_number == 12 ~ 9,
                              month_number == 1 ~ 10,
                              month_number == 2 ~ 11,
                              month_number == 1 ~ 12))

