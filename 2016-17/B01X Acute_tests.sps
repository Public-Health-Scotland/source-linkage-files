* Encoding: UTF-8.

*Tests for acute dataset.
get file = !file + 'acute_for_source-20' + !FY + '.zsav'.

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
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2)
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
    /Mean_cost_mar = Mean(mar_cost).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to Mean_cost_mar
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI record_keydate1 record_keydate2 gender dob age
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
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2)
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
    /Mean_cost_mar = Mean(mar_cost).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to Mean_cost_mar
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
Compute PctChange = Difference / Existing_Value * 100.
Compute Issue = (abs(PctChange) > 5).
Alter Type Issue (F1.0) PctChange (PCT4.2).

 * Highlight issues.
Crosstabs Measure by Issue.

*Save test file.
Save Outfile = !file + 'acute_tests_20' + !FY + '.zsav'
   /zcompressed .


