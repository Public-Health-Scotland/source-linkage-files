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
acute_file <- read_csv(extract_path(year, "Acute"))
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
         idpc = Inpatient_Day_Case_Identifier_Code,
         cij_idpc = `CIJ_Inpatient_Day_Case_Identifier_Code_(01)`
         )


acute_file <- acute_file %>%
#Set recid as 01B and flag GLS records
  mutate(recid = if_else(GLS_Record == "Y", "GLS", "01B")) %>%
#Set IDPC marker for the episode
  mutate(idpc = recode(idpc, "IP" = "I",
                             "DC" = "D")) %>%
#Set IDPC marker for the cij
  mutate(cij_idpc = recode(cij_idpc, "IP" = "I",
                                     "DC" = "D")) %>%
#Recode GP practice into 5 digit number
#We assume that if it starts with a letter it's an English practice and so recode to 99995.
#PUT INTO FUNCTION?
  mutate(gpprac = if_else(str_detect(gpprac, "[A-Z]"), "99995", gpprac))

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
         )


###############################################################
#FUNCTIONS TO DO
#GPprac into a function
#Monthly costs and beddays
#SMRType
#Value labels
