* Encoding: UTF-8.
GET DATA  /TYPE=TXT
    /FILE= !Extracts + "Homelessness extract-20" + !FY + ".csv"
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

 * Drop records for parthnerships which don't have good / complete data.
 * For most of the below there will be no data anyway but some have test data only.
Compute #Drop = 0.
If (!FY = "1617" and any(SendingLocalAuthorityCode9, "S12000005", "S12000017", "S12000028", "S12000040", "S12000041",  "S12000042")) #Drop = 1.
If (!FY = "1718" and any(SendingLocalAuthorityCode9, "S12000040", "S12000041")) #Drop = 1.

Select if #Drop = 0.

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

String hl1_reason_ftm (A10).
If FinancialDifficultiesDebtUnemployment = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "F").
If PhysicalHealthReasons = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "Ph").
If MentalHealthReasons = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "M").
If UnmetNeedforSupportfromHousingSocialWorkHealthServi = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "U").
If LackofSupportfromFriendsFamily = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "L").
If DifficultiesManagingonOwn = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "O").
If DrugAlcoholDependency = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "D").
If CriminalAntiSocialBehaviour = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "C").
If NottodowithApplicantHousehold = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "N").
If Refused = 1 HL1_reason_FtM = Concat(HL1_reason_FtM, "R"). 

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

Apply Dictionary From !PCDir
    /VarInfo ValLabels = Replace
    /Source variables = CA2011
    /Target variables = hl1_sending_lca.

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
    hl1_reason_ftm
    /zcompressed.

 * zip up the raw data.
Host Command = ["gzip '" + !Extracts + "Homelessness extract-20" + !FY + ".csv'"].
