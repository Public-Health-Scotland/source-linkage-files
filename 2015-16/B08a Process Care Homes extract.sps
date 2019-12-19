* Encoding: UTF-8.
************************************************************************************************************
                                                   NSS (ISD)
************************************************************************************************************
** AUTHOR:	James McMahon (j.mcmahon1@nhs.net)
** Date:    	01/05/2018
************************************************************************************************************
** Amended by:         
** Date:
** Changes:               
************************************************************************************************************.
********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA  /Type = TXT
   /File = !Extracts + "Care-Home-full-extract-20" + !FY + ".csv"
   /Encoding = 'UTF8'
   /Delimiters = ","
   /Qualifier = '"'
   /Arrangement = DELIMITED
   /Firstcase = 2
   /Variables=
      FinancialYear F4.0
      FinancialQuarter F1.0
      SendingCouncilAreaCode A2
      PracticeNHSBoardCode A9
      PracticeCode A5
      UPINumber A10
      AgeatMidpointofFinancialYear F3.0
      ClientDoB A10
      GenderDescription A6
      NHSBoardofResidenceCode A9
      ClientCouncilAreaCode A2
      ClientPostcode A8
      CareHomeAdmissionDate A10
      CareHomeDischargeDate A10
      CareHomeName A73
      CareHomeCouncilAreaCode A2
      CareHomePostcode A7
      ReasonforAdmission F2.0
      NursingCareProvision A1.
Cache.

 * Format dates so they are usable and readable.
alter type CareHomeAdmissionDate CareHomeDischargeDate ClientDoB (SDate10).

 * Fix end dates, shouldn't be after the end of the financial year.
Compute #FinancialYearEndDate = date.dmy(31, 03, Number(!altFY, F4.0) + 1).

if (CareHomeDischargeDate GE #FinancialYearEndDate) CareHomeDischargeDate = #FinancialYearEndDate.

 * Save the 'actual admission and discharge dates'.
Compute Admission = CareHomeAdmissionDate.
Compute Discharge = CareHomeDischargeDate.

 * Set the admission dates to be within the Financial year.
Compute #FinancialYearStartDate = date.dmy(01, 04, Number(!altFY, F4.0)).

if (CareHomeAdmissionDate LE #FinancialYearStartDate) CareHomeAdmissionDate = #FinancialYearStartDate.

 * Try to fix any erroneous dates if this doesn't make sense it will be deleted next anyway.
If Admission < ClientDob Admission = DateSum(CareHomeAdmissionDate, 100, "years").
 * Remove any records with obviously wrong dates.
If (CareHomeAdmissionDate > CareHomeDischargeDate) OR (CareHomeAdmissionDate > #FinancialYearEndDate) OR (Discharge < #FinancialYearStartDate) OR (Admission < ClientDob) BadDates = 1.
Select if Sysmiss(BadDates).

alter type Admission Discharge (SDate10).

 * Flag records which have a break between them.
sort cases by UPINumber FinancialQuarter CareHomeAdmissionDate CareHomeDischargeDate.

if UPINumber = lag(UPINumber) Days = DATEDIFF(CareHomeAdmissionDate,(lag(CareHomeDischargeDate)),"days").

compute break_ascending = 0.
if days ge 2 break_ascending = 1.

 * Currently the first episode for each person is not being flagged as distinct so repeat process above but in reverse.
sort cases by UPINumber FinancialQuarter CareHomeDischargeDate CareHomeAdmissionDate (D).

compute days = 0.
if UPINumber = lag(UPINumber) Days = DATEDIFF(CareHomeDischargeDate,(lag(CareHomeAdmissionDate)),"days").

compute break_descending = 0.
if days le -2 break_descending = 1.

sort cases by UPINumber FinancialQuarter CareHomeAdmissionDate CareHomeDischargeDate.

 * Combine break variables for first record.
if UPINumber ne lag(UPINumber) break_ascending = break_descending.

 * So now records which have the same dates or the dates run directly from one to the next, will be flagged 0, and Distinct stays will be flagged as 1, on the break_ascending variable.

 * Create counters for unique stays.
if $casenum = 1 or UPINumber ne lag(UPINumber) counter = 1.
if sysmis(counter) counter = lag(counter) + 1.

 * Correct counter so the counter always equals the last counter number for records with the same or overlapping dates.
 * This breaks it as a 'count' but does uniquely identify episodes per UPI.
if break_ascending = 0 counter = 0.
if (UPINumber =  lag(UPINumber)) and (counter = 0) counter = lag(counter).
execute.

save outfile= !File + "Care-Home-Temp-1.zsav"
   /zcompressed.
get file = !File + "Care-Home-Temp-1.zsav".

********************************************************************************************************.
********************************************************************************************************.
 * Tidy up care home names.

 * Run the Python function 'capwords' on CareHomeName.
 * This will capitalise each word for uniformity and will improve matching.
 * https://docs.python.org/2/library/string.html#string-functions

SPSSINC TRANS RESULT=CareHomeName Type=73
   /FORMULA "string.capwords(CareHomeName)".

 * First get a count of how often individual names are used.
Aggregate
   /break SendingCouncilAreaCode CareHomePostcode CareHomeName CareHomeCouncilAreaCode 
   /RecordsPerName = n.

 * Find out many authorities are using particular versions of names.
Aggregate outfile = * Mode = AddVariables Overwrite = Yes
   /break CareHomePostcode CareHomeName CareHomeCouncilAreaCode 
   /RecordsPerName = Sum(RecordsPerName)
   /DiffSendingAuthorities = n.

 * Created a weighted count, which means multiple authorities using the same name is more powerful, if they have a blank postcode or CA code give them zero weight.
Compute weighted_count = RecordsPerName * DiffSendingAuthorities * not(any('', CareHomePostcode, CareHomeCouncilAreaCode)).

*******************************************************************************************************.
Sort Cases by CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /In = AccurateData1
   /By CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
Frequencies AccurateData1.
* 16.7% Match the lookup.
********************************************************************************************************.

 * Fill in any blank CouncilAreaCodes which we can be reasonably sure about.
Sort cases by SendingCouncilAreaCode (A) CareHomeName (A) AccurateData1 (D) weighted_count (D).
Aggregate outfile = * Mode = AddVariables Overwrite = Yes
   /Presorted
   /break = SendingCouncilAreaCode CareHomeName
   /CareHomeCouncilAreaCode = First(CareHomeCouncilAreaCode).
 * Filled in about 2000 blanks

*******************************FIX NAMES*************************************************************************.
 * Guess some possible names for ones which don't match the lookup.
String TestName1 TestName2(A73).
Do if AccurateData1 = 0.
    * Try adding 'Care Home' or 'Nursing Home' on the end.
   Compute TestName1 = Concat(Rtrim(CareHomeName), " Care Home").
   Compute TestName2 = Concat(Rtrim(CareHomeName), " Nursing Home").
    * If they have the above name ending already, try removing / replacing it.
   Do if char.index(CareHomeName, "Care Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Care Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Care Home", "Nursing Home").
   Else if char.index(CareHomeName, "Nursing Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing Home", "Care Home").
   Else if char.index(CareHomeName, "Nursing") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing", "Care Home").
   * If ends in brackets replace it.
   Else if char.index(CareHomeName, "(") > 1.
      Compute TestName1 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Care Home").
      Compute TestName2 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Nursing Home").
   End if.
End if.
*******************************************************************************************************.
 * Check if TestName1 makes the record match the lookup.
Sort Cases by CareHomePostcode CareHomeCouncilAreaCode TestName1.
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /Rename (CareHomeName = TestName1)
   /In = TestName1Correct
   /By CareHomePostcode CareHomeCouncilAreaCode TestName1.

*******************************************************************************************************.
 * Check if TestName2 makes the record match the lookup.
Sort Cases by CareHomePostcode CareHomeCouncilAreaCode TestName2.
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /Rename (CareHomeName = TestName2)
   /In = TestName2Correct
   /By CareHomePostcode CareHomeCouncilAreaCode TestName2.

 * If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 AND TestName2Correct = 0.
   Compute CareHomeName = TestName1.
Else If TestName2Correct = 1 AND TestName1Correct = 0.
   Compute CareHomeName = TestName2.
End If.
Execute.
Delete Variables TestName1 TestName2 TestName1Correct TestName2Correct.

*******************************************************************************************************.
 * See which match now.
Sort Cases by CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /In = AccurateData2
   /By CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
Frequencies AccurateData2.
* 16.7% Match the lookup.

******************************FIX POSTCODES**************************************************************************.
 * Recalculate the weighted count.
Compute weighted_count = RecordsPerName * DiffSendingAuthorities * not(any('', CareHomePostcode, CareHomeCouncilAreaCode)).

 * Sort so the most likely postcode is at the top for each LA / Care home name combo.
 * We prefer a match from the lookup first if none then use the most submitted.
Sort cases by CareHomeCouncilAreaCode (A) CareHomeName (A) AccurateData2 (D) weighted_count (D).

 * Use the most likely postcode. Overwriting different ones. (On first try this 'removed' about 100).
Aggregate outfile = * Mode = AddVariables Overwrite = Yes
   /Presorted
   /break = CareHomeCouncilAreaCode CareHomeName
   /CareHomePostcode = First(CareHomePostcode).

*******************************************************************************************************.
Sort Cases by CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /In = AccurateData3
   /By CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
Frequencies AccurateData3.
* Now 17.9% Match the lookup.
********************************************************************************************************.

*******************************FIX NAMES*************************************************************************.
 * Guess some possible names for ones which don't match the lookup.
String TestName1 TestName2(A73).
Do if AccurateData3 = 0.
    * Try adding 'Care Home' or 'Nursing Home' on the end.
   Compute TestName1 = Concat(Rtrim(CareHomeName), " Care Home").
   Compute TestName2 = Concat(Rtrim(CareHomeName), " Nursing Home").
    * If they have the above try removing / replacing it.
   Do if char.index(CareHomeName, "Care Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Care Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Care Home", "Nursing Home").
   Else if char.index(CareHomeName, "Nursing Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing Home", "Care Home").
   Else if char.index(CareHomeName, "Nursing") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing", "Care Home").
   * If ends in brackets replace it.
   Else if char.index(CareHomeName, "(") > 1.
      Compute TestName1 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Care Home").
      Compute TestName2 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Nursing Home").
   End if.
End if.
*******************************************************************************************************.
 * Check if TestName1 makes the record match the lookup.
Sort Cases by CareHomePostcode CareHomeCouncilAreaCode TestName1.
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /Rename (CareHomeName = TestName1)
   /In = TestName1Correct
   /By CareHomePostcode CareHomeCouncilAreaCode TestName1.

*******************************************************************************************************.
 * Check if TestName2 makes the record match the lookup.
Sort Cases by CareHomePostcode CareHomeCouncilAreaCode TestName2.
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /Rename (CareHomeName = TestName2)
   /In = TestName2Correct
   /By CareHomePostcode CareHomeCouncilAreaCode TestName2.

*******************************************************************************************************.
 * If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 AND TestName2Correct = 0.
   Compute CareHomeName = TestName1.
Else If TestName2Correct = 1 AND TestName1Correct = 0.
   Compute CareHomeName = TestName2.
End If.
Execute.
Delete Variables TestName1 TestName2 TestName1Correct TestName2Correct.

*******************************************************************************************************.
 * See which match now.
Sort Cases by CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /In = AccurateData4
   /By CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
Frequencies AccurateData4.
* 16.7% Match the lookup.

******************************FIX POSTCODES**************************************************************************.
 * Recheck Postcodes as we may have some matches now that we weren't using before.
 * Recalculate the weighted count.
Compute weighted_count = RecordsPerName * DiffSendingAuthorities * not(any('', CareHomePostcode, CareHomeCouncilAreaCode)).

 * Sort so the most likely postcode is at the top for each LA / Care home name combo.
 * We prefer a match from the lookup first if none then use the most submitted.
Sort cases by CareHomeCouncilAreaCode (A) CareHomeName (A) AccurateData4 (D) weighted_count (D).

 * Use the most likely postcode. Overwriting different ones. (On first try this 'removed' about 100).
Aggregate outfile = * Mode = AddVariables Overwrite = Yes
   /Presorted
   /break = CareHomeCouncilAreaCode CareHomeName
   /CareHomePostcode = First(CareHomePostcode).

*******************************************************************************************************.
Sort Cases by CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /In = AccurateData5
   /By CareHomePostcode CareHomeName CareHomeCouncilAreaCode .
* Now 30.6% Match the lookup.
********************************************************************************************************.
Frequencies AccurateData1 AccurateData2 AccurateData3 AccurateData4 AccurateData5.

Delete Variables RecordsPerName DiffSendingAuthorities weighted_count AccurateData1 AccurateData2 AccurateData3 AccurateData4.
Rename Variables AccurateData5 = LookupMatch.
********************************************************************************************************.
********************************************************************************************************.

 * Fix some issues with gender we could possibly do better than this but for now just sort out "Not known" gender if we can.
Sort cases by UPINumber GenderDescription.
 * If we're looking at the same patient and they have an 'unknown' gender and their previous record's Gender matches their CHI derived gender then set that as their gender.
Do If (UPINumber = Lag(UPINumber) AND (GenderDescription = "NOT KN")).
   If (mod(number(char.substr(lag(UPINumber), 9, 1), F1.0), 2) = (GenderDescription = "MALE")) GenderDescription = Lag(GenderDescription).
End if.

 * Get a warning here as lag on the first case returns a sysmiss and confuses the rest of the functions.
save outfile= !File + "Care-Home-Temp-2.zsav"
   /zcompressed.
get file = !File + "Care-Home-Temp-2.zsav".

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(PracticeCode, 1, 1), "A", "Z").
   Compute PracticeCode = "99995".
End if. 
Alter Type PracticeCode (F5.0).

 * Set blanks as missing so they will be ignored by the aggregate.
Recode NHSBoardofResidenceCode (" " = "-").
Recode ClientCouncilAreaCode (" " = "-").
Recode ClientPostcode (" " = "-").
Recode NursingCareProvision (" " = "-").
Recode GenderDescription ("" = "-").
Missing Values NHSBoardofResidenceCode ClientCouncilAreaCode ClientPostcode NursingCareProvision GenderDescription ("-").

 * Aggregate to unique stays.
aggregate outfile = *
   /Break FinancialYear SendingCouncilAreaCode UPINumber Counter CareHomeName CareHomePostcode CareHomeCouncilAreaCode
    /Age = Last(AgeatMidpointofFinancialYear)
    /ClientDoB = Last(ClientDoB)
    /GenderDescription = Last(GenderDescription)
    /NHSBoardofResidenceCode = Last(NHSBoardofResidenceCode)
    /ClientCouncilAreaCode = Last(ClientCouncilAreaCode)
    /ClientPostcode = Last(ClientPostcode)
   /CareHomeAdmissionDate = min(CareHomeAdmissionDate)
   /CareHomeDischargeDate = max(CareHomeDischargeDate)
   /Admission = min(admission)
   /Discharge = max(discharge)
   /ReasonForAdmission NursingCareProvision PracticeCode  
       = Last(ReasonforAdmission NursingCareProvision PracticeCode).

 * Restore the blanks.
Recode NHSBoardofResidenceCode ("-" = "").
Recode ClientCouncilAreaCode ("-" = "").
Recode ClientPostcode ("-" = "").
Recode NursingCareProvision ("-" = "").
Recode GenderDescription ("" = "-").
Missing Values NHSBoardofResidenceCode ClientCouncilAreaCode ClientPostcode NursingCareProvision GenderDescription ().

 * Clean up any overlapping stays, take the most recent one to be more accurate.
Sort cases by UPINumber (A) CareHomeAdmissionDate CareHomeDischargeDate (D).
Do If (UPINumber = lag(UPINumber)) AND (CareHomeDischargeDate > lag(CareHomeAdmissionDate)).
   Compute CareHomeDischargeDate = lag(CareHomeAdmissionDate).
   Compute Discharge = lag(Admission).
End If.

 * Calculate the total stay for the episode as well as the stay for the financial year (include the last day). 
Compute stay = DateDiff(Discharge, Admission, "days").

Compute yearStay = DateDiff(CareHomeDischargeDate, CareHomeAdmissionDate, "days").

 * Get rid of any record where dates are still wrong.
Descriptives stay yearstay.
Select if stay > 0. 

save outfile = !File + "Care-Home-Temp-3.zsav"
   /zcompressed.
get file = !File + "Care-Home-Temp-3.zsav".

