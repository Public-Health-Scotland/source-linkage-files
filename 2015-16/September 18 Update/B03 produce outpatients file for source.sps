* Encoding: UTF-8.
* Create Outpatients costed extract in suitable format for PLICS.

* Read in the outpatients extract.  Rename/reformat/recode columns as appropriate. 

* Program by Denise Hastie, June 2016.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in CSV output file.
GET DATA  /TYPE=TXT
   /FILE= !Extracts + 'Outpatients-episode-level-extract-20' + !FY + '.csv'
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      ClinicDateFinYear A4
      ClinicDate00 A10
      SendingLocationCodeSMR00 A5
      EpisodeRecordKeySMR00C A11
      PatUPI A10
      PatGenderCode F1.0
      PatDateOfBirthC A10
      PracticeLocationCode A5
      PracticeNHSBoardCode A9
      GeoPostcodeC A7
      NHSBoardofResidenceCode A9
      GeoCouncilAreaCode A2
      TreatmentLocationCode A7
      TreatmentNHSBoardCode A9
      SpecialtyClassificat.1497Code A3
      SignificantFacilityCode A2
      ConsultantHCPCode A8
      PatientCategoryCode A1
      ReferralSourceCode A3
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

* Datazone for outpatients is not Datazone 2011. Consultant code does not have Lead in front of it. 
rename variables
    PatUPI = chi
    PatGenderCode = gender
    PracticeLocationCode = gpprac
    PracticeNHSBoardCode = hbpraccode
    GeoPostcodeC = postcode
    NHSBoardofResidenceCode = hbrescode
    GeoCouncilAreaCode = lca
    TreatmentLocationCode = location
    TreatmentNHSBoardCode = hbtreatcode
    SpecialtyClassificat.1497Code = spec
    SignificantFacilityCode = sigfac
    ConsultantHCPCode = conc
    PatientCategoryCode = cat
    ReferralSourceCode = refsource
    ReferralTypeCode = reftype
    ClinicTypeCode = clinic_type
    ClinicAttendanceStatusCode = attendance_status
    AlcoholRelatedAdmission = alcohol_adm
    SubstanceMisuseRelatedAdmission = submis_adm
    FallsRelatedAdmission = falls_adm
    SelfHarmRelatedAdmission = selfharm_adm
    TotalNetCosts = cost_total_net
    NHSHospitalFlag = nhshosp
    CommunityHospitalFlag = commhosp
    AgeatMidpointofFinancialYear = age
    SendingLocationCodeSMR00 = sendloc
    EpisodeRecordKeySMR00C = erk.

string year (a4) recid (a3).
compute year = !FY.
compute recid = '00B'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

Rename Variables
    ClinicDate00 = record_keydate1
    PatDateofBirthC = dob.

alter type record_keydate1 dob (SDate10).
Compute record_keydate2 = record_keydate1.
alter type record_keydate1 record_keydate2 dob (Date12).

string unique_id (a16).
compute unique_id = concat(sendloc, erk).

sort cases by unique_id.

save outfile = !file + 'op_temp.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca location hbtreatcode
      spec sigfac conc cat age refsource reftype attendance_status clinic_type alcohol_adm submis_adm falls_adm selfharm_adm commhosp nhshosp
      cost_total_net unique_id
   /zcompressed.
  
* Create a file that contains uri and costsfmth and net cost.  Make this look like a 'cross-tab' ready for matching back to the acute_temp file. 

get file = !file + 'op_temp.zsav'
   /keep unique_id cost_total_net record_keydate1.

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


save outfile = !file + 'op_monthly_costs_by_unique_id.zsav'
   /zcompressed.

* Match this file back to the main op file..  

match files file = !file + 'op_temp.zsav'
   /table = !file + 'op_monthly_costs_by_unique_id.zsav'
   /by unique_id.
execute.

 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

sort cases by chi record_keydate1.

save outfile = !file + 'outpatients_for_source-20'+!FY+'.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca location hbtreatcode
      spec sigfac conc cat age refsource reftype attendance_status clinic_type alcohol_adm submis_adm falls_adm selfharm_adm commhosp nhshosp
      cost_total_net unique_id
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
   /zcompressed.

get file = !file + 'outpatients_for_source-20'+!FY+'.zsav'.

* Housekeeping. 
erase file = !file + 'op_temp.zsav'.
erase file = !file + 'op_monthly_costs_by_unique_id.zsav'.

 * zip up the raw data.
Host Command = ["zip -m '" + !Extracts + "Outpatients-episode-level-extract-20" + !FY + ".zip' '" +
   !Extracts + "Outpatients-episode-level-extract-20" + !FY + ".csv'"].
