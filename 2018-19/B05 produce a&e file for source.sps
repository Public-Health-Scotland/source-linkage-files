* Encoding: UTF-8.
* Create A&E costed extract in suitable format for PLICS.
* Modified version of previous read in files used to create A&E data for PLICS. 

* Read in the a&e extract.  Rename/reformat/recode columns as appropriate. 

* Program by Denise Hastie, June 2016.
* Updated by Denise Hastie, July 2016 (to add in age at mid-point of financial year).

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA  /TYPE=TXT
   /FILE= !Extracts + 'A&E-episode-level-extract-20' + !FY + '.csv'
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      ArrivalDate A10
      PatCHINumberC A10
      PatDateOfBirthC A10
      PatGenderCode F1.0
      TreatmentNHSBoardCodeasatdateofepisode A1
      TreatmentLocationCode A7
      GPPracticeCode A5
      CouncilAreaCode A2
      PostcodeepiC A8
      PostcodeCHIC A8
      HSCPCode A9
      ArrivalTime Time5
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

rename variables
    PatCHINumberC = chi
    PatGenderCode = gender
    CouncilAreaCode = lca
    HSCPCode = HSCP2016
    TreatmentLocationCode = location
    GPPracticeCode = gpprac
    ArrivalTime = ae_arrivaltime
    ArrivalModeCode = ae_arrivalmode
    ReferralSourceCode = refsource
    AttendanceCategoryCode = ae_attendcat
    DischargeDestinationCode = ae_disdest
    PatientFlowCode = ae_patflow
    PlaceofIncidentCode = ae_placeinc
    ReasonforWaitCode = ae_reasonwait
    BodilyLocationOfInjuryCode = ae_bodyloc
    AlcoholInvolvedCode = ae_alcohol
    AlcoholRelatedAdmission = alcohol_adm
    SubstanceMisuseRelatedAdmission = submis_adm
    FallsRelatedAdmission = falls_adm
    SelfHarmRelatedAdmission = selfharm_adm
    TotalNetCosts = cost_total_net
    AgeatMidpointofFinancialYear = age.

string year (a4) recid (a3).
compute year = !FY.
compute recid = 'AE2'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

Rename Variables (ArrivalDate PatDateofBirthC = record_keydate1 dob).
alter type record_keydate1 dob (SDate10).
Compute record_keydate2 = record_keydate1.
alter type record_keydate1 record_keydate2 dob (Date12).

String hbtreatcode (a9).
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

* POSTCODE = need to make this length 7!  use the CHI postcode and if that is blank, then use the epi postcode.
String Postcode (A7).
Compute Postcode = Replace(PostcodeCHIC, " ", "").
If Postcode = "" Postcode = Replace(PostcodeepiC, " ", "").
If Length(Postcode) < 7 Postcode = Concat(char.substr(Postcode, 1, 3), " ", char.substr(Postcode, 4, 3)).

save outfile = !file + 'aande_temp.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob gpprac postcode lca HSCP2016 location hbtreatcode
      ae_arrivaltime ae_arrivalmode refsource ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol
      alcohol_adm submis_adm falls_adm selfharm_adm cost_total_net age
   /zcompressed.

* Create a file with costs by month.
get file = !file + 'aande_temp.zsav'.

compute month = xdate.Month(record_keydate1).

numeric costmonthnum (F2.0).
Do If (month eq 4).
   Compute costmonthnum = 1.
Else If (month eq 5).
   Compute costmonthnum = 2.
Else If (month eq 6).
   Compute costmonthnum = 3.
Else If (month eq 7).
   Compute costmonthnum = 4.
Else If (month eq 8).
   Compute costmonthnum = 5.
Else If (month eq 9).
   Compute costmonthnum = 6.
Else If (month eq 10).
   Compute costmonthnum = 7.
Else If (month eq 11).
   Compute costmonthnum = 8.
Else If (month eq 12).
   Compute costmonthnum = 9.
Else If (month eq 1).
   Compute costmonthnum = 10.
Else If (month eq 2).
   Compute costmonthnum = 11.
Else If (month eq 3).
   Compute costmonthnum = 12.
End If.

do repeat x = col1 to col12
   /y = 1 to 12.
   compute x = 0.
   if (y = costmonthnum) x = cost_total_net.
end repeat.

rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 = 
                  apr_cost may_cost jun_cost jul_cost aug_cost sep_cost 
                  oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).

 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

* Change arrival time to a time var and rename.
Numeric keyTime1 keyTime2 (Time5).
Compute keyTime1 = ae_arrivaltime.
Compute keyTime2 = $sysmis.

sort cases by chi record_keydate1 keyTime1.

save outfile = !file + 'aande_for_source-20' + !FY + '.zsav'
   /keep year recid record_keydate1 record_keydate2 keyTime1 keyTime2 chi gender dob gpprac postcode lca HSCP2016 location hbtreatcode
      ae_arrivalmode refsource ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol
      alcohol_adm submis_adm falls_adm selfharm_adm cost_total_net age
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost
      oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
   /zcompressed.

get file = !file + 'aande_for_source-20' + !FY + '.zsav'.

* Housekeeping. 
erase file = !file + 'aande_temp.zsav'.

 * Zip up raw data.
Host Command = ["zip -m '" + !Extracts + "A&E-episode-level-extract-20" + !FY + ".zip' '" +
   !Extracts + "A&E-episode-level-extract-20" + !FY + ".csv'"].





