* Encoding: UTF-8.

*Tests for GP OoHs dataset.
get file = !file + 'CMH_for_source-20' + !FY + '.zsav'.

 * Flag to count CHIs.
Recode CHI ("" = 0) (Else = 1) Into Has_CHI.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

 * Flags to count missing values.
If sysmis(dob) No_DoB = 1.

*Flag to count how many episodes in each HB by treatment code. 
If hbtreatcode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbtreatcode = 'S08000016' NHS_Borders = 1. 
If hbtreatcode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbtreatcode = 'S08000019' NHS_Forth_Valley = 1. 
If hbtreatcode = 'S08000020' NHS_Grampian = 1. 
If any(hbtreatcode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbtreatcode = 'S08000022' NHS_Highland = 1.
If any(hbtreatcode, 'S08000023', 'S08000032') NHS_Lanarkshire =1. 
If hbtreatcode = 'S08000024' NHS_Lothian = 1. 
If hbtreatcode = 'S08000025' NHS_Orkney = 1. 
If hbtreatcode = 'S08000026' NHS_Shetland = 1. 
If hbtreatcode = 'S08000028' NHS_Western_Isles = 1. 
If hbtreatcode = 'S08000029' NHS_Fife = 1. 
If hbtreatcode = 'S08000030' NHS_Tayside = 1. 

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran to NHS_Tayside (SYSMIS = 0).

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /n_episodes = n
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2)
    /All_NHS_Ayrshire_and_Arran = Sum(NHS_Ayrshire_and_Arran)
    /All_NHS_Borders = Sum(NHS_Borders)
    /All_NHS_Dumfries_and_Galloway = Sum(NHS_Dumfries_and_Galloway)
    /All_NHS_Forth_Valley = Sum(NHS_Forth_Valley)
    /All_NHS_Grampian = Sum(NHS_Grampian)
    /All_NHS_Greater_Glasgow_and_Clyde = Sum(NHS_Greater_Glasgow_and_Clyde)
    /All_NHS_Highland = Sum(NHS_Highland) 
    /All_NHS_Lanarkshire = Sum(NHS_Lanarkshire)
    /All_NHS_Lothian = Sum(NHS_Lothian)
    /All_NHS_Orkney = Sum(NHS_Orkney)
    /All_NHS_Shetland = Sum(NHS_Shetland)
    /All_NHS_Western_Isles = Sum(NHS_Western_Isles)
    /All_NHS_Fife = Sum(NHS_Fife)
    /All_NHS_Tayside = Sum(NHS_Tayside).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to All_NHS_Tayside
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI record_keydate1 record_keydate2 gender dob hbtreatcode.
select if recid = 'CMH'.

 * Flag to count CHIs.
Recode Anon_CHI ("" = 0) (Else = 1) Into Has_CHI.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

 * Flags to count missing values.
If sysmis(dob) No_DoB = 1.

*Flag to count how many episodes in each HB by treatment code. 
If hbtreatcode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbtreatcode = 'S08000016' NHS_Borders = 1. 
If hbtreatcode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbtreatcode = 'S08000019' NHS_Forth_Valley = 1. 
If hbtreatcode = 'S08000020' NHS_Grampian = 1. 
If any(hbtreatcode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbtreatcode = 'S08000022' NHS_Highland = 1.
If any(hbtreatcode, 'S08000023', 'S08000032') NHS_Lanarkshire =1. 
If hbtreatcode = 'S08000024' NHS_Lothian = 1. 
If hbtreatcode = 'S08000025' NHS_Orkney = 1. 
If hbtreatcode = 'S08000026' NHS_Shetland = 1. 
If hbtreatcode = 'S08000028' NHS_Western_Isles = 1. 
If hbtreatcode = 'S08000029' NHS_Fife = 1. 
If hbtreatcode = 'S08000030' NHS_Tayside = 1. 

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran to NHS_Tayside (SYSMIS = 0).

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /n_episodes = n
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2)
    /All_NHS_Ayrshire_and_Arran = Sum(NHS_Ayrshire_and_Arran)
    /All_NHS_Borders = Sum(NHS_Borders)
    /All_NHS_Dumfries_and_Galloway = Sum(NHS_Dumfries_and_Galloway)
    /All_NHS_Forth_Valley = Sum(NHS_Forth_Valley)
    /All_NHS_Grampian = Sum(NHS_Grampian)
    /All_NHS_Greater_Glasgow_and_Clyde = Sum(NHS_Greater_Glasgow_and_Clyde)
    /All_NHS_Highland = Sum(NHS_Highland) 
    /All_NHS_Lanarkshire = Sum(NHS_Lanarkshire)
    /All_NHS_Lothian = Sum(NHS_Lothian)
    /All_NHS_Orkney = Sum(NHS_Orkney)
    /All_NHS_Shetland = Sum(NHS_Shetland)
    /All_NHS_Western_Isles = Sum(NHS_Western_Isles)
    /All_NHS_Fife = Sum(NHS_Fife)
    /All_NHS_Tayside = Sum(NHS_Tayside).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to All_NHS_Tayside
    /Index Measure (Existing_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
 * Match together.
match files
    /file = SLFexisting
    /file = SLFnew
    /By Measure.
Dataset Name CMHComparison.

 * Close both datasets.
Dataset close SLFnew.
Dataset close SLFexisting.

 * Produce comparisons.
Compute Difference = New_Value - Existing_Value.
Do if Existing_Value NE 0.
    Compute PctChange = Difference / Existing_Value * 100.
End if.
Compute Issue = (abs(PctChange) > 5).
Alter Type Issue (F1.0) PctChange (PCT4.2).

 * Highlight issues.
Crosstabs Measure by Issue.

*Save test file. 
Save Outfile = !file + 'CMH_tests_20' + !FY + '.zsav'
   /zcompressed .


