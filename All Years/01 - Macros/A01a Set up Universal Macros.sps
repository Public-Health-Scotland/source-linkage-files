* Encoding: UTF-8.
*Run Macros before SLF update.
************************************************************************************************************
** AUTHOR:	James McMahon (james.mcmahon@phs.scot)
** Date:    	01/08/2018
************************************************************************************************************
** Amended by: Jennifer Thom (Jennifer.Thom@phs.scot)
** Date: 22/03/21
** Changes: Switched macro file so there is one universal macro file for each quarterly update. 
                  *and each year will have its own unique year macro. 
************************************************************************************************************.
*Universal Macros for Source Linkage Files - applies to all years. 
*Run A01a Set up Universal macros and then A01b Set up (year) Macro at the beginning of each update.
*Date: 22/03/21. 

*******************************************************.
 * Update Macros *
 * Needs changed every update *
*******************************************************.
* IT Extracts * 
* Replace the number with the CSD ref.
Define !IT_extract_ref()
    "SCTASK0205902"
!EndDefine.

*Latest update month for postcode and gp prac lookups.
Define !LatestUpdate()
   "March_2021"
!EndDefine.

*******************************************************.
* Directories for File Path locations *. 
*******************************************************.
*Directory for all years SLF development. Links to !FY() for updating each financial year.
Define !Year_dir()
   !Quote(!Concat("/conf/sourcedev/Source Linkage File Updates/", !Unquote(!Eval(!FY)), "/"))
!EndDefine.

* Extract files - "home".
*Directory for BO extracts. Links to !Year_dir() for storing raw extracts for each FY.
Define !Year_Extracts_dir()
   !Quote(!Concat(!Unquote(!Eval(!Year_dir)), "Extracts/"))
!EndDefine.

*Secondary extracts storage in case the above is full, or other reasons.
*Main storage folder in HSCDIIP.
Define !SLF_Extracts()
   "/conf/hscdiip/SLF_Extracts/"
!EndDefine.

*Directory for storing lookups created by SLFs. 
*Includes source_postcode_lookup, source_GPPrac_lookup and PracticeDetails.sav.
Define !Lookup_dir_slf()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "Lookups/"))
!EndDefine. 

*Directory for storing cost lookups for DN, CH and GP OOH.
Define !Costs_dir()
    !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "Costs/"))
!EndDefine.

*Directory for storing latest Delayed Discharges extracts. 
Define !Delayed_Discharges_dir()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "Delayed_Discharges/"))
!EndDefine. 

*Directory for storing latest HHG extract. 
Define !HHG_dir()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "HHG/"))
!EndDefine. 

*Directory for storing latest NSU extract.
Define !NSU_dir()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "NSU/"))
!EndDefine.

*Directory for storing latest SPARRA extract.
Define !SPARRA_dir()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "SPARRA/"))
!EndDefine. 

*Directory for storing latest Demographic and Service Use cohorts. 
Define !Cohort_dir()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "Cohorts/"))
!EndDefine. 

*Directory for storing LTC year specific reference files. 
Define !LTCs_dir()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "LTCs/"))
!EndDefine. 

*Directory for storing the All_Deaths file. 
Define !Deaths_dir()
   !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "Deaths/"))
!EndDefine. 

*******************************************************.
* IT extracts. 
*******************************************************.
*Directory for IT extracts.
Define !IT_Extracts_dir()
    !Quote(!Concat(!Unquote(!Eval(!SLF_Extracts)), "IT_extracts/"))
!EndDefine.

*LTC extract.
Define !LTC_extract_file()
    !Quote(!Concat(!Unquote(!Eval(!IT_extracts_dir)), !Unquote(!Eval(!IT_extract_ref)), "_extract_1_LTCs.csv"))
!EndDefine.

*Deaths extract.
Define !Deaths_extract_file()
    !Quote(!Concat(!Unquote(!Eval(!IT_extracts_dir)), !Unquote(!Eval(!IT_extract_ref)), "_extract_2_Deaths.csv"))			
!EndDefine.

*PIS extract.
Define !PIS_extract_file()
    !Quote(!Concat(!Unquote(!Eval(!IT_extracts_dir)), !Unquote(!Eval(!IT_extract_ref)), !Unquote(!Eval(!PIS_extract_number)), !Unquote(!Eval(!altFY)), ".csv"))		
!EndDefine.


*******************************************************.
 * AnonCHI lookup *
 * Should not need changing *
*******************************************************.
 * Locations of the existing Anon_CHI lookups.
Define !CHItoAnonlookup()
    "/conf/hscdiip/01-Source-linkage-files/CHI-to-Anon-lookup.zsav"
!EndDefine.

Define !AnontoCHIlookup()
    "/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav"
!EndDefine.

*******************************************************.
 * Geography Lookup Directories *
 * Will need to be changed when geography files update.
*******************************************************.
*Directory for lookups - should not need changing. 
Define !Global_Lookup_dir()
    "/conf/linkage/output/lookups/Unicode/"
!EndDefine. 

*Directory for Locality. 
Define !Locality_dir()
    "Geography/HSCP Locality/"
!EndDefine. 

*Directory for Scottish Postcode Directory (SPD).
Define !SPD_dir()
    "Geography/Scottish Postcode Directory/"
!EndDefine. 

*Directory for Scottish Index for Multiple Deprivation (SIMD). 
Define !SIMD_dir()
    "Deprivation/"
!EndDefine. 

*Directory for DataZone Populations. 
Define !DataZone_pop_dir()
    "Populations/Estimates/"
!EndDefine. 


*******************************************************.
 * Geography Lookup Files *
 * Will need to be changed when geography files update.
 * They are mainly changed here.
*******************************************************.
*Locality file - will need changing when geography files update. 
Define !Locality_file()
    "HSCP Localities_DZ11_Lookup_20200825.sav"
!EndDefine. 

*SPD file - will need changing when geography files update.
Define !SPD_file()
    "Scottish_Postcode_Directory_2021_1.sav"
!EndDefine. 

*SIMD file - will need changing when geography files update.
Define !SIMD_file()
    "postcode_2021_1_simd2020v2.sav"
!EndDefine.

*DataZone Populations file - will need changing when geography files update.
Define !DataZone_pop_file()
    "DataZone2011_pop_est_2011_2019.sav"
!EndDefine. 


*******************************************************.
 * Geography Lookup Macros *
 * Should only need to change above macros when geography file updates.
*******************************************************.
*Locality Lookup. 
Define !Localities_Lookup()
    !Quote(!Concat(!Unquote(!Eval(!Global_Lookup_dir)), !Unquote(!Eval(!Locality_dir)), !Unquote(!Eval(!Locality_file))))
!EndDefine.

*SPD Lookup. 
Define !SPD_Lookup()
    !Quote(!Concat(!Unquote(!Eval(!Global_Lookup_dir)), !Unquote(!Eval(!SPD_dir)), !Unquote(!Eval(!SPD_file))))
!EndDefine.

*SIMD Lookup. 
Define !SIMD_Lookup()
    !Quote(!Concat(!Unquote(!Eval(!Global_Lookup_dir)), !Unquote(!Eval(!SIMD_dir)), !Unquote(!Eval(!SIMD_file))))
!EndDefine.

*DataZone Population Lookup. 
Define !DataZone_Pop_Lookup
    !Quote(!Concat(!Unquote(!Eval(!Global_Lookup_dir)), !Unquote(!Eval(!DataZone_pop_dir)), !Unquote(!Eval(!DataZone_pop_file))))
!EndDefine. 


*******************************************************.
 * Functional macros *
 * Should not need changing unless something is broken or to update methodology.
*******************************************************.

 * The following two macros are used for creating the old LCA codes
 * They will need updating if the Council area codes change.
Define !CAtoLCA()
Do if ValueLabel(CA2018) = "Aberdeen City".
   Compute LCA = "01".
Else if ValueLabel(CA2018) = "Aberdeenshire".
   Compute LCA = "02".
Else if ValueLabel(CA2018) = "Angus".
   Compute LCA = "03".
Else if ValueLabel(CA2018) = "Argyll and Bute".
   Compute LCA = "04".
Else if ValueLabel(CA2018) = "Scottish Borders".
   Compute LCA = "05".
Else if ValueLabel(CA2018) = "Clackmannanshire".
   Compute LCA = "06".
Else if ValueLabel(CA2018) = "West Dunbartonshire".
   Compute LCA = "07".
Else if ValueLabel(CA2018) = "Dumfries and Galloway".
   Compute LCA = "08".
Else if ValueLabel(CA2018) = "Dundee City".
   Compute LCA = "09".
Else if ValueLabel(CA2018) = "East Ayrshire".
   Compute LCA = "10".
Else if ValueLabel(CA2018) = "East Dunbartonshire".
   Compute LCA = "11".
Else if ValueLabel(CA2018) = "East Lothian".
   Compute LCA = "12".
Else if ValueLabel(CA2018) = "East Renfrewshire".
   Compute LCA = "13".
Else if ValueLabel(CA2018) = "City of Edinburgh".
   Compute LCA = "14".
Else if ValueLabel(CA2018) = "Falkirk".
   Compute LCA = "15".
Else if ValueLabel(CA2018) = "Fife".
   Compute LCA = "16".
Else if ValueLabel(CA2018) = "Glasgow City".
   Compute LCA = "17".
Else if ValueLabel(CA2018) = "Highland".
   Compute LCA = "18".
Else if ValueLabel(CA2018) = "Inverclyde".
   Compute LCA = "19".
Else if ValueLabel(CA2018) = "Midlothian".
   Compute LCA = "20".
Else if ValueLabel(CA2018) = "Moray".
   Compute LCA = "21".
Else if ValueLabel(CA2018) = "North Ayrshire".
   Compute LCA = "22".
Else if ValueLabel(CA2018) = "North Lanarkshire".
   Compute LCA = "23".
Else if ValueLabel(CA2018) = "Orkney Islands".
   Compute LCA = "24".
Else if ValueLabel(CA2018) = "Perth and Kinross".
   Compute LCA = "25".
Else if ValueLabel(CA2018) = "Renfrewshire".
   Compute LCA = "26".
Else if ValueLabel(CA2018) = "Shetland Islands".
   Compute LCA = "27".
Else if ValueLabel(CA2018) = "South Ayrshire".
   Compute LCA = "28".
Else if ValueLabel(CA2018) = "South Lanarkshire".
   Compute LCA = "29".
Else if ValueLabel(CA2018) = "Stirling".
   Compute LCA = "30".
Else if ValueLabel(CA2018) = "West Lothian".
   Compute LCA = "31".
Else if ValueLabel(CA2018) = "Na h-Eileanan Siar".
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
Define !AddHB2018DictionaryInfo (HB = !CMDEND)
 * Copy the labels from the Postcode Lookup file.
Apply Dictionary From !PCDir
    /VarInfo ValLabels = Replace
    /Source variables = HB2018
    /Target variables = !HB.

 * Add extra non official labels.
Add Value Labels !HB
    'S08200001' "Out-with Scotland / RUK"
    'S08200002' "No Fixed Abode"
    'S08200003' "Not Known"
    'S08200004' "Outside UK"
    'S27000001' "Non-NHS Provider/Location"
    'S27000002' "Not Applicable"
    'S08100001' "National Facility (e.g. GJNH)"
    'S08100002' "NHS24"
    'S08100003' "NHS Education for Scotland"
    'S08100004' "NHS Health Scotland"
    'S08100005' "NHS National Services Scotland"
    'S08100006' "NHS Healthcare Improvement Scotland"
    'S08100007' "Scottish Ambulance Service"
    'S08100008' "State Hospital".

!EndDefine.

Define !AddHB2019DictionaryInfo (HB = !CMDEND)
 * Copy the labels from the Postcode Lookup file.
Apply Dictionary From !PCDir
    /VarInfo ValLabels = Replace
    /Source variables = HB2019
    /Target variables = !HB.

* Add extra non official labels.
Add Value Labels !HB
    'S08200001' "Out-with Scotland / RUK"
    'S08200002' "No Fixed Abode"
    'S08200003' "Not Known"
    'S08200004' "Outside UK"
    'S27000001' "Non-NHS Provider/Location"
    'S27000002' "Not Applicable"
    'S08100001' "National Facility (e.g. GJNH)"
    'S08100002' "NHS24"
    'S08100003' "NHS Education for Scotland"
    'S08100004' "NHS Health Scotland"
    'S08100005' "NHS National Services Scotland"
    'S08100006' "NHS Healthcare Improvement Scotland"
    'S08100007' "Scottish Ambulance Service"
    'S08100008' "State Hospital".

!EndDefine.

************************************************************************************************************.
 * This will automatically set from the FY macro above for example for !FY = "1718" it will produce "2017".
Define !altFY()
   !Quote(!Concat('20', !SubStr(!Unquote(!Eval(!FY)), 1, 2)))
!EndDefine.

 * These will also automatically set from the macro above, for example for !FY = "1718" it will produce Date.DMY(30, 9, 2017).
Define !midFY()
   Date.DMY(30, 9, !Unquote(!Eval(!altFY)))
!EndDefine.

Define !startFY()
   Date.DMY(01, 4, !Unquote(!Eval(!altFY)))
!EndDefine.

Define !endFY()
   Date.DMY(31, 03, !Unquote(!Eval(!altFY)) + 1)
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



