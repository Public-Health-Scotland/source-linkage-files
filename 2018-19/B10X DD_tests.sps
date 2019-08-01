* Encoding: UTF-8.

*Tests for Delayed Discharge dataset.
get file = !file + 'Extracts/DD_LinkageFile-20' + !FY + '.zsav'.

 * Flag to count CHIs.
Recode CHI ("" = 0) (Else = 1) Into Has_CHI.

 * Flags to count missing values.
if postcode = "" No_Postcode = 1.

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /No_Postcode = SUM(No_Postcode)
    /n_episodes = n
    /n_ammended_date = Sum(Ammended_Dates)
    /Earliest_start Earliest_end = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_start Latest_end  = Max(keydate1_dateformat keydate2_dateformat).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to Latest_end
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI keydate1_dateformat keydate2_dateformat postcode DD_Quality.
select if recid = 'DD'.

 * Flag to count CHIs.
Recode Anon_CHI ("" = 0) (Else = 1) Into Has_CHI.

if postcode = "" No_Postcode = 1.

 * Estimate records with assumed end dates.
If any(DD_Quality, "1A", "1AP", "2A", "2AP") Ammended_Dates = 1.

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /No_Postcode = SUM(No_Postcode)
    /n_episodes = n
    /n_ammended_date = Sum(Ammended_Dates)
    /Earliest_start Earliest_end = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_start Latest_end  = Max(keydate1_dateformat keydate2_dateformat).


Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_CHIs to Latest_end
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
Compute PctChange = Difference / Existing_Value * 100.
Compute Issue = (abs(PctChange) > 5).
Alter Type Issue (F1.0) PctChange (PCT4.2).

 * Highlight issues.
Crosstabs Measure by Issue.


