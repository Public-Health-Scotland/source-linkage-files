* Encoding: UTF-8.
*Tests for A&E dataset.

get file = !Year_dir + 'a&e_for_source-20' + !FY + '.zsav'.

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

*Flag to count how many episodes in each HB by rescode. 
If hbrescode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbrescode = 'S08000016' NHS_Borders = 1. 
If hbrescode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbrescode = 'S08000019' NHS_Forth_Valley = 1. 
If hbrescode = 'S08000020' NHS_Grampian = 1. 
If any(hbrescode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbrescode = 'S08000022' NHS_Highland = 1.
If any(hbrescode, 'S08000023', 'S08000032') NHS_Lanarkshire =1. 
If hbrescode = 'S08000024' NHS_Lothian = 1. 
If hbrescode = 'S08000025' NHS_Orkney = 1. 
If hbrescode = 'S08000026' NHS_Shetland = 1. 
If hbrescode = 'S08000028' NHS_Western_Isles = 1. 
If any(hbrescode, 'S08000018', 'S08000029') NHS_Fife = 1. 
If any(hbrescode, 'S08000027', 'S08000030') NHS_Tayside = 1. 

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran to NHS_Tayside (SYSMIS = 0).

*Flag to count HB costs. 
If NHS_Ayrshire_and_Arran = 1 NHS_Ayrshire_and_Arran_cost = (cost_total_net).
If NHS_Borders = 1 NHS_Borders_cost = (cost_total_net). 
If NHS_Dumfries_and_Galloway = 1 NHS_Dumfries_and_Galloway_cost = (cost_total_net).
If NHS_Forth_Valley = 1 NHS_Forth_Valley_cost = (cost_total_net).
If NHS_Grampian = 1 NHS_Grampian_cost = (cost_total_net).
If NHS_Greater_Glasgow_and_Clyde = 1 NHS_Greater_Glasgow_and_Clyde_cost = (cost_total_net).
If NHS_Highland = 1 NHS_Highland_cost = (cost_total_net).
If NHS_Lanarkshire = 1 NHS_Lanarkshire_cost = (cost_total_net).
If NHS_Lothian = 1 NHS_Lothian_cost = (cost_total_net).
If NHS_Orkney = 1 NHS_Orkney_cost = (cost_total_net).
If NHS_Shetland = 1 NHS_Shetland_cost = (cost_total_net).
If NHS_Western_Isles = 1 NHS_Western_Isles_cost = (cost_total_net).
If NHS_Fife = 1 NHS_Fife_cost = (cost_total_net).
If NHS_Tayside = 1 NHS_Tayside_cost = (cost_total_net).

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran_cost to NHS_Tayside_cost (SYSMIS = 0).

* Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /Mean_Age = mean(age)
    /n_episodes = n
    /Total__Costs_net = Sum(Cost_Total_Net)
    /Mean_Costs_net = Mean(Cost_Total_Net)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2)
    /Total_cost_apr = Sum(apr_cost)
    /Total_cost_may = Sum(may_cost)
    /Total_cost_jun = Sum(jun_cost)
    /Total_cost_jul = Sum(jul_cost)
    /Total_cost_aug = Sum(aug_cost)
    /Total_cost_sep = Sum(sep_cost)
    /Total_cost_oct = Sum(oct_cost)
    /Total_cost_nov = Sum(nov_cost)
    /Total_cost_dec = Sum(dec_cost)
    /Total_cost_jan = Sum(jan_cost)
    /Total_cost_feb = Sum(feb_cost)
    /Total_cost_mar = Sum(mar_cost)
    /Mean_cost_apr = Mean(apr_cost)
    /Mean_cost_may = Mean(may_cost)
    /Mean_cost_jun = Mean(jun_cost)
    /Mean_cost_jul = Mean(jul_cost)
    /Mean_cost_aug = Mean(aug_cost)
    /Mean_cost_sep = Mean(sep_cost)
    /Mean_cost_oct = Mean(oct_cost)
    /Mean_cost_nov = Mean(nov_cost)
    /Mean_cost_dec = Mean(dec_cost)
    /Mean_cost_jan = Mean(jan_cost)
    /Mean_cost_feb = Mean(feb_cost)
    /Mean_cost_mar = Mean(mar_cost)
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
    /NHS_Ayrshire_and_Arran_cost = Sum(NHS_Ayrshire_and_Arran_cost) 
    /NHS_Borders_cost = Sum(NHS_Borders_cost)
    /NHS_Dumfries_and_Galloway_cost = Sum(NHS_Dumfries_and_Galloway_cost) 
    /NHS_Forth_Valley_cost = Sum(NHS_Forth_Valley_cost)
    /NHS_Grampian_cost = Sum(NHS_Grampian_cost)
    /NHS_Greater_Glasgow_and_Clyde_cost = Sum(NHS_Greater_Glasgow_and_Clyde_cost)
    /NHS_Highland_cost = Sum(NHS_Highland_cost)
    /NHS_Lanarkshire_cost = Sum(NHS_Lanarkshire_cost) 
    /NHS_Lothian_cost = Sum(NHS_Lothian_cost) 
    /NHS_Orkney_cost = Sum(NHS_Orkney_cost)
    /NHS_Shetland_cost = Sum(NHS_Shetland_cost)
    /NHS_Western_Isles_cost = Sum(NHS_Western_Isles_cost) 
    /NHS_Fife_cost = Sum(NHS_Fife_cost)
    /NHS_Tayside_cost = Sum(NHS_Tayside_cost). 


* Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to NHS_Tayside_cost
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI record_keydate1 record_keydate2 gender dob age hbrescode
    cost_total_net apr_cost to mar_cost.
select if recid = 'AE2'.

* Flag to count CHIs.
Recode Anon_CHI ("" = 0) (Else = 1) Into Has_CHI.

* Flags to count Males / Females.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

* Flags to count missing values.
If sysmis(dob) No_DoB = 1.

*Flag to count how many episodes in each HB by rescode. 
If hbrescode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbrescode = 'S08000016' NHS_Borders = 1. 
If hbrescode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbrescode = 'S08000019' NHS_Forth_Valley = 1. 
If hbrescode = 'S08000020' NHS_Grampian = 1. 
If any(hbrescode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbrescode = 'S08000022' NHS_Highland = 1.
If any(hbrescode, 'S08000023', 'S08000032') NHS_Lanarkshire =1. 
If hbrescode = 'S08000024' NHS_Lothian = 1. 
If hbrescode = 'S08000025' NHS_Orkney = 1. 
If hbrescode = 'S08000026' NHS_Shetland = 1. 
If hbrescode = 'S08000028' NHS_Western_Isles = 1. 
If any(hbrescode, 'S08000018', 'S08000029') NHS_Fife = 1. 
If any(hbrescode, 'S08000027', 'S08000030') NHS_Tayside = 1. 

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran to NHS_Tayside (SYSMIS = 0).

*Flag to count HB costs. 
If NHS_Ayrshire_and_Arran = 1 NHS_Ayrshire_and_Arran_cost = (cost_total_net).
If NHS_Borders = 1 NHS_Borders_cost = (cost_total_net). 
If NHS_Dumfries_and_Galloway = 1 NHS_Dumfries_and_Galloway_cost = (cost_total_net).
If NHS_Forth_Valley = 1 NHS_Forth_Valley_cost = (cost_total_net).
If NHS_Grampian = 1 NHS_Grampian_cost = (cost_total_net).
If NHS_Greater_Glasgow_and_Clyde = 1 NHS_Greater_Glasgow_and_Clyde_cost = (cost_total_net).
If NHS_Highland = 1 NHS_Highland_cost = (cost_total_net).
If NHS_Lanarkshire = 1 NHS_Lanarkshire_cost = (cost_total_net).
If NHS_Lothian = 1 NHS_Lothian_cost = (cost_total_net).
If NHS_Orkney = 1 NHS_Orkney_cost = (cost_total_net).
If NHS_Shetland = 1 NHS_Shetland_cost = (cost_total_net).
If NHS_Western_Isles = 1 NHS_Western_Isles_cost = (cost_total_net).
If NHS_Fife = 1 NHS_Fife_cost = (cost_total_net).
If NHS_Tayside = 1 NHS_Tayside_cost = (cost_total_net).

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran_cost to NHS_Tayside_cost (SYSMIS = 0).

* Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /Mean_Age = mean(age)
    /n_episodes = n
    /Total__Costs_net = Sum(Cost_Total_Net)
    /Mean_Costs_net = Mean(Cost_Total_Net)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2)
    /Total_cost_apr = Sum(apr_cost)
    /Total_cost_may = Sum(may_cost)
    /Total_cost_jun = Sum(jun_cost)
    /Total_cost_jul = Sum(jul_cost)
    /Total_cost_aug = Sum(aug_cost)
    /Total_cost_sep = Sum(sep_cost)
    /Total_cost_oct = Sum(oct_cost)
    /Total_cost_nov = Sum(nov_cost)
    /Total_cost_dec = Sum(dec_cost)
    /Total_cost_jan = Sum(jan_cost)
    /Total_cost_feb = Sum(feb_cost)
    /Total_cost_mar = Sum(mar_cost)
    /Mean_cost_apr = Mean(apr_cost)
    /Mean_cost_may = Mean(may_cost)
    /Mean_cost_jun = Mean(jun_cost)
    /Mean_cost_jul = Mean(jul_cost)
    /Mean_cost_aug = Mean(aug_cost)
    /Mean_cost_sep = Mean(sep_cost)
    /Mean_cost_oct = Mean(oct_cost)
    /Mean_cost_nov = Mean(nov_cost)
    /Mean_cost_dec = Mean(dec_cost)
    /Mean_cost_jan = Mean(jan_cost)
    /Mean_cost_feb = Mean(feb_cost)
    /Mean_cost_mar = Mean(mar_cost)
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
    /NHS_Ayrshire_and_Arran_cost = Sum(NHS_Ayrshire_and_Arran_cost) 
    /NHS_Borders_cost = Sum(NHS_Borders_cost)
    /NHS_Dumfries_and_Galloway_cost = Sum(NHS_Dumfries_and_Galloway_cost) 
    /NHS_Forth_Valley_cost = Sum(NHS_Forth_Valley_cost)
    /NHS_Grampian_cost = Sum(NHS_Grampian_cost)
    /NHS_Greater_Glasgow_and_Clyde_cost = Sum(NHS_Greater_Glasgow_and_Clyde_cost)
    /NHS_Highland_cost = Sum(NHS_Highland_cost)
    /NHS_Lanarkshire_cost = Sum(NHS_Lanarkshire_cost) 
    /NHS_Lothian_cost = Sum(NHS_Lothian_cost) 
    /NHS_Orkney_cost = Sum(NHS_Orkney_cost)
    /NHS_Shetland_cost = Sum(NHS_Shetland_cost)
    /NHS_Western_Isles_cost = Sum(NHS_Western_Isles_cost) 
    /NHS_Fife_cost = Sum(NHS_Fife_cost)
    /NHS_Tayside_cost = Sum(NHS_Tayside_cost). 


Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to NHS_Tayside_cost
    /Index Measure (Existing_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
* Match together.
match files
    /file = SLFexisting
    /file = SLFnew
    /By Measure.
Dataset Name AandEComparison.

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

Save Outfile = !Year_dir + 'A&E_tests_20' + !FY + '.zsav'
   /zcompressed .
