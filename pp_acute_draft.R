#####################################################
#Draft pre processing code for Acute
#Author: Jennifer Thom
#Date: September 2021
#Written on RStudio Server
#Version of R - 3.6.1
#Input - Acute.csv from BOXI
#Description - Preprocessing of Acute raw BOXI file.
#              Tidy up file in line with SLF format
#              prior to processing.
#####################################################

#Load set up file
source("setup_environment.R")

#Set up for extract_path function
year <- "1819"

#Load extract file
acute_file <- read_csv(file = extract_path(year, "Acute"), n_max = 2000,
                       col_type = cols(
                       `Costs Financial Year (01)` = col_integer(),
                       `Costs Financial Month Number (01)` = col_double(),
                       `GLS Record` = col_character(),
                       `Date of Admission(01)` = col_character(),
                       `Date of Discharge(01)` = col_character(),
                       `Pat UPI` = col_character(),
                       `Pat Gender Code` = col_double(),
                       `Pat Date Of Birth [C]` = col_character(),
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
                       `Date of Operation 1 (01)` = col_character(),
                       `Operation 2A Code (4 char)` = col_character(),
                       `Operation 2B Code (4 char)` = col_character(),
                       `Date of Operation 2 (01)` = col_character(),
                       `Operation 3A Code (4 char)` = col_character(),
                       `Operation 3B Code (4 char)` = col_character(),
                       `Date of Operation 3 (01)` = col_character(),
                       `Operation 4A Code (4 char)` = col_character(),
                       `Operation 4B Code (4 char)` = col_character(),
                       `Date of Operation 4 (01)` = col_character(),
                       `Age at Midpoint of Financial Year (01)` = col_integer(),
                       `Continuous Inpatient Stay(SMR01) (inc GLS)` = col_integer(),
                       `Continuous Inpatient Journey Marker (01)` = col_character(),
                       `CIJ Planned Admission Code (01)` = col_integer(),
                       `CIJ Inpatient Day Case Identifier Code (01)` = col_character(),
                       `CIJ Type of Admission Code (01)` = col_character(),
                       `CIJ Admission Specialty Code (01)` = col_character(),
                       `CIJ Discharge Specialty Code (01)` = col_character(),
                       `CIJ Start Date (01)` = col_date(format = "%Y/%m/%d %T"),
                       `CIJ End Date (01)` = col_character(),
                       `Total Net Costs (01)` = col_double(),
                       `NHS Hospital Flag (01)` = col_character(),
                       `Community Hospital Flag (01)` = col_character(),
                       `Alcohol Related Admission (01)` = col_character(),
                       `Substance Misuse Related Admission (01)` = col_character(),
                       `Falls Related Admission (01)` = col_character(),
                       `Self Harm Related Admission (01)` = col_character(),
                       `Unique Record Identifier` = col_character(),
                       `Line Number (01)` = col_character()
                       ))
names(acute_file) <- str_replace_all(names(acute_file), " ", "_")

#Rename variables in line with SLF variable names
acute_file <- acute_file %>%
  rename(tadm = Admission_Type_Code,
         adtf = Admitted_Trans_From_Code,
         age = `Age_at_Midpoint_of_Financial_Year_(01)`,
         alcohol_adm = `Alcohol_Related_Admission_(01)`,
         cij_adm_spec = `CIJ_Admission_Specialty_Code_(01)`,
         cij_dis_spec = `CIJ_Discharge_Specialty_Code_(01)`,
         CIJ_end_date = `CIJ_End_Date_(01)`,
         cij_pattype_code = `CIJ_Planned_Admission_Code_(01)`,
         CIJ_start_date = `CIJ_Start_Date_(01)`,
         cij_admtype = `CIJ_Type_of_Admission_Code_(01)`,
         commhosp = `Community_Hospital_Flag_(01)`,
         cij_marker = `Continuous_Inpatient_Journey_Marker_(01)`,
         smr01_cis_marker = `Continuous_Inpatient_Stay(SMR01)_(inc_GLS)`,
         costmonthnum = `Costs_Financial_Month_Number_(01)`,
         costsfy = `Costs_Financial_Year_(01)`,
         diag1 = `Diagnosis_1_Code_(6_char)`,
         diag2 = `Diagnosis_2_Code_(6_char)`,
         diag3 = `Diagnosis_3_Code_(6_char)`,
         diag4 = `Diagnosis_4_Code_(6_char)`,
         diag5 = `Diagnosis_5_Code_(6_char)`,
         diag6 = `Diagnosis_6_Code_(6_char)`,
         dischto = Discharge_Trans_To_Code,
         disch = Discharge_Type_Code,
         falls_adm = `Falls_Related_Admission_(01)`,
         lca = Geo_Council_Area_Code,
         DataZone = Geo_Data_Zone_2011,
         postcode = `Geo_Postcode_[C]`,
         HSCP = `Geo_HSCP_of_Residence_Code_-_current`,
         conc = `Lead_Consultant/HCP_Code`,
         admloc = Location_Admitted_Trans_From_Code,
         dischloc = Location_Discharged_Trans_To_Code,
         mpat = Management_of_Patient_Code,
         hbrescode = `NHS_Board_of_Residence_Code_-_current`,
         nhshosp = `NHS_Hospital_Flag_(01)`,
         yearstay = `Occupied_Bed_Days_(01)`,
         oldtadm = Old_SMR1_Type_of_Admission_Code,
         op1a = `Operation_1A_Code_(4_char)`,
         op1b = `Operation_1B_Code_(4_char)`,
         op2a = `Operation_2A_Code_(4_char)`,
         op2b = `Operation_2B_Code_(4_char)`,
         op3a = `Operation_3A_Code_(4_char)`,
         op3b = `Operation_3B_Code_(4_char)`,
         op4a = `Operation_4A_Code_(4_char)`,
         op4b = `Operation_4B_Code_(4_char)`,
         gender = Pat_Gender_Code,
         chi = Pat_UPI,
         cat = Patient_Category_Code,
         gpprac = Practice_Location_Code,
         hbpraccode = `Practice_NHS_Board_Code_-_current`,
         selfharm_adm = `Self_Harm_Related_Admission_(01)`,
         sigfac = Significant_Facility_Code,
         spec = `Specialty_Classificat._1/4/97_Code`,
         submis_adm = `Substance_Misuse_Related_Admission_(01)`,
         cost_total_net = `Total_Net_Costs_(01)`,
         location = Treatment_Location_Code,
         hbtreatcode = `Treatment_NHS_Board_Code_-_current`,
         uri = Unique_Record_Identifier,
         record_keydate1 = `Date_of_Admission(01)`,
         record_keydate2 = `Date_of_Discharge(01)`,
         dateop1 = `Date_of_Operation_1_(01)`,
         dateop2 = `Date_of_Operation_2_(01)`,
         dateop3 = `Date_of_Operation_3_(01)`,
         dateop4 = `Date_of_Operation_4_(01)`,
         dob = `Pat_Date_Of_Birth_[C]`,
         ipdc = Inpatient_Day_Case_Identifier_Code,
         cij_ipdc = `CIJ_Inpatient_Day_Case_Identifier_Code_(01)`,
         lineno = `Line_Number_(01)`
         )


acute_file <- acute_file %>%
#Set recid as 01B and flag GLS records
  mutate(recid = if_else(GLS_Record == "Y", "GLS", "01B")) %>%
#Set IDPC marker for the episode
  mutate(ipdc = case_when(ipdc == "IP" ~ "I",
                          ipdc == "DC" ~ "D")) %>%
#Set IDPC marker for the cij
  mutate(cij_ipdc = case_when(cij_ipdc == "IP" ~ "I",
                              cij_ipdc == "DC" ~ "D")) %>%
#Recode GP practice into 5 digit number
#We assume that if it starts with a letter it's an English practice and so recode to 99995.
#PUT INTO FUNCTION?
  mutate(gpprac = if_else(str_detect(gpprac, "[A-Z]"), "99995", gpprac)) %>%
#Change dates to date type
  mutate(record_keydate1 = as_datetime(record_keydate1, format = "%Y/%m/%d"),
         record_keydate2 = as_datetime(record_keydate2, format = "%Y/%m/%d")) %>%
#Calculate the total length of stay (for the entire episode, not just within the financial year).
  mutate(stay = difftime(record_keydate2, record_keydate1, units = "days"))


#initialise monthly cost/beddays variables - PUT INTO FUNCTION
monthly_cost_beddays <- acute_file %>%
select(uri, cost_total_net, yearstay, costmonthnum) %>%
  mutate(apr_cost = if_else(costmonthnum == 4, cost_total_net, 0),
         may_cost = if_else(costmonthnum == 5, cost_total_net, 0),
         jun_cost = if_else(costmonthnum == 6, cost_total_net, 0),
         jul_cost = if_else(costmonthnum == 7, cost_total_net, 0),
         aug_cost = if_else(costmonthnum == 8, cost_total_net, 0),
         sep_cost = if_else(costmonthnum == 9, cost_total_net, 0),
         oct_cost = if_else(costmonthnum == 10, cost_total_net, 0),
         nov_cost = if_else(costmonthnum == 11, cost_total_net, 0),
         dec_cost = if_else(costmonthnum == 12, cost_total_net, 0),
         jan_cost = if_else(costmonthnum == 1, cost_total_net, 0),
         feb_cost = if_else(costmonthnum == 2, cost_total_net, 0),
         mar_cost = if_else(costmonthnum == 3, cost_total_net, 0),
         apr_beddays = if_else(costmonthnum == 4, yearstay, 0),
         may_beddays = if_else(costmonthnum == 5, yearstay, 0),
         jun_beddays = if_else(costmonthnum == 6, yearstay, 0),
         jul_beddays = if_else(costmonthnum == 7, yearstay, 0),
         aug_beddays = if_else(costmonthnum == 8, yearstay, 0),
         sep_beddays = if_else(costmonthnum == 9, yearstay, 0),
         oct_beddays = if_else(costmonthnum == 10, yearstay, 0),
         nov_beddays = if_else(costmonthnum == 11, yearstay, 0),
         dec_beddays = if_else(costmonthnum == 12, yearstay, 0),
         jan_beddays = if_else(costmonthnum == 1, yearstay, 0),
         feb_beddays = if_else(costmonthnum == 2, yearstay, 0),
         mar_beddays = if_else(costmonthnum == 3, yearstay, 0)
         ) %>%
#aggregate by uri and sum variables
#check how to remove duplicates here?
  group_by(uri) %>%
  summarise(apr_cost = sum(apr_cost),
            may_cost = sum(may_cost),
            jun_cost = sum(jun_cost),
            jul_cost = sum(jul_cost),
            aug_cost = sum(aug_cost),
            sep_cost = sum(sep_cost),
            oct_cost = sum(oct_cost),
            nov_cost = sum(nov_cost),
            dec_cost = sum(dec_cost),
            jan_cost = sum(jan_cost),
            feb_cost = sum(feb_cost),
            mar_cost = sum(mar_cost),
            apr_beddays = sum(apr_beddays),
            may_beddays = sum(may_beddays),
            jun_beddays = sum(jun_beddays),
            jul_beddays = sum(jul_beddays),
            aug_beddays = sum(aug_beddays),
            sep_beddays = sum(sep_beddays),
            oct_beddays = sum(oct_beddays),
            nov_beddays = sum(nov_beddays),
            dec_beddays = sum(dec_beddays),
            jan_beddays = sum(jan_beddays),
            feb_beddays = sum(feb_beddays),
            mar_beddays = sum(mar_beddays)
            ) %>%
  ungroup()

#match monthly cost and beddays back to acute_file
acute_monthly_totals <- acute_file %>%
  distinct(uri, .keep_all = TRUE)%>%
  left_join(monthly_cost_beddays, by = "uri") %>%
#total up yearstay and costs
  mutate(yearstay = rowSums(across(ends_with("beddays"))),
         cost_total_net = rowSums(across(ends_with("cost")))
         ) %>%
#create and populate SMRType
  mutate(SMRType = if_else(recid == '01B' & lineno != 330 & ipdc == 'I', 'Acute-IP', ''),
         SMRType = if_else(recid == '01B' & lineno != 330 & ipdc == 'D', 'Acute-DC', SMRType),
         SMRType = if_else(lineno == 330 & ipdc == 'I', 'GLS-IP', SMRType),
         SMRType = if_else(recid == 'GLS', 'GLS-IP', SMRType)
         )






mutate(yearstay = select(., apr_beddays:mar_beddays) %>%
           rowSums()) %>%
  mutate(cost_total_net = select(., apr_cost:mar_cost) %>%
           rowSums())

#ends with



dates<- acute_file%>%
  #Calculate the total length of stay (for the entire episode, not just within the financial year).
  mutate(stay = difftime(record_keydate2, record_keydate1, units = "days"),
         stay2 = time_length(record_keydate1 %--% record_keydate2, unit = "days"))

#If costs are missing fill them in
mutate(cost_total_net = if_else(lineno == "NA", 0, cost_total_net))

if(sum(is.na(acute_monthly_totals$cost_total_net)) > 0){
  rlang::warn("Found missing costs ")
}



#Test
acute_dates <- acute_file %>%
  #Convert dates from character to date format
  mutate(record_keydate1 = substr(1,10,ymd(record_keydate1)))

acute_dates <- acute_file %>%
  mutate(record_keydate1 = as_datetime(record_keydate1, format = "%Y/%m/%d"),
         record_keydate2 = as_datetime(record_keydate2, format = "%Y/%m/%d")
         )

acute_dates <- acute_file %>%
  mutate(record_keydate1 = str_replace_all(record_keydate1,"/", "-" ),
         record_keydate1 = ymd_hms(record_keydate1)
  )



acute_dates <- acute_file %>%
  mutate(across(str_replace_all(where("date"),"/", "-"), ymd))


acute_dates <- acute_file %>%
  mutate(across(contains("date"), fast_strptime(., format = "%Y/%m/%d %T")))

acute_dates <- acute_file %>%
mutate(across(contains("date"), ymd))

#working
#Change dates to date type
acute_dates <- acute_file %>%
  mutate(across(contains("date"), ~ str_replace_all(.,"/", "-") %>%
                  ymd_hms()))


###############################################################
#FUNCTIONS TO DO
#GPprac into a function
#Monthly costs and beddays
#SMRType
#Value labels
