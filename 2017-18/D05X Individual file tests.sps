* Encoding: UTF-8.
*Individual File checks.
*Run A01 for the individual year.

get file= !file + "source-individual-file-20" + !FY + ".zsav".

 * Set up some flags.

 * Flag to count the males and females.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

 * Flag to count the number of records with no cohorts (should be low and numbers should be similar).
If Demographic_Cohort = "" No_Demog = 1.
If Service_Use_Cohort = "" No_Service = 1.

 * Flag to count the number of records without a DoB.
If sysmis(dob) No_DoB = 1.

 * Flags to count the number of records without various geography info.
if postcode = "" No_Postcode = 1.
if hbrescode = "" No_HB = 1.
if LCA = "" No_LCA = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Recode SPARRA and HHG to count numbers of records without this data.
Recode SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY (sysmis = 1) (else = 0).

 * Produce the counts.
 * Ideally will name things better in the future!.
Dataset declare New_Summary.
aggregate outfile = New_Summary
    /Break
    /n_CHIs = n(CHI)
    /Age_mean = mean(age)
    /sex_Males sex_Females = Sum(Male Female)
    /n_NSUs n_Dead = SUM(NSU deceased)
    /n_No_Postcode n_No_HB n_No_LCA n_No_GPprac = SUM(No_Postcode No_HB No_LCA No_GPprac)
    /n_No_Demog n_No_Service = Sum(No_Demog No_Service)
    /n_No_SPARRA_start n_No_SPARRA_end n_No_HHG_start n_No_HHG_end = Sum(SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY)
    /Cost_01 to Cost_03 = Sum(health_net_cost to health_net_costincIncomplete)
    /Acute_01 to Acute_13 = Sum(acute_episodes to acute_non_el_inpatient_beddays)
    /Mat_01 to Mat_07 = Sum(Mat_episodes to Mat_inpatient_beddays)
    /MH_01 to MH_11 = Sum(MH_episodes to MH_non_el_inpatient_beddays)
    /GLS_01 to GLS_11 = Sum(GLS_episodes to GLS_non_el_inpatient_beddays)
    /DD_01 to DD_04 = Sum(DD_NonCode9_episodes to DD_Code9_beddays)
    /OP_01 to OP_04 = Sum(OP_newcons_attendances to OP_cost_dnas)
    /AE_01 AE_02 = SUM(AE_attendances AE_cost)
    /PIS_01 PIS_02 = Sum(PIS_dispensed_items PIS_cost)
    /CH_01 to CH_03 = Sum(CH_episodes to CH_cost)
    /OoH_01 to OoH_09 = Sum(OoH_cases to OoH_cost)
    /DN_01 to DN_03 = Sum(DN_episodes to DN_cost)
    /CHM = Sum(CMH_Contacts)
    /LTC_01 to LTC_19 = Sum(arth to digestive)
    /n_Population = Sum(Keep_Population)
    /HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN = Sum(HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN).

 * Rearrange nicely.
Dataset Activate New_Summary.
Varstocases
    /Make NewValue from n_CHIs to HRI_LCA_incDN
    /Index Measure (NewValue).
Sort cases by Measure.

get file = "/conf/hscdiip/01-Source-linkage-files/source-individual-file-20" + !FY + ".zsav"
    /Rename Anon_CHI = CHI.
Dataset Name OldFile.
Dataset Activate OldFile.


 * Set up some flags.

 * Flag to count the males and females.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

 * Flag to count the number of records with no cohorts (should be low and numbers should be similar).
If Demographic_Cohort = "" No_Demog = 1.
If Service_Use_Cohort = "" No_Service = 1.

 * Flag to count the number of records without a DoB.
If sysmis(dob) No_DoB = 1.

 * Flags to count the number of records without various geography info.
if postcode = "" No_Postcode = 1.
if hbrescode = "" No_HB = 1.
if LCA = "" No_LCA = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Create variables - should exist in most files and should be in all after May 2019 update.
Numeric HHG_Start_FY (F1.0).
Numeric  HHG_End_FY (F1.0).

Numeric SPARRA_Start_FY (F1.0).
Numeric SPARRA_End_FY (F1.0).

 * Recode SPARRA and HHG to count numbers of records without this data.
Recode SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY (sysmis = 1) (else = 0).

 * Create variables - should exist in most files and should be in all after May 2019 update.
Numeric DD_NonCode9_episodes DD2 DD3 DD_Code9_beddays  (F1.0).

Numeric CMH_Contacts (F1.0).

 * Delete some variables which no longer exist.
Frequencies GLS_daycase_episodes GLS_daycase_cost MH_daycase_episodes MH_daycase_cost.
Delete variables GLS_daycase_episodes GLS_daycase_cost.
Delete variables MH_daycase_episodes MH_daycase_cost.

Dataset declare Old_Summary.
aggregate outfile = Old_Summary
    /Break
    /n_CHIs = n(CHI)
    /Age_mean = mean(age)
    /sex_Males sex_Females = Sum(Male Female)
    /n_NSUs n_Dead = SUM(NSU deceased)
    /n_No_Postcode n_No_HB n_No_LCA n_No_GPprac = SUM(No_Postcode No_HB No_LCA No_GPprac)
    /n_No_Demog n_No_Service = Sum(No_Demog No_Service)
    /n_No_SPARRA_start n_No_SPARRA_end n_No_HHG_start n_No_HHG_end = Sum(SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY)
    /Cost_01 to Cost_03 = Sum(health_net_cost to health_net_costincIncomplete)
    /Acute_01 to Acute_13 = Sum(acute_episodes to acute_non_el_inpatient_beddays)
    /Mat_01 to Mat_07 = Sum(Mat_episodes to Mat_inpatient_beddays)
    /MH_01 to MH_11 = Sum(MH_episodes to MH_non_el_inpatient_beddays)
    /GLS_01 to GLS_11 = Sum(GLS_episodes to GLS_non_el_inpatient_beddays)
    /DD_01 to DD_04 = Sum(DD_NonCode9_episodes to DD_Code9_beddays)
    /OP_01 to OP_04 = Sum(OP_newcons_attendances to OP_cost_dnas)
    /AE_01 AE_02 = SUM(AE_attendances AE_cost)
    /PIS_01 PIS_02 = Sum(PIS_dispensed_items PIS_cost)
    /CH_01 to CH_03 = Sum(CH_episodes to CH_cost)
    /OoH_01 to OoH_09 = Sum(OoH_cases to OoH_cost)
    /DN_01 to DN_03 = Sum(DN_episodes to DN_cost)
    /CHM = Sum(CMH_Contacts)
    /LTC_01 to LTC_19 = Sum(arth to digestive)
    /n_Population = Sum(Keep_Population)
    /HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN = Sum(HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN).

Dataset Close OldFile.

 * Rearrange nicely.
Dataset Activate Old_Summary.
Varstocases
    /Make OldValue from n_CHIs to HRI_LCA_incDN
    /Index Measure (OldValue).
Sort cases by Measure.

 * Match the summaries together to compare.
match files
    /file = Old_Summary
    /file = New_Summary
    /By Measure.

 * Housekeeping.
Dataset Name Comparison.
Dataset Close Old_Summary.
Dataset Close New_Summary.

 * Compute percentage change from old to new.
 * Highlight any which have a >= 5 % change.
Compute Difference = NewValue - OldValue.
Compute PctChange = Difference / OldValue * 100.
Compute Issue = (PctChange > 5).
Alter Type Issue (F1.0) PctChange (F8.4).
Crosstabs Measure by Issue.
