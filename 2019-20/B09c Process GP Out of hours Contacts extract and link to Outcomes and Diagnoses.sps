* Encoding: UTF-8.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in Consultation data.
GET DATA  /TYPE=TXT
   /FILE= !Year_Extracts_dir + "GP-OoH-consultations-extract-20" + !FY + ".csv"
   /ENCODING="UTF8"
   /DELIMITERS=","
   /Qualifier = '"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      chi A10
      dob A10
      gender F1.0
      postcode A8
      PatientNHSBoardCode A9
      HSCPofResidenceCode A9
      PatientDataZone2011 A9
      PracticeCode A6
      PracticeNHSBoardCode A9
      GUID A36
      ConsultationRecorded A1
      ConsultationStart A20
      ConsultationEnd A20
      TreatmentLocationCode A7
      TreatmentLocationDescription A34
      TreatmentNHSBoardCode A9
      KISAccessed A1
      ReferralSource A47
      ConsultationType A26.
CACHE.

* If they don't have a CHI it isn't useful for linkage.
Select if Chi NE "".

* Some CHIs seem to have lost their leading zero.
If length(chi) = 9 chi = concat("0", chi).

Compute ConsultationStartDateTime = Number(char.substr(ConsultationStart, 1, 10), SDATE10) + Number(char.substr(ConsultationStart, 12, 5), TIME5).
Compute ConsultationEndDateTime = Number(char.substr(ConsultationEnd, 1, 10), SDATE10) + Number(char.substr(ConsultationEnd, 12, 5), TIME5).

Alter type ConsultationStartDateTime ConsultationEndDateTime (DATETIME16).

 * Some episodes are wrongly included.
Select if ConsultationStartDateTime LE Date.DMY(31, 03, Number(!altFY, F4.0) + 1).
Select if ConsultationEndDateTime GE Date.DMY(01, 04, Number(!altFY, F4.0)).

 * Sort out any duplicates or overlaps.
sort cases by GUID CHI ConsultationStartDateTime ConsultationEndDateTime.

Compute Duplicate = 0.
Compute Overlap = 0.
 * Flag duplicates and overlaps.
Do If CHI = lag(CHI) AND GUID = lag(GUID).
   If ConsultationStartDateTime < Lag(ConsultationEndDateTime) Overlap = 1.
   Do If ConsultationType = Lag(ConsultationType) AND TreatmentLocationCode = Lag(TreatmentLocationCode).
      Compute Duplicate = 1. 
      If ConsultationStartDateTime = Lag(ConsultationStartDateTime) AND ConsultationEndDateTime = Lag(ConsultationEndDateTime) Duplicate = 2.
   End If.
End if.
      
 * Get rid of obvious duplicates.
select if Duplicate NE 2.

 * Where it's a duplicate except for an overlapping time flag it.
If (Overlap = 1 AND Duplicate = 1) ToMerge = 1.

 * Repeat in the other direction so both records are flagged to be merged.
sort cases by GUID CHI ConsultationStartDateTime ConsultationEndDateTime (D).
IF GUID = lag(GUID) AND CHI = lag(CHI) AND ConsultationEndDateTime > Lag(ConsultationStartDateTime) 
   AND ConsultationType = Lag(ConsultationType) AND TreatmentLocationCode = Lag(TreatmentLocationCode) ToMerge = 1.

 * Create counters for unique consultations.
sort cases by GUID CHI ConsultationStartDateTime ConsultationEndDateTime.

if $casenum = 1 or (CHI ne lag(CHI) OR GUID ne lag(GUID)) counter = 1.
if sysmis(counter) counter = lag(counter) + 1.

 * If we've identified them as duplicates needing merged set the counter to indicate this.
if ToMerge = 1 counter = 0.

 * Set blank values to missing so they are ignored by the aggregate.
Missing Values PatientNHSBoardCode PatientDataZone2011 HSCPofResidenceCode Postcode PracticeCode (' ').

aggregate outfile = *
   /Break GUID chi ConsultationRecorded TreatmentNHSBoardCode TreatmentLocationCode TreatmentLocationDescription KISAccessed ReferralSource ConsultationType Counter
   /PatientNHSBoardCode PatientDataZone2011 HSCPofResidenceCode =
      Last(PatientNHSBoardCode PatientDataZone2011 HSCPofResidenceCode)
   /dob gender postcode PracticeCode = Last(dob gender postcode PracticeCode)
   /ConsultationStartDateTime = MIN(ConsultationStartDateTime)
   /ConsultationEndDateTime = MAX(ConsultationEndDateTime).

 * Restore the blank values.
Missing Values PatientNHSBoardCode PatientDataZone2011 HSCPofResidenceCode Postcode PracticeCode ().

save outfile = !Year_dir + "GPOOH-Temp-1.zsav"
   /zcompressed.
************************************************************************************************************.
 * Match data together.
match files
   /File = !Year_dir + "GPOOH-Temp-1.zsav"
   /Table = !Year_dir + "GP-Diagnosis-Data-" + !FY + ".zsav"
   /In DiagData
   /By GUID.

match files
   /File = *
   /Table = !Year_dir + "GP-Outcomes-Data-" + !FY + ".zsav"
   /In OutcomeData
   /By GUID.

save outfile = !Year_dir + "GPOOH-Temp-2.zsav"
   /zcompressed.

************************************************************************************************************.
* Costs.
get file = !Year_dir + "GPOOH-Temp-2.zsav".

* Recode Fife and Tayside so they match the cost lookup.
Recode TreatmentNHSBoardCode ("S08000018" = "S08000029") ("S08000027" = "S08000030").

*Recode Greater Glasgow & Clyde and Lanarkshire so they match the costs lookup. 
*(2018 > 2019 HB codes). 
Recode TreatmentNHSBoardCode ("S08000021" = "S08000031") ("S08000023" = "S08000032"). 


Sort cases by TreatmentNHSBoardCode.

* Year.
String Year (A4).
Compute  year = !FY.

match files
   /file = *
   /Table = !Costs_dir + "Cost_GPOoH_Lookup.sav"
   /By TreatmentNHSBoardCode Year.

Rename Variables Cost_per_consultation =  cost_total_net.
Alter type cost_total_net (F8.2).

* Calculate costs per month.
Compute cost_monthnum = xDate.Month(ConsultationStartDateTime).

Do repeat month = jan_cost feb_cost mar_cost apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost
    /monthnum = 1 to 12.
    If cost_monthnum = monthnum month = cost_total_net.
End repeat.

************************************************************************************************************.
* Variables.

* recid.
String recid (A3).
Compute recid = "OoH".
add value labels recid "OoH" "GP Out of Hours consultation".

* Dates.
Rename Variables  
ConsultationStartDateTime = record_keydate1 
ConsultationEndDateTime = record_keydate2.

 * Split out the time from the date.
Compute keyTime1 = time.hms(xdate.hour(record_keydate1), xdate.minute(record_keydate1), xdate.second(record_keydate1)).
Compute keyTime2 = time.hms(xdate.hour(record_keydate2), xdate.minute(record_keydate2), xdate.second(record_keydate2)).

 * Remove the time part from the date variables so they'll not sort weirdly.
Compute record_keydate1 = record_keydate1 - keyTime1.
Compute record_keydate2 = record_keydate2 - keyTime2.

Alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

* In case keydate is needed as F8.0...
Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate1 record_keydate2 (F8.0).


* SMRType.
Rename Variables ConsultationType = SMRType.
Recode SMRType ("DISTRICT NURSE" = "OOH-DN") ("DOCTOR ADVICE/NURSE ADVICE" = "OOH-Advice")
   ("HOME VISIT" = "OOH-HomeV") ("NHS 24 NURSE ADVICE" = "OOH-NHS24") ("PCEC/PCC" = "OOH-PCC")
   (Else = "OOH-Other").

add Value Labels SMRType
   "OOH-DN" "Out of Hours - District Nurse"
   "OOH-Advice" "Out of Hours - Doctor / Nurse Advice"
   "OOH-HomeV" "Out of Hours - Home Visit"
   "OOH-NHS24" "Out of Hours - NHS24 Nurse Advice"
   "OOH-PCC" "Out of Hours - Primary Care Emergency Centre / Primary Care Centre"
   "OOH-Other" "Out of Hours - Other".

* age.
alter type dob (SDate10).
Compute age = DateDiff(!midFY, dob, "years").

* dob.
Alter type dob (Date12).

 * GP Practice.
Rename Variables (PracticeCode = gpprac).
 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

 * Patient Geography.
Rename Variables (PatientNHSBoardCode PatientDataZone2011 HSCPofResidenceCode = hbrescode DataZone HSCP).

 * Treatment Geography.
Recode TreatmentLocationCode ("UNKNOWN" = "").
Rename Variables (TreatmentNHSBoardCode TreatmentLocationCode = hbtreatcode location).

 * Keep the location descriptions as a lookup.
aggregate outfile = !Year_dir + "GP-OOH-Location-Description-Lookup-20" + !FY + ".sav"
   /Break location
   /LocationDescription = First(TreatmentLocationDescription).

 * DNA.
Recode ConsultationRecorded ("Y" = "1") ("N" = "8").
Rename Variables ConsultationRecorded = attendance_status.

 * Referral Source.
 * Turn Referral source into a flag to save space.
 * This will partly line up with existing refsource.
Recode ReferralSource
   ("WALK-IN" = "1")
   ("PATIENT IS CALLER" = "2")
   ("SAS" = "3")
   ("FAMILY MEMBER/NEIGHBOUR/FRIEND/MEMBER OF PUBLIC" = "4")
   ("OTHER" = "9")
   ("HCP - CPN/DISTRICT NURSE/MIDWIFE" = "B")
   ("HCP - NURSING HOME/CARE HOME/RESIDENTIAL HOME" = "C")
   ("HCP - CHEMIST/PHARMACIST" = "D")
   ("HCP - HOSPITAL" = "E")
   ("HCP - NURSE" = "F")
   ("HCP - LABORATORY" = "G")
   ("HCP - DOCTOR (GP)" = "H")
   ("HCP - OTHER HCP" = "I")
   ("HCP - OTHER OOH SERVICE" = "J")
   ("POLICE/PRISON" = "P")
   ("SOCIAL SERVICES" = "S")
   ("A&E" = "A")
   ("MIU" = "M")
   ("NHS 24" = "N").

Variable Width ReferralSource (5).

Rename Variables ReferralSource = refsource.

 * KIS.
Recode KISAccessed ("Y" = "1") ("N" = "0") (Else = "9").
Value Labels KISAccessed
   1 "Yes"
   0 "No"
   9 "Unknown".

Rename Variables KISAccessed = KIS_accessed.
Variable Labels KIS_accessed "Key Information Summary Accessed".

 * Outcomes.
Rename Variables (Outcome.1 to Outcome.4 = ooh_outcome.1 to ooh_outcome.4).

Variable Labels
   ooh_outcome.1 "Categorised Out of Hours case outcome"
   ooh_outcome.2 "Categorised Out of Hours case outcome"
   ooh_outcome.3 "Categorised Out of Hours case outcome"
   ooh_outcome.4 "Categorised Out of Hours case outcome".

 * Case counter.
Sort cases by CHI GUID.

Compute ooh_CC = 0.
If $Casenum = 1 OR (CHI NE lag(CHI)) ooh_CC = 1.
Do If ooh_CC = 0.
   Do If GUID NE lag(GUID).
      Compute ooh_CC = lag(ooh_CC) + 1.
   Else.
      Compute ooh_CC = lag(ooh_CC).
   End if.
End if.

Variable Labels ooh_CC "Out of Hours case counter".

 * Alter types (quicker if we do them all together).
Alter Type
    keyTime1 keyTime2 (Time6)
    SMRType (A10)
    age (F3.0)
    attendance_status (F1.0)
    refsource (A3)
    KIS_Accessed (F1.0)
    ooh_CC (F1.0).

* sort.
sort cases by chi record_keydate1 keyTime1.

*Reorder and remove unneeded variables.
save outfile = !Year_dir + "GP_OOH_for_Source-20" + !FY + ".zsav"
    /Keep year
    recid
    SMRType
    record_keydate1
    record_keydate2
    keyTime1
    keyTime2
    chi
    gender
    dob
    age
    gpprac
    postcode
    hbrescode
    datazone
    HSCP
    hbtreatcode
    location
    attendance_status
    KIS_Accessed
    refsource
    diag1 To diag6
    ooh_outcome.1 to ooh_outcome.4
    cost_total_net
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
    ooh_CC
    /zcompressed.

get file = !Year_dir + "GP_OOH_for_Source-20" + !FY + ".zsav".

 * HouseKeeping.
 * Delete temp files.
Erase file = !Year_dir + "GPOOH-Temp-1.zsav".
Erase file = !Year_dir + "GPOOH-Temp-2.zsav".

Erase file = !Year_dir + "GP-Diagnosis-Data-" + !FY + ".zsav".
Erase file = !Year_dir + "GP-Outcomes-Data-" + !FY + ".zsav".

 * zip up the raw data.
Host Command = ["gzip '" + !Year_Extracts_dir + "GP-OoH-consultations-extract-20" + !FY + ".csv'"].
