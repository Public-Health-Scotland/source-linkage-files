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

* CD to working directory.
CD  '/conf/sourcedev/James/Care Homes'.

GET DATA  /Type = TXT
   /File = "care_home_for_source.csv"
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
      PracticeCode A6
      UPINumber A10
      AgeatMidpointofFinancialYear F3.0
      ClientDoB A10
      GenderDescription A6
      NHSBoardofResidenceCode A9
      ClientCouncilAreaCode A2
      ClientDataZone2001 A9
      ClientDataZone2011 A9
      ClientPostcode A7
      CareHomeAdmissionDate A10
      CareHomeDischargeDate A10
      CareHomeName A39
      CareHomeCouncilAreaCode A2
      CareHomePostcode A7
      ReasonforAdmission F2.0
      NursingCareProvision A1.
Cache.

 * Format dates so they are usable and readable.
alter type CareHomeAdmissionDate CareHomeDischargeDate ClientDoB (SDate10).

 * Fix end dates, shouldn't be after the end of the financial year.
Compute #FinancialYearEndDate = date.dmy(31, 03, FinancialYear + 1).

if (CareHomeDischargeDate GE #FinancialYearEndDate) CareHomeDischargeDate = #FinancialYearEndDate.

 * Save the 'actual admission and discharge dates'.
Compute Admission = CareHomeAdmissionDate.
Compute Discharge = CareHomeDischargeDate.

 * Set the admission dates to be within the Financial year.
Compute #FinancialYearStartDate = date.dmy(01, 04, FinancialYear).

if (CareHomeAdmissionDate LE #FinancialYearStartDate) CareHomeAdmissionDate = #FinancialYearStartDate.

 * Try to fix any erronous dates if this doesn't make sense it will be deleted next anyway.
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

 * Tidy up care home names.
insert file = "a4_Tidy_Care_Home_Names.sps" Error = Stop.

 * Fix some issues with gender we could possibly do better than this but for now just sort out "Not known" gender if we can.
Sort cases by UPINumber GenderDescription.
 * If we're looking at the same patient and they have an 'unknown' gender and their previous record's Gender matches their CHI derived gender then set that as their gender.
If (UPINumber = Lag(UPINumber) AND (GenderDescription = "NOT KN") AND (mod(number(char.substr(lag(UPINumber), 9, 1), F1.0), 2) = (GenderDescription = "MALE")))  GenderDescription = Lag(GenderDescription).

 * Get a warning here as lag on the first case returns a sysmiss and confuses the rest of the functions.
execute.

 * Aggregate to unique stays.
aggregate outfile = *
   /Break FinancialYear SendingCouncilAreaCode UPINumber Counter AgeatMidpointofFinancialYear ClientDoB GenderDescription 
     NHSBoardofResidenceCode ClientCouncilAreaCode ClientDataZone2001 ClientDataZone2011 ClientPostcode CareHomeName CareHomePostcode CareHomeCouncilAreaCode
   /CareHomeAdmissionDate = min(CareHomeAdmissionDate)
   /CareHomeDischargeDate = max(CareHomeDischargeDate)
   /Admission = min(admission)
   /Discharge = max(discharge)
   /ReasonForAdmission NursingCareProvision PracticeNHSBoardCode PracticeCode  
       = Last(ReasonforAdmission NursingCareProvision PracticeNHSBoardCode PracticeCode).

 * Clean up any overlapping stays, take the most recent one to be more accurate.
Sort cases by UPINumber (A) CareHomeAdmissionDate CareHomeDischargeDate (D).
Do If (UPINumber = lag(UPINumber)) AND (CareHomeDischargeDate > lag(CareHomeAdmissionDate)).
   Compute CareHomeDischargeDate = lag(CareHomeAdmissionDate).
   Compute Discharge = lag(Admission).
End If.

 * Calculate the total stay for the episode as well as the stay for the financial year.
Compute stay = DateDiff(Discharge, Admission, "days").
Compute yearStay = DateDiff(CareHomeDischargeDate, CareHomeAdmissionDate, "days").

 * Get rid of any record where dates are still wrong.
Select if stay > 0. 

save outfile= "CareHomeTemp.zsav"
   /zcompressed.

insert file = "03_2_care_home_for_source_JMc (Costing).sps" Error = Stop.
insert file = "03_3_care_home_for_source_JMc (Variables).sps" Error = Stop.

 * Number of new variables = 4
   care home admission reason
   sending LCA
   care home LCA
   care home name

 * Test  Code to link to source linkage.
add files 
   /file = "/conf/hscdiip/01-Source-linkage-files/source-episode-file-201516.sav"
   /file = "CareHomeForSource.zsav".

Sort cases by CHI keydate1_dateformat recid.
