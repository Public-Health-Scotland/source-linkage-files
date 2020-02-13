* Encoding: UTF-8.

*Tests for Delayed Discharge dataset.
get file = !file + 'Extracts/DD_LinkageFile-20' + !FY + '.zsav'.

 * Flag to count CHIs.
Recode Primary_Delay_Reason ("9" = 1) (Else = 0) Into Code_9.

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /Mean_Code_9 = Mean (Code_9)
    /Earliest_start Earliest_end = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_start Latest_end  = Max(keydate1_dateformat keydate2_dateformat).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from Mean_Code_9 to Latest_end
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid keydate1_dateformat keydate2_dateformat Primary_Delay_Reason.
select if recid = 'DD'.

 * Flag to count CHIs.
Recode Primary_Delay_Reason ("9" = 1) (Else = 0) Into Code_9.

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /Mean_Code_9 = Mean (Code_9)
    /Earliest_start Earliest_end = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_start Latest_end  = Max(keydate1_dateformat keydate2_dateformat).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from Mean_Code_9  to Latest_end
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

*Save test file . 
Save Outfile = !file + 'DD_tests_201718.zsav'
   /zcompressed .


