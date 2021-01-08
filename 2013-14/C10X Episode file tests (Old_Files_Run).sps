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
    /avg_yearstay avg_stay = Mean(yearstay stay)
    /total_yearstay total_stay = Sum(yearstay stay)
    /avg_cost_total_net avg_Cost_Total_Net_incDNAs = Mean(cost_total_net Cost_Total_Net_incDNAs)
    /total_cost_total_net total_Cost_Total_Net_incDNAs = Sum(cost_total_net Cost_Total_Net_incDNAs).
   

Dataset Activate !DatasetName.

Varstocases
    /make Value from n_episodes to total_Cost_Total_Net_incDNAs
    /Index Measure (Value).

sort cases by year recid measure.

Alter type value (F8.2).

!EndDefine.

get file = !File + "source-episode-file-20" + !FY + ".zsav".
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

save outfile = !File + "source-episode-TESTS-20" + !FY + ".sav".
