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

if postcode = "" No_Postcode = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /Mean_Age = mean(age)
    /No_Postcode No_GPprac = SUM(No_Postcode No_GPprac)
    /n_episodes = n
    /Total__Costs_net Total__yearstay Total__stay = Sum(cost_total_net yearstay stay)
    /Mean_Costs_net Mean_yearstay Mean_stay = Mean(cost_total_net yearstay stay)
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
    /Total_cost_mar = Sum(mar_cost).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to Total_cost_mar
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI record_keydate1 record_keydate2 gender dob postcode gpprac age
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

if postcode = "" No_Postcode = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /Mean_Age = mean(age)
    /No_Postcode No_GPprac = SUM(No_Postcode No_GPprac)
    /n_episodes = n
    /Total__Costs_net Total__yearstay Total__stay = Sum(cost_total_net yearstay stay)
    /Mean_Costs_net Mean_yearstay Mean_stay = Mean(cost_total_net yearstay stay)
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
    /Total_cost_mar = Sum(mar_cost).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to Total_cost_mar
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
