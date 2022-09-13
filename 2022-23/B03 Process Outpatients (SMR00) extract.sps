* Encoding: UTF-8.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in CSV output file.
GET DATA  /TYPE=TXT
    /FILE= !Year_Extracts_dir + 'Outpatients-episode-level-extract-20' + !FY + '.csv'
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    ClinicDateFinYear A4
    ClinicDate00 A10
    EpisodeRecordKey A11
    PatUPI A10
    PatGenderCode F1.0
    PatDateOfBirthC A10
    PracticeLocationCode A5
    PracticeNHSBoardCode A9
    GeoPostcodeC A8
    NHSBoardofResidenceCode A9
    GeoCouncilAreaCode A2
    TreatmentLocationCode A7
    TreatmentNHSBoardCode A9
    Operation1ACode A4
    Operation1BCode A4
    Operation1Date A10
    Operation2ACode A4
    Operation2BCode A4
    Operation2Date A10
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
Execute.

Rename Variables
    AgeatMidpointofFinancialYear = age
    AlcoholRelatedAdmission = alcohol_adm
    ClinicAttendanceStatusCode = attendance_status
    ClinicTypeCode = clinic_type
    CommunityHospitalFlag = commhosp
    ConsultantHCPCode = conc
    EpisodeRecordKey = uri
    FallsRelatedAdmission = falls_adm
    GeoCouncilAreaCode = lca
    GeoPostcodeC = postcode
    NHSBoardofResidenceCode = hbrescode
    NHSHospitalFlag = nhshosp
    Operation1ACode = op1a
    Operation1BCode = op1b
    Operation1Date = dateop1
    Operation2ACode = op2a
    Operation2BCode = op2b
    Operation2Date = dateop2
    PatGenderCode = gender
    PatUPI = chi
    PatientCategoryCode = cat
    PracticeLocationCode = gpprac
    PracticeNHSBoardCode = hbpraccode
    ReferralSourceCode = refsource
    ReferralTypeCode = reftype
    SelfHarmRelatedAdmission = selfharm_adm
    SignificantFacilityCode = sigfac
    SpecialtyClassificat.1497Code = spec
    SubstanceMisuseRelatedAdmission = submis_adm
    TotalNetCosts = cost_total_net
    TreatmentLocationCode = location
    TreatmentNHSBoardCode = hbtreatcode.

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

alter type record_keydate1 dob dateop1 dateop2 (SDate10).
Compute record_keydate2 = record_keydate1.
alter type record_keydate1 record_keydate2 dob dateop1 dateop2 (Date12).

* Allocate the costs to the correct month.

* Set up the variables.
Numeric apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost (F8.2).

* Get the month number.
compute month = xdate.Month(record_keydate1).

* Loop through the months (in the correct FY order and assign the cost to the relevant month.
Do Repeat month_num = 4 5 6 7 8 9 10 11 12 1 2 3
    /month_cost = apr_cost to mar_cost.
    Do if month = month_num.
        Compute month_cost = cost_total_net.
    Else.
        Compute month_cost = 0.
    End if.
End Repeat.

* Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

sort cases by chi record_keydate1.

 * Add Outpatient specific value labels.
Value Labels reftype
    '1' "New Outpatient: Consultation and Management"
    '2' "New Outpatient: Consultation only"
    '3' "Follow-up/Return Outpatient".

Value Labels clinic_type
    '1' "Consultant"
    '2' "Dentist"
    '3' "Nurse PIN"
    '4' "AHP".


save outfile = !Year_dir + 'outpatients_for_source-20'+!FY+'.zsav'
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
    location
    hbtreatcode
    op1a
    op1b
    dateop1
    op2a
    op2b
    dateop2
    spec
    sigfac
    conc
    cat
    age
    refsource
    reftype
    attendance_status
    clinic_type
    alcohol_adm
    submis_adm
    falls_adm
    selfharm_adm
    commhosp
    nhshosp
    cost_total_net
    apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
    uri
    /zcompressed.

get file = !Year_dir + 'outpatients_for_source-20' + !FY + '.zsav'.

* zip up the raw data.
Host Command = ["gzip " + !Year_Extracts_dir + "Outpatients-episode-level-extract-20" + !FY + ".csv"].
