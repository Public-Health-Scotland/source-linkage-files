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

library(janitor)

#Load set up file
source("setup_environment.R")

year <- "1819"
year_dir <- path("/conf/sourcedev/Source_Linkage_File_Updates", year, "Extracts")
file_path <- path(year_dir, "Acute-episode-level-extract-201819.csv.gz")

extract_path <- function(year, type = c("Acute", "Mental")) {
  year_dir <- path("/conf/sourcedev/Source_Linkage_File_Updates", year, "Extracts")

  file_name <- case_when(type == "Acute" ~ "Acute-episode-level-extract",
                         type == "Mental" ~ "Mental-Health-episode-level-extract")

  file_path <- path(year_dir, glue::glue("{file_name}-20{year}.csv.gz"))

  if (file_exists(path_ext_remove(file_path))) {
    file_path <- path_ext_remove(file_path)
  } else if (!file_exists(file_path)) {
    rlang::abort(glue::glue("{type} Extract not found"))
  }

  return(file_path)
}



#Load extract file
acute_file <- read_csv(file_path)

boxi_acute %>%
  rename(tadm = AdmissionTypeCode,
         adtf = AdmittedTransFromCode,
         age = AgeatMidpointofFinancialYear01,
         alcohol_adm = AlcoholRelatedAdmission01,
         cij_adm_spec = CIJAdmissionSpecialtyCode01,
         cij_dis_spec = CIJDischargeSpecialtyCode01,
         CIJ_end_date = CIJEndDate01,
         cij_pattype_code = CIJPlannedAdmissionCode01,
         CIJ_start_date = CIJStartDate01,
         cij_admtype = CIJTypeofAdmissionCode01,
         commhosp = CommunityHospitalFlag01,
         cij_marker = ContinuousInpatientJourneyMarker01,
         smr01_cis_marker = ContinuousInpatientStaySMR01incGLS,
         costmonthnum = CostsFinancialMonthNumber01,
         costsfy = CostsFinancialYear01,
         diag1 = Diagnosis1Code6char,
         diag2 = Diagnosis2Code6char,
         diag3 = Diagnosis3Code6char,
         diag4 = Diagnosis4Code6char,
         diag5 = Diagnosis5Code6char,
         diag6 = Diagnosis6Code6char,
         dischto = DischargeTransToCode,
         disch = DischargeTypeCode,
         falls_adm = FallsRelatedAdmission01,
         lca = GeoCouncilAreaCode,
         DataZone = GeoDatazone2011,
         postcode = GeoPostcodeC,
         HSCP = HSCPCode,
         conc = LeadConsultantHCPCode,
         admloc = LocationAdmittedTransFromCode,
         dischloc = LocationDischargedTransToCode,
         mpat = ManagementofPatientCode,
         hbrescode = NHSBoardofResidenceCode,
         nhshosp = NHSHospitalFlag01,
         yearstay = OccupiedBedDays01,
         oldtadm = OldSMR1TypeofAdmissionCode,
         op1a = Operation1ACode4char,
         op1b = Operation1BCode4char,
         op2a = Operation2ACode4char,
         op2b = Operation2BCode4char,
         op3a = Operation3ACode4char,
         op3b = Operation3BCode4char,
         op4a = Operation4ACode4char,
         op4b = Operation4BCode4char,
         gender = PatGenderCode,
         chi = PatUPI,
         cat = PatientCategoryCode,
         gpprac = PracticeLocationCode,
         hbpraccode = PracticeNHSBoardCode,
         selfharm_adm = SelfHarmRelatedAdmission01,
         sigfac = SignificantFacilityCode,
         spec = SpecialtyClassificat1497Code,
         submis_adm = SubstanceMisuseRelatedAdmission01,
         cost_total_net = TotalNetCosts01,
         location = TreatmentLocationCode,
         hbtreatcode = TreatmentNHSBoardCode,
         uri = UniqueRecordIdentifier
         )

