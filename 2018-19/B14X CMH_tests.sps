* Encoding: UTF-8.

*Tests for GP OoHs dataset.
get file = !file + 'CMH_for_source-20' + !FY + '.zsav'.

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

 * Flag to check how many HBs we have.
AutoRecode hbtreatcode /into HBs.

 * Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /No_Postcode No_GPprac = SUM(No_Postcode No_GPprac)
    /n_episodes = n
    /n_hbs = Max(HBs)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2).

 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_CHIs to Latest_end
    /Index Measure (New_Value).
Sort cases by Measure.
*************************************************************************************************************.

*************************************************************************************************************.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'
    /Keep recid Anon_CHI record_keydate1 record_keydate2 gender dob postcode gpprac hbtreatcode.
select if recid = 'CMH'.

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

 * Flag to check how many HBs we have.
AutoRecode hbtreatcode /into HBs.

 * Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_CHIs = sum(Has_CHI)
    /n_Males n_Females = Sum(Male Female)
    /No_Postcode No_GPprac = SUM(No_Postcode No_GPprac)
    /n_episodes = n
    /n_hbs = Max(HBs)
    /Earliest_start Earliest_end = Min(record_keydate1 record_keydate2)
    /Latest_start Latest_end  = Max(record_keydate1 record_keydate2).

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
Dataset Name CMHComparison.

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


