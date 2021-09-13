* Encoding: UTF-8.

*Tests for Delayed Discharge dataset.
get file = !Year_Extracts_dir + "DD_LinkageFile-20" + !FY + ".zsav".

 * Flag to count CHIs.
add files file = *
    /first = unique_chi
    /by = chi.

Compute Delay = 1.

Recode Primary_Delay_Reason ("9" = 1) (Else = 0) Into Code_9.

*Flag to count how many episodes in each HB by treatment code. 
If hbtreatcode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbtreatcode = 'S08000016' NHS_Borders = 1. 
If hbtreatcode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbtreatcode = 'S08000019' NHS_Forth_Valley = 1. 
If hbtreatcode = 'S08000020' NHS_Grampian = 1. 
If any(hbtreatcode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbtreatcode = 'S08000022' NHS_Highland = 1.
If any(hbtreatcode, 'S08000023', 'S08000032') NHS_Lanarkshire = 1. 
If hbtreatcode = 'S08000024' NHS_Lothian = 1. 
If hbtreatcode = 'S08000025' NHS_Orkney = 1. 
If hbtreatcode = 'S08000026' NHS_Shetland = 1. 
If hbtreatcode = 'S08000028' NHS_Western_Isles = 1. 
If any(hbtreatcode, 'S08000018', 'S08000029') NHS_Fife = 1. 
If any(hbtreatcode, 'S08000027', 'S08000030') NHS_Tayside = 1. 

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_delay_any = sum(Delay)
    /n_delay_code9 = sum(code_9)
    /n_unique_chi = sum(unique_chi)
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
    /All_NHS_Tayside = Sum(NHS_Tayside)
    /prop_code9 = mean(code_9)
    /Earliest_start Earliest_end = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_start Latest_end = Max(keydate1_dateformat keydate2_dateformat).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_delay_any to Latest_end
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid anon_chi keydate1_dateformat keydate2_dateformat Primary_Delay_Reason hbtreatcode.
select if recid = 'DD'.

 * Flag to count CHIs.
add files file = *
    /first = unique_chi
    /by = anon_chi.

Compute Delay = 1.

Recode Primary_Delay_Reason ("9" = 1) (Else = 0) Into Code_9.

*Flag to count how many episodes in each HB by treatment code. 
If hbtreatcode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbtreatcode = 'S08000016' NHS_Borders = 1. 
If hbtreatcode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbtreatcode = 'S08000019' NHS_Forth_Valley = 1. 
If hbtreatcode = 'S08000020' NHS_Grampian = 1. 
If any(hbtreatcode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbtreatcode = 'S08000022' NHS_Highland = 1.
If any(hbtreatcode, 'S08000023', 'S08000032') NHS_Lanarkshire = 1. 
If hbtreatcode = 'S08000024' NHS_Lothian = 1. 
If hbtreatcode = 'S08000025' NHS_Orkney = 1. 
If hbtreatcode = 'S08000026' NHS_Shetland = 1. 
If hbtreatcode = 'S08000028' NHS_Western_Isles = 1. 
If any(hbtreatcode, 'S08000018', 'S08000029') NHS_Fife = 1. 
If any(hbtreatcode, 'S08000027', 'S08000030') NHS_Tayside = 1. 

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_delay_any = sum(Delay)
    /n_delay_code9 = sum(code_9)
    /n_unique_chi = sum(unique_chi)
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
    /All_NHS_Tayside = Sum(NHS_Tayside)
    /prop_code9 = mean(code_9)
    /Earliest_start Earliest_end = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_start Latest_end = Max(keydate1_dateformat keydate2_dateformat).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_delay_any to Latest_end
    /Index Measure (Existing_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
 * Match together.
match files
    /file = SLFexisting
    /file = SLFnew
    /By Measure.
Dataset Name DDComparison.

 * Close both datasets.
Dataset close SLFnew.
Dataset close SLFexisting.

 * Produce comparisons.
Compute Difference = New_Value - Existing_Value.
Do if Existing_Value NE 0.
    Compute PctChange = Difference / Existing_Value * 100.
End if.
Compute Issue = abs(PctChange) > 5.
Alter Type Issue (F1.0) PctChange (PCT4.2).

 * Highlight issues.
Crosstabs Measure by Issue.

*Save test file . 
Save Outfile = !Year_dir + 'DD_tests_20' + !FY + '.zsav'
   /zcompressed .
