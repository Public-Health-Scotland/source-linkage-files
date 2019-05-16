* Encoding: UTF-8.
*Created by Anita George 15/03/2019.
*Individual File checks.
*Run A01 for the individual year.

*check alive and deceased has been matched correctly.
get file= !file + "source-individual-file-20" + !FY + ".zsav".

*Set up some flags.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

If Demographic_Cohort = "" No_Demog = 1.
If Service_Use_Cohort = "" No_Service = 1.

If sysmis(dob) No_DoB = 1.

if postcode = "" No_Postcode = 1.
if hbrescode = "" No_HB = 1.
if LCA = "" No_LCA = 1.
if sysmis(gpprac) No_GPprac = 1.


Recode SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY (sysmis = 1) (else = 0).

Dataset declare New_Summary.
aggregate outfile = New_Summary
    /Break
    /nCHIs = n(CHI)
    /MeanAge = mean(age)
    /Males Females = Sum(Male Female)
    /NSUs Dead = SUM(NSU deceased)
    /No_Postcode No_HB No_LCA No_GPprac = SUM(No_Postcode No_HB No_LCA No_GPprac)
    /No_Demog No_Service = Sum(No_Demog No_Service)
    /No_SPARRA1 No_SPARRA2 No_HHG1 No_HHG2 = Sum(SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY)
    /cost1 to cost3 = Sum(health_net_cost to health_net_costincIncomplete)
    /acute1 to acute13 = Sum(acute_episodes to acute_non_el_inpatient_beddays)
    /mat1 to mat7 = Sum(Mat_episodes to Mat_inpatient_beddays)
    /MH1 to MH11 = Sum(MH_episodes to MH_non_el_inpatient_beddays)
    /GLS1 to GLS11 = Sum(GLS_episodes to GLS_non_el_inpatient_beddays)
    /DD1 to DD4 = Sum(DD_NonCode9_episodes to DD_Code9_beddays)
    /OP1 to OP4 = Sum(OP_newcons_attendances to OP_cost_dnas)
    /AE1 AE2 = SUM(AE_attendances AE_cost)
    /PIS1 PIS2 = Sum(PIS_dispensed_items PIS_cost)
    /CH1 to CH3 = Sum(CH_episodes to CH_cost)
    /OoH1 to OoH9 = Sum(OoH_cases to OoH_cost)
    /DN1 to DN3 = Sum(DN_episodes to DN_cost)
    /CHM = Sum(CMH_Contacts)
    /LTC1 to LTC19 = Sum(arth to digestive)
    /Pop = Sum(Keep_Population)
    /HRI1 to HRI4 = Sum(HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN).

Dataset Activate New_Summary.
Varstocases
    /Make NewValue from nCHIs to HRI4
    /Index Measure (NewValue).
Sort cases by Measure.

get file = "/conf/hscdiip/01-Source-linkage-files/source-individual-file-20" + !FY + ".zsav"
    /Rename Anon_CHI = CHI.
Dataset Name OldFile.
Dataset Activate OldFile.

*Set up some flags.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

If Demographic_Cohort = "" No_Demog = 1.
If Service_Use_Cohort = "" No_Service = 1.

If sysmis(dob) No_DoB = 1.

if postcode = "" No_Postcode = 1.
if hbrescode = "" No_HB = 1.
if LCA = "" No_LCA = 1.
if sysmis(gpprac) No_GPprac = 1.

Numeric HHG_Start_FY HHG_End_FY (F1.0).
Recode SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY (sysmis = 1) (else = 0).

Numeric DD_NonCode9_episodes DD2 DD3 DD_Code9_beddays CMH_Contacts (F1.0).

Dataset declare Old_Summary.
aggregate outfile = Old_Summary
    /Break
    /nCHIs = n(CHI)
    /MeanAge = mean(age)
    /Males Females = Sum(Male Female)
    /NSUs Dead = SUM(NSU deceased)
    /No_Postcode No_HB No_LCA No_GPprac = SUM(No_Postcode No_HB No_LCA No_GPprac)
    /No_Demog No_Service = Sum(No_Demog No_Service)
    /No_SPARRA1 No_SPARRA2 No_HHG1 No_HHG2 = Sum(SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY)
    /cost1 to cost3 = Sum(health_net_cost to health_net_costincIncomplete)
    /acute1 to acute13 = Sum(acute_episodes to acute_non_el_inpatient_beddays)
    /mat1 to mat7 = Sum(Mat_episodes to Mat_inpatient_beddays)
    /MH1 to MH13 = Sum(MH_episodes to MH_non_el_inpatient_beddays)
    /GLS1 to GLS13 = Sum(GLS_episodes to GLS_non_el_inpatient_beddays)
    /DD1 to DD4 = Sum(DD_NonCode9_episodes to DD_Code9_beddays)
    /OP1 to OP4 = Sum(OP_newcons_attendances to OP_cost_dnas)
    /AE1 AE2 = SUM(AE_attendances AE_cost)
    /PIS1 PIS2 = Sum(PIS_dispensed_items PIS_cost)
    /CH1 to CH3 = Sum(CH_episodes to CH_cost)
    /OoH1 to OoH9 = Sum(OoH_cases to OoH_cost)
    /DN1 to DN3 = Sum(DN_episodes to DN_cost)
    /CHM = Sum(CMH_Contacts)
    /LTC1 to LTC19 = Sum(arth to digestive)
    /Pop = Sum(Keep_Population)
    /HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN = Sum(HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN).

Dataset Close OldFile.

Dataset Activate Old_Summary.
Varstocases
    /Make OldValue from nCHIs to HRI4
    /Index Measure (OldValue).
Sort cases by Measure.

match files
    /file = Old_Summary
    /file = New_Summary
    /By Measure.

Dataset Name Comparison.
Dataset Close Old_Summary.
Dataset Close New_Summary.

Compute Difference = NewValue - OldValue.
Compute PctChange = Difference / OldValue.
Compute Issue = (abs(PctChange) > 5).
Alter Type Issue (F1.0) PctChange (PCT).
Crosstabs Measure by Issue.
