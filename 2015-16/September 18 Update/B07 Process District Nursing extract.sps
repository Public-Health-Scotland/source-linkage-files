* Encoding: UTF-8.

*District Nursing Database.
*Anita George 15/11/2017 .
*calculate recid frequencies for cost book and to average out costs in the excel spreadsheet.
*Last ran 30/5/18.-AnitaGeorge.

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
    PatientDoDDate A10
    ContactStartTime Time5
    ContactEndTime Time5
    ContactDate A10
    OtherInterventionCategory1 F2.0
    PatientContactCategory F1.0
    OtherInterventionSubcategory1 F1.0
    OtherInterventionCategory2 F2.0
    OtherInterventionSubcategory2 F1.0
    NumberofContacts F1.0
    OtherInterventionCategory3 F2.0
    OtherInterventionSubcategory3 F1.0
    OtherInterventionCategory4 F2.0
    OtherInterventionSubcategory4 F1.0
    PrimaryInterventionSubcategory F1.0
    PrimaryInterventionCategory F2.0
    VisitStatus F1.0
    UPINumberC A10
    PatientDoBDateC A10
    PlannedUnplanned F1.0
    PatientPostcodeCContact A7
    DurationofContactmeasure F3.0
    Gender F1.0
    ContactFinancialYear A4
    LocationofContact F1.0
    ContactID A36
    PracticeNHSBoardCode9Contact A9
    PatientCouncilAreaCodeContact A2
    PracticeCodeContact A5
    NHSBoardofResidenceCode9Contact A9
    HSCPofResidenceCodeContact A9.
CACHE.

rename variables UPINumberC = chi.

 * Only keep records with CHI.
Select if chi ne "".

*Check frequencies for Healthboards.
*Check Frequencies for NumberofContacts (should be 1).
*Frequencies TreatmentNHSBoardName NumberofContacts.

*Alter or create variables to match file to source file.
rename variables
   ContactFinancialYear = year
   TreatmentNHSBoardName = hbtreatname
   TreatmentNHSBoardCode9 = hbtreatcode
   HSCPofResidenceCodeContact = HSCP2016
   PatientPostcodeCContact = postcode
   PracticeNHSBoardCode9Contact = hbpraccode
   NHSBoardofResidenceCode9Contact = hbrescode
   Ageatcontactdate = age
   PracticeCodeContact = gpprac
   PatientCouncilAreaCodeContact = lca.

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
    PatientDoDDate = death_date
    PatientDoBDateC = dob.

Compute ContactEndTime = DateSum(ContactStartTime, DurationofContactmeasure, "minutes").

Alter Type record_keydate1 death_date dob (SDate10).
compute record_keydate2 = record_keydate1.
Alter Type record_keydate1 record_keydate2 death_date dob (Date12).

* Create costs for the DN from costsbook. (Work from here).
Compute year = !FY.

sort cases by hbtreatcode.

match files file = *
    /Table = !Extracts_Alt + "Cost_DN_Lookup.sav"
    /Drop hbtreatname
    /By hbtreatcode year. 

Compute cost_total_net = rnd(cost_total_net).

save outfile = !File + "DN-Temp-1" + ".zsav"
   /zcompressed.
get file = !File + "DN-Temp-1" + ".zsav".

 * Finding the difference between dates of contacts and creating new variable DATEDIFF.
sort cases by chi dob record_keydate1.
if (chi=lag(chi) and dob eq lag(dob)) Day_diff eq DATEDIFF(record_keydate1, lag(record_keydate1), "days").

*Creating CCM Continuous Care Marker. Records with less than or equal to 7 days are maintained as same CCM and greater than 7 days is CCM+1.
AGGREGATE
   /BREAK chi
   /record_keydate1_1 = first(record_keydate1)
   /Day_diff_1 = first(day_diff).

Numeric  CCM (F5.0).
Compute CCM_1 = 1.

Do if (chi=lag(chi)).
   Do if (lag(record_keydate1) eq record_keydate1_1).
      Do if  (Day_diff le 7).
         compute CCM = CCM_1.
      Else if (Day_diff gt 7).
         compute CCM = CCM_1 + 1.
      End if.

   Else if (lag (record_keydate1) ne record_keydate1_1).
      Do if (Day_diff le 7).
         compute Flag = 1.
      Else if (Day_diff gt 7).
         compute  Flag = 2.
      End if.
   End if.
End if.

Do if  Flag = 1.
   Compute CCM = lag(CCM).
Else if Flag = 2.
   Compute CCM = (lag(CCM) + 1).
End If.

Recode CCM (Sysmiss = 1).

 * Calculate costs per month.
Compute cost_monthnum = xDate.Month(record_keydate1).

Do repeat month = jan_cost feb_cost mar_cost apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost
   /monthnum = 1 to 12.
   If cost_monthnum = monthnum month = cost_total_net.
End repeat.

save outfile = !File + "DN-Temp-2" + ".zsav"
   /zcompressed.
get file = !File + "DN-Temp-2" + ".zsav".

*Aggregate out records for final DN to source linkage files.
sort cases by chi dob record_keydate1 record_keydate2.

 * Set blanks as missing so that the aggregate ignores them.
Recode hbtreatcode hbrescode HSCP2016 (" " = "-").
Recode postcode (" " = "-").
Recode LCA (" " = "-").

Missing Values
    hbtreatcode hbrescode HSCP2016 postcode lca ("-").

aggregate outfile=*
    /break chi CCM
    /record_keydate1 = Min(record_keydate1)
    /record_keydate2 = Max(record_keydate2)
    /SMRType = First(SMRType)
    /recid = First(recid)
    /death_date = Last(death_date)
    /dob = Last(dob)
    /hbtreatcode = Last(hbtreatcode)
    /hbrescode = Last(hbrescode)
    /HSCP2016 = Last(HSCP2016)
    /lca = Last(lca)
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
    /year = First(year)
    /TotalnoDNcontacts = Sum(NumberofContacts)
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

 * Put the blanks back..
Recode hbtreatcode hbrescode HSCP2016 ("-" = " ").
Recode postcode ("-" = " ").
Recode LCA ("-" = " ").

Missing Values
    hbtreatcode hbrescode HSCP2016 postcode lca ().

*Tidy up for source linkage episode file.
alter type year(A4).
compute year = !FY.

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

Define !LocationofContact()
    Value Labels
    Location
    "1" "Hospital"
    "2" "HealthCentre"
    "3" "GP Surgery"
    "5" "Nursing Home or Care Home or Residential Home"
    "6" "Patient or client residence"
    "7" "Day Centre"
    "8" "Other"
!EndDefine.

!InterventionCategory Vars = diag1 to diag6.
!LocationofContact.

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
    death_date
    dob
    CCM
    gpprac
    postcode
    hbrescode
    hbtreatcode
    HSCP2016
    lca
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

   *Delete temp files.
Erase file = !File + "DN-Temp-1" + ".zsav".
Erase file = !File + "DN-Temp-2" + ".zsav".

* zip up the raw data.
Host Command = ["zip -m '" + !Extracts + "District-Nursing-contact-level-extract-20" + !FY + ".zip' '" +
   !Extracts + "District-Nursing-contact-level-extract-20" + !FY + ".csv'"].

