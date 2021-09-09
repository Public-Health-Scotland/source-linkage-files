* Encoding: UTF-8.
*Individual File checks.
*Run A01 for the individual year.

Define !FinalName()
    !Concat("Indiv_Comparison_", !unquote(!Eval(!FY)))
!EndDefine.

get file = !Year_dir + "source-individual-file-20" + !FY + ".zsav".
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

*Flag to count how many patients in each HB by rescode. 
If hbrescode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbrescode = 'S08000016' NHS_Borders = 1. 
If hbrescode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbrescode = 'S08000019' NHS_Forth_Valley = 1. 
If hbrescode = 'S08000020' NHS_Grampian = 1. 
If any(hbrescode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbrescode = 'S08000022' NHS_Highland = 1.
If any(hbrescode, 'S08000023', 'S08000032') NHS_Lanarkshire = 1. 
If hbrescode = 'S08000024' NHS_Lothian = 1. 
If hbrescode = 'S08000025' NHS_Orkney = 1. 
If hbrescode = 'S08000026' NHS_Shetland = 1. 
If hbrescode = 'S08000028' NHS_Western_Isles = 1. 
If any(hbrescode, 'S08000018', 'S08000029') NHS_Fife = 1. 
If any(hbrescode, 'S08000027', 'S08000030') NHS_Tayside = 1. 

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran to NHS_Tayside (SYSMIS = 0).

*Flag to count HB costs. 
If NHS_Ayrshire_and_Arran = 1 NHS_Ayrshire_and_Arran_cost = cost_total_net.
If NHS_Borders = 1 NHS_Borders_cost = cost_total_net. 
If NHS_Dumfries_and_Galloway = 1 NHS_Dumfries_and_Galloway_cost = cost_total_net.
If NHS_Forth_Valley = 1 NHS_Forth_Valley_cost = cost_total_net.
If NHS_Grampian = 1 NHS_Grampian_cost = cost_total_net.
If NHS_Greater_Glasgow_and_Clyde = 1 NHS_Greater_Glasgow_and_Clyde_cost = cost_total_net.
If NHS_Highland = 1 NHS_Highland_cost = cost_total_net.
If NHS_Lanarkshire = 1 NHS_Lanarkshire_cost = cost_total_net.
If NHS_Lothian = 1 NHS_Lothian_cost = cost_total_net.
If NHS_Orkney = 1 NHS_Orkney_cost = cost_total_net.
If NHS_Shetland = 1 NHS_Shetland_cost = cost_total_net.
If NHS_Western_Isles = 1 NHS_Western_Isles_cost = cost_total_net.
If NHS_Fife = 1 NHS_Fife_cost = cost_total_net.
If NHS_Tayside = 1 NHS_Tayside_cost = cost_total_net.

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran_cost to NHS_Tayside_cost (SYSMIS = 0).

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
    /n_preventable_admissions = Sum(preventable_admissions)
    /total_preventable_beddays = Sum(preventable_beddays)
    /total_health_net_cost = Sum(health_net_cost)
    /total_health_net_costincDNAs = Sum(health_net_costincDNAs)
    /total_health_net_costincIncomplete = Sum(health_net_costincIncomplete)
    /total_Acute_episodes = Sum(Acute_episodes)
    /total_Acute_daycase_episodes = Sum(Acute_daycase_episodes)
    /total_Acute_inpatient_episodes = Sum(Acute_inpatient_episodes)
    /total_Acute_el_inpatient_episodes = Sum(Acute_el_inpatient_episodes)
    /total_Acute_non_el_inpatient_episodes = Sum(Acute_non_el_inpatient_episodes)
    /total_Acute_cost = Sum(Acute_cost)
    /total_Acute_daycase_cost = Sum(Acute_daycase_cost)
    /total_Acute_inpatient_cost = Sum(Acute_inpatient_cost)
    /total_Acute_el_inpatient_cost = Sum(Acute_el_inpatient_cost)
    /total_Acute_non_el_inpatient_cost = Sum(Acute_non_el_inpatient_cost)
    /total_Acute_inpatient_beddays = Sum(Acute_inpatient_beddays)
    /total_Acute_el_inpatient_beddays = Sum(Acute_el_inpatient_beddays)
    /total_Acute_non_el_inpatient_beddays = Sum(Acute_non_el_inpatient_beddays)
    /total_Mat_episodes = Sum(Mat_episodes)
    /total_Mat_daycase_episodes = Sum(Mat_daycase_episodes)
    /total_Mat_inpatient_episodes = Sum(Mat_inpatient_episodes)
    /total_Mat_cost = Sum(Mat_cost)
    /total_Mat_daycase_cost = Sum(Mat_daycase_cost)
    /total_Mat_inpatient_cost = Sum(Mat_inpatient_cost)
    /total_Mat_inpatient_beddays = Sum(Mat_inpatient_beddays)
    /total_MH_episodes = Sum(MH_episodes)
    /total_MH_inpatient_episodes = Sum(MH_inpatient_episodes)
    /total_MH_el_inpatient_episodes = Sum(MH_el_inpatient_episodes)
    /total_MH_non_el_inpatient_episodes = Sum(MH_non_el_inpatient_episodes)
    /total_MH_cost = Sum(MH_cost)
    /total_MH_inpatient_cost = Sum(MH_inpatient_cost)
    /total_MH_el_inpatient_cost = Sum(MH_el_inpatient_cost)
    /total_MH_non_el_inpatient_cost = Sum(MH_non_el_inpatient_cost)
    /total_MH_inpatient_beddays = Sum(MH_inpatient_beddays)
    /total_MH_el_inpatient_beddays = Sum(MH_el_inpatient_beddays)
    /total_MH_non_el_inpatient_beddays = Sum(MH_non_el_inpatient_beddays)
    /total_GLS_episodes = Sum(GLS_episodes)
    /total_GLS_inpatient_episodes = Sum(GLS_inpatient_episodes)
    /total_GLS_el_inpatient_episodes = Sum(GLS_el_inpatient_episodes)
    /total_GLS_non_el_inpatient_episodes = Sum(GLS_non_el_inpatient_episodes)
    /total_GLS_cost = Sum(GLS_cost)
    /total_GLS_inpatient_cost = Sum(GLS_inpatient_cost)
    /total_GLS_el_inpatient_cost = Sum(GLS_el_inpatient_cost)
    /total_GLS_non_el_inpatient_cost = Sum(GLS_non_el_inpatient_cost)
    /total_GLS_inpatient_beddays = Sum(GLS_inpatient_beddays)
    /total_GLS_el_inpatient_beddays = Sum(GLS_el_inpatient_beddays)
    /total_GLS_non_el_inpatient_beddays = Sum(GLS_non_el_inpatient_beddays)
    /total_DD_NonCode9_episodes = Sum(DD_NonCode9_episodes)
    /total_DD_NonCode9_beddays = Sum(DD_NonCode9_beddays)
    /total_DD_Code9_episodes = Sum(DD_Code9_episodes)
    /total_DD_Code9_beddays = Sum(DD_Code9_beddays)
    /total_OP_newcons_attendances = Sum(OP_newcons_attendances)
    /total_OP_newcons_dnas = Sum(OP_newcons_dnas)
    /total_OP_cost_attend = Sum(OP_cost_attend)
    /total_OP_cost_dnas = Sum(OP_cost_dnas)
    /total_AE_attendances = Sum(AE_attendances)
    /total_AE_cost = Sum(AE_cost)
    /total_PIS_dispensed_items = Sum(PIS_dispensed_items)
    /total_PIS_cost = Sum(PIS_cost)
    /total_CH_cis_episodes = Sum(CH_cis_episodes)
    /total_CH_beddays = Sum(CH_beddays)
    /total_CH_cost = Sum(CH_cost)
    /total_OoH_cases = Sum(OoH_cases)
    /total_OoH_homeV = Sum(OoH_homeV)
    /total_OoH_advice = Sum(OoH_advice)
    /total_OoH_DN = Sum(OoH_DN)
    /total_OoH_NHS24 = Sum(OoH_NHS24)
    /total_OoH_other = Sum(OoH_other)
    /total_OoH_PCC = Sum(OoH_PCC)
    /total_OoH_consultation_time = Sum(OoH_consultation_time)
    /total_OoH_cost = Sum(OoH_cost)
    /total_DN_episodes = Sum(DN_episodes)
    /total_DN_contacts = Sum(DN_contacts)
    /total_DN_cost = Sum(DN_cost)
    /total_CMH_contacts = Sum(CMH_contacts)
    /total_CIJ_el = Sum(CIJ_el)
    /total_CIJ_non_el = Sum(CIJ_non_el)
    /total_CIJ_mat = Sum(CIJ_mat)
    /total_cij_delay = Sum(cij_delay)
    /total_arth = Sum(arth)
    /total_asthma = Sum(asthma)
    /total_atrialfib = Sum(atrialfib)
    /total_cancer = Sum(cancer)
    /total_cvd = Sum(cvd)
    /total_liver = Sum(liver)
    /total_copd = Sum(copd)
    /total_dementia = Sum(dementia)
    /total_diabetes = Sum(diabetes)
    /total_epilepsy = Sum(epilepsy)
    /total_chd = Sum(chd)
    /total_hefailure = Sum(hefailure)
    /total_ms = Sum(ms)
    /total_parkinsons = Sum(parkinsons)
    /total_refailure = Sum(refailure)
    /total_congen = Sum(congen)
    /total_bloodbfo = Sum(bloodbfo)
    /total_endomet = Sum(endomet)
    /total_digestive = Sum(digestive)
    /mean_health_net_cost = Mean(health_net_cost)
    /mean_health_net_costincDNAs = Mean(health_net_costincDNAs)
    /mean_health_net_costincIncomplete = Mean(health_net_costincIncomplete)
    /mean_Acute_episodes = Mean(Acute_episodes)
    /mean_Acute_daycase_episodes = Mean(Acute_daycase_episodes)
    /mean_Acute_inpatient_episodes = Mean(Acute_inpatient_episodes)
    /mean_Acute_el_inpatient_episodes = Mean(Acute_el_inpatient_episodes)
    /mean_Acute_non_el_inpatient_episodes = Mean(Acute_non_el_inpatient_episodes)
    /mean_Acute_cost = Mean(Acute_cost)
    /mean_Acute_daycase_cost = Mean(Acute_daycase_cost)
    /mean_Acute_inpatient_cost = Mean(Acute_inpatient_cost)
    /mean_Acute_el_inpatient_cost = Mean(Acute_el_inpatient_cost)
    /mean_Acute_non_el_inpatient_cost = Mean(Acute_non_el_inpatient_cost)
    /mean_Acute_inpatient_beddays = Mean(Acute_inpatient_beddays)
    /mean_Acute_el_inpatient_beddays = Mean(Acute_el_inpatient_beddays)
    /mean_Acute_non_el_inpatient_beddays = Mean(Acute_non_el_inpatient_beddays)
    /mean_Mat_episodes = Mean(Mat_episodes)
    /mean_Mat_daycase_episodes = Mean(Mat_daycase_episodes)
    /mean_Mat_inpatient_episodes = Mean(Mat_inpatient_episodes)
    /mean_Mat_cost = Mean(Mat_cost)
    /mean_Mat_daycase_cost = Mean(Mat_daycase_cost)
    /mean_Mat_inpatient_cost = Mean(Mat_inpatient_cost)
    /mean_Mat_inpatient_beddays = Mean(Mat_inpatient_beddays)
    /mean_MH_episodes = Mean(MH_episodes)
    /mean_MH_inpatient_episodes = Mean(MH_inpatient_episodes)
    /mean_MH_el_inpatient_episodes = Mean(MH_el_inpatient_episodes)
    /mean_MH_non_el_inpatient_episodes = Mean(MH_non_el_inpatient_episodes)
    /mean_MH_cost = Mean(MH_cost)
    /mean_MH_inpatient_cost = Mean(MH_inpatient_cost)
    /mean_MH_el_inpatient_cost = Mean(MH_el_inpatient_cost)
    /mean_MH_non_el_inpatient_cost = Mean(MH_non_el_inpatient_cost)
    /mean_MH_inpatient_beddays = Mean(MH_inpatient_beddays)
    /mean_MH_el_inpatient_beddays = Mean(MH_el_inpatient_beddays)
    /mean_MH_non_el_inpatient_beddays = Mean(MH_non_el_inpatient_beddays)
    /mean_GLS_episodes = Mean(GLS_episodes)
    /mean_GLS_inpatient_episodes = Mean(GLS_inpatient_episodes)
    /mean_GLS_el_inpatient_episodes = Mean(GLS_el_inpatient_episodes)
    /mean_GLS_non_el_inpatient_episodes = Mean(GLS_non_el_inpatient_episodes)
    /mean_GLS_cost = Mean(GLS_cost)
    /mean_GLS_inpatient_cost = Mean(GLS_inpatient_cost)
    /mean_GLS_el_inpatient_cost = Mean(GLS_el_inpatient_cost)
    /mean_GLS_non_el_inpatient_cost = Mean(GLS_non_el_inpatient_cost)
    /mean_GLS_inpatient_beddays = Mean(GLS_inpatient_beddays)
    /mean_GLS_el_inpatient_beddays = Mean(GLS_el_inpatient_beddays)
    /mean_GLS_non_el_inpatient_beddays = Mean(GLS_non_el_inpatient_beddays)
    /mean_DD_NonCode9_episodes = Mean(DD_NonCode9_episodes)
    /mean_DD_NonCode9_beddays = Mean(DD_NonCode9_beddays)
    /mean_DD_Code9_episodes = Mean(DD_Code9_episodes)
    /mean_DD_Code9_beddays = Mean(DD_Code9_beddays)
    /mean_OP_newcons_attendances = Mean(OP_newcons_attendances)
    /mean_OP_newcons_dnas = Mean(OP_newcons_dnas)
    /mean_OP_cost_attend = Mean(OP_cost_attend)
    /mean_OP_cost_dnas = Mean(OP_cost_dnas)
    /mean_AE_attendances = Mean(AE_attendances)
    /mean_AE_cost = Mean(AE_cost)
    /mean_PIS_dispensed_items = Mean(PIS_dispensed_items)
    /mean_PIS_cost = Mean(PIS_cost)
    /mean_CH_cis_episodes = Mean(CH_cis_episodes)
    /mean_CH_beddays = Mean(CH_beddays)
    /mean_CH_cost = Mean(CH_cost)
    /mean_OoH_cases = Mean(OoH_cases)
    /mean_OoH_homeV = Mean(OoH_homeV)
    /mean_OoH_advice = Mean(OoH_advice)
    /mean_OoH_DN = Mean(OoH_DN)
    /mean_OoH_NHS24 = Mean(OoH_NHS24)
    /mean_OoH_other = Mean(OoH_other)
    /mean_OoH_PCC = Mean(OoH_PCC)
    /mean_OoH_consultation_time = Mean(OoH_consultation_time)
    /mean_OoH_cost = Mean(OoH_cost)
    /mean_DN_episodes = Mean(DN_episodes)
    /mean_DN_contacts = Mean(DN_contacts)
    /mean_DN_cost = Mean(DN_cost)
    /mean_CMH_contacts = Mean(CMH_contacts)
    /mean_CIJ_el = Mean(CIJ_el)
    /mean_CIJ_non_el = Mean(CIJ_non_el)
    /mean_CIJ_mat = Mean(CIJ_mat)
    /mean_cij_delay = Mean(cij_delay)
    /mean_arth = Mean(arth)
    /mean_asthma = Mean(asthma)
    /mean_atrialfib = Mean(atrialfib)
    /mean_cancer = Mean(cancer)
    /mean_cvd = Mean(cvd)
    /mean_liver = Mean(liver)
    /mean_copd = Mean(copd)
    /mean_dementia = Mean(dementia)
    /mean_diabetes = Mean(diabetes)
    /mean_epilepsy = Mean(epilepsy)
    /mean_chd = Mean(chd)
    /mean_hefailure = Mean(hefailure)
    /mean_ms = Mean(ms)
    /mean_parkinsons = Mean(parkinsons)
    /mean_refailure = Mean(refailure)
    /mean_congen = Mean(congen)
    /mean_bloodbfo = Mean(bloodbfo)
    /mean_endomet = Mean(endomet)
    /mean_digestive = Mean(digestive)
    /n_Population = Sum(Keep_Population)
    /HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN = Sum(HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN)
    /All_NHS_Ayrshire_and_Arran = Sum(NHS_Ayrshire_and_Arran)
    /All_NHS_Borders = Sum(NHS_Borders)
    /All_NHS_Dumfries_and_Galloway = Sum(NHS_Dumfries_and_Galloway)
    /All_NHS_Forth_Valley = Sum(NHS_Forth_Valley)
    /All_NHS_Grampian = Sum(NHS_Grampian)
    /All_NHS_Greater_Glasgow_and_Clyde = Sum(NHS_Greater_Glasgow_and_Clyde)
    /All_NHS_Highland = Sum(NHS_Highland) 
    /All_NHS_Lanarkshire = Sum(NHS_Lanarkshire)
    /All_NHS_Lothian = Sum(NHS_Lothian)
    /All_NHS_Orkney = Sum(NHS_Orkney)
    /All_NHS_Shetland = Sum(NHS_Shetland)
    /All_NHS_Western_Isles = Sum(NHS_Western_Isles)
    /All_NHS_Fife = Sum(NHS_Fife)
    /All_NHS_Tayside = Sum(NHS_Tayside)
    /NHS_Ayrshire_and_Arran_cost = Sum(NHS_Ayrshire_and_Arran_cost) 
    /NHS_Borders_cost = Sum(NHS_Borders_cost)
    /NHS_Dumfries_and_Galloway_cost = Sum(NHS_Dumfries_and_Galloway_cost) 
    /NHS_Forth_Valley_cost = Sum(NHS_Forth_Valley_cost)
    /NHS_Grampian_cost = Sum(NHS_Grampian_cost)
    /NHS_Greater_Glasgow_and_Clyde_cost = Sum(NHS_Greater_Glasgow_and_Clyde_cost)
    /NHS_Highland_cost = Sum(NHS_Highland_cost)
    /NHS_Lanarkshire_cost = Sum(NHS_Lanarkshire_cost) 
    /NHS_Lothian_cost = Sum(NHS_Lothian_cost) 
    /NHS_Orkney_cost = Sum(NHS_Orkney_cost)
    /NHS_Shetland_cost = Sum(NHS_Shetland_cost)
    /NHS_Western_Isles_cost = Sum(NHS_Western_Isles_cost) 
    /NHS_Fife_cost = Sum(NHS_Fife_cost)
    /NHS_Tayside_cost = Sum(NHS_Tayside_cost). 

 * Rearrange nicely.
Dataset Activate New_Summary.
Varstocases
    /Make NewValue from n_CHIs to NHS_Tayside_cost
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

 * Recode SPARRA and HHG to count numbers of records without this data.
Recode SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY HHG_End_FY (sysmis = 1) (else = 0).

*Flag to count how many patients in each HB by rescode. 
If hbrescode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbrescode = 'S08000016' NHS_Borders = 1. 
If hbrescode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbrescode = 'S08000019' NHS_Forth_Valley = 1. 
If hbrescode = 'S08000020' NHS_Grampian = 1. 
If any(hbrescode, 'S08000021', 'S08000031') NHS_Greater_Glasgow_and_Clyde = 1.
If hbrescode = 'S08000022' NHS_Highland = 1.
If any(hbrescode, 'S08000023', 'S08000032') NHS_Lanarkshire = 1. 
If hbrescode = 'S08000024' NHS_Lothian = 1. 
If hbrescode = 'S08000025' NHS_Orkney = 1. 
If hbrescode = 'S08000026' NHS_Shetland = 1. 
If hbrescode = 'S08000028' NHS_Western_Isles = 1. 
If any(hbrescode, 'S08000018', 'S08000029') NHS_Fife = 1. 
If any(hbrescode, 'S08000027', 'S08000030') NHS_Tayside = 1. 

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran to NHS_Tayside (SYSMIS = 0).

*Flag to count HB costs. 
If NHS_Ayrshire_and_Arran = 1 NHS_Ayrshire_and_Arran_cost = cost_total_net.
If NHS_Borders = 1 NHS_Borders_cost = cost_total_net. 
If NHS_Dumfries_and_Galloway = 1 NHS_Dumfries_and_Galloway_cost = cost_total_net.
If NHS_Forth_Valley = 1 NHS_Forth_Valley_cost = cost_total_net.
If NHS_Grampian = 1 NHS_Grampian_cost = cost_total_net.
If NHS_Greater_Glasgow_and_Clyde = 1 NHS_Greater_Glasgow_and_Clyde_cost = cost_total_net.
If NHS_Highland = 1 NHS_Highland_cost = cost_total_net.
If NHS_Lanarkshire = 1 NHS_Lanarkshire_cost = cost_total_net.
If NHS_Lothian = 1 NHS_Lothian_cost = cost_total_net.
If NHS_Orkney = 1 NHS_Orkney_cost = cost_total_net.
If NHS_Shetland = 1 NHS_Shetland_cost = cost_total_net.
If NHS_Western_Isles = 1 NHS_Western_Isles_cost = cost_total_net.
If NHS_Fife = 1 NHS_Fife_cost = cost_total_net.
If NHS_Tayside = 1 NHS_Tayside_cost = cost_total_net.

*Change missing HB values to 0. 
Recode NHS_Ayrshire_and_Arran_cost to NHS_Tayside_cost (SYSMIS = 0).

*No PPA or PPB available in the old file. 
*Will need to add these back into the old summary once the year is updated again.
*   /n_preventable_admissions = Sum(preventable_admissions)
*   /total_preventable_beddays = Sum(preventable_beddays)
*   /total_cij_delay = Sum(cij_delay)

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
    /total_health_net_cost = Sum(health_net_cost)
    /total_health_net_costincDNAs = Sum(health_net_costincDNAs)
    /total_health_net_costincIncomplete = Sum(health_net_costincIncomplete)
    /total_Acute_episodes = Sum(Acute_episodes)
    /total_Acute_daycase_episodes = Sum(Acute_daycase_episodes)
    /total_Acute_inpatient_episodes = Sum(Acute_inpatient_episodes)
    /total_Acute_el_inpatient_episodes = Sum(Acute_el_inpatient_episodes)
    /total_Acute_non_el_inpatient_episodes = Sum(Acute_non_el_inpatient_episodes)
    /total_Acute_cost = Sum(Acute_cost)
    /total_Acute_daycase_cost = Sum(Acute_daycase_cost)
    /total_Acute_inpatient_cost = Sum(Acute_inpatient_cost)
    /total_Acute_el_inpatient_cost = Sum(Acute_el_inpatient_cost)
    /total_Acute_non_el_inpatient_cost = Sum(Acute_non_el_inpatient_cost)
    /total_Acute_inpatient_beddays = Sum(Acute_inpatient_beddays)
    /total_Acute_el_inpatient_beddays = Sum(Acute_el_inpatient_beddays)
    /total_Acute_non_el_inpatient_beddays = Sum(Acute_non_el_inpatient_beddays)
    /total_Mat_episodes = Sum(Mat_episodes)
    /total_Mat_daycase_episodes = Sum(Mat_daycase_episodes)
    /total_Mat_inpatient_episodes = Sum(Mat_inpatient_episodes)
    /total_Mat_cost = Sum(Mat_cost)
    /total_Mat_daycase_cost = Sum(Mat_daycase_cost)
    /total_Mat_inpatient_cost = Sum(Mat_inpatient_cost)
    /total_Mat_inpatient_beddays = Sum(Mat_inpatient_beddays)
    /total_MH_episodes = Sum(MH_episodes)
    /total_MH_inpatient_episodes = Sum(MH_inpatient_episodes)
    /total_MH_el_inpatient_episodes = Sum(MH_el_inpatient_episodes)
    /total_MH_non_el_inpatient_episodes = Sum(MH_non_el_inpatient_episodes)
    /total_MH_cost = Sum(MH_cost)
    /total_MH_inpatient_cost = Sum(MH_inpatient_cost)
    /total_MH_el_inpatient_cost = Sum(MH_el_inpatient_cost)
    /total_MH_non_el_inpatient_cost = Sum(MH_non_el_inpatient_cost)
    /total_MH_inpatient_beddays = Sum(MH_inpatient_beddays)
    /total_MH_el_inpatient_beddays = Sum(MH_el_inpatient_beddays)
    /total_MH_non_el_inpatient_beddays = Sum(MH_non_el_inpatient_beddays)
    /total_GLS_episodes = Sum(GLS_episodes)
    /total_GLS_inpatient_episodes = Sum(GLS_inpatient_episodes)
    /total_GLS_el_inpatient_episodes = Sum(GLS_el_inpatient_episodes)
    /total_GLS_non_el_inpatient_episodes = Sum(GLS_non_el_inpatient_episodes)
    /total_GLS_cost = Sum(GLS_cost)
    /total_GLS_inpatient_cost = Sum(GLS_inpatient_cost)
    /total_GLS_el_inpatient_cost = Sum(GLS_el_inpatient_cost)
    /total_GLS_non_el_inpatient_cost = Sum(GLS_non_el_inpatient_cost)
    /total_GLS_inpatient_beddays = Sum(GLS_inpatient_beddays)
    /total_GLS_el_inpatient_beddays = Sum(GLS_el_inpatient_beddays)
    /total_GLS_non_el_inpatient_beddays = Sum(GLS_non_el_inpatient_beddays)
    /total_DD_NonCode9_episodes = Sum(DD_NonCode9_episodes)
    /total_DD_NonCode9_beddays = Sum(DD_NonCode9_beddays)
    /total_DD_Code9_episodes = Sum(DD_Code9_episodes)
    /total_DD_Code9_beddays = Sum(DD_Code9_beddays)
    /total_OP_newcons_attendances = Sum(OP_newcons_attendances)
    /total_OP_newcons_dnas = Sum(OP_newcons_dnas)
    /total_OP_cost_attend = Sum(OP_cost_attend)
    /total_OP_cost_dnas = Sum(OP_cost_dnas)
    /total_AE_attendances = Sum(AE_attendances)
    /total_AE_cost = Sum(AE_cost)
    /total_PIS_dispensed_items = Sum(PIS_dispensed_items)
    /total_PIS_cost = Sum(PIS_cost)
    /total_CH_episodes = Sum(CH_episodes)
    /total_CH_beddays = Sum(CH_beddays)
    /total_CH_cost = Sum(CH_cost)
    /total_OoH_cases = Sum(OoH_cases)
    /total_OoH_homeV = Sum(OoH_homeV)
    /total_OoH_advice = Sum(OoH_advice)
    /total_OoH_DN = Sum(OoH_DN)
    /total_OoH_NHS24 = Sum(OoH_NHS24)
    /total_OoH_other = Sum(OoH_other)
    /total_OoH_PCC = Sum(OoH_PCC)
    /total_OoH_consultation_time = Sum(OoH_consultation_time)
    /total_OoH_cost = Sum(OoH_cost)
    /total_DN_episodes = Sum(DN_episodes)
    /total_DN_contacts = Sum(DN_contacts)
    /total_DN_cost = Sum(DN_cost)
    /total_CMH_contacts = Sum(CMH_contacts)
    /total_CIJ_el = Sum(CIJ_el)
    /total_CIJ_non_el = Sum(CIJ_non_el)
    /total_CIJ_mat = Sum(CIJ_mat)
    /total_arth = Sum(arth)
    /total_asthma = Sum(asthma)
    /total_atrialfib = Sum(atrialfib)
    /total_cancer = Sum(cancer)
    /total_cvd = Sum(cvd)
    /total_liver = Sum(liver)
    /total_copd = Sum(copd)
    /total_dementia = Sum(dementia)
    /total_diabetes = Sum(diabetes)
    /total_epilepsy = Sum(epilepsy)
    /total_chd = Sum(chd)
    /total_hefailure = Sum(hefailure)
    /total_ms = Sum(ms)
    /total_parkinsons = Sum(parkinsons)
    /total_refailure = Sum(refailure)
    /total_congen = Sum(congen)
    /total_bloodbfo = Sum(bloodbfo)
    /total_endomet = Sum(endomet)
    /total_digestive = Sum(digestive)
    /mean_health_net_cost = Mean(health_net_cost)
    /mean_health_net_costincDNAs = Mean(health_net_costincDNAs)
    /mean_health_net_costincIncomplete = Mean(health_net_costincIncomplete)
    /mean_Acute_episodes = Mean(Acute_episodes)
    /mean_Acute_daycase_episodes = Mean(Acute_daycase_episodes)
    /mean_Acute_inpatient_episodes = Mean(Acute_inpatient_episodes)
    /mean_Acute_el_inpatient_episodes = Mean(Acute_el_inpatient_episodes)
    /mean_Acute_non_el_inpatient_episodes = Mean(Acute_non_el_inpatient_episodes)
    /mean_Acute_cost = Mean(Acute_cost)
    /mean_Acute_daycase_cost = Mean(Acute_daycase_cost)
    /mean_Acute_inpatient_cost = Mean(Acute_inpatient_cost)
    /mean_Acute_el_inpatient_cost = Mean(Acute_el_inpatient_cost)
    /mean_Acute_non_el_inpatient_cost = Mean(Acute_non_el_inpatient_cost)
    /mean_Acute_inpatient_beddays = Mean(Acute_inpatient_beddays)
    /mean_Acute_el_inpatient_beddays = Mean(Acute_el_inpatient_beddays)
    /mean_Acute_non_el_inpatient_beddays = Mean(Acute_non_el_inpatient_beddays)
    /mean_Mat_episodes = Mean(Mat_episodes)
    /mean_Mat_daycase_episodes = Mean(Mat_daycase_episodes)
    /mean_Mat_inpatient_episodes = Mean(Mat_inpatient_episodes)
    /mean_Mat_cost = Mean(Mat_cost)
    /mean_Mat_daycase_cost = Mean(Mat_daycase_cost)
    /mean_Mat_inpatient_cost = Mean(Mat_inpatient_cost)
    /mean_Mat_inpatient_beddays = Mean(Mat_inpatient_beddays)
    /mean_MH_episodes = Mean(MH_episodes)
    /mean_MH_inpatient_episodes = Mean(MH_inpatient_episodes)
    /mean_MH_el_inpatient_episodes = Mean(MH_el_inpatient_episodes)
    /mean_MH_non_el_inpatient_episodes = Mean(MH_non_el_inpatient_episodes)
    /mean_MH_cost = Mean(MH_cost)
    /mean_MH_inpatient_cost = Mean(MH_inpatient_cost)
    /mean_MH_el_inpatient_cost = Mean(MH_el_inpatient_cost)
    /mean_MH_non_el_inpatient_cost = Mean(MH_non_el_inpatient_cost)
    /mean_MH_inpatient_beddays = Mean(MH_inpatient_beddays)
    /mean_MH_el_inpatient_beddays = Mean(MH_el_inpatient_beddays)
    /mean_MH_non_el_inpatient_beddays = Mean(MH_non_el_inpatient_beddays)
    /mean_GLS_episodes = Mean(GLS_episodes)
    /mean_GLS_inpatient_episodes = Mean(GLS_inpatient_episodes)
    /mean_GLS_el_inpatient_episodes = Mean(GLS_el_inpatient_episodes)
    /mean_GLS_non_el_inpatient_episodes = Mean(GLS_non_el_inpatient_episodes)
    /mean_GLS_cost = Mean(GLS_cost)
    /mean_GLS_inpatient_cost = Mean(GLS_inpatient_cost)
    /mean_GLS_el_inpatient_cost = Mean(GLS_el_inpatient_cost)
    /mean_GLS_non_el_inpatient_cost = Mean(GLS_non_el_inpatient_cost)
    /mean_GLS_inpatient_beddays = Mean(GLS_inpatient_beddays)
    /mean_GLS_el_inpatient_beddays = Mean(GLS_el_inpatient_beddays)
    /mean_GLS_non_el_inpatient_beddays = Mean(GLS_non_el_inpatient_beddays)
    /mean_DD_NonCode9_episodes = Mean(DD_NonCode9_episodes)
    /mean_DD_NonCode9_beddays = Mean(DD_NonCode9_beddays)
    /mean_DD_Code9_episodes = Mean(DD_Code9_episodes)
    /mean_DD_Code9_beddays = Mean(DD_Code9_beddays)
    /mean_OP_newcons_attendances = Mean(OP_newcons_attendances)
    /mean_OP_newcons_dnas = Mean(OP_newcons_dnas)
    /mean_OP_cost_attend = Mean(OP_cost_attend)
    /mean_OP_cost_dnas = Mean(OP_cost_dnas)
    /mean_AE_attendances = Mean(AE_attendances)
    /mean_AE_cost = Mean(AE_cost)
    /mean_PIS_dispensed_items = Mean(PIS_dispensed_items)
    /mean_PIS_cost = Mean(PIS_cost)
    /mean_CH_episodes = Mean(CH_episodes)
    /mean_CH_beddays = Mean(CH_beddays)
    /mean_CH_cost = Mean(CH_cost)
    /mean_OoH_cases = Mean(OoH_cases)
    /mean_OoH_homeV = Mean(OoH_homeV)
    /mean_OoH_advice = Mean(OoH_advice)
    /mean_OoH_DN = Mean(OoH_DN)
    /mean_OoH_NHS24 = Mean(OoH_NHS24)
    /mean_OoH_other = Mean(OoH_other)
    /mean_OoH_PCC = Mean(OoH_PCC)
    /mean_OoH_consultation_time = Mean(OoH_consultation_time)
    /mean_OoH_cost = Mean(OoH_cost)
    /mean_DN_episodes = Mean(DN_episodes)
    /mean_DN_contacts = Mean(DN_contacts)
    /mean_DN_cost = Mean(DN_cost)
    /mean_CMH_contacts = Mean(CMH_contacts)
    /mean_CIJ_el = Mean(CIJ_el)
    /mean_CIJ_non_el = Mean(CIJ_non_el)
    /mean_CIJ_mat = Mean(CIJ_mat)
    /mean_arth = Mean(arth)
    /mean_asthma = Mean(asthma)
    /mean_atrialfib = Mean(atrialfib)
    /mean_cancer = Mean(cancer)
    /mean_cvd = Mean(cvd)
    /mean_liver = Mean(liver)
    /mean_copd = Mean(copd)
    /mean_dementia = Mean(dementia)
    /mean_diabetes = Mean(diabetes)
    /mean_epilepsy = Mean(epilepsy)
    /mean_chd = Mean(chd)
    /mean_hefailure = Mean(hefailure)
    /mean_ms = Mean(ms)
    /mean_parkinsons = Mean(parkinsons)
    /mean_refailure = Mean(refailure)
    /mean_congen = Mean(congen)
    /mean_bloodbfo = Mean(bloodbfo)
    /mean_endomet = Mean(endomet)
    /mean_digestive = Mean(digestive)
    /n_Population = Sum(Keep_Population)
    /HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN = Sum(HRI_Scot HRI_HB HRI_LCA HRI_LCA_incDN)
    /All_NHS_Ayrshire_and_Arran = Sum(NHS_Ayrshire_and_Arran)
    /All_NHS_Borders = Sum(NHS_Borders)
    /All_NHS_Dumfries_and_Galloway = Sum(NHS_Dumfries_and_Galloway)
    /All_NHS_Forth_Valley = Sum(NHS_Forth_Valley)
    /All_NHS_Grampian = Sum(NHS_Grampian)
    /All_NHS_Greater_Glasgow_and_Clyde = Sum(NHS_Greater_Glasgow_and_Clyde)
    /All_NHS_Highland = Sum(NHS_Highland) 
    /All_NHS_Lanarkshire = Sum(NHS_Lanarkshire)
    /All_NHS_Lothian = Sum(NHS_Lothian)
    /All_NHS_Orkney = Sum(NHS_Orkney)
    /All_NHS_Shetland = Sum(NHS_Shetland)
    /All_NHS_Western_Isles = Sum(NHS_Western_Isles)
    /All_NHS_Fife = Sum(NHS_Fife)
    /All_NHS_Tayside = Sum(NHS_Tayside)
    /NHS_Ayrshire_and_Arran_cost = Sum(NHS_Ayrshire_and_Arran_cost) 
    /NHS_Borders_cost = Sum(NHS_Borders_cost)
    /NHS_Dumfries_and_Galloway_cost = Sum(NHS_Dumfries_and_Galloway_cost) 
    /NHS_Forth_Valley_cost = Sum(NHS_Forth_Valley_cost)
    /NHS_Grampian_cost = Sum(NHS_Grampian_cost)
    /NHS_Greater_Glasgow_and_Clyde_cost = Sum(NHS_Greater_Glasgow_and_Clyde_cost)
    /NHS_Highland_cost = Sum(NHS_Highland_cost)
    /NHS_Lanarkshire_cost = Sum(NHS_Lanarkshire_cost) 
    /NHS_Lothian_cost = Sum(NHS_Lothian_cost) 
    /NHS_Orkney_cost = Sum(NHS_Orkney_cost)
    /NHS_Shetland_cost = Sum(NHS_Shetland_cost)
    /NHS_Western_Isles_cost = Sum(NHS_Western_Isles_cost) 
    /NHS_Fife_cost = Sum(NHS_Fife_cost)
    /NHS_Tayside_cost = Sum(NHS_Tayside_cost). 

Dataset Close OldFile.

 * Rearrange nicely.
Dataset Activate Old_Summary.
Varstocases
    /Make OldValue from n_CHIs to NHS_Tayside_cost
    /Index Measure (OldValue).
Sort cases by Measure.

 * Match the summaries together to compare.
match files
    /file = Old_Summary
    /file = New_Summary
    /By Measure.

 * Housekeeping.
Dataset Name !FinalName.
Dataset Close Old_Summary.
Dataset Close New_Summary.

Dataset Activate !FinalName.

 * Compute percentage change from old to new.
 * Highlight any which have a >= 5 % change.
Numeric Issue (F1.0) PctChange (F8.4).
Compute Difference = NewValue - OldValue.
Compute PctChange = Difference / OldValue * 100.
Compute Issue = abs(PctChange) > 5.

Sort cases by Issue (D) Measure (A).

save outfile = !Year_dir + "source-individual-TESTS-20" + !FY + ".sav".
