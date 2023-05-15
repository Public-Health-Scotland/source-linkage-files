* Encoding: UTF-8.
get file = !Year_dir + "care_home_for_source-20" + !FY + ".zsav".

* Flag to count CHIs.
Recode CHI ("" = 0) (Else = 1) Into Has_CHI.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

*Flag to count missing CH name.
If ch_name = '' ch_name_missing = 1.

*Flag to count CH provider.
If any(ch_provider, '1', '2', '3', '4', '5') ch_provider_1_to_5 = 1. 
If ch_provider = '6' ch_provider_other = 1. 

*Flag to count missing ch admission reason. 
If sysmis(ch_adm_reason) ch_adm_reason_missing = 1. 

*Flag to count sc support. 
*sc_living_alone.
If sc_living_alone = 0 sc_living_alone_no = 1. 
If sc_living_alone = 1 sc_living_alone_yes = 1. 
If sc_living_alone = 9 sc_living_alone_unknown = 1. 

*sc_support_from_unpaid_carer.
If sc_support_from_unpaid_carer = 0 sc_support_from_unpaid_carer_no = 1. 
If sc_support_from_unpaid_carer = 1 sc_support_from_unpaid_carer_yes = 1.
If sc_support_from_unpaid_carer = 9 sc_support_from_unpaid_carer_unknown = 1. 

*sc_social_worker.
If sc_social_worker = 0 sc_social_worker_no = 1.
If sc_social_worker = 1 sc_social_worker_yes = 1.
If sc_social_worker = 9 sc_social_worker_unknown = 1.

*sc_meals.
If sc_meals = 0 sc_meals_no = 1. 
If sc_meals = 1 sc_meals_yes = 1. 
If sc_meals = 9 sc_meals_unknown = 1. 

*sc_day_care.
If sc_day_care = 0 sc_day_care_no = 1.
If sc_day_care = 1 sc_day_care_yes = 1.
If sc_day_care = 9 sc_day_care_unknown = 1. 


*Flags to count sc_send_lca.
If sc_send_lca = '01' Aberdeen_city = 1.
If sc_send_lca = '02' Aberdeenshire = 1.
If sc_send_lca = '03' Angus = 1.
If sc_send_lca = '04' Argyll_and_Bute = 1. 
If sc_send_lca = '05' Scottish_Borders = 1. 
If sc_send_lca = '06' Clackmannanshire = 1.
If sc_send_lca = '07' West_Dunbartonshire = 1.
If sc_send_lca = '08' Dumfries_and_Galloway = 1. 
If sc_send_lca = '09' Dundee_City = 1. 
If sc_send_lca = '10' East_Ayrshire = 1.
If sc_send_lca = '11' East_Dunbartonshire = 1.
If sc_send_lca = '12' East_Lothian = 1.
If sc_send_lca = '13' East_Renfrewshire = 1. 
If sc_send_lca = '14' City_of_Edinburgh = 1. 
If sc_send_lca = '15' Falkirk = 1. 
If sc_send_lca = '16' Fife = 1. 
If sc_send_lca = '17' Glasgow_City = 1.
If sc_send_lca = '18' Highland = 1.
If sc_send_lca = '19' Inverclyde = 1.
If sc_send_lca = '20' Midlothian = 1.
If sc_send_lca = '21' Moray = 1. 
If sc_send_lca = '22' North_Ayrshire = 1. 
If sc_send_lca = '23' North_Lanarkshire = 1.
If sc_send_lca = '24' Orkney_Islands = 1.
If sc_send_lca = '25' Perth_and_Kinross = 1. 
If sc_send_lca = '26' Renfrewshire = 1.
If sc_send_lca = '27' Shetland_Islands = 1. 
If sc_send_lca = '28' South_Ayrshire = 1. 
If sc_send_lca = '29' South_Lanarkshire = 1.
If sc_send_lca = '30' Stirling = 1.
If sc_send_lca = '31' West_Lothian = 1.
If sc_send_lca = '32' Na_h_Eileanan_Siar = 1. 

* Flags to count missing values.
If sysmis(dob) No_DoB = 1.

* Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /avg_Age = mean(age)
    /n_episodes = n
    /Total__Costs_net Total__yearstay Total__stay = Sum(cost_total_net yearstay stay)
    /Mean__Costs_net Mean__yearstay Mean__stay = Mean(cost_total_net yearstay stay)
    /Max_Cost Max_yearstay Max_stay = Max(cost_total_net yearstay stay)
    /Min_Cost Min_yearstay Min_stay = Min(cost_total_net yearstay stay)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end = Max(record_keydate1 record_keydate2)
    /Total_beddays_apr = Sum(Apr_beddays)
    /Total_beddays_may = Sum(May_beddays)
    /Total_beddays_jun = Sum(Jun_beddays)
    /Total_beddays_jul = Sum(Jul_beddays)
    /Total_beddays_aug = Sum(Aug_beddays)
    /Total_beddays_sep = Sum(Sep_beddays)
    /Total_beddays_oct = Sum(Oct_beddays)
    /Total_beddays_nov = Sum(Nov_beddays)
    /Total_beddays_dec = Sum(Dec_beddays)
    /Total_beddays_jan = Sum(Jan_beddays)
    /Total_beddays_feb = Sum(Feb_beddays)
    /Total_beddays_mar = Sum(Mar_beddays)
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
    /Mean_beddays_apr = Mean(Apr_beddays)
    /Mean_beddays_may = Mean(May_beddays)
    /Mean_beddays_jun = Mean(Jun_beddays)
    /Mean_beddays_jul = Mean(Jul_beddays)
    /Mean_beddays_aug = Mean(Aug_beddays)
    /Mean_beddays_sep = Mean(Sep_beddays)
    /Mean_beddays_oct = Mean(Oct_beddays)
    /Mean_beddays_nov = Mean(Nov_beddays)
    /Mean_beddays_dec = Mean(Dec_beddays)
    /Mean_beddays_jan = Mean(Jan_beddays)
    /Mean_beddays_feb = Mean(Feb_beddays)
    /Mean_beddays_mar = Mean(Mar_beddays)
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
    /n_ch_name_missing = Sum(ch_name_missing)
    /n_ch_provider_1_to_5 = Sum(ch_provider_1_to_5)
    /n_ch_provider_other = Sum(ch_provider_other)
    /n_ch_adm_reason_missing = Sum(ch_adm_reason_missing)
    /n_ch_nursing = Sum(ch_nursing)
    /n_sc_living_alone_no = Sum(sc_living_alone_no)
    /n_sc_living_alone_yes = Sum(sc_living_alone_yes)
    /n_sc_living_alone_unknown = Sum(sc_living_alone_unknown)
    /n_sc_support_from_unpaid_carer_no = Sum(sc_support_from_unpaid_carer_no)
    /n_sc_support_from_unpaid_carer_yes = Sum(sc_support_from_unpaid_carer_yes)
    /n_sc_support_from_unpaid_carer_unknown = Sum(sc_support_from_unpaid_carer_unknown)
    /n_sc_social_worker_no = Sum(sc_social_worker_no)
    /n_sc_social_worker_yes = Sum(sc_social_worker_yes)
    /n_sc_social_worker_unknown = Sum(sc_social_worker_unknown)
    /n_sc_meals_no = Sum(sc_meals_no)
    /n_sc_meals_yes = Sum(sc_meals_yes)
    /n_sc_meals_unknown = Sum(sc_meals_unknown)
    /n_sc_day_care_no = Sum(sc_day_care_no)
    /n_sc_day_care_yes = Sum(sc_day_care_yes)
    /n_sc_day_care_unknown = Sum(sc_day_care_unknown)
    /All_Aberdeen_city = Sum(Aberdeen_city)
    /All_Aberdeenshire = Sum(Aberdeenshire)
    /All_Angus = Sum(Angus)
    /All_Argyll_and_Bute = Sum(Argyll_and_Bute)
    /All_Scottish_Borders = Sum(Scottish_Borders)
    /All_Clackmannanshire = Sum(Clackmannanshire)
    /All_West_Dunbartonshire = Sum(West_Dunbartonshire)
    /All_Dumfries_and_Galloway = Sum(Dumfries_and_Galloway)
    /All_Dundee_City = Sum(Dundee_City)
    /All_East_Ayrshire = Sum(East_Ayrshire)
    /All_East_Dunbartonshire = Sum(East_Dunbartonshire)
    /All_East_Lothian = Sum(East_Lothian)
    /All_East_Renfrewshire = Sum(East_Renfrewshire)
    /All_City_of_Edinburgh = Sum(City_of_Edinburgh)
    /All_Falkirk = Sum(Falkirk)
    /All_Fife = Sum(Fife)
    /All_Glasgow_City = Sum(Glasgow_City)
    /All_Highland = Sum(Highland)
    /All_Inverclyde = Sum(Inverclyde)
    /All_Midlothian = Sum(Midlothian)
    /All_Moray = Sum(Moray)
    /All_North_Ayrshire = Sum(North_Ayrshire)
    /All_North_Lanarkshire = Sum(North_Lanarkshire)
    /All_Orkney_Islands = Sum(Orkney_Islands)
    /All_Perth_and_Kinross = Sum(Perth_and_Kinross)
    /All_Renfrewshire = Sum(Renfrewshire)
    /All_Shetland_Islands = Sum(Shetland_Islands)
    /All_South_Ayrshire = Sum(South_Ayrshire)
    /All_South_Lanarkshire = Sum(South_Lanarkshire)
    /All_Stirling = Sum(Stirling)
    /All_West_Lothian = Sum(West_Lothian)
    /All_Na_h_Eileanan_Siar = Sum(Na_h_Eileanan_Siar).


Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to All_Na_h_Eileanan_Siar
    /Index Measure (New_Value).
Sort cases by Measure.

**************************************************************************************************************************

**************************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid SMRType Anon_CHI record_keydate1 record_keydate2 gender dob age
               cost_total_net yearstay stay apr_beddays to mar_beddays apr_cost to mar_cost
               ch_name ch_adm_reason ch_provider ch_nursing sc_send_lca to sc_day_care.
select if recid = 'CH'.

* Flag to count CHIs.
Recode Anon_CHI ("" = 0) (Else = 1) Into Has_CHI.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

*Flag to count missing CH name.
If ch_name = '' ch_name_missing = 1.

*Flag to count CH provider.
If any(ch_provider, '1', '2', '3', '4', '5') ch_provider_1_to_5 = 1. 
If ch_provider = '6' ch_provider_other = 1. 

*Flag to count missing ch admission reason. 
If sysmis(ch_adm_reason) ch_adm_reason_missing = 1. 

*Flag to count sc support. 
*sc_living_alone.
If sc_living_alone = 0 sc_living_alone_no = 1. 
If sc_living_alone = 1 sc_living_alone_yes = 1. 
If sc_living_alone = 9 sc_living_alone_unknown = 1. 

*sc_support_from_unpaid_carer.
If sc_support_from_unpaid_carer = 0 sc_support_from_unpaid_carer_no = 1. 
If sc_support_from_unpaid_carer = 1 sc_support_from_unpaid_carer_yes = 1.
If sc_support_from_unpaid_carer = 9 sc_support_from_unpaid_carer_unknown = 1. 

*sc_social_worker.
If sc_social_worker = 0 sc_social_worker_no = 1.
If sc_social_worker = 1 sc_social_worker_yes = 1.
If sc_social_worker = 9 sc_social_worker_unknown = 1.

*sc_meals.
If sc_meals = 0 sc_meals_no = 1. 
If sc_meals = 1 sc_meals_yes = 1. 
If sc_meals = 9 sc_meals_unknown = 1. 

*sc_day_care.
If sc_day_care = 0 sc_day_care_no = 1.
If sc_day_care = 1 sc_day_care_yes = 1.
If sc_day_care = 9 sc_day_care_unknown = 1. 


*Flags to count sc_send_lca.
If sc_send_lca = '01' Aberdeen_city = 1.
If sc_send_lca = '02' Aberdeenshire = 1.
If sc_send_lca = '03' Angus = 1.
If sc_send_lca = '04' Argyll_and_Bute = 1. 
If sc_send_lca = '05' Scottish_Borders = 1. 
If sc_send_lca = '06' Clackmannanshire = 1.
If sc_send_lca = '07' West_Dunbartonshire = 1.
If sc_send_lca = '08' Dumfries_and_Galloway = 1. 
If sc_send_lca = '09' Dundee_City = 1. 
If sc_send_lca = '10' East_Ayrshire = 1.
If sc_send_lca = '11' East_Dunbartonshire = 1.
If sc_send_lca = '12' East_Lothian = 1.
If sc_send_lca = '13' East_Renfrewshire = 1. 
If sc_send_lca = '14' City_of_Edinburgh = 1. 
If sc_send_lca = '15' Falkirk = 1. 
If sc_send_lca = '16' Fife = 1. 
If sc_send_lca = '17' Glasgow_City = 1.
If sc_send_lca = '18' Highland = 1.
If sc_send_lca = '19' Inverclyde = 1.
If sc_send_lca = '20' Midlothian = 1.
If sc_send_lca = '21' Moray = 1. 
If sc_send_lca = '22' North_Ayrshire = 1. 
If sc_send_lca = '23' North_Lanarkshire = 1.
If sc_send_lca = '24' Orkney_Islands = 1.
If sc_send_lca = '25' Perth_and_Kinross = 1. 
If sc_send_lca = '26' Renfrewshire = 1.
If sc_send_lca = '27' Shetland_Islands = 1. 
If sc_send_lca = '28' South_Ayrshire = 1. 
If sc_send_lca = '29' South_Lanarkshire = 1.
If sc_send_lca = '30' Stirling = 1.
If sc_send_lca = '31' West_Lothian = 1.
If sc_send_lca = '32' Na_h_Eileanan_Siar = 1. 

* Flags to count missing values.
If sysmis(dob) No_DoB = 1.

* Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /avg_Age = mean(age)
    /n_episodes = n
    /Total__Costs_net Total__yearstay Total__stay = Sum(cost_total_net yearstay stay)
    /Mean__Costs_net Mean__yearstay Mean__stay = Mean(cost_total_net yearstay stay)
    /Max_Cost Max_yearstay Max_stay = Max(cost_total_net yearstay stay)
    /Min_Cost Min_yearstay Min_stay = Min(cost_total_net yearstay stay)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end = Max(record_keydate1 record_keydate2)
    /Total_beddays_apr = Sum(Apr_beddays)
    /Total_beddays_may = Sum(May_beddays)
    /Total_beddays_jun = Sum(Jun_beddays)
    /Total_beddays_jul = Sum(Jul_beddays)
    /Total_beddays_aug = Sum(Aug_beddays)
    /Total_beddays_sep = Sum(Sep_beddays)
    /Total_beddays_oct = Sum(Oct_beddays)
    /Total_beddays_nov = Sum(Nov_beddays)
    /Total_beddays_dec = Sum(Dec_beddays)
    /Total_beddays_jan = Sum(Jan_beddays)
    /Total_beddays_feb = Sum(Feb_beddays)
    /Total_beddays_mar = Sum(Mar_beddays)
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
    /Mean_beddays_apr = Mean(Apr_beddays)
    /Mean_beddays_may = Mean(May_beddays)
    /Mean_beddays_jun = Mean(Jun_beddays)
    /Mean_beddays_jul = Mean(Jul_beddays)
    /Mean_beddays_aug = Mean(Aug_beddays)
    /Mean_beddays_sep = Mean(Sep_beddays)
    /Mean_beddays_oct = Mean(Oct_beddays)
    /Mean_beddays_nov = Mean(Nov_beddays)
    /Mean_beddays_dec = Mean(Dec_beddays)
    /Mean_beddays_jan = Mean(Jan_beddays)
    /Mean_beddays_feb = Mean(Feb_beddays)
    /Mean_beddays_mar = Mean(Mar_beddays)
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
    /n_ch_name_missing = Sum(ch_name_missing)
    /n_ch_provider_1_to_5 = Sum(ch_provider_1_to_5)
    /n_ch_provider_other = Sum(ch_provider_other)
    /n_ch_adm_reason_missing = Sum(ch_adm_reason_missing)
    /n_ch_nursing = Sum(ch_nursing)
    /n_sc_living_alone_no = Sum(sc_living_alone_no)
    /n_sc_living_alone_yes = Sum(sc_living_alone_yes)
    /n_sc_living_alone_unknown = Sum(sc_living_alone_unknown)
    /n_sc_support_from_unpaid_carer_no = Sum(sc_support_from_unpaid_carer_no)
    /n_sc_support_from_unpaid_carer_yes = Sum(sc_support_from_unpaid_carer_yes)
    /n_sc_support_from_unpaid_carer_unknown = Sum(sc_support_from_unpaid_carer_unknown)
    /n_sc_social_worker_no = Sum(sc_social_worker_no)
    /n_sc_social_worker_yes = Sum(sc_social_worker_yes)
    /n_sc_social_worker_unknown = Sum(sc_social_worker_unknown)
    /n_sc_meals_no = Sum(sc_meals_no)
    /n_sc_meals_yes = Sum(sc_meals_yes)
    /n_sc_meals_unknown = Sum(sc_meals_unknown)
    /n_sc_day_care_no = Sum(sc_day_care_no)
    /n_sc_day_care_yes = Sum(sc_day_care_yes)
    /n_sc_day_care_unknown = Sum(sc_day_care_unknown)
    /All_Aberdeen_city = Sum(Aberdeen_city)
    /All_Aberdeenshire = Sum(Aberdeenshire)
    /All_Angus = Sum(Angus)
    /All_Argyll_and_Bute = Sum(Argyll_and_Bute)
    /All_Scottish_Borders = Sum(Scottish_Borders)
    /All_Clackmannanshire = Sum(Clackmannanshire)
    /All_West_Dunbartonshire = Sum(West_Dunbartonshire)
    /All_Dumfries_and_Galloway = Sum(Dumfries_and_Galloway)
    /All_Dundee_City = Sum(Dundee_City)
    /All_East_Ayrshire = Sum(East_Ayrshire)
    /All_East_Dunbartonshire = Sum(East_Dunbartonshire)
    /All_East_Lothian = Sum(East_Lothian)
    /All_East_Renfrewshire = Sum(East_Renfrewshire)
    /All_City_of_Edinburgh = Sum(City_of_Edinburgh)
    /All_Falkirk = Sum(Falkirk)
    /All_Fife = Sum(Fife)
    /All_Glasgow_City = Sum(Glasgow_City)
    /All_Highland = Sum(Highland)
    /All_Inverclyde = Sum(Inverclyde)
    /All_Midlothian = Sum(Midlothian)
    /All_Moray = Sum(Moray)
    /All_North_Ayrshire = Sum(North_Ayrshire)
    /All_North_Lanarkshire = Sum(North_Lanarkshire)
    /All_Orkney_Islands = Sum(Orkney_Islands)
    /All_Perth_and_Kinross = Sum(Perth_and_Kinross)
    /All_Renfrewshire = Sum(Renfrewshire)
    /All_Shetland_Islands = Sum(Shetland_Islands)
    /All_South_Ayrshire = Sum(South_Ayrshire)
    /All_South_Lanarkshire = Sum(South_Lanarkshire)
    /All_Stirling = Sum(Stirling)
    /All_West_Lothian = Sum(West_Lothian)
    /All_Na_h_Eileanan_Siar = Sum(Na_h_Eileanan_Siar).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to All_Na_h_Eileanan_Siar
    /Index Measure (Existing_Value).
Sort cases by Measure.

**************************************************************************************************************************

**************************************************************************************************************************.
* Match together.
match files
    /file = SLFexisting
    /file = SLFnew
    /By Measure.
Dataset Name CHComparison.

* Close both datasets.
Dataset close SLFnew.
Dataset close SLFexisting.

* Produce comparisons.
Compute Difference = New_Value - Existing_Value.
Compute PctChange = Difference / Existing_Value * 100.
Compute Issue = abs(PctChange) > 5.
Alter Type Issue (F1.0) PctChange (PCT4.2).

* Highlight issues.
Crosstabs Measure by Issue.

Save Outfile = !Year_dir + 'Care_Home_tests_20' + !FY + '.zsav'
   /zcompressed .

