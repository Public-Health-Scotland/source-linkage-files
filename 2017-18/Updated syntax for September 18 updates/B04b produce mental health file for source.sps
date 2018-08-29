* Encoding: UTF-8.
* Create mental health costed extract in suitable format for PLICS.

* Read in the mental health extract.  Rename/reformat/recode columns as appropriate. 

* Program by Denise Hastie, June 2016.

********************************************************************************************************.
 * Run 01-Set up Macros first!.

********************************************************************************************************.

* Read in CSV output file.
GET DATA  /TYPE=TXT
   /FILE= !Extracts + 'Mental-Health-episode-level-extract-20' + !FY + '.csv'
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      CostsFinancialYear04 A4
      CostsFinancialMonthName04 A9
      DateofAdmission04 A10
      DateofDischarge04 A10
      PatUPI A10
      PatGenderCode F1.0
      PatDateOfBirthC A10
      PracticeLocationCode A5
      PracticeNHSBoardCode A9
      GeoPostcodeC A7
      NHSBoardofResidenceCode A9
      GeoCouncilAreaCode A2
      HSCPCode A9
      GeoDataZone2011 A9
      TreatmentLocationCode A7
      TreatmentNHSBoardCode A9
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
      StatusonAdmissionCode F1.0
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

* Having issues trying to get this column to output from Business Objects.  So just creating a dummy variable just now.  
* Note the the Occupied bed days, renamed in the next section to yearstay is the LOS variable that is used for analysis with 
* the PLICs file as this is the number of bed days that have been costed within the financial year. 
numeric lengthofstay (f7.0).

* SMR04 specific variables need to be added in here. 
rename variables
    PatUPI = chi
    UniqueRecordIdentifier = uri
    PatGenderCode = gender
    PracticeLocationCode = gpprac
    PracticeNHSBoardCode = hbpraccode
    GeoPostcodeC = postcode
    NHSBoardofResidenceCode = hbrescode
    GeoCouncilAreaCode = lca
    HSCPCode = HSCP2016
    GeoDatazone2011 = DataZone2011
    TreatmentLocationCode = location
    TreatmentNHSBoardCode = hbtreatcode
    OccupiedBedDays04 = yearstay
    SpecialtyClassificat.1497Code = spec
    SignificantFacilityCode = sigfac
    LeadConsultantHCPCode = conc
    ManagementofPatientCode = mpat
    PatientCategoryCode = cat
    AdmissionTypeCode = tadm
    AdmittedTransFromCode = adtf
    LocationAdmittedTransFromCode = admloc
    DischargeTypeCode = disch
    DischargeTransToCode = dischto
    LocationDischargedTransToCode = dischloc
    Diagnosis1Code6char = diag1
    Diagnosis2Code6char = diag2
    Diagnosis3Code6char = diag3
    Diagnosis4Code6char = diag4
    Diagnosis5Code6char = diag5
    Diagnosis6Code6char = diag6
    ContinuousInpatientJourneyMarker04 = cis_marker
    CIJTypeofAdmissionCode04 = newcis_admtype
    CIJAdmissionSpecialtyCode04 = CIJadm_spec
    CIJDischargeSpecialtyCode04 = CIJdis_spec
    AlcoholRelatedAdmission04 = alcohol_adm
    SubstanceMisuseRelatedAdmission04 = submis_adm
    FallsRelatedAdmission04 = falls_adm
    SelfHarmRelatedAdmission04 = selfharm_adm
    TotalDirectCosts04 = cost_direct_net
    TotalAllocatedCosts04 = cost_allocated_net
    TotalNetCosts04 = cost_total_net
    NHSHospitalFlag04 = nhshosp
    CommunityHospitalFlag04 = commhosp
    AgeatMidpointofFinancialYear04 = age
    CostsFinancialYear04 = costsfy
    CostsFinancialMonthName04 = costsfmth
    CIJPlannedAdmissionCode04 = newpattype_ciscode
    StatusonAdmissionCode = stadm
    AdmissionDiagnosis1Code6char = adcon1
    AdmissionDiagnosis2Code6char = adcon2
    AdmissionDiagnosis3Code6char = adcon3
    AdmissionDiagnosis4Code6char = adcon4.


string year (a4) recid (a3) ipdc (a1) newcis_ipdc (a1) newpattype_cis (a13).
compute year = !FY.
compute recid = '04B'.
compute ipdc = 'I'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

if (CIJInpatientDayCaseIdentifierCode04 EQ 'MH') newcis_ipdc = 'I'.

Do if (newpattype_ciscode EQ 2).
   Compute newpattype_cis = 'Maternity'.
Else if (newpattype_ciscode EQ 0).
   Compute newpattype_cis = 'Non-elective'.
Else if (newpattype_ciscode EQ 1).
   Compute newpattype_cis = 'Elective'.
End if.


Rename Variables (DateofAdmission04 DateofDischarge04 PatDateOfBirthC
   = record_keydate1 record_keydate2 dob).

alter type record_keydate1 record_keydate2 dob (SDate10).
alter type record_keydate1 record_keydate2 dob (Date12).

* Need to make CIJ Type of Admission (newcis_admtype) two characters in length (to be consistent with acute).  Recode the Unknown to 99.

Recode newcis_admtype ('Unknown' = '99').
alter type newcis_admtype (A2).

sort cases by uri.

* need to add in SMR04 specific variables in to here. 
save outfile = !file + 'mh_temp.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      cost_direct_net cost_allocated_net cost_total_net costsfy costsfmth stadm adcon1 adcon2 adcon3 adcon4 uri
   /zcompressed.
  

* Create a file that contains uri and costsfmth and net cost.  Make this look like a 'crosstab' ready for matching back to the acute_temp file. 

get file = !file + 'mh_temp.zsav'
   /keep uri cost_total_net costsfmth.

Numeric costmonthnum (F2.0).
Do If (costsfmth EQ 'APRIL').
   Compute costmonthnum = 1.
Else If (costsfmth EQ 'MAY').
   Compute costmonthnum = 2.
Else If (costsfmth EQ 'JUNE').
   Compute costmonthnum = 3.
Else If (costsfmth EQ 'JULY').
   Compute costmonthnum = 4.
Else If (costsfmth EQ 'AUGUST').
   Compute costmonthnum = 5.
Else If (costsfmth EQ 'SEPTEMBER').
   Compute costmonthnum = 6.
Else If (costsfmth EQ 'OCTOBER').
   Compute costmonthnum = 7.
Else If (costsfmth EQ 'NOVEMBER').
   Compute costmonthnum = 8.
Else If (costsfmth EQ 'DECEMBER').
   Compute costmonthnum = 9.
Else If (costsfmth EQ 'JANUARY').
   Compute costmonthnum = 10.
Else If (costsfmth EQ 'FEBRUARY').
   Compute costmonthnum = 11.
Else If (costsfmth EQ 'MARCH').
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

aggregate outfile = !file + 'mh_monthly_costs_by_uri.sav'
   /Presorted
   /break uri
   /apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
      sum(apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).
   

* Create a file that contains uri and costsfmth and yearstay.  Make this look like a 'crosstab' ready for matching back to the acute_temp file.

get file = !file + 'mh_temp.zsav'
   /keep uri yearstay costsfmth.

numeric costmonthnum (F2.0).
Do If (costsfmth EQ 'APRIL').
   Compute costmonthnum = 1.
Else If (costsfmth EQ 'MAY').
   Compute costmonthnum = 2.
Else If (costsfmth EQ 'JUNE').
   Compute costmonthnum = 3.
Else If (costsfmth EQ 'JULY').
   Compute costmonthnum = 4.
Else If (costsfmth EQ 'AUGUST').
   Compute costmonthnum = 5.
Else If (costsfmth EQ 'SEPTEMBER').
   Compute costmonthnum = 6.
Else If (costsfmth EQ 'OCTOBER').
   Compute costmonthnum = 7.
Else If (costsfmth EQ 'NOVEMBER').
   Compute costmonthnum = 8.
Else If (costsfmth EQ 'DECEMBER').
   Compute costmonthnum = 9.
Else If (costsfmth EQ 'JANUARY').
   Compute costmonthnum = 10.
Else If (costsfmth EQ 'FEBRUARY').
   Compute costmonthnum = 11.
Else If (costsfmth EQ 'MARCH').
   Compute costmonthnum = 12.
End If.


do repeat x = col1 to col12
   /y = 1 to 12.
   compute x = 0.
   if (y = costmonthnum) x = yearstay.
end repeat.

rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 =
   apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays
   oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).

aggregate outfile = !file + 'mh_monthly_beddays_by_uri.sav'
   /break uri
   /apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays =
      sum(apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).
   

* Match both these files back to the main acute file and then create totals adding across the months for each of the costs 
 and yearstay variables.  
* Need to reduce each uri to one row only.  All columns will have the same information except for the costs month variable.

match files file = !file + 'mh_temp.zsav'
   /table = !file + 'mh_monthly_beddays_by_uri.sav'
   /table = !file + 'mh_monthly_costs_by_uri.sav'
   /by uri.
execute.

aggregate outfile = *
   /break uri
   /year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      stadm adcon1 adcon2 adcon3 adcon4
      apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
      first(year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      stadm adcon1 adcon2 adcon3 adcon4
      apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).

Numeric stay (F7.0).
Compute stay = Datediff(record_keydate2, record_keydate1, "days").

compute yearstay = apr_beddays + may_beddays + jun_beddays + jul_beddays + aug_beddays + sep_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
compute cost_total_net = apr_cost + may_cost + jun_cost + jul_cost + aug_cost + sep_cost + oct_cost + nov_cost + dec_cost + jan_cost + feb_cost + mar_cost.

match files file = *
   /table = !file + 'mh_los_by_uri.zsav'
   /by uri.
execute.

 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

sort cases by chi record_keydate1.

save outfile = !file + 'mental_health_for_source-20' + !FY + '.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      stay yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      cost_total_net
      stadm adcon1 adcon2 adcon3 adcon4
      apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost uri
   /zcompressed.


get file = !file + 'mental_health_for_source-20' + !FY + '.zsav'.

* Housekeeping.
erase file = !file + 'mh_temp.zsav'.
erase file = !file + 'mh_los_by_uri.zsav'.
erase file = !file + 'mh_monthly_beddays_by_uri.sav'.
erase file = !file + 'mh_monthly_costs_by_uri.sav'.

Host Command = ["zip -m '" + !Extracts + "Mental-Health-LoS-by-URI-extract-20" + !FY + ".zip' '" +
   !Extracts + "Mental-Health-LoS-by-URI-extract-20" + !FY + ".csv'"].
Host Command = ["zip -m '" + !Extracts + "Mental-Health-episode-level-extract-20" + !FY + ".zip' '" +
   !Extracts + "Mental-Health-episode-level-extract-20" + !FY + ".csv'"].





