* Encoding: UTF-8.
*PIS tests.
get file = !File + "prescribing_file_for_source-20" + !FY + ".zsav".

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
    /Males Females = Sum(Male Female)
    /n_episodes = n
    /mean_dispensed = Mean(no_dispensed_items)
    /mean_cost = Mean(cost_total_net)
    /Total_dispensed = Sum(no_dispensed_items)
    /Total_Costs_net = Sum(cost_total_net).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to Total_Costs_net
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI gender dob hbrescode LCA age cost_total_net yearstay stay no_dispensed_items.
select if recid = 'PIS'.

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
    /Males Females = Sum(Male Female)
    /n_episodes = n
    /mean_dispensed = Mean(no_dispensed_items)
    /mean_cost = Mean(cost_total_net)
    /Total_dispensed = Sum(no_dispensed_items)
    /Total_Costs_net = Sum(cost_total_net).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to Total_Costs_net
    /Index Measure (Existing_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
 * Match together.
match files
    /file = SLFexisting
    /file = SLFnew
    /By Measure.
Dataset Name PISComparison.

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

Save Outfile = !file + 'PIS_tests_20' + !FY + '.zsav'
   /zcompressed .

