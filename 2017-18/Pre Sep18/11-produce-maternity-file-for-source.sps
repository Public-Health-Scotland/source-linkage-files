* Create maternity costed extract in suitable format for PLICS.

* Read in the maternity extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, July 2016.
* Updated by Denise Hastie, August 2016.  Added in a section that was in the master PLICS file creation program
* with regards to calculating the length of stay for maternity.  


******************************* **** UPDATE THIS BIT **** *************************************.
********************************************************************************************************.
* Create macros for file path.

define !file()
   '/conf/sourcedev/Anita_temp/'
!enddefine.

* Extract files - 'home'.
define !Extracts()
   '/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

*define macro for FY.
define !FY()
   '1718'
!enddefine.

********************************************************************************************************.
********************************************************************************************************.

* Read in CSV output file.
GET DATA  /TYPE=TXT
   /FILE = !file +'maternity all scotland episode level extract for source file production 20' +!FY + '.csv'
   /ENCODING='UTF8'
   /DELCASE=LINE
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /IMPORTCASE=ALL
   /VARIABLES=
      CostsFinancialYear F4.0
      DateofAdmissionFullDate A19
      DateofDischargeFullDate A19
      PatUPIC A10
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
      OccupiedBedDays F4.2
      SpecialtyClassification1497Code A3
      SignificantFacilityCode A2
      ConsultantHCPCode A8
      ManagementofPatientCode A1
      AdmissionReasonCode A2
      AdmittedTransferfromCodenew A2
      AdmittedtransferfromLocationCode A5
      DischargeTypeCode A2
      DischargeTransfertoCodenew A2
      DischargedtoLocationCode A5
      ConditionOnDischargeCode F1.0
      ContinuousInpatientJourneyMarker A5
      CIJPlannedAdmissionCode F1.0
      CIJInpatientDayCaseIdentifierCode A2
      CIJTypeofAdmissionCode A2
      CIJAdmissionSpecialtyCode A3
      CIJDischargeSpecialtyCode A3
      TotalDirectCosts F8.2
      TotalAllocatedCosts F7.2
      TotalNetCosts F8.2
      Diagnosis1DischargeCode A4
      Diagnosis2DischargeCode A5
      Diagnosis3DischargeCode A4
      Diagnosis4DischargeCode A4
      Diagnosis5DischargeCode A4
      Diagnosis6DischargeCode A4
      Operation1ACode A4
      Operation2ACode A4
      Operation3ACode A4
      Operation4ACode A4
      DateofMainOperationFullDate A19
      AgeatMidpointofFinancialYear F3.0
      NHSHospitalFlag A1
      CommunityHospitalFlag A1
      AlcoholRelatedAdmissioN A1
      SubstanceMisuseRelatedAdmission A1
      FallsRelatedAdmission A1
      SelfHarmRelatedAdmission A1.
CACHE.

save outfile = !file + 'maternity_temp.zsav'
   /zcompressed.
get file = !file + 'maternity_temp.zsav'.

rename variables (PatUPIC  
                  PracticeLocationCode PracticeNHSBoardCodecurrent GeoPostcodeC NHSBoardofResidenceCodecurrent
                  GeoCouncilAreaCode CHPCode GeoDatazone TreatmentLocationCode TreatmentNHSBoardCodecurrent
                  OccupiedBedDays SpecialtyClassification1497Code SignificantFacilityCode ConsultantHCPCode
                  ManagementofPatientCode AdmittedTransferFromCodenew AdmittedTransferFromLocationCode
                  DischargeTypeCode DischargeTransferToCodenew DischargedtoLocationCode
                  ContinuousInpatientJourneyMarker CIJTypeofAdmissionCode CIJAdmissionSpecialtyCode CIJDischargeSpecialtyCode
                  AlcoholRelatedAdmission SubstanceMisuseRelatedAdmission FallsRelatedAdmission SelfHarmRelatedAdmission
                  TotalDirectCosts TotalAllocatedCosts TotalNetCosts
                  NHSHospitalFlag CommunityHospitalFlag AgeatMidpointofFinancialYear CostsFinancialYear 
                  CIJPlannedAdmissionCode
                  Diagnosis1DischargeCode Diagnosis2DischargeCode Diagnosis3DischargeCode Diagnosis4DischargeCode 
                  Diagnosis5DischargeCode Diagnosis6DischargeCode 
                  Operation1ACode Operation2ACode Operation3ACode Operation4ACode
                  ConditionOnDischargeCode
                = chi 
                  prac hbpraccode pc7 hbrescode
                  lca chp datazone location hbtreatcode
                  yearstay spec sigfac conc
                  mpat adtf admloc 
                  disch dischto dischloc
                  cis_marker newcis_admtype CIJadm_spec CIJdis_spec
                  alcohol_adm submis_adm falls_adm selfharm_adm
                  cost_direct_net cost_allocated_net cost_total_net
                  nhshosp commhosp age costsfy
                  newpattype_ciscode
                  diag1 diag2 diag3 diag4 
                  diag5 diag6
                  op1a op2a op3a op4a
                  discondition).

* Create a variable for gender.
numeric gender (f1.0).
compute gender = 2.

* used to check some URIs where episode straddles one or more calendar months.
* DH, June 2016. 
*compute same = 0.
*sort cases by uri. 
*if uri eq lag(uri) same =1.
*execute.

string year (a4) recid (a3) ipdc (a1) newcis_ipdc (a1) newpattype_cis (a13).
compute year = !FY.
compute recid = '02B'.

Do if (CIJInpatientDayCaseIdentifierCode eq 'IP').
   Compute newcis_ipdc = 'I'.
Else if (CIJInpatientDayCaseIdentifierCode eq 'DC').
   Compute newcis_ipdc = 'D'.
End if.

Do if ((newpattype_ciscode eq 2) and recid eq '02B').
   Compute newpattype_cis = 'Maternity'.
Else if (newpattype_ciscode eq 0).
   Compute newpattype_cis = 'Non-elective'.
Else if (newpattype_ciscode eq 1).
   Compute newpattype_cis = 'Elective'.
End if.

string record_keydate1 record_keydate2 dob dateop1 (a8).
compute record_keydate1 = concat(substr(DateofAdmissionFullDate,1,4),substr(DateofAdmissionFullDate,6,2),substr(DateofAdmissionFullDate,9,2)).
compute record_keydate2 = concat(substr(DateofDischargeFullDate,1,4),substr(DateofDischargeFullDate,6,2),substr(DateofDischargeFullDate,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
compute dateop1 = concat(substr(DateofMainOperationFullDate,1,4),substr(DateofMainOperationFullDate,6,2),substr(DateofMainOperationFullDate,9,2)).


alter type record_keydate1 record_keydate2 dob dateop1 (f8.0).
alter type diag1 diag2 diag3 diag4 diag5 diag6 (a6).

delete variables cost_direct_net cost_allocated_net. 

* adding a fix for the length of stay for maternity records.  This is until there is a unique identifier available via
* the maternity universe. 

alter type record_keydate1 record_keydate2 (a8).
string year1 month1 day1 year2 month2 day2 (a2).
compute year1 = substr(record_keydate1,3,2).
compute month1 = substr(record_keydate1,5,2).
compute day1 = substr(record_keydate1,7,2).
compute year2 = substr(record_keydate2,3,2).
compute month2 = substr(record_keydate2,5,2).
compute day2 = substr(record_keydate2,7,2).


alter type year1 month1 day1 year2 month2 day2 (f2.0).

compute stay = yrmoda(year2,month2,day2) - yrmoda(year1,month1,day1).

alter type record_keydate1 record_keydate2 (f8.0).

 * frequency variables = stay yearstay.

delete variables year1 month1 day1 year2 month2 day2.

alter type stay (f7.0).

save outfile = !file + 'maternity_temp2.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
      stay yearstay spec sigfac conc mpat adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      op1a dateop1 op2a op3a op4a age discondition cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp nhshosp
      cost_total_net costsfy
   /zcompressed.
  

* Create a file that contains uri and costsfmth and net cost.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 
* ONCE A WAY TO UNIQUELY IDENTIFY A MATERNITY RECORD IS AVAILABLE IN THE DATA MART, THE NEXT SECTION CANNOT BE RUN.
* NOTE THAT THE CODE MAY NEED TO BE MODIFIED.  THE INITIAL EXTRACT FROM BUSINESS OBJECTS WILL NEED TO BE UDPATED TO INCLUDE
* COSTS FINANCIAL MONTH AS WELL AS THE DIMENSIONS REQUIRED TO CREATE A UNIQUE ID.
* Denise Hastie, July 2016.

*get file = !file + 'maternity_temp2.sav' 
 /keep UNIQUE ID VARIABLE cost_total_net costsfmth.

*numeric costmonthnum (f2.0).
*if (costsfmth eq 'APRIL') costmonthnum = 1.
*if (costsfmth eq 'MAY') costmonthnum = 2.
*if (costsfmth eq 'JUNE') costmonthnum = 3.
*if (costsfmth eq 'JULY') costmonthnum = 4.
*if (costsfmth eq 'AUGUST') costmonthnum = 5.
*if (costsfmth eq 'SEPTEMBER') costmonthnum = 6.
*if (costsfmth eq 'OCTOBER') costmonthnum = 7.
*if (costsfmth eq 'NOVEMBER') costmonthnum = 8.
*if (costsfmth eq 'DECEMBER') costmonthnum = 9.
*if (costsfmth eq 'JANUARY') costmonthnum = 10.
*if (costsfmth eq 'FEBRUARY') costmonthnum = 11.
*if (costsfmth eq 'MARCH') costmonthnum = 12.
*execute.

*do repeat x = col1 to col12
 /y = 1 to 12.
*compute x = 0.
*if (y=costmonthnum) x = cost_total_net.
*end repeat.
*execute.

*rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 = 
                  april_cost may_cost june_cost july_cost august_cost sept_cost 
                  oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).

*aggregate outfile = *
 /break uri
 /april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost = 
  sum(april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).
*execute.

*sort cases by uri.

*save outfile = !file + 'maternity_monthly_costs_by_uri.sav'.

* Create a file that contains uri and costsfmth and yearstay.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 

*get file = !file + 'maternity_temp2.sav' 
 /keep uri yearstay costsfmth.

*numeric costmonthnum (f2.0).
*if (costsfmth eq 'APRIL') costmonthnum = 1.
*if (costsfmth eq 'MAY') costmonthnum = 2.
*if (costsfmth eq 'JUNE') costmonthnum = 3.
*if (costsfmth eq 'JULY') costmonthnum = 4.
*if (costsfmth eq 'AUGUST') costmonthnum = 5.
*if (costsfmth eq 'SEPTEMBER') costmonthnum = 6.
*if (costsfmth eq 'OCTOBER') costmonthnum = 7.
*if (costsfmth eq 'NOVEMBER') costmonthnum = 8.
*if (costsfmth eq 'DECEMBER') costmonthnum = 9.
*if (costsfmth eq 'JANUARY') costmonthnum = 10.
*if (costsfmth eq 'FEBRUARY') costmonthnum = 11.
*if (costsfmth eq 'MARCH') costmonthnum = 12.
*execute.

*do repeat x = col1 to col12
 /y = 1 to 12.
*compute x = 0.
*if (y=costmonthnum) x = yearstay.
*end repeat.
*execute.

*rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 = 
                  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays 
                  oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).

*aggregate outfile = *
 /break uri
 /april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays = 
  sum(april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).
*execute.

*sort cases by uri.

*save outfile = !file + 'maternity_monthly_beddays_by_uri.sav'.


* Match both these files back to the main acute file and then create totals adding across the months for each of the costs 
 and yearstay variables.  
* Need to reduce each uri to one row only.  All columns will have the same information except for the costs month variable.

*get file = !file + 'maternity_temp2.sav'.

*sort cases by uri.

*match files file = *
 /table = !file + 'maternity_monthly_beddays_by_uri.sav'
 /by uri.
*execute.

*match files file = *
 /table = !file + 'maternity_monthly_costs_by_uri.sav'
 /by uri.
*execute.

*delete variables cost_direct_net cost_allocated_net. 

*aggregate outfile = *
 /break uri
 /year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp 
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
  first(year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp 
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).
*execute.

*compute yearstay = april_beddays + may_beddays + june_beddays + july_beddays + august_beddays + sept_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
*compute cost_total_net = april_cost + may_cost + june_cost + july_cost + august_cost + sept_cost + oct_cost + nov_cost + dec_cost + jan_cost + feb_cost + mar_cost.
*execute.

*save outfile = !file + 'maternity_temp3.sav'
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
  yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
  op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
  newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
  cost_total_net 
  april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
  april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost.

get file = !file + 'maternity_temp2.zsav'.
save outfile = !file + 'maternity_for_source-20'+!FY+'.zsav'
   /zcompressed. 


*change costsfy to string.
get file=!file + 'maternity_for_source-20'+!FY+'.sav'.

alter type costsfy(A4).

save outfile = !file + 'maternity_for_source-20'+!FY+'.zsav'
   /zcompressed.

* Housekeeping. 
erase file = !file + 'maternity_temp.zsav'.
erase file = !file + 'maternity_temp2.zsav'.


*erase file = !file + 'maternity_temp3.sav'.






