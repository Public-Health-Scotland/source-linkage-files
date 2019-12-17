* Encoding: UTF-8.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA  /TYPE=TXT
    /FILE= !Extracts + "District-Nursing-contact-level-extract-20" + !FY + ".csv"
    /ENCODING="UTF8"
    /DELIMITERS=" ,"
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    TreatmentNHSBoardName A63
    TreatmentNHSBoardCode9 A9
    AgeatContactDate F3.0
    EpisodeContactNumber F4.0
    ContactStartTime Time5
    ContactEndTime Time5
    ContactDate A10
    OtherInterventionCategory1 F2.0
    PatientContactCategory F1.0
    OtherInterventionSubcategory1 F1.0
    OtherInterventionCategory2 F2.0
    OtherInterventionSubcategory2 F1.0
    OtherInterventionCategory3 F2.0
    OtherInterventionSubcategory3 F1.0
    OtherInterventionCategory4 F2.0
    OtherInterventionSubcategory4 F1.0
    PrimaryInterventionSubcategory F1.0
    PrimaryInterventionCategory F2.0
    UPINumberC A10
    PatientDoBDateC A10
    PatientPostcodeCContact A8
    DurationofContactmeasure F3.0
    Gender F1.0
    LocationofContact F1.0
    PracticeNHSBoardCode9Contact A9
    PatientCouncilAreaCodeContact A2
    PracticeCodeContact A5
    NHSBoardofResidenceCode9Contact A9
    HSCPofResidenceCodeContact A9
    PatientDataZone2011Contact A9.
CACHE.

*Alter or create variables to match file to source file.
Rename Variables
    Ageatcontactdate = age
    HSCPofResidenceCodeContact = HSCP
    NHSBoardofResidenceCode9Contact = hbrescode
    PatientCouncilAreaCodeContact = lca
    PatientPostcodeCContact = postcode
    PracticeCodeContact = gpprac
    PatientDataZone2011Contact = datazone
    PracticeNHSBoardCode9Contact = hbpraccode
    TreatmentNHSBoardCode9 = hbtreatcode
    TreatmentNHSBoardName = hbtreatname
    UPINumberC = chi.

* Only keep records with a CHI so we can group into continuous episodes.
Select if CHI NE "".

*Create recid variable .
string recid(A3).
compute recid = "DN".

*Create variable SMRtype with value DN(District Nursing).
string SMRType (A10).
compute SMRType = "DN".

* Recode GP Practice into a 5 digit number.
* We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
    Compute gpprac = "99995".
End if.
Alter Type GPprac (F5.0).

*Create variables recordkeydate1 = Contact Date and record keydate2 = recordkeydate1.
Rename Variables
    ContactDate = record_keydate1
    PatientDoBDateC = dob.

Compute ContactEndTime = DateSum(ContactStartTime, DurationofContactmeasure, "minutes").

Alter Type record_keydate1 dob (SDate10).
compute record_keydate2 = record_keydate1.
Alter Type record_keydate1 record_keydate2 dob (Date12).

* Create costs for the DN from Costs Book. (Work from here).
String Year (A4).
Compute year = !FY.

* Recode Fife and Tayside so they match the cost lookup.
Recode hbtreatcode ("S08000018" = "S08000029") ("S08000027" = "S08000030").

sort cases by hbtreatcode.

match files file = *
    /Table = !Extracts_Alt + "Costs/Cost_DN_Lookup.sav"
    /Drop hbtreatname
    /By hbtreatcode year.

* Since the costs are rough estimates we round them to the nearest pound.
* This hopefully means they aren't seen as too 'exact'.
Compute cost_total_net = rnd(cost_total_net).

* Finding the difference between dates of contacts and creating new variable DATEDIFF.
sort cases by chi record_keydate1.
if (chi=lag(chi)) Day_diff eq DateDiff(record_keydate1, lag(record_keydate1), "days").

*Creating CCM Continuous Care Marker. Records with less than or equal to 7 days are maintained as same CCM and greater than 7 days is CCM+1.
Numeric CCM (F5.0).
Compute CCM = 1.
Do if (CHI = lag(CHI)).
    Do If (Day_diff LE 7 ).
        Compute CCM = lag(CCM).
    Else.
        Compute CCM = lag(CCM) + 1.
    End if.
End if.

* Calculate costs per month.
Compute cost_monthnum = xDate.Month(record_keydate1).

Do repeat month = jan_cost feb_cost mar_cost apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost
    /monthnum = 1 to 12.
    If cost_monthnum = monthnum month = cost_total_net.
End repeat.

*Aggregate out records for final DN to source linkage files.

* Set blanks as missing so that the aggregate ignores them.
Missing Values
    hbtreatcode hbrescode HSCP postcode lca datazone (" ").

aggregate outfile=*
    /Presorted
    /break year chi recid SMRType CCM
    /record_keydate1 = Min(record_keydate1)
    /record_keydate2 = Max(record_keydate2)
    /dob = Last(dob)
    /hbtreatcode = Last(hbtreatcode)
    /hbrescode = Last(hbrescode)
    /HSCP = Last(HSCP)
    /lca = Last(lca)
    /datazone = Last(datazone)
    /age = Last(age)
    /diag1 = First(PrimaryInterventionCategory)
    /diag2 = First(OtherInterventionCategory1)
    /diag3 = First(OtherInterventionCategory2)
    /diag4 = Last(PrimaryInterventionCategory)
    /diag5 = Last(OtherInterventionCategory1)
    /diag6 = Last(OtherInterventionCategory2)
    /postcode = Last(postcode)
    /gender = First(gender)
    /gpprac = First(gpprac)
    /cost_total_net = Sum(cost_total_net)
    /location = First (LocationofContact)
    /TotalnoDNcontacts = n
    /jan_cost = Sum(jan_cost)
    /feb_cost = Sum(feb_cost)
    /mar_cost = Sum(mar_cost)
    /apr_cost = Sum(apr_cost)
    /may_cost = Sum(may_cost)
    /jun_cost = Sum(jun_cost)
    /jul_cost = Sum(jul_cost)
    /aug_cost = Sum(aug_cost)
    /sep_cost = Sum(sep_cost)
    /oct_cost = Sum(oct_cost)
    /nov_cost = Sum(nov_cost)
    /dec_cost = Sum(dec_cost).

Missing Values
    hbtreatcode hbrescode HSCP postcode lca ().

*Tidy up for source linkage episode file.
Alter type diag1 to diag6 (A6) location(A7).

* Trim leading and trailing spaces.
Do Repeat var = location diag1 to diag6.
    Compute var = Rtrim(Ltrim(var)).
End Repeat.

*Add values to variables-Run Macros.
Define !InterventionCategory (Vars = !CMDEND)
    Value Labels !Vars
    "1" "Assessment"
    "10" "Long Term Condition Management"
    "11" "Medication"
    "12" "Mobility"
    "13" "Nutrition/Fluids"
    "14" "Personal Care"
    "16" "Procedures"
    "17" "Risk Management"
    "18" "Skin/Wound Care"
    "19" "Social Circumstances"
    "2" "Bladder/Bowel Care"
    "20" "Symptom Management"
    "21" "Teaching"
    "22" "Palliative Care"
    "3" "Care Management"
    "4" "Carers"
    "5" "Emotional / Psychological Issues"
    "6" "Equipment"
    "8" "Health Promotion".
!EndDefine.

!InterventionCategory Vars = diag1 to diag6.

Value Labels
    Location
    "1" "Hospital"
    "2" "HealthCentre"
    "3" "GP Surgery"
    "5" "Nursing Home or Care Home or Residential Home"
    "6" "Patient or client residence"
    "7" "Day Centre"
    "8" "Other"

Variable Labels
    CCM "Continuous Care Marker"
    TotalnoDNcontacts "Total Number of Patient Contacts".

* Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

save outfile = !File + "DN_for_source-20" + !FY + ".zsav"
    /keep
    year
    recid
    record_keydate1
    record_keydate2
    SMRType
    chi
    gender
    dob
    CCM
    gpprac
    postcode
    hbrescode
    hbtreatcode
    HSCP
    lca
    datazone
    location
    diag1
    diag2
    diag3
    diag4
    diag5
    diag6
    age
    cost_total_net
    jan_cost
    feb_cost
    mar_cost
    apr_cost
    may_cost
    jun_cost
    jul_cost
    aug_cost
    sep_cost
    oct_cost
    nov_cost
    dec_cost
    TotalnoDNcontacts
    /zcompressed.

get file = !File + "DN_for_source-20" + !FY + ".zsav".

* zip up the raw data.
Host Command = ["gzip '" + !Extracts + "District-Nursing-contact-level-extract-20" + !FY + ".csv'"].

