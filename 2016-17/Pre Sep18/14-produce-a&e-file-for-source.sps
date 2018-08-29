* Create A&E costed extract in suitable format for PLICS.
* Modified version of previous read in files used to create A&E data for PLICS. 

* Read in the a&e extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, June 2016.
* Updated by Denise Hastie, July 2016 (to add in age at mid-point of financial year).

* Create macros for file path.


******************************* **** UPDATE THIS BIT **** *************************************.
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

GET DATA  /TYPE=TXT
  /FILE= !file + 'a & e all scotland episode level extract for source file production 20' +!FY +'.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  DataMonth A8
  ArrivalFinancialMonthName A9
  ArrivalDate A19
  PatCHINumberC A10
  PatDateOfBirthC A19
  PatGenderCode F1.0
  TreatmentNHSBoardCodeasatdateofepisode A1
  TreatmentLocationCode A5
  GPPracticeCode A5
  NHSBoardofResidenceCodeasatdateofepisode A1
  DataZone A9
  CouncilAreaCode A2
  PostcodeepiC A8
  PostcodeCHIC A8
  CHPCode A9
  ArrivalTime A5
  ArrivalModeCode A2
  ReferralSourceCode A3
  AttendanceCategoryCode A2
  DischargeDestinationCode A3
  PatientFlowCode A1
  PlaceofIncidentCode A3
  ReasonforWaitCode A3
  BodilyLocationOfInjuryCode A3
  AlcoholInvolvedCode A2
  AlcoholRelatedAdmission A1
  SubstanceMisuseRelatedAdmission A1
  FallsRelatedAdmission A1
  SelfHarmRelatedAdmission A1
  TotalNetCosts F8.2
  AgeatMidpointofFinancialYear F3.0.
CACHE.
EXECUTE.
DATASET NAME WINDOW=FRONT.

save outfile = !file + 'aande_temp.sav'.

get file = !file + 'aande_temp.sav'.

rename variables (PatCHINumberC PatGenderCode CouncilAreaCode CHPCode TreatmentLocationCode DataZone GPPracticeCode
                  ArrivalTime ArrivalModeCode ReferralSourceCode AttendanceCategoryCode DischargeDestinationCode
                  PatientFlowCode PlaceofIncidentCode ReasonforWaitCode BodilyLocationOfInjuryCode AlcoholInvolvedCode
                  AlcoholRelatedAdmission SubstanceMisuseRelatedAdmission FallsRelatedAdmission SelfHarmRelatedAdmission
                  TotalNetCosts AgeatMidpointofFinancialYear
                = chi gender lca chp location datazone prac
                  ae_arrivaltime ae_arrivalmode ae_refsource ae_attendcat ae_disdest
                  ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol
                  alcohol_adm submis_adm falls_adm selfharm_adm
                  cost_total_net age).

string year (a4) recid (a3).
compute year = !FY.
compute recid = 'AE2'.
execute.

string record_keydate1 record_keydate2 dob (a8).
compute record_keydate1 = concat(substr(ArrivalDate,1,4),substr(ArrivalDate,6,2),substr(ArrivalDate,9,2)).
compute record_keydate2 = concat(substr(ArrivalDate,1,4),substr(ArrivalDate,6,2),substr(ArrivalDate,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
execute.

alter type record_keydate1 record_keydate2 dob (f8.0).

string hbtreatcode (a9).
if (TreatmentNHSBoardCodeasatdateofepisode eq 'A') hbtreatcode = 'S08000015'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'B') hbtreatcode = 'S08000016'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'Y') hbtreatcode = 'S08000017'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'F') hbtreatcode = 'S08000018'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'V') hbtreatcode = 'S08000019'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'N') hbtreatcode = 'S08000020'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'G') hbtreatcode = 'S08000021'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'H') hbtreatcode = 'S08000022'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'L') hbtreatcode = 'S08000023'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'S') hbtreatcode = 'S08000024'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'R') hbtreatcode = 'S08000025'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'Z') hbtreatcode = 'S08000026'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'T') hbtreatcode = 'S08000027'.
if (TreatmentNHSBoardCodeasatdateofepisode eq 'W') hbtreatcode = 'S08000028'.
execute.

string hbrescode (a9).
if (NHSBoardofResidenceCodeasatdateofepisode eq 'A') hbrescode = 'S08000015'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'B') hbrescode = 'S08000016'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'Y') hbrescode = 'S08000017'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'F') hbrescode = 'S08000018'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'V') hbrescode = 'S08000019'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'N') hbrescode = 'S08000020'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'G') hbrescode = 'S08000021'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'H') hbrescode = 'S08000022'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'L') hbrescode = 'S08000023'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'S') hbrescode = 'S08000024'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'R') hbrescode = 'S08000025'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'Z') hbrescode = 'S08000026'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'T') hbrescode = 'S08000027'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'W') hbrescode = 'S08000028'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'E') hbrescode = 'S08200001'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'Q') hbrescode = 'S08200002'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'U') hbrescode = 'S08200003'.
if (NHSBoardofResidenceCodeasatdateofepisode eq 'O') hbrescode = 'S08200004'.
execute. 


* Are all these codes still correct??  DH June 2016.
string hbpraccode (a9).
if (prac ge '80005' and prac le '83997') hbpraccode = 'S08000015'.
if (prac ge '16009' and prac le '17995') hbpraccode = 'S08000016'.
if (prac ge '18004' and prac le '19991') hbpraccode = 'S08000017'.
if (prac ge '20004' and prac le '24999') hbpraccode = 'S08000018'.
if (prac ge '25008' and prac le '29992') hbpraccode = 'S08000019'.
if (prac ge '30006' and prac le '37999') hbpraccode = 'S08000020'.
do if ((prac ge '40008' and prac le '54994') or (prac eq 	'84990') or (prac ge '86000' and prac le '86999') or (prac ge '87000' and prac le '87999')
         or ((prac ge '85000' and prac le '85999') and  ((prac ne '85009') and (prac ne '85117') and (prac ne '85141') and (prac ne '85155') and (prac ne	'85193')))).
compute hbpraccode = 'S08000021'.
else.
end if.
execute.
do if ((prac ge '55003' and prac le '59998') or (prac ge '84000' and prac le '84989') or (prac eq	'85009') or (prac eq '85117') or (prac eq	'85141') or (prac eq '85155') or (prac eq	'85193')).
compute hbpraccode = 'S08000022'.
else.
end if.
execute.

if (prac ge '60001' and prac le '65999') hbpraccode = 'S08000023'.
if (prac ge '70003' and prac le '79991') hbpraccode = 'S08000024'.
if (prac ge '38008' and prac le '38991') hbpraccode = 'S08000025'.
if (prac ge '39001' and prac le '39994') hbpraccode = 'S08000026'.
if (prac ge '10002' and prac le '15990') hbpraccode = 'S08000027'.
if (prac ge '90007' and prac le '90991') hbpraccode = 'S08000028'.
frequency variables = hbpraccode.
alter type prac (a6).

temporary.
select if hbpraccode = ''.
frequency variables = prac.

* Set hbpraccode for GP Practice codes that begin 999 as unknown health board.

if (substr(prac,1,3) eq '999') hbpraccode = 'S08200003'.
execute.

* Set hbpraccode for GP Practice codes that are blank as unknown health board.

if (prac eq '') hbpraccode = 'S08200003'.
execute.


* POSTCODE = need to make this length 7!  use the CHI postcode - this is what was used in previous years. 

delete variables PostcodeepiC.
rename variables (PostcodeCHIC = pc_chi).

string pc7 (a7).
do if (substr(pc_chi,5,1) eq '').
compute pc7 = concat(substr(pc_chi,1,4),substr(pc_chi,6,3)).
else.
compute pc7 = substr(pc_chi,1,8).
end if. 
execute.

save outfile = !file + 'aande_temp2.sav' 
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode 
       ae_arrivaltime ae_arrivalmode ae_refsource ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol
       alcohol_adm submis_adm falls_adm selfharm_adm cost_total_net age.

* Create a file with costs by month.
get file = !file + 'aande_temp2.sav'.

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


* Final amendments.
alter type prac (a5).

* Sort formatting of postcodes with only 5 characters. 
string pc7_2 (a7).
do if ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')).
compute pc7_2 = concat(substr(pc7,1,2),"  ",substr(pc7,4,3)).
end if. 
execute.
do if ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')).
compute pc7 = pc7_2.
end if. 
execute.


save outfile = !file + 'aande_for_source-20'+!FY+'.sav' 
 /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode 
       ae_arrivaltime ae_arrivalmode ae_refsource ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol
       alcohol_adm submis_adm falls_adm selfharm_adm cost_total_net age
       april_cost may_cost june_cost july_cost august_cost sept_cost 
       oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
 /compressed.

get file = !file + 'aande_for_source-20'+!FY+'.sav'.

* Housekeeping. 
erase file = !file + 'aande_temp.sav'.
erase file = !file + 'aande_temp2.sav'.






