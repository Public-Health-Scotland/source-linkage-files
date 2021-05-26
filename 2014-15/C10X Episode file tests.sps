* Encoding: UTF-8.
Define !FinalName()
    !Concat("Recid_Compare_", !unquote(!Eval(!FY)))
!EndDefine.

Define !Create_Aggregate(FileVersion = !Tokens(1)).

!Let !DatasetName = !Concat(!Unquote(!FileVersion), "By", "Recid").

Dataset Declare !DatasetName.

 * Flags to count M/Fs.
Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

 * Flags to count age groups.
Do if age < 18.
    Compute Child = 1.
Else.
    Compute Adult = 1.
End if.

If age >= 65 Over_65 = 1.


 * Flags to count missing values.
If sysmis(dob) No_DoB = 1.

if postcode = "" No_Postcode = 1.
if sysmis(gpprac) No_GPprac = 1.

 * Flags to count stay types.
If cij_pattype = "Elective" CIJ_elective = 1.
If cij_pattype = "Non-Elective" CIJ_non_elective = 1.
If cij_pattype = "Maternity" CIJ_maternity = 1.
If cij_pattype = "Other" CIJ_other = 1.

sort cases by recid.

aggregate outfile = !DatasetName
    /Presorted
    /break year recid
    /n_episodes = n
    /n_male n_female = Sum(Male Female)
    /n_no_dob n_no_postcode n_no_gpprac= Sum(No_DoB No_Postcode No_GPprac)
    /n_CIJ_elective n_CIJ_non_elective n_CIJ_maternity n_CIJ_other = Sum(CIJ_elective CIJ_non_elective CIJ_maternity CIJ_other)
    /Avg_age = Mean(age)
    /n_children n_adults n_over65 = Sum(Child Adult Over_65)
    /Earliest_adm Earliest_dis = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_adm Latest_dis= Max(keydate1_dateformat keydate2_dateformat)
    /cij_ppas = Sum(cij_ppa)
    /avg_yearstay avg_stay = Mean(yearstay stay)
    /total_yearstay total_stay = Sum(yearstay stay)
    /avg_apr_beddays = Mean(apr_beddays)
    /avg_may_beddays = Mean(may_beddays)
    /avg_jun_beddays = Mean(jun_beddays)
    /avg_jul_beddays = Mean(jul_beddays)
    /avg_aug_beddays = Mean(aug_beddays)
    /avg_sep_beddays = Mean(sep_beddays)
    /avg_oct_beddays = Mean(oct_beddays)
    /avg_nov_beddays = Mean(nov_beddays)
    /avg_dec_beddays = Mean(dec_beddays)
    /avg_jan_beddays = Mean(jan_beddays)
    /avg_feb_beddays = Mean(feb_beddays)
    /avg_mar_beddays = Mean(mar_beddays)
    /total_apr_beddays = Sum(apr_beddays)
    /total_may_beddays = Sum(may_beddays)
    /total_jun_beddays = Sum(jun_beddays)
    /total_jul_beddays = Sum(jul_beddays)
    /total_aug_beddays = Sum(aug_beddays)
    /total_sep_beddays = Sum(sep_beddays)
    /total_oct_beddays = Sum(oct_beddays)
    /total_nov_beddays = Sum(nov_beddays)
    /total_dec_beddays = Sum(dec_beddays)
    /total_jan_beddays = Sum(jan_beddays)
    /total_feb_beddays = Sum(feb_beddays)
    /total_mar_beddays = Sum(mar_beddays)
    /avg_cost_total_net avg_Cost_Total_Net_incDNAs = Mean(cost_total_net Cost_Total_Net_incDNAs)
    /total_cost_total_net total_Cost_Total_Net_incDNAs = Sum(cost_total_net Cost_Total_Net_incDNAs)
    /avg_apr_cost = Mean(apr_cost)
    /avg_may_cost = Mean(may_cost)
    /avg_jun_cost = Mean(jun_cost)
    /avg_jul_cost = Mean(jul_cost)
    /avg_aug_cost = Mean(aug_cost)
    /avg_sep_cost = Mean(sep_cost)
    /avg_oct_cost = Mean(oct_cost)
    /avg_nov_cost = Mean(nov_cost)
    /avg_dec_cost = Mean(dec_cost)
    /avg_jan_cost = Mean(jan_cost)
    /avg_feb_cost = Mean(feb_cost)
    /avg_mar_cost = Mean(mar_cost)
    /total_apr_cost = Sum(apr_cost)
    /total_may_cost = Sum(may_cost)
    /total_jun_cost = Sum(jun_cost)
    /total_jul_cost = Sum(jul_cost)
    /total_aug_cost = Sum(aug_cost)
    /total_sep_cost = Sum(sep_cost)
    /total_oct_cost = Sum(oct_cost)
    /total_nov_cost = Sum(nov_cost)
    /total_dec_cost = Sum(dec_cost)
    /total_jan_cost = Sum(jan_cost)
    /total_feb_cost = Sum(feb_cost)
    /total_mar_cost = Sum(mar_cost).

Dataset Activate !DatasetName.

Varstocases
    /make Value from n_episodes to total_mar_cost
    /Index Measure (Value).

sort cases by year recid measure.

Alter type value (F8.2).

!EndDefine.

get file = !Year_dir + "source-episode-file-20" + !FY + ".zsav".
!Create_Aggregate FileVersion = New.

get file =  "/conf/hscdiip/01-Source-linkage-files/source-episode-file-20" + !FY + ".zsav".
!Create_Aggregate FileVersion = Old.

match files 
    /file = NewByRecid
    /Rename Value = New_Value
    /file OldByRecid
    /rename Value = Old_Value
    /By year recid measure.
Dataset Name !FinalName.
Dataset Close Newbyrecid.
Dataset Close Oldbyrecid.

Dataset Activate  !FinalName.

Compute diff = New_Value - Old_Value.
Compute pct_diff = (diff / Old_Value) * 100.
If abs(pct_diff) >= 5 Possible_issue = 1.

Crosstabs recid by Possible_issue.

save outfile = !Year_dir + "source-episode-TESTS-20" + !FY + ".sav".
