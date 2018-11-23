* Encoding: UTF-8.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
*Last ran:23/11/2018-AG.
* Read in CSV output file.
GET DATA /TYPE=TXT
   /FILE= !Extracts + 'Acute-episode-level-extract-20' + !FY + '.csv'
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      CostsFinancialYear01 A4
      CostsFinancialMonthNumber01 F2.0
      GLSRecord A1
      DateofAdmission01 A10
      DateofDischarge01 A10
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
      OldSMR1TypeofAdmissionCode F1.0
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
      DateofOperation101 A10
      Operation2ACode4char A4
      Operation2BCode4char A4
      DateofOperation201 A10
      Operation3ACode4char A4
      Operation3BCode4char A4
      DateofOperation301 A10
      Operation4ACode4char A4
      Operation4BCode4char A4
      DateofOperation401 A10
      AgeatMidpointofFinancialYear01 F3.0
      ContinuousInpatientStaySMR01 F5.0
      ContinuousInpatientStaySMR01incGLS F5.0
      ContinuousInpatientJourneyMarker01 A5
      CIJPlannedAdmissionCode01 F1.0
      CIJInpatientDayCaseIdentifierCode01 A2
      CIJTypeofAdmissionCode01 A2
      CIJAdmissionSpecialtyCode01 A3
      CIJDischargeSpecialtyCode01 A3
      TotalNetCosts01 F8.2
      NHSHospitalFlag01 A1
      CommunityHospitalFlag01 A1
      AlcoholRelatedAdmission01 A1
      SubstanceMisuseRelatedAdmission01 A1
      FallsRelatedAdmission01 A1
      SelfHarmRelatedAdmission01 A1
      UniqueRecordIdentifier A8
      lineno F3.0.
CACHE.
Execute.

Rename Variables
    AdmissionTypeCode = tadm
    AdmittedTransFromCode = adtf
    AgeatMidpointofFinancialYear01 = age
    AlcoholRelatedAdmission01 = alcohol_adm
    CIJAdmissionSpecialtyCode01 = CIJadm_spec
    CIJDischargeSpecialtyCode01 = CIJdis_spec
    CIJPlannedAdmissionCode01 = newpattype_ciscode
    CIJTypeofAdmissionCode01 = newcis_admtype
    CommunityHospitalFlag01 = commhosp
    ContinuousInpatientJourneyMarker01 = cis_marker
    ContinuousInpatientStaySMR01 = smr01_cis
    CostsFinancialMonthNumber01 = costmonthnum
    CostsFinancialYear01 = costsfy
    Diagnosis1Code6char = diag1
    Diagnosis2Code6char = diag2
    Diagnosis3Code6char = diag3
    Diagnosis4Code6char = diag4
    Diagnosis5Code6char = diag5
    Diagnosis6Code6char = diag6
    DischargeTransToCode = dischto
    DischargeTypeCode = disch
    FallsRelatedAdmission01 = falls_adm
    GeoCouncilAreaCode = lca
    GeoDatazone2011 = DataZone2011
    GeoPostcodeC = postcode
    HSCPCode = HSCP2016
    LeadConsultantHCPCode = conc
    LocationAdmittedTransFromCode = admloc
    LocationDischargedTransToCode = dischloc
    ManagementofPatientCode = mpat
    NHSBoardofResidenceCode = hbrescode
    NHSHospitalFlag01 = nhshosp
    OccupiedBedDays01 = yearstay
    OldSMR1TypeofAdmissionCode = oldtadm
    Operation1ACode4char = op1a
    Operation1BCode4char = op1b
    Operation2ACode4char = op2a
    Operation2BCode4char = op2b
    Operation3ACode4char = op3a
    Operation3BCode4char = op3b
    Operation4ACode4char = op4a
    Operation4BCode4char = op4b
    PatGenderCode = gender
    PatUPI = chi
    PatientCategoryCode = cat
    PracticeLocationCode = gpprac
    PracticeNHSBoardCode = hbpraccode
    SelfHarmRelatedAdmission01 = selfharm_adm
    SignificantFacilityCode = sigfac
    SpecialtyClassificat.1497Code = spec
    SubstanceMisuseRelatedAdmission01 = submis_adm
    TotalNetCosts01 = cost_total_net
    TreatmentLocationCode = location
    TreatmentNHSBoardCode = hbtreatcode
    UniqueRecordIdentifier = uri.

 * Create some variables.
string year (a4) recid (a3).
compute year = !FY.
compute recid = '01B'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

 * Flag GLS records.
if (glsrecord EQ 'Y') recid = 'GLS'.

String ipdc (A1) newcis_ipdc (A1) newpattype_cis (A13).

 * Set the IPDC marker for the episode.
Recode InpatientDayCaseIdentifierCode ("IP" = "I") ("DC" = "D") into ipdc.

 * Set the IPDC marker for the CIJ.
Recode CIJInpatientDayCaseIdentifierCode01 ("IP" = "I") ("DC" = "D") into newcis_ipdc.

 * Recode newpattype.
Recode newpattype_ciscode
    (2 = "Maternity")
    (0 = "Non-elective")
    (1 = "Elective")
    Into newpattype_cis.

 * Rename date variables.
Rename Variables
    DateofAdmission01 = record_keydate1
    DateofDischarge01 = record_keydate2
    DateofOperation101 = dateop1
    DateofOperation201 = dateop2
    DateofOperation301 = dateop3
    DateofOperation401 = dateop4
    PatDateOfBirthC = dob.

 * Change dates to date types.
alter type record_keydate1 record_keydate2 dob dateop1 dateop2 dateop3 dateop4 (SDate10).
alter type record_keydate1 record_keydate2 dob dateop1 dateop2 dateop3 dateop4 (Date12).

 * If we have no costs lets fix this.
Recode lineno cost_total_net (sysmis = 0).

sort cases by uri.

save outfile = !file + 'acute_temp.zsav'
   /zcompressed.
  
* Create a file that contains uri, the month number and the net cost and yearstay.
* Make this look like a 'crosstab' ready for matching back To the acute_temp file. 
get file = !file + 'acute_temp.zsav'
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
aggregate outfile = !file + 'acute_monthly_costs_and_beddays_by_uri.sav'
   /Presorted
   /break uri
   /apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
       Sum(apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost)
   /apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays =
       Sum(apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).


* Match this file back to the main acute file and then create totals adding across the months for each of the costs and yearstay variables.  
* Need To reduce each uri to one row only. All columns will have the same information except for the costs month variable.

match files file = !file + 'acute_temp.zsav'
   /table = !file + 'acute_monthly_costs_and_beddays_by_uri.sav'
   /by uri.

 * This is just to remove duplicates.
add files file = *
    /By URI
    /First = Keep.

Select if Keep = 1.

compute yearstay = apr_beddays + may_beddays + jun_beddays + jul_beddays + aug_beddays + sep_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
compute cost_total_net = apr_cost + may_cost + jun_cost + jul_cost + aug_cost + sep_cost + oct_cost + nov_cost + dec_cost + jan_cost + feb_cost + mar_cost.

 * Create the SMRType.
 * 310 is the line number for GLS, however, not all records with this line number are tagged as GLS records.
string SMRType(a10).
Do if (recid EQ '01B').
   Do if (lineno NE 330).
      If ipdc EQ 'I' SMRType = 'Acute-IP'.
      If ipdc EQ 'D' SMRType = 'Acute-DC'.
   Else If (lineno EQ 330 and ipdc EQ 'I').
      Compute SMRType = 'GLS-IP'.
   End If.
Else If (recid EQ 'GLS').
   Compute SMRType = 'GLS-IP'.
End If.
frequencies SMRType.

* Calculate the total length of stay (for the entire episode, not just within the financial year).
Numeric stay (F7.0).
Compute stay = Datediff(record_keydate2, record_keydate1, "days").

 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

frequencies stay yearstay.

sort cases by chi record_keydate1.

save outfile = !file + 'acute_for_source-20' + !FY + '.zsav'
    /keep year
    recid
    record_keydate1
    record_keydate2
    SMRType
    chi
    gender
    dob
    gpprac
    hbpraccode
    postcode
    hbrescode
    lca
    HSCP2016
    DataZone2011
    location
    hbtreatcode
    yearstay
    stay
    ipdc
    spec
    sigfac
    conc
    mpat
    cat
    tadm
    adtf
    admloc
    oldtadm
    disch
    dischto
    dischloc
    diag1
    diag2
    diag3
    diag4
    diag5
    diag6
    op1a
    op1b
    dateop1
    op2a
    op2b
    dateop2
    op3a
    op3b
    dateop3
    op4a
    op4b
    dateop4
    smr01_cis
    age
    cis_marker
    newcis_admtype
    newcis_ipdc
    newpattype_ciscode
    newpattype_cis
    CIJadm_spec
    CIJdis_spec
    alcohol_adm
    submis_adm
    falls_adm
    selfharm_adm
    commhosp
    cost_total_net
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

get file = !file + 'acute_for_source-20' + !FY + '.zsav'.

* Housekeeping.
erase file = !file + 'acute_temp.zsav'.
erase file = !file + 'acute_monthly_costs_and_beddays_by_uri.sav'.

 * zip up the raw data.
Host Command = ["gzip '" + !Extracts + "Acute-episode-level-extract-20" + !FY + ".csv'"].



