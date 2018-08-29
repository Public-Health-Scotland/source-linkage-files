* Create Acute costed extract in suitable format for Source Linkage Files.

* Read in the acute extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, June 2016.
* Program updated by Denise Hastie, September 2016.
* September 2016 updates - reading in data from an BO output, not NSS IT output. 
*                        - adding in a section to match on the length of stay by uri (amendments required at a few places).                       
*                        - added in new code that populates newpattype_cis based on the admission type for records without a
                           upi number (chi).  Note that transfers will be coded as Other.   This will be handled in program 20. 

* Create macros for file path.

* Changed reference of PLICS to source/source linkage files where appropriate in the file names.  DKG, October 2017.

* Temporary storage.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 

* Extract files - 'home'.
define !Extracts()
'/conf/irf/11-Development team/Dev00-PLICS-files/data-extracts/'
!enddefine.


* Read in CSV output file.


GET DATA  /TYPE=TXT
  /FILE="/conf/hscdiip/DH-Extract/acute_all_scotland_episode_level_extract_for_source_file_production_-_excluding_stay_201516.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  CostsFinancialYear01 A4
  CostsFinancialMonthName01 A9
  GLSRecord A1
  DateofAdmission01 A19
  DateofDischarge01 A19
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
  OccupiedBedDays01 F8.2
  InpatientDayCaseIdentifierCode A2
  SpecialtyClassificat.1497Code A3
  SignificantFacilityCode A2
  LeadConsultantHCPCode A8
  ManagementofPatientCode A1
  PatientCategoryCode A1
  AdmissionTypeCode A2
  AdmittedTransFromCode A2
  LocationAdmittedTransFromCode A5
  OldSMR1TypeofAdmissionCode A1
  DischargeTypeCode A2
  DischargeTransToCode A2
  LocationDischargedTransToCode A5
  Diagnosis1Code6char A6
  Diagnosis2Code6char A6
  Diagnosis3Code6char A6
  Diagnosis4Code6char A6
  Diagnosis5Code6char A6
  Diagnosis6Code6char A6
  Operation1ACode4char A4
  Operation1BCode4char A4
  DateofOperation101 A19
  Operation2ACode4char A4
  Operation2BCode4char A4
  DateofOperation201 A19
  Operation3ACode4char A4
  Operation3BCode4char A4
  DateofOperation301 A19
  Operation4ACode4char A4
  Operation4BCode4char A4
  DateofOperation401 A19
  AgeatMidpointofFinancialYear01 F3.0
  ContinuousInpatientStaySMR01 F5.0
  ContinuousInpatientStaySMR01incGLS F5.0
  ContinuousInpatientJourneyMarker01 A5
  CIJPlannedAdmissionCode01 F1.0
  CIJInpatientDayCaseIdentifierCode01 A2
  CIJTypeofAdmissionCode01 A2
  CIJAdmissionSpecialtyCode01 A3
  CIJDischargeSpecialtyCode01 A3
  TotalDirectCosts01 F8.2
  TotalAllocatedCosts01 F8.2
  TotalNetCosts01 F8.2
  NHSHospitalFlag01 A1
  CommunityHospitalFlag01 A1
  AlcoholRelatedAdmission01 A1
  SubstanceMisuseRelatedAdmission01 A1
  FallsRelatedAdmission01 A1
  SelfHarmRelatedAdmission01 A1
  UniqueRecordIdentifier A8.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

save outfile = !file + 'acute_temp.sav'.

get file = !file + 'acute_temp.sav'.

rename variables (PatUPI UniqueRecordIdentifier PatGenderCode 
                  PracticeLocationCode PracticeNHSBoardCodecurrent GeoPostcodeC NHSBoardofResidenceCodecurrent
                  GeoCouncilAreaCode CHPCode GeoDatazone2011 TreatmentLocationCode TreatmentNHSBoardCodecurrent
                  OccupiedBedDays01 SpecialtyClassificat.1497Code SignificantFacilityCode LeadConsultantHCPCode
                  ManagementofPatientCode PatientCategoryCode AdmissionTypeCode AdmittedTransFromCode LocationAdmittedTransFromCode
                  OldSMR1TypeofAdmissionCode DischargeTypeCode DischargeTransToCode LocationDischargedTransToCode
                  Diagnosis1Code6char Diagnosis2Code6char Diagnosis3Code6char Diagnosis4Code6char Diagnosis5Code6char Diagnosis6Code6char
                  Operation1ACode4char Operation1BCode4char Operation2ACode4char Operation2BCode4char
                  Operation3ACode4char Operation3BCode4char Operation4ACode4char Operation4BCode4char ContinuousInpatientStaySMR01
                  ContinuousInpatientJourneyMarker01 CIJTypeofAdmissionCode01 CIJAdmissionSpecialtyCode01 CIJDischargeSpecialtyCode01
                  AlcoholRelatedAdmission01 SubstanceMisuseRelatedAdmission01 FallsRelatedAdmission01 SelfHarmRelatedAdmission01
                  TotalDirectCosts01 TotalAllocatedCosts01 TotalNetCosts01
                  NHSHospitalFlag01 CommunityHospitalFlag01 AgeatMidpointofFinancialYear01 CostsFinancialYear01 CostsFinancialMonthName01
                  CIJPlannedAdmissionCode01
                = chi uri gender
                  prac hbpraccode pc7 hbrescode
                  lca chp datazone location hbtreatcode
                  yearstay spec sigfac conc
                  mpat cat tadm adtf admloc 
                  oldtadm disch dischto dischloc
                  diag1 diag2 diag3 diag4 diag5 diag6
                  op1a op1b op2a op2b 
                  op3a op3b op4a op4b smr01_cis
                  cis_marker newcis_admtype CIJadm_spec CIJdis_spec
                  alcohol_adm submis_adm falls_adm selfharm_adm
                  cost_direct_net cost_allocated_net cost_total_net
                  nhshosp commhosp age costsfy costsfmth
                  newpattype_ciscode).

* used to check some URIs where episode straddles one or more calendar months.
* DH, June 2016. 
*compute same = 0.
*sort cases by uri. 
*if uri eq lag(uri) same =1.
*execute.

string year (a4) recid (a3) ipdc (a1) newcis_ipdc (a1) newpattype_cis (a13).
compute year = '1516'.
compute recid = '01B'.
if (glsrecord eq 'Y') recid = 'GLS'.
if (InpatientDayCaseIdentifierCode eq 'IP') ipdc = 'I'.
if (InpatientDayCaseIdentifierCode eq 'DC') ipdc = 'D'.
if (CIJInpatientDayCaseIdentifierCode01 eq 'IP') newcis_ipdc = 'I'.
if (CIJInpatientDayCaseIdentifierCode01 eq 'DC') newcis_ipdc = 'D'.
*if ((newpattype_ciscode eq 2) and recid eq '02B') newpattype_cis = 'Maternity'.
if (newpattype_ciscode eq 2) newpattype_cis = 'Maternity'.
if (newpattype_ciscode eq 0) newpattype_cis = 'Non-elective'.
if (newpattype_ciscode eq 1) newpattype_cis = 'Elective'.
execute.

string record_keydate1 record_keydate2 dob dateop1 dateop2 dateop3 dateop4 (a8).
compute record_keydate1 = concat(substr(DateofAdmission01,1,4),substr(DateofAdmission01,6,2),substr(DateofAdmission01,9,2)).
compute record_keydate2 = concat(substr(DateofDischarge01,1,4),substr(DateofDischarge01,6,2),substr(DateofDischarge01,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
compute dateop1 = concat(substr(DateofOperation101,1,4),substr(DateofOperation101,6,2),substr(DateofOperation101,9,2)).
compute dateop2 = concat(substr(DateofOperation201,1,4),substr(DateofOperation201,6,2),substr(DateofOperation201,9,2)).
compute dateop3 = concat(substr(DateofOperation301,1,4),substr(DateofOperation301,6,2),substr(DateofOperation301,9,2)).
compute dateop4 = concat(substr(DateofOperation401,1,4),substr(DateofOperation401,6,2),substr(DateofOperation401,9,2)).
execute.

alter type record_keydate1 record_keydate2 dob dateop1 dateop2 dateop3 dateop4 (f8.0).

save outfile = !file + 'acute_temp2.sav'
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
  cost_direct_net cost_allocated_net cost_total_net costsfy costsfmth uri.
  

* Create a file that contains uri and costsfmth and net cost.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 

get file = !file + 'acute_temp2.sav'
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

save outfile = !file + 'acute_monthly_costs_by_uri.sav'.

* Create a file that contains uri and costsfmth and yearstay.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 

get file = !file + 'acute_temp2.sav' 
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

save outfile = !file + 'acute_monthly_beddays_by_uri.sav'.


* Match both these files back to the main acute file and then create totals adding across the months for each of the costs 
 and yearstay variables.  
* Need to reduce each uri to one row only.  All columns will have the same information except for the costs month variable.

get file = !file + 'acute_temp2.sav'.

sort cases by uri.

match files file = *
 /table = !file + 'acute_monthly_beddays_by_uri.sav'
 /by uri.
execute.

match files file = *
 /table = !file + 'acute_monthly_costs_by_uri.sav'
 /by uri.
execute.

delete variables cost_direct_net cost_allocated_net. 

aggregate outfile = *
 /break uri
 /year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp 
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
  first(year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp 
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).
execute.

compute yearstay = april_beddays + may_beddays + june_beddays + july_beddays + august_beddays + sept_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
compute cost_total_net = april_cost + may_cost + june_cost + july_cost + august_cost + sept_cost + oct_cost + nov_cost + dec_cost + jan_cost + feb_cost + mar_cost.
execute.

* Create the SMRtype variable that was first introduced for 2013/14.  Note that the line number
* is required for sorting the acute records, so SMRType will be created here.  An extract has been taking by URI and LINE NO and this 
* needs to be matched on first. 

sort cases by uri.

match files file = *
 /table = !file + 'acute_line_number_by_uri_201516.sav'
 /by uri.
execute.

* Create the column SMRType.
string SMRType(a10).
if (recid eq '01B' and lineno ne '330' and ipdc eq 'I') SMRType = 'Acute-IP'.
if (recid eq '01B' and lineno ne '330' and ipdc eq 'D') SMRType = 'Acute-DC'.
if (recid eq '01B' and lineno eq '330' and ipdc eq 'I') SMRType = 'GLS-IP'.
if (recid eq 'GLS') SMRType = 'GLS-IP'.
frequencies SMRType.

* Calculate the length of stay 'manually'.  Due to the grain of the data for costs and the grain of the non-cost 
* data, too large a file is created from Business Objects (data since the start of the catalog).  This is not 
* suitable for extracting, sorting and finally matching as the acute data in the data mart is currently in excess 
* of 40 million records and will only continue to grow in size.
* DH, September 2016.  

alter type record_keydate1 record_keydate2 (a8).
string year1 month1 day1 year2 month2 day2 (a2).
compute year1 = substr(record_keydate1,3,2).
compute month1 = substr(record_keydate1,5,2).
compute day1 = substr(record_keydate1,7,2).
compute year2 = substr(record_keydate2,3,2).
compute month2 = substr(record_keydate2,5,2).
compute day2 = substr(record_keydate2,7,2).
execute.

alter type year1 month1 day1 year2 month2 day2 (f2.0).

compute stay = yrmoda(year2,month2,day2) - yrmoda(year1,month1,day1).
execute.

alter type record_keydate1 record_keydate2 (f8.0).

frequency variables = stay yearstay.

delete variables year1 month1 day1 year2 month2 day2.

alter type stay (f7.0).



save outfile = !file + 'acute_file_for_source-201516.sav'
 /keep year recid record_keydate1 record_keydate2 SMRType chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
  cost_total_net 
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost uri
 /compressed.

get file = !file + 'acute_file_for_source-201516.sav'.


* Housekeeping. 
erase file = !file + 'acute_temp.sav'.
erase file = !file + 'acute_temp2.sav'.
erase file = !file + 'acute_monthly_beddays_by_uri.sav'.
erase file = !file + 'acute_monthly_costs_by_uri.sav'.
erase file = !file + 'acute_line_number_by_uri_201516.sav'.

