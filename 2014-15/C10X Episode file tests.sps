* Encoding: UTF-8.
Define !FinalName()
    !Concat("Recid_Compare_", !unquote(!Eval(!FY)))
!EndDefine.

Define !Create_Aggregate(FileVersion = !Tokens(1)).

!Let !DatasetName = !Concat(!Unquote(!FileVersion), "By", "Recid").

Dataset Declare !DatasetName.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

 * Flags to count age groups.
Do if age < 18.
    Compute Child = 1.
Else.
    Compute Adult = 1.
End if.

If age >= 65 Over_65 = 1.

 * Flags to count missing values.
If sysmis(dob) No_DoB = 1.

if postcode = "" No_Postcode = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Flags to count stay types.
If cij_pattype = "Elective" CIJ_elective = 1.
If cij_pattype = "Non-Elective" CIJ_non_elective = 1.
If cij_pattype = "Maternity" CIJ_maternity = 1.
If cij_pattype = "Other" CIJ_other = 1.

*Flag to count how many episodes in each HB by treatment code. 
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
If NHS_Ayrshire_and_Arran = 1 NHS_Ayrshire_and_Arran_cost = cost_total_net.
If NHS_Borders = 1 NHS_Borders_cost = cost_total_net. 
If NHS_Dumfries_and_Galloway = 1 NHS_Dumfries_and_Galloway_cost = cost_total_net.
If NHS_Forth_Valley = 1 NHS_Forth_Valley_cost = cost_total_net.
If NHS_Grampian = 1 NHS_Grampian_cost = cost_total_net.
If NHS_Greater_Glasgow_and_Clyde = 1 NHS_Greater_Glasgow_and_Clyde_cost = cost_total_net.
If NHS_Highland = 1 NHS_Highland_cost = cost_total_net.
If NHS_Lanarkshire = 1 NHS_Lanarkshire_cost = cost_total_net.
If NHS_Lothian = 1 NHS_Lothian_cost = cost_total_net.
If NHS_Orkney = 1 NHS_Orkney_cost = cost_total_net.
If NHS_Shetland = 1 NHS_Shetland_cost = cost_total_net.
If NHS_Western_Isles = 1 NHS_Western_Isles_cost = cost_total_net.
If NHS_Fife = 1 NHS_Fife_cost = cost_total_net.
If NHS_Tayside = 1 NHS_Tayside_cost = cost_total_net.

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran_cost to NHS_Tayside_cost (SYSMIS = 0).

sort cases by recid.

aggregate outfile = !DatasetName
    /Presorted
    /break year recid
    /n_episodes = n
    /n_male n_female = Sum(Male Female)
    /n_no_dob n_no_postcode n_no_gpprac= Sum(No_DoB No_Postcode No_GPprac)
    /n_CIJ_elective n_CIJ_non_elective n_CIJ_maternity n_CIJ_other = Sum(CIJ_elective CIJ_non_elective CIJ_maternity CIJ_other)
    /Avg_age = Mean(age)
    /n_children n_adults n_over65 = Sum(Child Adult Over_65)
    /Earliest_adm Earliest_dis = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_adm Latest_dis= Max(keydate1_dateformat keydate2_dateformat)
    /cij_ppas = Sum(cij_ppa)
    /avg_yearstay avg_stay = Mean(yearstay stay)
    /total_yearstay total_stay = Sum(yearstay stay)
    /avg_apr_beddays = Mean(apr_beddays)
    /avg_may_beddays = Mean(may_beddays)
    /avg_jun_beddays = Mean(jun_beddays)
    /avg_jul_beddays = Mean(jul_beddays)
    /avg_aug_beddays = Mean(aug_beddays)
    /avg_sep_beddays = Mean(sep_beddays)
    /avg_oct_beddays = Mean(oct_beddays)
    /avg_nov_beddays = Mean(nov_beddays)
    /avg_dec_beddays = Mean(dec_beddays)
    /avg_jan_beddays = Mean(jan_beddays)
    /avg_feb_beddays = Mean(feb_beddays)
    /avg_mar_beddays = Mean(mar_beddays)
    /total_apr_beddays = Sum(apr_beddays)
    /total_may_beddays = Sum(may_beddays)
    /total_jun_beddays = Sum(jun_beddays)
    /total_jul_beddays = Sum(jul_beddays)
    /total_aug_beddays = Sum(aug_beddays)
    /total_sep_beddays = Sum(sep_beddays)
    /total_oct_beddays = Sum(oct_beddays)
    /total_nov_beddays = Sum(nov_beddays)
    /total_dec_beddays = Sum(dec_beddays)
    /total_jan_beddays = Sum(jan_beddays)
    /total_feb_beddays = Sum(feb_beddays)
    /total_mar_beddays = Sum(mar_beddays)
    /avg_cost_total_net avg_Cost_Total_Net_incDNAs = Mean(cost_total_net Cost_Total_Net_incDNAs)
    /total_cost_total_net total_Cost_Total_Net_incDNAs = Sum(cost_total_net Cost_Total_Net_incDNAs)
    /avg_apr_cost = Mean(apr_cost)
    /avg_may_cost = Mean(may_cost)
    /avg_jun_cost = Mean(jun_cost)
    /avg_jul_cost = Mean(jul_cost)
    /avg_aug_cost = Mean(aug_cost)
    /avg_sep_cost = Mean(sep_cost)
    /avg_oct_cost = Mean(oct_cost)
    /avg_nov_cost = Mean(nov_cost)
    /avg_dec_cost = Mean(dec_cost)
    /avg_jan_cost = Mean(jan_cost)
    /avg_feb_cost = Mean(feb_cost)
    /avg_mar_cost = Mean(mar_cost)
    /total_apr_cost = Sum(apr_cost)
    /total_may_cost = Sum(may_cost)
    /total_jun_cost = Sum(jun_cost)
    /total_jul_cost = Sum(jul_cost)
    /total_aug_cost = Sum(aug_cost)
    /total_sep_cost = Sum(sep_cost)
    /total_oct_cost = Sum(oct_cost)
    /total_nov_cost = Sum(nov_cost)
    /total_dec_cost = Sum(dec_cost)
    /total_jan_cost = Sum(jan_cost)
    /total_feb_cost = Sum(feb_cost)
    /total_mar_cost = Sum(mar_cost)
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

Dataset Activate !DatasetName.

Varstocases
    /make Value from n_episodes to NHS_Tayside_cost
    /Index Measure (Value).

sort cases by year recid measure.

Alter type value (F8.2).

!EndDefine.

get file = !Year_dir + "source-episode-file-20" + !FY + ".zsav".
!Create_Aggregate FileVersion = New.

get file =  "/conf/hscdiip/01-Source-linkage-files/source-episode-file-20" + !FY + ".zsav".
!Create_Aggregate FileVersion = Old.

match files 
    /file = NewByRecid
    /Rename Value = New_Value
    /file OldByRecid
    /rename Value = Existing_Value
    /By year recid measure.
Dataset Name !FinalName.
Dataset Close Newbyrecid.
Dataset Close Oldbyrecid.

Dataset Activate  !FinalName.

* Produce comparisons.
Compute Difference = New_Value - Existing_Value.
Do if Existing_Value NE 0.
    Compute PctChange = Difference / Existing_Value * 100.
End if.
Compute Issue = (abs(PctChange) > 5).
Alter Type Issue (F1.0) PctChange (PCT4.2).

Crosstabs recid by Issue.

save outfile = !Year_dir + "source-episode-TESTS-20" + !FY + ".sav".
