* Create Outpatients costed extract in suitable format for PLICS.

* Read in the outpatients extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, June 2016.

* Create macros for file path.

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
  /FILE=
    "/conf/hscdiip/DH-Extract/outpatients_all_scotland_episode_level_extract_for_source_file_productio"+
    "n_201516.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  ClinicDateFinYear A4
  ClinicDate00 A19
  SendingLocationCodeSMR00 A5
  EpisodeRecordKeySMR00C A11
  PatUPI A10
  PatGenderCode F1.0
  PatDateOfBirthC A19
  PracticeLocationCode A5
  PracticeNHSBoardCodecurrent A9
  GeoPostcodeC A7
  NHSBoardofResidenceCodecurrent A9
  GeoCouncilAreaCode A2
  CHPCode A9
  GeoDataZone A9
  TreatmentLocationCode A5
  TreatmentNHSBoardCodecurrent A9
  SpecialtyClassificat.1497Code A3
  SignificantFacilityCode A2
  ConsultantHCPCode A8
  PatientCategoryCode A1
  ReferralSourceCode A1
  ReferralTypeCode F1.0
  ClinicTypeCode F1.0
  ClinicAttendanceStatusCode F1.0
  AgeatMidpointofFinancialYear F3.0
  AlcoholRelatedAdmission A1
  SubstanceMisuseRelatedAdmission A1
  FallsRelatedAdmission A1
  SelfHarmRelatedAdmission A1
  NHSHospitalFlag A1
  CommunityHospitalFlag A1
  TotalNetCosts F7.2.
CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

save outfile = !file + 'op_temp.sav'.

get file = !file + 'op_temp.sav'.

* Datazone for outpatients is not Datazone 2011. Consultant code does not have Lead in front of it. 
rename variables (PatUPI PatGenderCode 
                  PracticeLocationCode PracticeNHSBoardCodecurrent GeoPostcodeC NHSBoardofResidenceCodecurrent
                  GeoCouncilAreaCode CHPCode GeoDatazone TreatmentLocationCode TreatmentNHSBoardCodecurrent
                  SpecialtyClassificat.1497Code SignificantFacilityCode ConsultantHCPCode PatientCategoryCode
                  ReferralSourceCode ReferralTypeCode ClinicTypeCode ClinicAttendanceStatusCode
                  AlcoholRelatedAdmission SubstanceMisuseRelatedAdmission FallsRelatedAdmission SelfHarmRelatedAdmission
                  TotalNetCosts NHSHospitalFlag CommunityHospitalFlag AgeatMidpointofFinancialYear
                  SendingLocationCodeSMR00 EpisodeRecordKeySMR00C
                = chi gender
                  prac hbpraccode pc7 hbrescode
                  lca chp datazone location hbtreatcode
                  spec sigfac conc cat
                  refsource reftype clinic_type attendance_status
                  alcohol_adm submis_adm falls_adm selfharm_adm
                  cost_total_net nhshosp commhosp age
                  sendloc erk).

string year (a4) recid (a3).
compute year = '1516'.
compute recid = '00B'.
execute.

string record_keydate1 record_keydate2 dob (a8).
compute record_keydate1 = concat(substr(ClinicDate00,1,4),substr(ClinicDate00,6,2),substr(ClinicDate00,9,2)).
compute record_keydate2 = concat(substr(ClinicDate00,1,4),substr(ClinicDate00,6,2),substr(ClinicDate00,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
execute.

alter type record_keydate1 record_keydate2 dob (f8.0).

string unique_id (a16).
compute unique_id = concat (sendloc,erk).
execute.

save outfile = !file + 'op_temp2.sav'
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  spec sigfac conc cat age refsource reftype attendance_status clinic_type alcohol_adm submis_adm falls_adm selfharm_adm commhosp nhshosp
  cost_total_net unique_id.
  

* Create a file that contains uri and costsfmth and net cost.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 

get file = !file + 'op_temp2.sav' 
 /keep unique_id cost_total_net record_keydate1.

alter type record_keydate1 (a8).
string month (a2).
compute month = substr(record_keydate1,5,2).
execute.
alter type record_keydate1 (f8.0).

numeric costmonthnum (f2.0).
if (month eq '04') costmonthnum = 1.
if (month eq '05') costmonthnum = 2.
if (month eq '06') costmonthnum = 3.
if (month eq '07') costmonthnum = 4.
if (month eq '08') costmonthnum = 5.
if (month eq '09') costmonthnum = 6.
if (month eq '10') costmonthnum = 7.
if (month eq '11') costmonthnum = 8.
if (month eq '12') costmonthnum = 9.
if (month eq '01') costmonthnum = 10.
if (month eq '02') costmonthnum = 11.
if (month eq '03') costmonthnum = 12.
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

sort cases by unique_id.

save outfile = !file + 'op_monthly_costs_by_unique_id.sav'.

* Match this file back to the main op file..  

get file = !file + 'op_temp2.sav'.

sort cases by unique_id.

match files file = *
 /table = !file + 'op_monthly_costs_by_unique_id.sav'
 /by unique_id.
execute.

save outfile = !file + 'op_temp3.sav'
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  spec sigfac conc cat age refsource reftype attendance_status clinic_type alcohol_adm submis_adm falls_adm selfharm_adm commhosp nhshosp
  cost_total_net unique_id
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost.

get file = !file + 'op_temp3.sav'.

save outfile = !file + 'op_file_for_source-201516.sav'
 /compressed. 

get file = !file + 'op_file_for_source-201516.sav'.


* Housekeeping. 
erase file = !file + 'op_temp.sav'.
erase file = !file + 'op_temp2.sav'.
erase file = !file + 'op_temp3.sav'.
erase file = !file + 'op_monthly_costs_by_unique_id.sav'.







