* Create A&E costed extract in suitable format for PLICS.
* Modified version of previous read in files used to create A&E data for PLICS. 

* Read in the a&e extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, June 2016.
* Updated by Denise Hastie, July 2016 (to add in age at mid-point of financial year).

* Create macros for file path.


******************************* **** UPDATE THIS BIT **** *************************************.
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

save outfile = !file + 'aande_temp.zsav'
   /zcompressed.

get file = !file + 'aande_temp.zsav'.

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


string record_keydate1 record_keydate2 dob (a8).
compute record_keydate1 = concat(substr(ArrivalDate,1,4),substr(ArrivalDate,6,2),substr(ArrivalDate,9,2)).
compute record_keydate2 = concat(substr(ArrivalDate,1,4),substr(ArrivalDate,6,2),substr(ArrivalDate,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).


alter type record_keydate1 record_keydate2 dob (f8.0).

string hbtreatcode (a9).
Do If (TreatmentNHSBoardCodeasatdateofepisode eq 'A').
   Compute hbtreatcode = 'S08000015'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'B').
   Compute hbtreatcode = 'S08000016'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'Y').
   Compute hbtreatcode = 'S08000017'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'F').
   Compute hbtreatcode = 'S08000029'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'V').
   Compute hbtreatcode = 'S08000019'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'N').
   Compute hbtreatcode = 'S08000020'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'G').
   Compute hbtreatcode = 'S08000021'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'H').
   Compute hbtreatcode = 'S08000022'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'L').
   Compute hbtreatcode = 'S08000023'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'S').
   Compute hbtreatcode = 'S08000024'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'R').
   Compute hbtreatcode = 'S08000025'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'Z').
   Compute hbtreatcode = 'S08000026'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'T').
   Compute hbtreatcode = 'S08000030'.
Else If (TreatmentNHSBoardCodeasatdateofepisode eq 'W').
   Compute hbtreatcode = 'S08000028'.
End If.

string hbrescode (a9).
Do If (NHSBoardofResidenceCodeasatdateofepisode eq 'A').
   Compute hbrescode = 'S08000015'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'B').
   Compute hbrescode = 'S08000016'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'Y').
   Compute hbrescode = 'S08000017'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'F').
   Compute hbrescode = 'S08000029'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'V').
   Compute hbrescode = 'S08000019'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'N').
   Compute hbrescode = 'S08000020'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'G').
   Compute hbrescode = 'S08000021'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'H').
   Compute hbrescode = 'S08000022'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'L').
   Compute hbrescode = 'S08000023'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'S').
   Compute hbrescode = 'S08000024'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'R').
   Compute hbrescode = 'S08000025'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'Z').
   Compute hbrescode = 'S08000026'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'T').
   Compute hbrescode = 'S08000030'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'W').
   Compute hbrescode = 'S08000028'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'E').
   Compute hbrescode = 'S08200001'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'Q').
   Compute hbrescode = 'S08200002'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'U').
   Compute hbrescode = 'S08200003'.
Else If (NHSBoardofResidenceCodeasatdateofepisode eq 'O').
   Compute hbrescode = 'S08200004'.
End If.



* These are correct as of May 2018 JMc.
string hbpraccode (a9).
Do If (prac GE '80005' AND prac LE '83997').
   Compute hbpraccode = 'S08000015'.
Else If (prac GE '16009' AND prac LE '17995').
   Compute hbpraccode = 'S08000016'.
Else If (prac GE '18004' AND prac LE '19991').
   Compute hbpraccode = 'S08000017'.
Else If (prac GE '20004' AND prac LE '24999').
   Compute hbpraccode = 'S08000029'.
Else If (prac GE '25008' AND prac LE '29992').
   Compute hbpraccode = 'S08000019'.
Else If (prac GE '30006' AND prac LE '37999').
   Compute hbpraccode = 'S08000020'.
Else if ((prac GE '40008' AND prac LE '54994') OR (prac EQ 	'84990') OR (prac GE '86000' AND prac LE '86999') OR (prac GE '87000' AND prac LE '87999')
   OR ((prac GE '85000' AND prac LE '85999') AND  ((prac NE '85009') AND (prac NE '85117') AND (prac NE '85141') AND (prac NE '85155') AND (prac NE '85193')))).
   Compute hbpraccode = 'S08000021'.
Else if ((prac GE '55003' AND prac LE '59998') OR (prac GE '84000' AND prac LE '84989') OR (prac EQ '85009') OR (prac EQ '85117') OR (prac EQ '85141') OR (prac EQ '85155') OR (prac EQ '85193')).
   Compute hbpraccode = 'S08000022'.
Else If (prac GE '60001' AND prac LE '65999').
   Compute hbpraccode = 'S08000023'.
Else If (prac GE '70003' AND prac LE '79991').
   Compute hbpraccode = 'S08000024'.
Else If (prac GE '38008' AND prac LE '38991').
   Compute hbpraccode = 'S08000025'.
Else If (prac GE '39001' AND prac LE '39994').
   Compute hbpraccode = 'S08000026'.
Else If (prac GE '10002' AND prac LE '15990').
   Compute hbpraccode = 'S08000030'.
Else If (prac GE '90007' AND prac LE '90991').
   Compute hbpraccode = 'S08000028'.
End If.

alter type prac (a6).

* Set hbpraccode for GP Practice codes that begin 999 as unknown health board.
if (substr(prac,1,3) eq '999') hbpraccode = 'S08200003'.

* Set hbpraccode for GP Practice codes that are blank as unknown health board.
if (prac eq '') hbpraccode = 'S08200003'.

* POSTCODE = need to make this length 7!  use the CHI postcode - this is what was used in previous years. 
rename variables (PostcodeCHIC = pc_chi).

string pc7 (a7).
do if (substr(pc_chi,5,1) eq '').
   compute pc7 = concat(substr(pc_chi,1,4),substr(pc_chi,6,3)).
else.
   compute pc7 = substr(pc_chi,1,8).
end if.


save outfile = !file + 'aande_temp2.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
      ae_arrivaltime ae_arrivalmode ae_refsource ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol
      alcohol_adm submis_adm falls_adm selfharm_adm cost_total_net age
   /zcompressed.

* Create a file with costs by month.
get file = !file + 'aande_temp2.zsav'.

alter type record_keydate1 (a8).
string month (a2).
compute month = substr(record_keydate1,5,2).

alter type record_keydate1 (f8.0).

numeric costmonthnum (f2.0).
Do If (month eq '04').
   Compute costmonthnum = 1.
Else If (month eq '05').
   Compute costmonthnum = 2.
Else If (month eq '06').
   Compute costmonthnum = 3.
Else If (month eq '07').
   Compute costmonthnum = 4.
Else If (month eq '08').
   Compute costmonthnum = 5.
Else If (month eq '09').
   Compute costmonthnum = 6.
Else If (month eq '10').
   Compute costmonthnum = 7.
Else If (month eq '11').
   Compute costmonthnum = 8.
Else If (month eq '12').
   Compute costmonthnum = 9.
Else If (month eq '01').
   Compute costmonthnum = 10.
Else If (month eq '02').
   Compute costmonthnum = 11.
Else If (month eq '03').
   Compute costmonthnum = 12.
End If.

do repeat x = col1 to col12
   /y = 1 to 12.
   compute x = 0.
   if (y=costmonthnum) x = cost_total_net.
end repeat.

rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 = 
                  april_cost may_cost june_cost july_cost august_cost sept_cost 
                  oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).


* Final amendments.
alter type prac (a5).

* Sort formatting of postcodes with only 5 characters.
string pc7_2 (a7).
If ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')) pc7_2 = concat(substr(pc7,1,2),"  ",substr(pc7,4,3)).

If ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')) pc7 = pc7_2.


save outfile = !file + 'aande_for_source-20'+!FY+'.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob prac hbpraccode pc7 hbrescode lca chp datazone location hbtreatcode
      ae_arrivaltime ae_arrivalmode ae_refsource ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol
      alcohol_adm submis_adm falls_adm selfharm_adm cost_total_net age
      april_cost may_cost june_cost july_cost august_cost sept_cost
      oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
   /zcompressed.


* Housekeeping. 
erase file = !file + 'aande_temp.zsav'.
erase file = !file + 'aande_temp2.zsav'.






