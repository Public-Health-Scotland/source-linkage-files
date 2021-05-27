* Encoding: UTF-8.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in CSV output file.
GET DATA
    /TYPE=TXT
    /FILE= !Year_Extracts_dir + "Community-MH-contact-level-extract-20" + !FY + ".csv"
    /DELIMITERS=" ,"
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    UPINumber A10
    PatientDoBDate A10
    Gender F1.0
    PatientPostcode A8
    NHSBoardofResidenceCode9 A9
    PatientHSCPCodeatEvent A9
    PracticeCode F5.0
    TreatmentNHSBoardCode9 A9
    ContactDate A10
    ContactStartTime Time5
    DurationofContact F3.0
    LocationofContact A7
    MainAimofContact A6
    OtherAimofContact1 A6
    OtherAimofContact2 A6
    OtherAimofContact3 A6
    OtherAimofContact4 A6.
Cache.
Execute.

Rename Variables
    UPINumber = chi
    PatientDoBDate = dob
    PatientPostcode = postcode
    NHSBoardofResidenceCode9 = hbrescode
    PatientHSCPCodeatEvent  = HSCP
    PracticeCode = gpprac
    TreatmentNHSBoardCode9 = hbtreatcode.

*Create recid variable .
string recid(A3).
compute recid = "CMH".

*Create variable SMRtype with value DN(District Nursing).
string SMRType (A10).
compute SMRType = "Comm-MH".

String year (A4).
Compute Year = !FY.

alter type dob ContactDate (SDate10).
alter type dob ContactDate (Date12).

Numeric ContactEndTime (Time5).
Compute ContactEndTime = DateSum(ContactStartTime, DurationofContact, "minutes").

Rename Variables
    ContactDate = record_keydate1
    ContactStartTime = keyTime1
    ContactEndTime = keyTime2
    LocationofContact = location
    MainAimofContact = diag1
    OtherAimofContact1 = diag2
    OtherAimofContact2 = diag3
    OtherAimofContact3 = diag4
    OtherAimofContact4 = diag5.

Numeric record_keydate2 (Date12).
Compute record_keydate2 = record_keydate1.

 * Create diag6 as blank.
String diag6 (A6).

sort cases by chi record_keydate1 keyTime1.

 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

save outfile = !Year_dir + 'CMH_for_source-20' + !FY + '.zsav'
    /Keep year
    recid
    record_keydate1
    record_keydate2
    keyTime1
    keyTime2
    SMRType
    chi
    gender
    dob
    gpprac
    postcode
    hbrescode
    HSCP
    location
    hbtreatcode
    diag1
    diag2
    diag3
    diag4
    diag5
    diag6
    /zcompressed.

get file = !Year_dir + 'CMH_for_source-20' + !FY + '.zsav'.

 * zip up the raw data.
Host Command = ["gzip '" + !Year_Extracts_dir + "Community-MH-contact-level-extract-20" + !FY + ".csv'"].
