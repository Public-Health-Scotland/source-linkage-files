* Encoding: UTF-8.
* Create A&E costed extract in suitable format for PLICS.
* Modified version of previous read in files used to create A&E data for PLICS. 

* Read in the a&e extract.  Rename/reformat/recode columns as appropriate. 

* Program by Denise Hastie, June 2016.
* Updated by Denise Hastie, July 2016 (to add in age at mid-point of financial year).

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA  /TYPE=TXT
    /FILE= !Extracts + 'A&E-episode-level-extract-20' + !FY + '.csv'
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    ArrivalDate A10
    PatCHINumberC A10
    PatDateOfBirthC A10
    PatGenderCode F1.0
    ResidenceNHSBoardCypher A1
    TreatmentNHSBoardCypher A1
    TreatmentLocationCode A7
    GPPracticeCode A5
    CouncilAreaCode A2
    PostcodeepiC A8
    PostcodeCHIC A8
    HSCPCode A9
    ArrivalTime Time5
    ArrivalModeCode A2
    ReferralSourceCode A3
    AttendanceCategoryCode A2
    DischargeDestinationCode A3
    PatientFlowCode A1
    PlaceofIncidentCode A3
    ReasonforWaitCode A3
    BodilyLocationOfInjuryCode A3
    AlcoholInvolvedCode A2
    AlcoholRelatedAdmission A1
    SubstanceMisuseRelatedAdmission A1
    FallsRelatedAdmission A1
    SelfHarmRelatedAdmission A1
    TotalNetCosts F8.2
    AgeatMidpointofFinancialYear F3.0.
CACHE.
Execute.

rename variables
    AgeatMidpointofFinancialYear = age
    AlcoholInvolvedCode = ae_alcohol
    AlcoholRelatedAdmission = alcohol_adm
    ArrivalModeCode = ae_arrivalmode
    ArrivalTime = ae_arrivaltime
    AttendanceCategoryCode = ae_attendcat
    BodilyLocationOfInjuryCode = ae_bodyloc
    CouncilAreaCode = lca
    DischargeDestinationCode = ae_disdest
    FallsRelatedAdmission = falls_adm
    GPPracticeCode = gpprac
    HSCPCode = HSCP
    PatCHINumberC = chi
    PatGenderCode = gender
    PatientFlowCode = ae_patflow
    PlaceofIncidentCode = ae_placeinc
    ReasonforWaitCode = ae_reasonwait
    ReferralSourceCode = refsource
    SelfHarmRelatedAdmission = selfharm_adm
    SubstanceMisuseRelatedAdmission = submis_adm
    TotalNetCosts = cost_total_net
    TreatmentLocationCode = location.

string year (a4) recid (a3).
compute year = !FY.
compute recid = 'AE2'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

Rename Variables
    ArrivalDate = record_keydate1
    PatDateofBirthC =dob.

alter type record_keydate1 dob (SDate10).
Compute record_keydate2 = record_keydate1.
alter type record_keydate1 record_keydate2 dob (Date12).


* POSTCODE = need to make this length 7!  use the CHI postcode and if that is blank, then use the epi postcode.
String Postcode (A7).
Compute Postcode = Replace(PostcodeCHIC, " ", "").
If Postcode = "" Postcode = Replace(PostcodeepiC, " ", "").
If Length(Postcode) < 7 Postcode = Concat(char.substr(Postcode, 1, 3), " ", char.substr(Postcode, 4, 3)).

String hbtreatcode hbrescode(A9).

 * Recode the cipher type HB codes into 9-char.
 * Currently using HB2018 set-up.
Recode TreatmentNHSBoardCypher ResidenceNHSBoardCypher
    ("A" = "S08000015") 
    ("B" = "S08000016") 
    ("F" = "S08000029")
    ("G" = "S08000021")
    ("H" = "S08000022")
    ("L" = "S08000023")
    ("N" = "S08000020")
    ("R" = "S08000025")
    ("S" = "S08000024")
    ("T" = "S08000030")
    ("V" = "S08000019")
    ("W" = "S08000028")
    ("Y" = "S08000017")
    ("Z" = "S08000026")
    Into hbtreatcode hbrescode.

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

* Change arrival time to a time var and rename.
Numeric keyTime1 keyTime2 (Time5).
Compute keyTime1 = ae_arrivaltime.
Compute keyTime2 = $sysmis.

sort cases by chi record_keydate1 keyTime1.

save outfile = !file + 'aande_for_source-20' + !FY + '.zsav'
    /keep year
    recid
    record_keydate1
    record_keydate2
    keyTime1
    keyTime2
    chi
    gender
    dob
    gpprac
    postcode
    lca
    HSCP
    location
    hbrescode
    hbtreatcode
    ae_arrivalmode
    refsource
    ae_attendcat
    ae_disdest
    ae_patflow
    ae_placeinc
    ae_reasonwait
    ae_bodyloc
    ae_alcohol
    alcohol_adm
    submis_adm
    falls_adm
    selfharm_adm
    cost_total_net
    age
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
    /zcompressed.

get file = !file + 'aande_for_source-20' + !FY + '.zsav'.

 * Zip up raw data.
Host Command = ["gzip '" + !Extracts + "A&E-episode-level-extract-20" + !FY + ".csv'"].





