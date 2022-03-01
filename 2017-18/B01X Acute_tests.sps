* Encoding: UTF-8.

*Tests for acute dataset.
get file = !Year_dir + 'acute_for_source-20' + !FY + '.zsav'.

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

* Flags to count Health Board episodes, costs and beddays.
Do if (hbtreatcode = 'S08000015').
    Compute NHS_Ayrshire_and_Arran_episodes = 1.
    Compute NHS_Ayrshire_and_Arran_cost = cost_total_net.
    Compute NHS_Ayrshire_and_Arran_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000016').
    Compute NHS_Borders_episodes = 1.
    Compute NHS_Borders_cost = cost_total_net.
    Compute NHS_Borders_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000017').
    Compute NHS_Ayrshire_and_Arran_episodes = 1.
    Compute NHS_Dumfries_and_Galloway_cost = cost_total_net.
    Compute NHS_Dumfries_and_Galloway_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000019').
    Compute NHS_Forth_Valley_episodes = 1.
    Compute NHS_Forth_Valley_cost = cost_total_net.
    Compute NHS_Forth_Valley_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000020').
    Compute NHS_Grampian_episodes = 1.
    Compute NHS_Grampian_cost = cost_total_net.
    Compute NHS_Grampian_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000021', 'S08000031')).
    Compute NHS_Greater_Glasgow_and_Clyde_episodes = 1.
    Compute NHS_Greater_Glasgow_and_Clyde_cost = cost_total_net.
    Compute NHS_Greater_Glasgow_and_Clyde_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000022').
    Compute NHS_Highland_episodes = 1.
    Compute NHS_Highland_cost = cost_total_net.
    Compute NHS_Highland_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000023', 'S08000032')).
    Compute NHS_Lanarkshire_episodes = 1.
    Compute NHS_Lanarkshire_cost = cost_total_net.
    Compute NHS_Lanarkshire_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000024').
    Compute NHS_Lothian_episodes = 1.
    Compute NHS_Lothian_cost = cost_total_net.
    Compute NHS_Lothian_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000025').
    Compute NHS_Orkney_episodes = 1.
    Compute NHS_Orkney_cost = cost_total_net.
    Compute NHS_Orkney_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000026').
    Compute NHS_Shetland_episodes = 1.
    Compute NHS_Shetland_cost = cost_total_net.
    Compute NHS_Shetland_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000028').
    Compute NHS_Western_Isles_episodes = 1.
    Compute NHS_Western_Isles_cost = cost_total_net.
    Compute NHS_Western_Isles_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000018', 'S08000029')).
    Compute NHS_Fife_episodes = 1.
    Compute NHS_Fife_cost = cost_total_net.
    Compute NHS_Fife_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000027', 'S08000030')).
    Compute NHS_Tayside_episodes = 1.
    Compute NHS_Tayside_cost = cost_total_net.
    Compute NHS_Tayside_beddays = yearstay.
End if.

* Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /Mean_Age = mean(age)
    /n_episodes = n
    /Total__Costs_net Total__yearstay Total__stay = Sum(cost_total_net yearstay stay)
    /Mean__Costs_net Mean__yearstay Mean__stay = Mean(cost_total_net yearstay stay)
    /Max_Cost Max_yearstay Max_stay = Max(cost_total_net yearstay stay)
    /Min_Cost Min_yearstay Min_stay = Min(cost_total_net yearstay stay)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end = Max(record_keydate1 record_keydate2)
    /Total_beddays_apr = Sum(apr_beddays)
    /Total_beddays_may = Sum(may_beddays)
    /Total_beddays_jun = Sum(jun_beddays)
    /Total_beddays_jul = Sum(jul_beddays)
    /Total_beddays_aug = Sum(aug_beddays)
    /Total_beddays_sep = Sum(sep_beddays)
    /Total_beddays_oct = Sum(oct_beddays)
    /Total_beddays_nov = Sum(nov_beddays)
    /Total_beddays_dec = Sum(dec_beddays)
    /Total_beddays_jan = Sum(jan_beddays)
    /Total_beddays_feb = Sum(feb_beddays)
    /Total_beddays_mar = Sum(mar_beddays)
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
    /Mean_beddays_apr = Mean(apr_beddays)
    /Mean_beddays_may = Mean(may_beddays)
    /Mean_beddays_jun = Mean(jun_beddays)
    /Mean_beddays_jul = Mean(jul_beddays)
    /Mean_beddays_aug = Mean(aug_beddays)
    /Mean_beddays_sep = Mean(sep_beddays)
    /Mean_beddays_oct = Mean(oct_beddays)
    /Mean_beddays_nov = Mean(nov_beddays)
    /Mean_beddays_dec = Mean(dec_beddays)
    /Mean_beddays_jan = Mean(jan_beddays)
    /Mean_beddays_feb = Mean(feb_beddays)
    /Mean_beddays_mar = Mean(mar_beddays)
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
    /NHS_Ayrshire_and_Arran_episodes = sum(NHS_Ayrshire_and_Arran_episodes)
    /NHS_Borders_episodes = sum(NHS_Borders_episodes)
    /NHS_Dumfries_and_Galloway_episodes = sum(NHS_Dumfries_and_Galloway_episodes)
    /NHS_Forth_Valley_episodes = sum(NHS_Forth_Valley_episodes)
    /NHS_Grampian_episodes = sum(NHS_Grampian_episodes)
    /NHS_Greater_Glasgow_and_Clyde_episodes = sum(NHS_Greater_Glasgow_and_Clyde_episodes)
    /NHS_Highland_episodes = sum(NHS_Highland_episodes)
    /NHS_Lanarkshire_episodes = sum(NHS_Lanarkshire_episodes)
    /NHS_Lothian_episodes = sum(NHS_Lothian_episodes)
    /NHS_Orkney_episodes = sum(NHS_Orkney_episodes)
    /NHS_Shetland_episodes = sum(NHS_Shetland_episodes)
    /NHS_Western_Isles_episodes = sum(NHS_Western_Isles_episodes)
    /NHS_Fife_episodes = sum(NHS_Fife_episodes)
    /NHS_Tayside_episodes = sum(NHS_Tayside_episodes)
    /NHS_Ayrshire_and_Arran_beddays = sum(NHS_Ayrshire_and_Arran_beddays)
    /NHS_Borders_beddays = sum(NHS_Borders_beddays)
    /NHS_Dumfries_and_Galloway_beddays = sum(NHS_Dumfries_and_Galloway_beddays)
    /NHS_Forth_Valley_beddays = sum(NHS_Forth_Valley_beddays)
    /NHS_Grampian_beddays = sum(NHS_Grampian_beddays)
    /NHS_Greater_Glasgow_and_Clyde_beddays = sum(NHS_Greater_Glasgow_and_Clyde_beddays)
    /NHS_Highland_beddays = sum(NHS_Highland_beddays)
    /NHS_Lanarkshire_beddays = sum(NHS_Lanarkshire_beddays)
    /NHS_Lothian_beddays = sum(NHS_Lothian_beddays)
    /NHS_Orkney_beddays = sum(NHS_Orkney_beddays)
    /NHS_Shetland_beddays = sum(NHS_Shetland_beddays)
    /NHS_Western_Isles_beddays = sum(NHS_Western_Isles_beddays)
    /NHS_Fife_beddays = sum(NHS_Fife_beddays)
    /NHS_Tayside_beddays = sum(NHS_Tayside_beddays)
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
    /Keep recid Anon_CHI record_keydate1 record_keydate2 gender dob age hbtreatcode
    cost_total_net yearstay stay apr_beddays to mar_beddays apr_cost to mar_cost.
select if any(recid, "01B", "GLS").

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

* Flags to count Health Board episodes, costs and beddays.
Do if (hbtreatcode = 'S08000015').
    Compute NHS_Ayrshire_and_Arran_episodes = 1.
    Compute NHS_Ayrshire_and_Arran_cost = cost_total_net.
    Compute NHS_Ayrshire_and_Arran_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000016').
    Compute NHS_Borders_episodes = 1.
    Compute NHS_Borders_cost = cost_total_net.
    Compute NHS_Borders_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000017').
    Compute NHS_Ayrshire_and_Arran_episodes = 1.
    Compute NHS_Dumfries_and_Galloway_cost = cost_total_net.
    Compute NHS_Dumfries_and_Galloway_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000019').
    Compute NHS_Forth_Valley_episodes = 1.
    Compute NHS_Forth_Valley_cost = cost_total_net.
    Compute NHS_Forth_Valley_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000020').
    Compute NHS_Grampian_episodes = 1.
    Compute NHS_Grampian_cost = cost_total_net.
    Compute NHS_Grampian_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000021', 'S08000031')).
    Compute NHS_Greater_Glasgow_and_Clyde_episodes = 1.
    Compute NHS_Greater_Glasgow_and_Clyde_cost = cost_total_net.
    Compute NHS_Greater_Glasgow_and_Clyde_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000022').
    Compute NHS_Highland_episodes = 1.
    Compute NHS_Highland_cost = cost_total_net.
    Compute NHS_Highland_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000023', 'S08000032')).
    Compute NHS_Lanarkshire_episodes = 1.
    Compute NHS_Lanarkshire_cost = cost_total_net.
    Compute NHS_Lanarkshire_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000024').
    Compute NHS_Lothian_episodes = 1.
    Compute NHS_Lothian_cost = cost_total_net.
    Compute NHS_Lothian_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000025').
    Compute NHS_Orkney_episodes = 1.
    Compute NHS_Orkney_cost = cost_total_net.
    Compute NHS_Orkney_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000026').
    Compute NHS_Shetland_episodes = 1.
    Compute NHS_Shetland_cost = cost_total_net.
    Compute NHS_Shetland_beddays = yearstay.
End if.
Do if (hbtreatcode = 'S08000028').
    Compute NHS_Western_Isles_episodes = 1.
    Compute NHS_Western_Isles_cost = cost_total_net.
    Compute NHS_Western_Isles_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000018', 'S08000029')).
    Compute NHS_Fife_episodes = 1.
    Compute NHS_Fife_cost = cost_total_net.
    Compute NHS_Fife_beddays = yearstay.
End if.
Do if (any(hbtreatcode, 'S08000027', 'S08000030')).
    Compute NHS_Tayside_episodes = 1.
    Compute NHS_Tayside_cost = cost_total_net.
    Compute NHS_Tayside_beddays = yearstay.
End if.

* Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /Mean_Age = mean(age)
    /n_episodes = n
    /Total__Costs_net Total__yearstay Total__stay = Sum(cost_total_net yearstay stay)
    /Mean__Costs_net Mean__yearstay Mean__stay = Mean(cost_total_net yearstay stay)
    /Max_Cost Max_yearstay Max_stay = Max(cost_total_net yearstay stay)
    /Min_Cost Min_yearstay Min_stay = Min(cost_total_net yearstay stay)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end = Max(record_keydate1 record_keydate2)
    /Total_beddays_apr = Sum(apr_beddays)
    /Total_beddays_may = Sum(may_beddays)
    /Total_beddays_jun = Sum(jun_beddays)
    /Total_beddays_jul = Sum(jul_beddays)
    /Total_beddays_aug = Sum(aug_beddays)
    /Total_beddays_sep = Sum(sep_beddays)
    /Total_beddays_oct = Sum(oct_beddays)
    /Total_beddays_nov = Sum(nov_beddays)
    /Total_beddays_dec = Sum(dec_beddays)
    /Total_beddays_jan = Sum(jan_beddays)
    /Total_beddays_feb = Sum(feb_beddays)
    /Total_beddays_mar = Sum(mar_beddays)
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
    /Mean_beddays_apr = Mean(apr_beddays)
    /Mean_beddays_may = Mean(may_beddays)
    /Mean_beddays_jun = Mean(jun_beddays)
    /Mean_beddays_jul = Mean(jul_beddays)
    /Mean_beddays_aug = Mean(aug_beddays)
    /Mean_beddays_sep = Mean(sep_beddays)
    /Mean_beddays_oct = Mean(oct_beddays)
    /Mean_beddays_nov = Mean(nov_beddays)
    /Mean_beddays_dec = Mean(dec_beddays)
    /Mean_beddays_jan = Mean(jan_beddays)
    /Mean_beddays_feb = Mean(feb_beddays)
    /Mean_beddays_mar = Mean(mar_beddays)
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
    /NHS_Ayrshire_and_Arran_episodes = sum(NHS_Ayrshire_and_Arran_episodes)
    /NHS_Borders_episodes = sum(NHS_Borders_episodes)
    /NHS_Dumfries_and_Galloway_episodes = sum(NHS_Dumfries_and_Galloway_episodes)
    /NHS_Forth_Valley_episodes = sum(NHS_Forth_Valley_episodes)
    /NHS_Grampian_episodes = sum(NHS_Grampian_episodes)
    /NHS_Greater_Glasgow_and_Clyde_episodes = sum(NHS_Greater_Glasgow_and_Clyde_episodes)
    /NHS_Highland_episodes = sum(NHS_Highland_episodes)
    /NHS_Lanarkshire_episodes = sum(NHS_Lanarkshire_episodes)
    /NHS_Lothian_episodes = sum(NHS_Lothian_episodes)
    /NHS_Orkney_episodes = sum(NHS_Orkney_episodes)
    /NHS_Shetland_episodes = sum(NHS_Shetland_episodes)
    /NHS_Western_Isles_episodes = sum(NHS_Western_Isles_episodes)
    /NHS_Fife_episodes = sum(NHS_Fife_episodes)
    /NHS_Tayside_episodes = sum(NHS_Tayside_episodes)
    /NHS_Ayrshire_and_Arran_beddays = sum(NHS_Ayrshire_and_Arran_beddays)
    /NHS_Borders_beddays = sum(NHS_Borders_beddays)
    /NHS_Dumfries_and_Galloway_beddays = sum(NHS_Dumfries_and_Galloway_beddays)
    /NHS_Forth_Valley_beddays = sum(NHS_Forth_Valley_beddays)
    /NHS_Grampian_beddays = sum(NHS_Grampian_beddays)
    /NHS_Greater_Glasgow_and_Clyde_beddays = sum(NHS_Greater_Glasgow_and_Clyde_beddays)
    /NHS_Highland_beddays = sum(NHS_Highland_beddays)
    /NHS_Lanarkshire_beddays = sum(NHS_Lanarkshire_beddays)
    /NHS_Lothian_beddays = sum(NHS_Lothian_beddays)
    /NHS_Orkney_beddays = sum(NHS_Orkney_beddays)
    /NHS_Shetland_beddays = sum(NHS_Shetland_beddays)
    /NHS_Western_Isles_beddays = sum(NHS_Western_Isles_beddays)
    /NHS_Fife_beddays = sum(NHS_Fife_beddays)
    /NHS_Tayside_beddays = sum(NHS_Tayside_beddays)
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
Dataset Name AcuteComparison.

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

*Save test file.
Save Outfile = !Year_dir + 'acute_tests_20' + !FY + '.zsav'
   /zcompressed .
