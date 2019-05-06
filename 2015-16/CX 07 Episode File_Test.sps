* Encoding: UTF-8.
Define !Create_Aggregate(FileVersion = !Tokens(1)
    /BreakVar = !Tokens(1)).

!Let !DatasetName = !Concat(!Unquote(!FileVersion), "By", !Unquote(!BreakVar)).

Dataset Declare !DatasetName.

aggregate outfile = !DatasetName
    /break year !BreakVar
    /Num_episodes = n
    /Avg_age Avg_gender = Mean(age gender)
    /Earliest_adm Earliest_dis = Min(keydate1_dateformat keydate2_dateformat)
    /Latest_adm Latest_dis= Max(keydate1_dateformat keydate2_dateformat)
    /CIS_PPAs = Sum(CIS_PPA)
    /avg_yearstay avg_stay = Mean(yearstay stay)
    /avg_cost_total_net avg_Cost_Total_Net_incDNAs = Mean(cost_total_net Cost_Total_Net_incDNAs)
    /apr_beddays
    may_beddays
    jun_beddays
    jul_beddays
    aug_beddays
    sep_beddays
    oct_beddays
    nov_beddays
    dec_beddays
    jan_beddays
    feb_beddays
    mar_beddays
    apr_cost
    may_cost
    jun_cost
    jul_cost
    aug_cost
    sep_cost
    oct_cost
    nov_cost
    dec_cost
    jan_cost
    feb_cost
    mar_cost
    = Mean(apr_beddays
    may_beddays
    jun_beddays
    jul_beddays
    aug_beddays
    sep_beddays
    oct_beddays
    nov_beddays
    dec_beddays
    jan_beddays
    feb_beddays
    mar_beddays
    apr_cost
    may_cost
    jun_cost
    jul_cost
    aug_cost
    sep_cost
    oct_cost
    nov_cost
    dec_cost
    jan_cost
    feb_cost
    mar_cost).
!EndDefine.


get file = !File + "source-episode-file-20" + !FY + ".zsav".
!Create_Aggregate FileVersion = New BreakVar = Recid.
!Create_Aggregate FileVersion = New BreakVar = LCA.


get file =  "/conf/hscdiip/01-Source-linkage-files/source-episode-file-20" + !FY + ".zsav".

!Create_Aggregate FileVersion = Old BreakVar = Recid.
!Create_Aggregate FileVersion = Old BreakVar = LCA.

add files
    /file = Newbyrecid
    /In = New
    /file = Oldbyrecid
    /In = Old
    /By Year recid.

do repeat var = Num_episodes to Mar_cost
    /num = var.1 to var.36.

    Do if Old = 1.
        Compute num = ((lag(var) - var) / var) * 100.
    End if.
End repeat.


***************************************.

add files
    /file = NewbyLCA
    /In = New
    /file = OldbyLCA
    /In = Old
    /By Year LCA.

do repeat var = Num_episodes to Mar_cost
    /num = var.1 to var.36.

    Do if Old = 1.
        Compute num = ((lag(var) - var) / var) * 100.
    End if.

End repeat.


