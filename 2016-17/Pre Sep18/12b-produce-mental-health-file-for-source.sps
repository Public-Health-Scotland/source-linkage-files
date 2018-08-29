* Create mental health costed extract in suitable format for PLICS.

* Read in the mental health extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, June 2016.

* Create macros for file path.


******************************* **** UPDATE THIS BIT **** *************************************.
********************************************************************************************************.
********************************************************************************************************.
********************************************************************************************************.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 

* Extract files - 'home'.
define !Extracts()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

*define macro for FY.
define !FY()
'1617'
!enddefine.

********************************************************************************************************.
********************************************************************************************************.


* Read in CSV output file.
GET DATA  /TYPE=TXT
  /FILE= !file + 'mental health all scotland episode level extract for source file production 20' +!FY +'.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  CostsFinancialYear04 A4
  CostsFinancialMonthName04 A9
  DateofAdmission04 A19
  DateofDischarge04 A19
  PatUPI A10
  PatGenderCode F1.0
  PatDateOfBirthC A19
  PracticeLocationCode A5
  PracticeNHSBoardCodecurrent A9
  GeoPostcodeC A7
  NHSBoardofResidenceCodecurrent A9
  GeoCouncilAreaCode A2
  CHPCode A9
  GeoDataZone2011 A9
  TreatmentLocationCode A5
  TreatmentNHSBoardCodecurrent A9
  OccupiedBedDays04 F8.2
  SpecialtyClassificat.1497Code A3
  SignificantFacilityCode A2
  LeadConsultantHCPCode A8
  ManagementofPatientCode A1
  PatientCategoryCode A1
  AdmissionTypeCode A2
  AdmittedTransFromCode A2
  LocationAdmittedTransFromCode A5
  DischargeTypeCode A2
  DischargeTransToCode A2
  LocationDischargedTransToCode A5
  Diagnosis1Code6char A6
  Diagnosis2Code6char A6
  Diagnosis3Code6char A6
  Diagnosis4Code6char A6
  Diagnosis5Code6char A6
  Diagnosis6Code6char A6
  StatusonAdmissionCode A1
  AdmissionDiagnosis1Code6char A6
  AdmissionDiagnosis2Code6char A6
  AdmissionDiagnosis3Code6char A6
  AdmissionDiagnosis4Code6char A6
  AgeatMidpointofFinancialYear04 F3.0
  ContinuousInpatientJourneyMarker04 A5
  CIJPlannedAdmissionCode04 F1.0
  CIJInpatientDayCaseIdentifierCode04 A2
  CIJTypeofAdmissionCode04 A7
  CIJAdmissionSpecialtyCode04 A3
  CIJDischargeSpecialtyCode04 A3
  TotalDirectCosts04 F8.2
  TotalAllocatedCosts04 F8.2
  TotalNetCosts04 F8.2
  AlcoholRelatedAdmission04 A1
  SubstanceMisuseRelatedAdmission04 A1
  FallsRelatedAdmission04 A1
  SelfHarmRelatedAdmission04 A1
  DuplicateRecordFlag04 A1
  NHSHospitalFlag04 A1
  CommunityHospitalFlag04 A1
  UniqueRecordIdentifier A8.
CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

* Having issues trying to get this column to output from Business Objects.  So just creating a dummy variable just now.  
* Note the the Occupied bed days, renamed in the next section to yearstay is the LOS variable that is used for analysis with 
* the PLICs file as this is the number of bed days that have been costed within the financial year. 
numeric lengthofstay (f7.0).

save outfile = !file + 'mh_temp.sav'.

get file = !file + 'mh_temp.sav'.
* SMR04 specific variables need to be added in here. 
rename variables (PatUPI UniqueRecordIdentifier PatGenderCode 
                  PracticeLocationCode PracticeNHSBoardCodecurrent GeoPostcodeC NHSBoardofResidenceCodecurrent
                  GeoCouncilAreaCode CHPCode GeoDatazone2011 TreatmentLocationCode TreatmentNHSBoardCodecurrent
                  OccupiedBedDays04 LengthofStay SpecialtyClassificat.1497Code SignificantFacilityCode LeadConsultantHCPCode
                  ManagementofPatientCode PatientCategoryCode AdmissionTypeCode AdmittedTransFromCode LocationAdmittedTransFromCode
                  DischargeTypeCode DischargeTransToCode LocationDischargedTransToCode
                  Diagnosis1Code6char Diagnosis2Code6char Diagnosis3Code6char Diagnosis4Code6char Diagnosis5Code6char Diagnosis6Code6char
                  ContinuousInpatientJourneyMarker04 CIJTypeofAdmissionCode04 CIJAdmissionSpecialtyCode04 CIJDischargeSpecialtyCode04
                  AlcoholRelatedAdmission04 SubstanceMisuseRelatedAdmission04 FallsRelatedAdmission04 SelfHarmRelatedAdmission04
                  TotalDirectCosts04 TotalAllocatedCosts04 TotalNetCosts04
                  NHSHospitalFlag04 CommunityHospitalFlag04 AgeatMidpointofFinancialYear04 CostsFinancialYear04 CostsFinancialMonthName04
                  CIJPlannedAdmissionCode04
                  StatusonAdmissionCode AdmissionDiagnosis1Code6char AdmissionDiagnosis2Code6char AdmissionDiagnosis3Code6char AdmissionDiagnosis4Code6char
                = chi uri gender
                  prac hbpraccode pc7 hbrescode
                  lca chp datazone location hbtreatcode
                  yearstay stay spec sigfac conc
                  mpat cat tadm adtf admloc 
                  disch dischto dischloc
                  diag1 diag2 diag3 diag4 diag5 diag6
                  cis_marker newcis_admtype CIJadm_spec CIJdis_spec
                  alcohol_adm submis_adm falls_adm selfharm_adm
                  cost_direct_net cost_allocated_net cost_total_net
                  nhshosp commhosp age costsfy costsfmth
                  newpattype_ciscode
                  stadm adcon1 adcon2 adcon3 adcon4).

* used to check some URIs where episode straddles one or more calendar months.
* DH, June 2016. 
*compute same = 0.
*sort cases by uri. 
*if uri eq lag(uri) same =1.
*execute.

string year (a4) recid (a3) ipdc (a1) newcis_ipdc (a1) newpattype_cis (a13).
compute year = !FY.
compute recid = '04B'.
compute ipdc = 'I'.
EXECUTE.

if (CIJInpatientDayCaseIdentifierCode04 eq 'MH') newcis_ipdc = 'I'.
if ((newpattype_ciscode eq 2) and recid eq '02B') newpattype_cis = 'Maternity'.
if (newpattype_ciscode eq 0) newpattype_cis = 'Non-elective'.
if (newpattype_ciscode eq 1) newpattype_cis = 'Elective'.
execute.

string record_keydate1 record_keydate2 dob (a8).
compute record_keydate1 = concat(substr(DateofAdmission04,1,4),substr(DateofAdmission04,6,2),substr(DateofAdmission04,9,2)).
compute record_keydate2 = concat(substr(DateofDischarge04,1,4),substr(DateofDischarge04,6,2),substr(DateofDischarge04,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
execute.

alter type record_keydate1 record_keydate2 dob (f8.0).

* Need to make CIJ Type of Admission (newcis_admtype) two characters in length (to be consistent with acute).  Recode the Unknown to 99.

string newcistadm (a7).
compute newcistadm = newcis_admtype.
if (newcistadm eq 'Unknown') newcis_admtype = '99'.
alter type newcis_admtype (a2).

frequencies newcistadm newcis_admtype.

* need to add in SMR04 specific variables in to here. 
save outfile = !file + 'mh_temp2.sav'
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
  cost_direct_net cost_allocated_net cost_total_net costsfy costsfmth stadm adcon1 adcon2 adcon3 adcon4 uri.
  

* Create a file that contains uri and costsfmth and net cost.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 

get file = !file + 'mh_temp2.sav' 
 /keep uri cost_total_net costsfmth.

numeric costmonthnum (f2.0).
if (costsfmth eq 'APRIL') costmonthnum = 1.
if (costsfmth eq 'MAY') costmonthnum = 2.
if (costsfmth eq 'JUNE') costmonthnum = 3.
if (costsfmth eq 'JULY') costmonthnum = 4.
if (costsfmth eq 'AUGUST') costmonthnum = 5.
if (costsfmth eq 'SEPTEMBER') costmonthnum = 6.
if (costsfmth eq 'OCTOBER') costmonthnum = 7.
if (costsfmth eq 'NOVEMBER') costmonthnum = 8.
if (costsfmth eq 'DECEMBER') costmonthnum = 9.
if (costsfmth eq 'JANUARY') costmonthnum = 10.
if (costsfmth eq 'FEBRUARY') costmonthnum = 11.
if (costsfmth eq 'MARCH') costmonthnum = 12.
execute.

do repeat x = col1 to col12
 /y = 1 to 12.
compute x = 0.
if (y=costmonthnum) x = cost_total_net.
end repeat.
execute.

rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 = 
                  april_cost may_cost june_cost july_cost august_cost sept_cost 
                  oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).

aggregate outfile = *
 /break uri
 /april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost = 
  sum(april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).
execute.

sort cases by uri.

save outfile = !file + 'mh_monthly_costs_by_uri.sav'.

* Create a file that contains uri and costsfmth and yearstay.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 

get file = !file + 'mh_temp2.sav' 
 /keep uri yearstay costsfmth.

numeric costmonthnum (f2.0).
if (costsfmth eq 'APRIL') costmonthnum = 1.
if (costsfmth eq 'MAY') costmonthnum = 2.
if (costsfmth eq 'JUNE') costmonthnum = 3.
if (costsfmth eq 'JULY') costmonthnum = 4.
if (costsfmth eq 'AUGUST') costmonthnum = 5.
if (costsfmth eq 'SEPTEMBER') costmonthnum = 6.
if (costsfmth eq 'OCTOBER') costmonthnum = 7.
if (costsfmth eq 'NOVEMBER') costmonthnum = 8.
if (costsfmth eq 'DECEMBER') costmonthnum = 9.
if (costsfmth eq 'JANUARY') costmonthnum = 10.
if (costsfmth eq 'FEBRUARY') costmonthnum = 11.
if (costsfmth eq 'MARCH') costmonthnum = 12.
execute.

do repeat x = col1 to col12
 /y = 1 to 12.
compute x = 0.
if (y=costmonthnum) x = yearstay.
end repeat.
execute.

rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 = 
                  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays 
                  oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).

aggregate outfile = *
 /break uri
 /april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays = 
  sum(april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).
execute.

sort cases by uri.

save outfile = !file + 'mh_monthly_beddays_by_uri.sav'.


* Match both these files back to the main acute file and then create totals adding across the months for each of the costs 
 and yearstay variables.  
* Need to reduce each uri to one row only.  All columns will have the same information except for the costs month variable.

get file = !file + 'mh_temp2.sav'.

sort cases by uri.

match files file = *
 /table = !file + 'mh_monthly_beddays_by_uri.sav'
 /by uri.
execute.

match files file = *
 /table = !file + 'mh_monthly_costs_by_uri.sav'
 /by uri.
execute.

delete variables cost_direct_net cost_allocated_net. 

aggregate outfile = *
 /break uri
 /year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp 
  stadm adcon1 adcon2 adcon3 adcon4
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
  first(year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp 
  stadm adcon1 adcon2 adcon3 adcon4
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).
execute.

compute yearstay = april_beddays + may_beddays + june_beddays + july_beddays + august_beddays + sept_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
compute cost_total_net = april_cost + may_cost + june_cost + july_cost + august_cost + sept_cost + oct_cost + nov_cost + dec_cost + jan_cost + feb_cost + mar_cost.
execute.

* match on the length of stay by uri.

delete variables stay.

sort cases by uri.
match files file = *
 /table = !file + 'mh_los_by_uri.sav'
 /by uri.
execute.

save outfile = !file + 'mh_temp3.sav'
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
  cost_total_net 
  stadm adcon1 adcon2 adcon3 adcon4
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost uri.

get file = !file + 'mh_temp3.sav'.
save outfile = !file + 'mental_health_for_source-20' +!FY +'.sav'
 /compressed. 

get file = !file + 'mental_health_for_source-20'+!FY+'.sav'.

* Housekeeping.
erase file = !file + 'mh_temp.sav'.
erase file = !file + 'mh_temp2.sav'.
erase file = !file + 'mh_temp3.sav'.
erase file = !file + 'mh_los_by_uri.sav'.
erase file = !file + 'mh_monthly_beddays_by_uri.sav'.
erase file = !file + 'mh_monthly_costs_by_uri.sav'.







