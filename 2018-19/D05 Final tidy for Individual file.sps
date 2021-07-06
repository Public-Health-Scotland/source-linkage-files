* Encoding: UTF-8.
get file = !Year_dir + "temp-source-individual-file-5-20" + !FY + ".zsav".

Value Labels year
    "1011" "2010/11"
    "1112" "2011/12"
    "1213" "2012/13"
    "1314" "2013/14"
    "1415" "2014/15"
    "1516" "2015/16"
    "1617" "2016/17"
    "1718" "2017/18"
    "1819" "2018/19"
    "1920" "2019/20"
    "2021" "2020/21"
    "2122" "2021/22"
    "2223" "2022/23"
    "2324" "2023/24"
    "2425" "2024/25".

* Tidy up counter variables.
Alter type
    Acute_episodes Acute_daycase_episodes Acute_inpatient_episodes Acute_el_inpatient_episodes Acute_non_el_inpatient_episodes Acute_el_inpatient_beddays Acute_non_el_inpatient_beddays
    Mat_episodes Mat_daycase_episodes Mat_inpatient_episodes Mat_inpatient_beddays
    MH_episodes MH_inpatient_episodes MH_el_inpatient_episodes MH_non_el_inpatient_episodes MH_inpatient_beddays MH_el_inpatient_beddays MH_non_el_inpatient_beddays
    GLS_episodes GLS_inpatient_episodes GLS_el_inpatient_episodes GLS_non_el_inpatient_episodes GLS_inpatient_beddays GLS_el_inpatient_beddays GLS_non_el_inpatient_beddays
    DD_NonCode9_episodes DD_NonCode9_beddays DD_Code9_episodes DD_Code9_beddays
    OP_newcons_attendances OP_newcons_dnas
    AE_attendances
    PIS_dispensed_items
    CH_cis_episodes CH_beddays
    OoH_cases OoH_homeV OoH_advice OoH_DN OoH_NHS24 OoH_other OoH_PCC OoH_consultation_time
    DN_episodes DN_contacts
    CMH_contacts
    CIJ_el CIJ_non_el CIJ_mat (F8.0).

* Tidy up the display.
Variable width
    gender age postcode gpprac (7)
    health_net_cost health_net_costincDNAs health_net_costincIncomplete (15)
    dob HL1_in_FY NSU to digestive_date (10).

* Add variable labels.
Variable Labels
    year "Financial Year"
    gender "Gender"
    dob "Date of birth"
    age "Age at mid-point of financial year"
    postcode "7 character postcode of residence"
    gpprac "GP practice code"
    lca "Local Council Authority"
    Locality "HSCP Locality"
    Cluster "GP Practice Cluster"
    NSU "Flag to indicate Non-service-users"
    HL1_in_FY "CHI had an active homelessness application during this financial year"
    health_net_cost "Total net cost"
    health_net_costincDNAs "Total net cost including 'did not attend'"
    health_net_costincIncomplete "Total net cost including CH and DN (not DNAs)"
    acute_episodes "Number of acute episodes"
    acute_daycase_episodes "Number of acute day case episodes"
    acute_inpatient_episodes "Number of acute inpatient episodes"
    acute_el_inpatient_episodes "Number of elective inpatient episodes"
    acute_non_el_inpatient_episodes "Number of non-elective inpatient episodes"
    acute_cost "Cost of acute activity"
    acute_daycase_cost "Cost of acute day case activity"
    acute_inpatient_cost "Cost of acute inpatient activity"
    acute_el_inpatient_cost "Cost of acute elective inpatient activity"
    acute_non_el_inpatient_cost "Cost of acute non-elective inpatient activity"
    acute_inpatient_beddays "Number of acute inpatient bed days"
    acute_el_inpatient_beddays "Number of acute elective inpatient bed days"
    acute_non_el_inpatient_beddays "Number of acute non-elective inpatient bed days"
    DD_NonCode9_episodes'Number of Delayed Discharge episodes with a non-Code9 reason for delay'
    DD_Code9_episodes'Number of Delayed Discharge episodes with a Code9 reason for delay'
    DD_NonCode9_beddays'Total number of Delayed Discharge episodes with a non-Code9 reason for delay'
    DD_Code9_beddays'Total number of Delayed Discharge beddays with a Code9 reason for delay'
    mat_episodes "Number of maternity episodes"
    mat_daycase_episodes "Number of maternity day case episodes"
    mat_inpatient_episodes "Number of maternity inpatient episodes"
    mat_cost "Cost of maternity activity"
    mat_daycase_cost "Cost of maternity day case activity"
    mat_inpatient_cost "Cost of maternity inpatient activity"
    mat_inpatient_beddays "Number of maternity inpatient bed days"
    MH_episodes "Number of mental health episodes"
    MH_inpatient_episodes "Number of mental health inpatient episodes"
    MH_el_inpatient_episodes "Number of mental health elective inpatient episodes"
    MH_non_el_inpatient_episodes "Number of mental health non-elective inpatient episodes"
    MH_cost "Cost of mental health activity"
    MH_inpatient_cost "Cost of mental health inpatient activity"
    MH_el_inpatient_cost "Cost of mental health elective inpatient activity"
    MH_non_el_inpatient_cost "Cost of mental health non-elective inpatient activity"
    MH_inpatient_beddays "Number of mental health inpatient bed days"
    MH_el_inpatient_beddays "Number of mental health elective inpatient bed days"
    MH_non_el_inpatient_beddays "Number of mental health non-elective inpatient bed days"
    gls_episodes "Number of geriatric long stay episodes"
    gls_inpatient_episodes "Number of geriatric long stay inpatient episodes"
    gls_el_inpatient_episodes "Number of geriatric long stay elective inpatient episodes"
    gls_non_el_inpatient_episodes "Number of geriatric long stay non-elective inpatient episodes"
    gls_cost "Cost of geriatric long stay activity"
    gls_inpatient_cost "Cost of geriatric long stay inpatient activity"
    gls_el_inpatient_cost "Cost of geriatric long stay elective inpatient activity"
    gls_non_el_inpatient_cost "Cost of geriatric long stay non-elective inpatient activity"
    gls_inpatient_beddays "Number of geriatric long stay inpatient bed days"
    gls_el_inpatient_beddays "Number of geriatric long stay elective inpatient bed days"
    gls_non_el_inpatient_beddays "Number of geriatric long stay non-elective inpatient bed days"
    DD_NonCode9_episodes "Number of Delayed Discharge episodes with a non-Code 9 reason for delay"
    DD_NonCode9_beddays "Number of Delayed Discharge beddays with a non-Code 9 reason for delay"
    DD_Code9_episodes "Number of Delayed Discharge episodes with a Code 9 reason for delay"
    DD_Code9_beddays "Number of Delayed Discharge beddays with a Code 9 reason for delay"
    op_newcons_attendances "Number of new outpatient attendances"
    op_newcons_dnas "Number of new outpatient appointments"
    op_cost_attend "Cost of new outpatient attendances"
    OP_cost_dnas "Cost of new outpatient appointments which were not attended"
    ae_attendances "Number of A&E attendances"
    ae_cost "Cost of A&E attendances"
    pis_dispensed_items "Number of prescribing items dispensed"
    pis_cost "Cost of prescribing items dispensed "
    ooh_cases "Number of GP OoH cases (multiple consultations per case)"
    ooh_homeV "Number of GP OoH Home visit consultations"
    ooh_advice "Number of GP OoH Doctor / Nurse advice consultations"
    ooh_DN "Number of GP OoH District Nurse consultations"
    ooh_NHS24 "Number of GP OoH NHS24 consultations"
    ooh_other "Number of GP OoH Other consultations"
    ooh_PCC "Number of GP OoH Primary Care Centre / Emergency Primary Care Centre consultations"
    ooh_cost "Cost of all GP OoHs"
    ooh_consultation_time "Total time for GP OoH Consultations"
    DN_episodes "Number of District Nursing episodes (consultations more than 7-days apart)"
    DN_contacts "Number of District Nursing contacts"
    DN_cost "Cost of District Nursing"
    CMH_contacts "Number of Community Mental Health contacts"
    CH_cis_episodes "Number of distinct Care Home episodes"
    ch_cost "Cost of Care Home stays"
    ch_beddays "Number of Care Home beddays"
    HC_episodes "Total number of home care episodes, includes personal, non-personal and unknown type"
    HC_personal_episodes "Total number of personal home care episodes"
    HC_non_personal_episodes "Total number of non-personal home care episodes"
    AT_alarms "Total number of alarms packages"
    AT_telecare "Total number of telecare packages"
    SDS_option_1 "Total number of SDS packages (option 1)"
    SDS_option_2 "Total number of SDS packages (option 2)"
    SDS_option_3 "Total number of SDS packages (option 3)"
    SDS_option_4 "A flag to indicate whether the client had an SDS option 4 (a mix) within the year - not a count"
    CIJ_el "Number of Continous Inpatient Journeys (CIJ) which began with an Elective admission"
    CIJ_non_el "Number of Continous Inpatient Journeys (CIJ) which began with a Non-Elective admission"
    CIJ_mat "Number of Continous Inpatient Journeys (CIJ) which began with an Maternity admission"
    HRI_lca "HRIs in LCA excluding District Nursing and Care Home costs"
    HRI_lca_incDN "HRIs in LCA including District Nursing costs"
    HRI_hb "HRIs in HB excluding District Nursing and Care Home costs"
    HRI_scot "HRIs in Scotland excluding District Nursing and Care Home costs"
    HRI_lcaP "Cumulative percent in LCA excluding District Nursing and Care Home costs"
    HRI_lcaP_incDN "Cumulative percent in LCA including District Nursing costs"
    HRI_hbP "Cumulative percent in HB excluding District Nursing and Care Home costs"
    HRI_scotP "Cumulative percent in Scotland excluding District Nursing and Care Home costs"
    Keep_Population "Flag indicating whether this CHI should be kept or discarded when scaling the whole population to be more in line with official population estimates".

* Set Value Labels.
Value Labels Keep_Population
    1 "Keep"
    0 "Discard".

* Do a quick check and set any variables which are empty as sysmiss.
aggregate
    /HHG_Start HHG_End = Max(HHG_Start_FY HHG_End_FY)
    /SPARRA_Start SPARRA_End = MAx(SPARRA_Start_FY  SPARRA_End_FY)
    /DD = Max(DD_NonCode9_episodes)
    /DN = Max(DN_contacts)
    /CMH = Max(CMH_contacts)
    /CH = Max(CH_cis_episodes)
    /HC = Max(hc_episodes)
    /ATA ATT = Max(AT_alarms AT_telecare)
    /SDS1 SDS2 SDS3 = Max(SDS_option_1 SDS_option_2 SDS_option_3).

* If there are no values (i.e. the max is sysmis or 0) then we should set the variable to sysmis to hopefully avoid confusion.
Do repeat Test = HHG_Start HHG_End SPARRA_Start SPARRA_End
    /Var = HHG_Start_FY HHG_End_FY SPARRA_Start_FY  SPARRA_End_FY.
    If Test = 0 Var = $sysmis.
End Repeat.

Do if DD = 0.
    Compute DD_NonCode9_episodes = $sysmis.
    Compute DD_NonCode9_beddays = $sysmis.
    Compute DD_Code9_episodes = $sysmis.
    Compute DD_Code9_beddays = $sysmis.
End if.

Do if DN = 0.
    Compute DN_episodes = $sysmis.
    Compute DN_contacts = $sysmis.
    Compute DN_cost = $sysmis.
End if.

Do if CMH = 0.
    Compute CMH_contacts = $sysmis.
End if.

Do if CH = 0.
    Compute CH_cis_episodes = $sysmis.
    Compute ch_beddays = $sysmis.
    Compute ch_cost = $sysmis.
End if.

Do if HC = 0.
    Compute HC_episodes = $sysmis.
    Compute HC_personal_episodes = $sysmis.
    Compute HC_non_personal_episodes = $sysmis.
End if.

Do if ATA = 0 and ATT = 0.
    Compute AT_alarms = $sysmis.
    Compute AT_telecare = $sysmis.
End if.

Do if SDS1 = 0 and SDS2 = 0 and SDS3 = 0.
    Compute SDS_option_1 = $sysmis.
    Compute SDS_option_2 = $sysmis.
    Compute SDS_option_3 = $sysmis.
    Compute SDS_option_4 = $sysmis.
End if.

 * Final sort.
sort cases by chi.

save outfile = !Year_dir + "source-individual-file-20" + !FY + ".zsav"
    /Keep
    year
    chi
    gender
    dob
    age
    postcode
    gpprac
    health_net_cost
    health_net_costincdnas
    health_net_costincincomplete
    nsu
    hl1_in_fy
    deceased
    death_date
    acute_episodes
    acute_daycase_episodes
    acute_inpatient_episodes
    acute_el_inpatient_episodes
    acute_non_el_inpatient_episodes
    acute_cost
    acute_daycase_cost
    acute_inpatient_cost
    acute_el_inpatient_cost
    acute_non_el_inpatient_cost
    acute_inpatient_beddays
    acute_el_inpatient_beddays
    acute_non_el_inpatient_beddays
    mat_episodes
    mat_daycase_episodes
    mat_inpatient_episodes
    mat_cost
    mat_daycase_cost
    mat_inpatient_cost
    mat_inpatient_beddays
    mh_episodes
    mh_inpatient_episodes
    mh_el_inpatient_episodes
    mh_non_el_inpatient_episodes
    mh_cost
    mh_inpatient_cost
    mh_el_inpatient_cost
    mh_non_el_inpatient_cost
    mh_inpatient_beddays
    mh_el_inpatient_beddays
    mh_non_el_inpatient_beddays
    gls_episodes
    gls_inpatient_episodes
    gls_el_inpatient_episodes
    gls_non_el_inpatient_episodes
    gls_cost
    gls_inpatient_cost
    gls_el_inpatient_cost
    gls_non_el_inpatient_cost
    gls_inpatient_beddays
    gls_el_inpatient_beddays
    gls_non_el_inpatient_beddays
    dd_noncode9_episodes
    dd_noncode9_beddays
    dd_code9_episodes
    dd_code9_beddays
    op_newcons_attendances
    op_newcons_dnas
    op_cost_attend
    op_cost_dnas
    ae_attendances
    ae_cost
    pis_dispensed_items
    pis_cost
    ooh_cases
    ooh_homev
    ooh_advice
    ooh_dn
    ooh_nhs24
    ooh_other
    ooh_pcc
    ooh_consultation_time
    ooh_cost
    dn_episodes
    dn_contacts
    dn_cost
    cmh_contacts
    CH_cis_episodes
    ch_beddays
    ch_cost
    hc_episodes
    hc_personal_episodes
    hc_non_personal_episodes
    at_alarms
    at_telecare
    sds_option_1
    sds_option_2
    sds_option_3
    sds_option_4
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    cij_el
    cij_non_el
    cij_mat
    arth
    asthma
    atrialfib
    cancer
    cvd
    liver
    copd
    dementia
    diabetes
    epilepsy
    chd
    hefailure
    ms
    parkinsons
    refailure
    congen
    bloodbfo
    endomet
    digestive
    arth_date
    asthma_date
    atrialfib_date
    cancer_date
    cvd_date
    liver_date
    copd_date
    dementia_date
    diabetes_date
    epilepsy_date
    chd_date
    hefailure_date
    ms_date
    parkinsons_date
    refailure_date
    congen_date
    bloodbfo_date
    endomet_date
    digestive_date
    hbrescode
    hscp2018
    lca
    ca2018
    locality
    datazone2011
    hbpraccode
    cluster
    simd2020v2_rank
    simd2020v2_sc_decile
    simd2020v2_sc_quintile
    simd2020v2_hb2019_decile
    simd2020v2_hb2019_quintile
    simd2020v2_hscp2019_decile
    simd2020v2_hscp2019_quintile
    ur8_2016
    ur6_2016
    ur3_2016
    ur2_2016
    hb2019
    hscp2019
    ca2019
    hri_lca
    hri_lca_incdn
    hri_hb
    hri_scot
    hri_lcap
    hri_lcap_incdn
    hri_hbp
    hri_scotp
    sparra_start_fy
    sparra_end_fy
    hhg_start_fy
    hhg_end_fy
    demographic_cohort
    service_use_cohort
    keep_population
    /zcompressed.

get file = !Year_dir + "source-individual-file-20" + !FY + ".zsav".

*************************************************************************************************************************************************.
*Housekeeping. 
erase file = !Year_dir + 'HRI_lookup_' + !FY + '.zsav'.
erase file = !Year_dir + "Population-estimates-20" + !FY + ".zsav".
erase file = !Year_dir + "NSU-Keep-Lookup-20" + !FY + ".zsav".
