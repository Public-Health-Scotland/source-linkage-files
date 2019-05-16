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
if hbrescode = "" No_HB = 1.
if LCA = "" No_LCA = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /Males Females = Sum(Male Female)
    /MeanAge = mean(age)
    /No_Postcode No_HB No_LCA No_GPprac = SUM(No_Postcode No_HB No_LCA No_GPprac)
    /n_episodes = n
    /Total_Costs_net = Sum(cost_total_net)
    /Total_yearstay = Sum(yearstay)
    /Total_stay = Sum(stay).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to Total_stay
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI gender dob postcode hbrescode LCA gpprac age cost_total_net yearstay stay.
select if recid = '01B'.

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
if hbrescode = "" No_HB = 1.
if LCA = "" No_LCA = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /Males Females = Sum(Male Female)
    /MeanAge = mean(age)
    /No_Postcode No_HB No_LCA No_GPprac = SUM(No_Postcode No_HB No_LCA No_GPprac)
    /n_episodes = n
    /Total_Costs_net = Sum(cost_total_net)
    /Total_yearstay = Sum(yearstay)
    /Total_stay = Sum(stay).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to Total_stay
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
