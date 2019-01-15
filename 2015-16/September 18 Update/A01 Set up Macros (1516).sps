* Encoding: UTF-8.
************************************************************************************************************
                                                   NSS (ISD)
************************************************************************************************************
** AUTHOR:	James McMahon (j.mcmahon1@nhs.net)
** Date:    	01/08/2018
************************************************************************************************************
** Amended by:         
** Date:
** Changes:               
************************************************************************************************************.
 * Set the Financial Year.
Define !FY()
   "1516"
!EndDefine.

 * Set the next FY, needed for SPARRA (and HHG).
Define !NextFY ()
    "1617"
!EndDefine.

Define !File()
   !Quote(!Concat("/conf/sourcedev/Source Linkage File Updates/", !Unquote(!Eval(!FY)), "/"))
!EndDefine.

* Extract files - "home".
Define !Extracts()
   !Quote(!Concat(!Unquote(!Eval(!File)), "Extracts/"))
!EndDefine.

 * Secondary extracts storage in case the above is full, or other reasons.
Define !Extracts_Alt()
   "/conf/hscdiip/DH-Extract/"
!EndDefine.


Define !Costs_Lookup()
    !Quote(!Concat(!Unquote(!Eval(!Extracts_Alt)), "Costs/"))
!EndDefine.


 * Replace the number with the CSD ref.
Define !CSDRef()
    "SCTASK0076848"
!EndDefine.

Define !CSDExtractLoc()
    !Quote(!Concat(!Unquote(!Eval(!Extracts_Alt)), !Unquote(!Eval(!CSDRef))))
!EndDefine.

 * Location of source lookups.
Define !Lookup()
   "/conf/irf/05-lookups/04-geography/"
!EndDefine.

 * Locations of the existing Anon_CHI lookups.
Define !CHItoAnonlookup()
    "/conf/hscdiip/01-Source-linkage-files/CHI-to-Anon-lookup.zsav"
!EndDefine.

Define !AnontoCHIlookup()
    "/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav"
!EndDefine.


************************************************************************************************************.
 * This will automatically set from the FY macro above for example for !FY = "1718" it will produce "2017".
Define !altFY()
   !Quote(!Concat('20', !SubStr(!Unquote(!Eval(!FY)), 1, 2)))
!EndDefine.

 * This will also automatically set from the macro above, for example for !FY = "1718" it will produce Date.DMY(30, 9, 2017).
Define !midFY()
   Date.DMY(30, 9, !Unquote(!Eval(!altFY)))
!EndDefine.

************************************************************************************************************.

 * This macro is used in a number of places to calculate bed days per month.
 * Parameters:
 * Month_abbr (Required) - The month as a 3 char abbreviation e.g. 'Apr'.
 * AdmissionVar (Optional) - The admission variable in date format (if not supplied will use keydate1_dateformat).
 * DischargeVar (Optional) - The discharge variable in date format (if not supplied will use keydate2_dateformat).
 * DelayedDischarge (Optional)
 * 0 (default value) - count the first day but not the last.
 * 1 - count the last day but not the first (this is the methodology for Delayed Discharge beddays).
 
Define !BedDaysPerMonth (Month_abbr = !Tokens(1) 
    /AdmissionVar = !Default(keydate1_dateformat) !Tokens(1)
    /DischargeVar = !Default(keydate2_dateformat) !Tokens(1)
    /DelayedDischarge = !Default(0) !Tokens(1))

 * Compute the month number from the name abbreviation.
Compute #MonthNum = xdate.Month(Number(!Quote(!Concat(!Month_abbr, "-00")), MOYR6)).

 * Find out which year we need e.g for FY 1718: Apr - Dec = 2018, Jan - Mar = 2018.
Do if (#MonthNum >= 4).
    Compute #Year = !Concat("20", !substr(!Unquote(!Eval(!FY)), 1, 2)).
Else.
    Compute #Year = !Concat("20", !substr(!Unquote(!Eval(!FY)), 3, 2)).
End if.

 * Now we have the year work out the start and end dates for the month.
Compute #StartOfMonth = Date.DMY(1, #MonthNum, #Year).
Compute #EndOfMonth = Date.DMY(1, #MonthNum + 1, #Year) - time.days(1).

 * Set the names of the variable for this month e.g. April_beddays.
 * And then create the variable.
!Let !BedDays = !Concat(!Month_abbr, "_beddays").
Numeric !BedDays (F2.0).

 * Go through all possibilities to decide how many days to be allocated.
Do if !AdmissionVar LE #StartOfMonth.
	Do if !DischargeVar GT #EndOfMonth.
		* They were in hospital throughout this month.
		* This will be the maximum number of days in the month.
		Compute !BedDays = DateDiff(#EndOfMonth, #StartOfMonth, "days") + 1.
	Else if !DischargeVar LE #StartOfMonth.
		* The whole record occurred before the month began.
		Compute !BedDays = 0.
	Else.
		* They were discharged at some point in the month.
		Compute !BedDays = DateDiff(!DischargeVar, #StartOfMonth, "days").
	End If.
 * If we're here they were admitted during the month.
Else if !AdmissionVar LE #EndOfMonth.
	Do if !DischargeVar GT #EndOfMonth.
		Compute !BedDays = DateDiff(#EndOfMonth, !AdmissionVar, "days") + 1.
	Else.
		* Admitted and discharged within this month.
		Compute !BedDays = DateDiff(!DischargeVar, !AdmissionVar, "days").
	End If.
Else.
	* They were admitted in a future month.
	Compute !BedDays = 0.
End If.

 * If we are looking at Delayed Discharge records, we should count the last day and not the first.
 * We achieve this by taking a day from the first month and adding it to the last.
!If (!DelayedDischarge = 1) !Then
    Do if xdate.Month(!AdmissionVar) = xdate.Month(date.MOYR(#MonthNum, #Year))
        and xdate.Year(!AdmissionVar) =  #Year.
        Compute !BedDays = !BedDays - 1.
    End if.
    
    Do if xdate.Month(!DischargeVar) = xdate.Month(date.MOYR(#MonthNum, #Year))
        and xdate.Year(!DischargeVar) =  #Year.
        Compute !BedDays = !BedDays + 1.
    End if.
!ifEnd.

 * Tidy up the variable.
Variable Width !Beddays (5).
Variable Level !Beddays (Scale).

!EndDefine.


