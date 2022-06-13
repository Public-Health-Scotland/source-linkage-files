* Encoding: UTF-8.

********************************************************************************************************.
 * Run 01-Set up Macros first!.

********************************************************************************************************.

* Read in CSV output file.
GET DATA  /TYPE=TXT
   /FILE= !Year_Extracts_dir + 'Mental-Health-episode-level-extract-20' + !FY + '.csv'
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      CostsFinancialYear04 A4
      CostsFinancialMonthNumber04 F2.0
      DateofAdmission04 A10
      DateofDischarge04 A10
      PatUPI A10
      PatGenderCode F1.0
      PatDateOfBirthC A10
      PracticeLocationCode A5
      PracticeNHSBoardCode A9
      GeoPostcodeC A8
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
      ContinuousInpatientJourneyMarker04 F5.0
      CIJPlannedAdmissionCode04 F1.0
      CIJInpatientDayCaseIdentifierCode04 A2
      CIJTypeofAdmissionCode04 A7
      CIJAdmissionSpecialtyCode04 A3
      CIJDischargeSpecialtyCode04 A3
      CIJStartDate04 A10
      CIJEndDate04 A10
      TotalNetCosts04 F8.2
      AlcoholRelatedAdmission04 A1
      SubstanceMisuseRelatedAdmission04 A1
      FallsRelatedAdmission04 A1
      SelfHarmRelatedAdmission04 A1
      DuplicateRecordFlag04 A1
      NHSHospitalFlag04 A1
      CommunityHospitalFlag04 A1
      UniqueRecordIdentifier A11.
CACHE.
Execute.

* SMR04 specific variables need to be added in here.
rename variables
    AdmissionDiagnosis1Code6char = adcon1
    AdmissionDiagnosis2Code6char = adcon2
    AdmissionDiagnosis3Code6char = adcon3
    AdmissionDiagnosis4Code6char = adcon4
    AdmissionTypeCode = tadm
    AdmittedTransFromCode = adtf
    AgeatMidpointofFinancialYear04 = age
    AlcoholRelatedAdmission04 = alcohol_adm
    CIJAdmissionSpecialtyCode04 = cij_adm_spec
    CIJDischargeSpecialtyCode04 = cij_dis_spec
    CIJEndDate04 = CIJ_end_date
    CIJPlannedAdmissionCode04 = cij_pattype_code
    CIJStartDate04 = CIJ_start_date
    CIJTypeofAdmissionCode04 = cij_admtype
    CommunityHospitalFlag04 = commhosp
    ContinuousInpatientJourneyMarker04 = cij_marker
    CostsFinancialMonthNumber04 = costmonthnum
    CostsFinancialYear04 = costsfy
    Diagnosis1Code6char = diag1
    Diagnosis2Code6char = diag2
    Diagnosis3Code6char = diag3
    Diagnosis4Code6char = diag4
    Diagnosis5Code6char = diag5
    Diagnosis6Code6char = diag6
    DischargeTransToCode = dischto
    DischargeTypeCode = disch
    FallsRelatedAdmission04 = falls_adm
    GeoCouncilAreaCode = lca
    GeoDatazone2011 = DataZone
    GeoPostcodeC = postcode
    HSCPCode = HSCP
    LeadConsultantHCPCode = conc
    LocationAdmittedTransFromCode = admloc
    LocationDischargedTransToCode = dischloc
    ManagementofPatientCode = mpat
    NHSBoardofResidenceCode = hbrescode
    NHSHospitalFlag04 = nhshosp
    OccupiedBedDays04 = yearstay
    PatGenderCode = gender
    PatUPI = chi
    PatientCategoryCode = cat
    PracticeLocationCode = gpprac
    PracticeNHSBoardCode = hbpraccode
    SelfHarmRelatedAdmission04 = selfharm_adm
    SignificantFacilityCode = sigfac
    SpecialtyClassificat.1497Code = spec
    StatusonAdmissionCode = stadm
    SubstanceMisuseRelatedAdmission04 = submis_adm
    TotalNetCosts04 = cost_total_net
    TreatmentLocationCode = location
    TreatmentNHSBoardCode = hbtreatcode
    UniqueRecordIdentifier = uri.


string year (a4) recid (a3) ipdc (a1) cij_ipdc (a1) cij_pattype(a13).
compute year = !FY.
compute recid = '04B'.
compute ipdc = 'I'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if.
Alter Type GPprac (F5.0).

if (CIJInpatientDayCaseIdentifierCode04 EQ 'MH') cij_ipdc = 'I'.

 * Deal with date variables.
Rename Variables
    DateofAdmission04 = record_keydate1
    DateofDischarge04 = record_keydate2
    PatDateOfBirthC = dob.

alter type record_keydate1 record_keydate2 dob CIJ_start_date CIJ_end_date (SDate10).
alter type record_keydate1 record_keydate2 dob CIJ_start_date CIJ_end_date (Date12).

* Need to make CIJ Type of Admission (cij_admtype) two characters in length (to be consistent with acute).  Recode the Unknown to 99.

Recode cij_admtype ('Unknown' = '99').
alter type cij_admtype (A2).

sort cases by uri.

* need to add in SMR04 specific variables in to here.
save outfile = !Year_dir + 'mh_temp.zsav'
   /zcompressed.

* Create a file that contains uri and costs month and net cost. Make this look like a 'cross-tab' ready for matching back to the acute_temp file.
get file = !Year_dir + 'mh_temp.zsav'
   /keep uri cost_total_net yearstay costmonthnum.

 * Initialise the variables we'll need.
Numeric apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost (F8.2).
Numeric apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays (F8.2).

* Loop over the months by number.
 * Populate the cost and beddays variables for the correct month.
Do Repeat Month_num = 1 To 12
    /month_cost = apr_cost To mar_cost
    /month_beddays = apr_beddays To mar_beddays.

   Do if Month_num = costmonthnum.
        Compute month_cost = cost_total_net.
        Compute month_beddays = yearstay.
   Else.
        Compute month_cost = 0.
        Compute month_beddays = 0.
    End if.
End Repeat.

* Create a lookup file for each URI.
aggregate outfile = !Year_dir + 'MH_monthly_costs_and_beddays_by_uri.sav'
   /Presorted
   /break uri
   /apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
       Sum(apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost)
   /apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays =
       Sum(apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).


* Match this file back to the main acute file and then create totals adding across the months for each of the costs and yearstay variables.
* Need To reduce each uri to one row only. All columns will have the same information except for the costs month variable.
match files file = !Year_dir + 'mh_temp.zsav'
   /table = !Year_dir + 'MH_monthly_costs_and_beddays_by_uri.sav'
   /by uri.

 * This is just to remove duplicates.
add files file = *
    /By URI
    /First = Keep.

Select if Keep = 1.

compute yearstay = apr_beddays + may_beddays + jun_beddays + jul_beddays + aug_beddays + sep_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
compute cost_total_net = apr_cost + may_cost + jun_cost + jul_cost + aug_cost + sep_cost + oct_cost + nov_cost + dec_cost + jan_cost + feb_cost + mar_cost.

Numeric stay (F7.0).
 * Work out total length of stay.
 * Get the time before this FY, add it to yearstay (round to ignore the .33 for daycases) and then add on any days after this FY.
 * Note those without end dates are given 365 as yearstay so will get 365 days for this FY in stay too.
 * It's a bit complicated so that it can handle the episodes with no end date.
Compute stay = Max(datediff(!startFY, record_keydate1, "days"), 0) + Rnd(yearstay) + Max(datediff(record_keydate2, !endFY + time.days(1), "days"), 0).

 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

sort cases by chi record_keydate1.

 * Add MH specific labels.
Value Labels stadm
    '3' "Formal"
    '4' "Informal".

save outfile = !Year_dir + 'mental_health_for_source-20' + !FY + '.zsav'
    /keep year
    recid
    record_keydate1
    record_keydate2
    chi
    gender
    dob
    gpprac
    hbpraccode
    postcode
    hbrescode
    lca
    HSCP
    DataZone
    location
    hbtreatcode
    stay
    yearstay
    ipdc
    spec
    sigfac
    conc
    mpat
    cat
    tadm
    adtf
    admloc
    disch
    dischto
    dischloc
    diag1
    diag2
    diag3
    diag4
    diag5
    diag6
    age
    cij_marker
    cij_admtype
    cij_ipdc
    cij_pattype_code
    cij_adm_spec
    cij_dis_spec
    CIJ_start_date
    CIJ_end_date
    alcohol_adm
    submis_adm
    falls_adm
    selfharm_adm
    commhosp
    cost_total_net
    stadm
    adcon1
    adcon2
    adcon3
    adcon4
    apr_beddays
    may_beddays
    jun_beddays
    jul_beddays
    aug_beddays
    sep_beddays
    oct_beddays
    nov_beddays
    dec_beddays
    jan_beddays
    feb_beddays
    mar_beddays
    apr_cost
    may_cost
    jun_cost
    jul_cost
    aug_cost
    sep_cost
    oct_cost
    nov_cost
    dec_cost
    jan_cost
    feb_cost
    mar_cost
    uri
    /zcompressed.

get file = !Year_dir + 'mental_health_for_source-20' + !FY + '.zsav'.

* Housekeeping.
erase file = !Year_dir + 'mh_temp.zsav'.
erase file = !Year_dir + "MH_monthly_costs_and_beddays_by_uri.sav".

Host Command = ["gzip " + !Year_Extracts_dir + "Mental-Health-episode-level-extract-20" + !FY + ".csv"].
