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
   "1819"
!EndDefine.

* Set the next FY, needed for SPARRA (and HHG).
Define !NextFY ()
    "1920"
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

* Geography file lookups  - these will sometimes need updating.

 * Localities lookup file.
Define !LocalitiesLookup()
	!Quote(!Concat(!Unquote(!Eval(!Lookup)), "01-locality/Locality_lookup_source.sav")) 
!EndDefine.

 * Most up to date Postcode directory.
Define !PCDir()
   "/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2018_2.sav"
!EndDefine.

 * Most up to date Urban-Rural / Postcode lookup.
Define !URLookup()
   "/conf/linkage/output/lookups/Unicode/Geography/Urban Rural Classification/postcode_urban_rural_2016.sav"
!EndDefine.

 * Most up to date SIMD / Postcode lookup.
Define !SIMDLookup()
   "/conf/linkage/output/lookups/Unicode/Deprivation/postcode_2018_2_simd2016.sav"
!EndDefine.

 * Most up to date DataZone Population estimates.
Define !DataZone_Pops()
   "/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2011_pop_est_2011_2017.sav"
!EndDefine.

 * The following two macros are used for creating the old LCA codes
 * They will need updating if the Council area codes change.
Define !CA2011toLCA()
	Do if ValueLabel(CA2011) = "Aberdeen City".
	   Compute LCA = "01".
	Else if ValueLabel(CA2011) = "Aberdeenshire".
	   Compute LCA = "02".
	Else if ValueLabel(CA2011) = "Angus".
	   Compute LCA = "03".
	Else if ValueLabel(CA2011) = "Argyll and Bute".
	   Compute LCA = "04".
	Else if ValueLabel(CA2011) = "Scottish Borders".
	   Compute LCA = "05".
	Else if ValueLabel(CA2011) = "Clackmannanshire".
	   Compute LCA = "06".
	Else if ValueLabel(CA2011) = "West Dunbartonshire".
	   Compute LCA = "07".
	Else if ValueLabel(CA2011) = "Dumfries and Galloway".
	   Compute LCA = "08".
	Else if ValueLabel(CA2011) = "Dundee City".
	   Compute LCA = "09".
	Else if ValueLabel(CA2011) = "East Ayrshire".
	   Compute LCA = "10".
	Else if ValueLabel(CA2011) = "East Dunbartonshire".
	   Compute LCA = "11".
	Else if ValueLabel(CA2011) = "East Lothian".
	   Compute LCA = "12".
	Else if ValueLabel(CA2011) = "East Renfrewshire".
	   Compute LCA = "13".
	Else if ValueLabel(CA2011) = "City of Edinburgh".
	   Compute LCA = "14".
	Else if ValueLabel(CA2011) = "Falkirk".
	   Compute LCA = "15".
	Else if ValueLabel(CA2011) = "Fife".
	   Compute LCA = "16".
	Else if ValueLabel(CA2011) = "Glasgow City".
	   Compute LCA = "17".
	Else if ValueLabel(CA2011) = "Highland".
	   Compute LCA = "18".
	Else if ValueLabel(CA2011) = "Inverclyde".
	   Compute LCA = "19".
	Else if ValueLabel(CA2011) = "Midlothian".
	   Compute LCA = "20".
	Else if ValueLabel(CA2011) = "Moray".
	   Compute LCA = "21".
	Else if ValueLabel(CA2011) = "North Ayrshire".
	   Compute LCA = "22".
	Else if ValueLabel(CA2011) = "North Lanarkshire".
	   Compute LCA = "23".
	Else if ValueLabel(CA2011) = "Orkney Islands".
	   Compute LCA = "24".
	Else if ValueLabel(CA2011) = "Perth and Kinross".
	   Compute LCA = "25".
	Else if ValueLabel(CA2011) = "Renfrewshire".
	   Compute LCA = "26".
	Else if ValueLabel(CA2011) = "Shetland Islands".
	   Compute LCA = "27".
	Else if ValueLabel(CA2011) = "South Ayrshire".
	   Compute LCA = "28".
	Else if ValueLabel(CA2011) = "South Lanarkshire".
	   Compute LCA = "29".
	Else if ValueLabel(CA2011) = "Stirling".
	   Compute LCA = "30".
	Else if ValueLabel(CA2011) = "West Lothian".
	   Compute LCA = "31".
	Else if ValueLabel(CA2011) = "Na h-Eileanan Siar".
	   Compute LCA = "32".
	End If.
!EndDefine.

 * This 'might' need updating if the Council areas change.
Define !AddLCADictionaryInfo (LCA = !CMDEND)
   Value Labels !LCA
      '01' "Aberdeen City"
      '02' "Aberdeenshire"
      '03' "Angus"
      '04' "Argyll and Bute"
      '05' "Scottish Borders"
      '06' "Clackmannanshire"
      '07' "West Dunbartonshire"
      '08' "Dumfries and Galloway"
      '09' "Dundee City"
      '10' "East Ayrshire"
      '11' "East Dunbartonshire"
      '12' "East Lothian"
      '13' "East Renfrewshire"
      '14' "City of Edinburgh"
      '15' "Falkirk"
      '16' "Fife"
      '17' "Glasgow City"
      '18' "Highland"
      '19' "Inverclyde"
      '20' "Midlothian"
      '21' "Moray"
      '22' "North Ayrshire"
      '23' "North Lanarkshire"
      '24' "Orkney Islands"
      '25' "Perth and Kinross"
      '26' "Renfrewshire"
      '27' "Shetland Islands"
      '28' "South Ayrshire"
      '29' "South Lanarkshire"
      '30' "Stirling"
      '31' "West Lothian"
      '32' "Na h-Eileanan Siar"
!EndDefine.

 * This will only need updating if the name of the Health Board variable changes.
 * Change '/Source variables = HBXXXX' in the below.
Define !AddHBDictionaryInfo (HB = !CMDEND)
	* Copy the labels from the Postcode Lookup file.
	Apply Dictionary From !PCDir
		/VarInfo ValLabels = Replace
		/Source variables = HB2018 
		/Target variables = !HB.
		
	* Add extra non official labels.
    Add Value Labels !HB
        'S08200001' 'Out-with Scotland'
        'S08200002' 'No Fixed Abode'
        'S08200003' 'Not Known'
        'S08200004' 'Outside UK'.
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
