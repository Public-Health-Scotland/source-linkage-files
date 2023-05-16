* Encoding: UTF-8.
* Prescribing (PIS) tests.
get file = !Year_dir + "prescribing_file_for_source-20" + !FY + ".zsav".

 * Flag to count CHIs.
Recode CHI ("" = 0) (Else = 1) Into has_chi_number.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute male = 1.
Else if gender = 2.
    Compute female = 1.
End if.

 * Flags to count missing values.
If sysmis(dob) no_dob = 1.

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_chis n_missing_dob = sum(has_chi_number no_dob)
    /males females = Sum(male female)
    /n_episodes = n
    /paid_items_mean cost_mean = mean(no_paid_items cost_total_net)
    /paid_items_total cost_total = sum(no_paid_items cost_total_net)
    /paid_items_sd cost_sd = sd(no_paid_items cost_total_net).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make new_value from n_CHIs to cost_sd
    /Index measure (new_value).
Sort cases by measure.

*******************************************************************************.

get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid anon_chi gender dob cost_total_net no_paid_items.
select if recid = 'PIS'.

 * Flag to count CHIs.
Recode anon_chi ("" = 0) (Else = 1) Into has_chi_number.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute male = 1.
Else if gender = 2.
    Compute female = 1.
End if.

 * Flags to count missing values.
If sysmis(dob) no_dob = 1.

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_chis n_missing_dob = sum(has_chi_number no_dob)
    /males females = Sum(male female)
    /n_episodes = n
    /paid_items_mean cost_mean = mean(no_paid_items cost_total_net)
    /paid_items_total cost_total = sum(no_paid_items cost_total_net)
    /paid_items_sd cost_sd = sd(no_paid_items cost_total_net).

Dataset activate SLFexisting.
Varstocases
    /Make existing_value from n_CHIs to cost_sd
    /Index measure (existing_value).
Sort cases by measure.

*******************************************************************************.

 * Match together.
match files
    /file = SLFexisting
    /file = SLFnew
    /By measure.
Dataset Name PISComparison.

 * Close both datasets.
Dataset close SLFnew.
Dataset close SLFexisting.

 * Produce comparisons.
Compute difference = new_value - existing_value.
Do if existing_value NE 0.
    Compute pct_change = difference / existing_value * 100.
End if.
Compute issue = abs(pct_change) > 5.
Alter Type issue (F1.0) pct_change (PCT4.2).

 * Highlight issues.
Crosstabs measure by issue.

Save Outfile = !Year_dir + 'prescribing_tests_20' + !FY + '.zsav'
   /zcompressed .
