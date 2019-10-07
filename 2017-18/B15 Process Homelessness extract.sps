* Encoding: UTF-8.
GET DATA  /TYPE=TXT
    /FILE="/conf/sourcedev/James/Homelessness/Homelessness extract-20" + !FY + ".csv"
    /ENCODING='UTF8'
    /DELCASE=LINE
    /DELIMITERS=" ,"
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /DATATYPEMIN PERCENTAGE=95.0
    /VARIABLES=
    AssessmentDecisionDate YMDHMS19
    CaseClosedDate YMDHMS19
    SendingLocalAuthorityCode9 A9
    UPINumberC A10
    ClientDoBDateC YMDHMS19
    GenderCode F1.0
    ClientPostcodeC A8
    MainApplicantFlag A1
    ApplicationReferenceNumber A15
    PropertyTypeCode F2.0
    FinancialDifficultiesDebtUnemployment F1.0
    PhysicalHealthReasons F1.0
    MentalHealthReasons F1.0
    UnmetNeedforSupportfromHousingSocialWorkHealthServi F1.0
    LackofSupportfromFriendsFamily F1.0
    DifficultiesManagingonOwn F1.0
    DrugAlcoholDependency F1.0
    CriminalAntiSocialBehaviour F1.0
    NottodowithApplicantHousehold F1.0
    Refused F1.0
    /MAP.

* Display dates nicely.
Alter Type AssessmentDecisionDate CaseClosedDate (Date12).

* Create some variables.
string year (a4) recid (a3) SMRType (A10).
compute year = !FY.
compute recid = "HL1".

Recode MainApplicantFlag
    ("Y"  = "HL1-Main")
    ("N" = "HL1-Other")
    Into SMRType.

Value Labels PropertyTypeCode
    1 "Own Property - LA Tenancy"
    2 "Own Property - RSL Tenancy"
    3 "Own Property - private rented tenancy"
    4 "Own Property - tenancy secured through employment/tied house"
    5 "Own Property - owning/buying"
    6 "Parental / family home / relatives"
    7 "Friends / partners"
    8 "Armed Services Accommodation"
    9 "Prison"
    10 "Hospital"
    11 "Children's residential accommodation (looked after by the local authority)"
    12 "Supported accommodation"
    13 "Hostel (unsupported)"
    14 "Bed & Breakfast"
    15 "Caravan / mobile home"
    16 "Long-term roofless"
    17 "Long-term sofa surfing"
    18 "Other"
    19 "Not known / refused"
    20 "Own property - Shared ownership/Shared equity/ LCHO"
    21 "Lodger"
    22 "Shared Property - Private Rented Sector"
    23 "Shared Property - Local Authority"
    24 "Shared Property - RSL".

String reason_ftm (A10).
Compute reason_ftm = Concat(String(FinancialDifficultiesDebtUnemployment, F1.0), 
String(PhysicalHealthReasons, F1.0), 
String(MentalHealthReasons, F1.0), 
String(UnmetNeedforSupportfromHousingSocialWorkHealthServi, F1.0), 
String(LackofSupportfromFriendsFamily, F1.0), 
String(DifficultiesManagingonOwn, F1.0), 
String(DrugAlcoholDependency, F1.0), 
String(CriminalAntiSocialBehaviour, F1.0), 
String(NottodowithApplicantHousehold, F1.0), 
String(Refused, F1.0)).

String reason_ftm_2 (A10).
If FinancialDifficultiesDebtUnemployment = 1 reason_ftm_2 = Concat(reason_ftm_2, "F").
If PhysicalHealthReasons = 1 reason_ftm_2 = Concat(reason_ftm_2, "P").
If MentalHealthReasons = 1 reason_ftm_2 = Concat(reason_ftm_2, "M").
If UnmetNeedforSupportfromHousingSocialWorkHealthServi = 1 reason_ftm_2 = Concat(reason_ftm_2, "U").
If LackofSupportfromFriendsFamily = 1 reason_ftm_2 = Concat(reason_ftm_2, "L").
If DifficultiesManagingonOwn = 1 reason_ftm_2 = Concat(reason_ftm_2, "O").
If DrugAlcoholDependency = 1 reason_ftm_2 = Concat(reason_ftm_2, "D").
If CriminalAntiSocialBehaviour = 1 reason_ftm_2 = Concat(reason_ftm_2, "C").
If NottodowithApplicantHousehold = 1 reason_ftm_2 = Concat(reason_ftm_2, "N").
If Refused = 1 reason_ftm_2 = Concat(reason_ftm_2, "R").

Rename Variables
    AssessmentDecisionDate = record_keydate1
    CaseClosedDate = record_keydate2
    SendingLocalAuthorityCode9 = hl1_sending_lca
    UPINumberC = chi
    ClientDoBDateC = dob
    GenderCode = gender
    ClientPostcodeC = postcode
    ApplicationReferenceNumber = hl1_application_ref
    PropertyTypeCode = hl1_property_type.


* Put record_keydate into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).

alter type record_keydate1 record_keydate2 (F8.0).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !file + 'homelessness_for_source-20' + !FY + '.zsav'
    /Keep year
    recid
    SMRType
    chi
    dob
    gender
    postcode
    record_keydate1
    record_keydate2
    hl1_application_ref
    hl1_sending_lca
    hl1_property_type
    reason_ftm
    reason_ftm_2
    /zcompressed.

 * zip up the raw data.
Host Command = ["gzip '" + !Extracts + "Homelessness extract-20" + !FY + ".csv'"].
