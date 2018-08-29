get file = !file + "temp-source-individual-file-2-20" + !FY + ".zsav".

* Create a year variable, similar to the master PLICs file - in case analysts require to add together the CHI master PLICS files.
string year (a4).
compute year = !FY.

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

 * Tidy up variable types.
alter type
   acute_episodes to acute_non_el_inpatient_episodes acute_inpatient_beddays to acute_non_el_inpatient_beddays
   mat_episodes to mat_inpatient_episodes mat_inpatient_beddays
   mentalh_episodes to mentalh_non_el_inpatient_episodes mentalh_inpatient_beddays to mentalh_non_el_inpatient_beddays
   gls_episodes to gls_daycase_episodes gls_non_el_inpatient_episodes gls_inpatient_beddays to gls_non_el_inpatient_beddays
   op_newcons_attendances op_newcons_dnas
   ae_attendances
   pis_dispensed_items
   ch_episodes ch_beddays
   ooh_cases to ooh_PCC
   DN_episodes DN_contacts (F8.0).

 * Add variable labels.
Variable Labels
   year "Financial Year"
   gender "Gender"
   dob "Date of birth"
   gpprac "GP practice code"
   lca "Local Council Authority"
   health_net_cost "Total net cost"
   health_net_costincDNAs "Total net cost including "did not attend""
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
   mat_episodes "Number of  maternity episodes"
   mat_daycase_episodes "Number of maternity day case episodes"
   mat_inpatient_episodes "Number of maternity inpatient episodes"
   mat_cost "Cost of maternity activity"
   mat_daycase_cost "Cost of maternity day case activity"
   mat_inpatient_cost "Cost of maternity inpatient activity"
   mat_inpatient_beddays "Number of maternity inpatient bed days"
   mentalh_episodes "Number of mental health episodes"
   mentalh_daycase_episodes "Number of mental health day case episodes"
   mentalh_inpatient_episodes "Number of mental health inpatient episodes"
   mentalh_el_inpatient_episodes "Number of mental health elective inpatient episodes"
   mentalh_non_el_inpatient_episodes "Number of mental health non-elective inpatient episodes"
   mentalh_cost "Cost of mental health activity"
   mentalh_daycase_cost "Cost of mental health day case activity"
   mentalh_inpatient_cost "Cost of mental health inpatient activity"
   mentalh_el_inpatient_cost "Cost of mental health elective inpatient activity"
   mentalh_non_el_inpatient_cost "Cost of mental health non-elective inpatient activity"
   mentalh_inpatient_beddays "Number of mental health inpatient bed days"
   mentalh_el_inpatient_beddays "Number of mental health elective inpatient bed days"
   mentalh_non_el_inpatient_beddays "Number of mental health non-elective inpatient bed days"
   gls_episodes "Number of geriatric long stay episodes"
   gls_daycase_episodes "Number of geriatric long stay day case episodes"
   gls_inpatient_episodes "Number of geriatric long stay inpatient episodes"
   gls_el_inpatient_episodes "Number of geriatric long stay elective inpatient episodes"
   gls_non_el_inpatient_episodes "Number of geriatric long stay non-elective inpatient episodes"
   gls_cost "Cost of geriatric long stay activity"
   gls_daycase_cost "Cost of geriatric long stay day case activity"
   gls_inpatient_cost "Cost of geriatric long stay inpatient activity"
   gls_el_inpatient_cost "Cost of geriatric long stay elective inpatient activity"
   gls_non_el_inpatient_cost "Cost of geriatric long stay non-elective inpatient activity"
   gls_inpatient_beddays "Number of geriatric long stay inpatient bed days"
   gls_el_inpatient_beddays "Number of geriatric long stay elective inpatient bed days"
   gls_non_el_inpatient_beddays "Number of geriatric long stay non-elective inpatient bed days"
   op_newcons_attendances "Number of new outpatient attendances"
   op_newcons_dnas "Number of new outpatient appointments"
   op_cost_attend "Cost of new outpatient attendances"
   op_cost_dnas "Cost of new outpatient appointments"
   ae_attendances "Number of A&E attendances"
   ae_cost "Cost of A&E attendances"
   pis_dispensed_items "Number of prescribing items dispensed"
   pis_cost "Cost of prescribing items dispensed "
   ch_episodes	"Number of distinct Care Home episodes"
   ch_cost	"Cost of Care Home stays"
   ch_beddays	"Number of Care Home beddays"
   ooh_cases	"Number of GP OoH cases (multiple consultations per case)"
   ooh_homeV	"Number of GP OoH Home visit consultations"
   ooh_advice	"Number of GP OoH Doctor / Nurse advice consultations"
   ooh_DN	"Number of GP OoH District Nurse consultations"
   ooh_NHS24	"Number of GP OoH NHS24 consultations"
   ooh_other	"Number of GP OoH Other consultations"
   ooh_PCC	"Number of GP OoH Primary Care Centre / Emergency Primary Care Centre consultations"
   ooh_cost	"Cost of all GP OoHs"
   ooh_consultation_time	"Total time for GP OoH Consultations"
   DN_episodes	"Number of District Nursing episodes (consultations more than 7-days apart)"
   DN_contacts	"Number of District Nursing contact"
   DN_cost	"Cost of District Nursing"
   DN_total_duration	"Total Duration of all District Nursing contacts"
   HRI_lca "HRIs in LCA excluding District Nursing and Care Home costs"
   HRI_lca_all	"HRIs in LCA including all costs"
   HRI_hb "HRIs in HB excluding District Nursing and Care Home costs"
   HRI_scot "HRIs in Scotland excluding District Nursing and Care Home costs"
   HRI_lcaP "Cumulative percent in LCA excluding District Nursing and Care Home costs"
   HRI_lcaP_all	"Cumulative percent in LCA including all costs"
   HRI_hbP "Cumulative percent in HB excluding District Nursing and Care Home costs"
   HRI_scotP "Cumulative percent in Scotland excluding District Nursing and Care Home costs".

sort cases by chi.
save outfile = !file + "source-individual-file-20" + !FY + ".zsav"
   /Keep
      year
      chi
      gender
      dob
      age
      health_postcode
      gpprac
      health_net_cost
      health_net_costincDNAs
      health_net_costincIncomplete
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
      mentalh_episodes
      mentalh_daycase_episodes
      mentalh_inpatient_episodes
      mentalh_el_inpatient_episodes
      mentalh_non_el_inpatient_episodes
      mentalh_cost
      mentalh_daycase_cost
      mentalh_inpatient_cost
      mentalh_el_inpatient_cost
      mentalh_non_el_inpatient_cost
      mentalh_inpatient_beddays
      mentalh_el_inpatient_beddays
      mentalh_non_el_inpatient_beddays
      gls_episodes
      gls_daycase_episodes
      gls_inpatient_episodes
      gls_el_inpatient_episodes
      gls_non_el_inpatient_episodes
      gls_cost
      gls_daycase_cost
      gls_inpatient_cost
      gls_el_inpatient_cost
      gls_non_el_inpatient_cost
      gls_inpatient_beddays
      gls_el_inpatient_beddays
      gls_non_el_inpatient_beddays
      op_newcons_attendances
      op_newcons_dnas
      op_cost_attend
      op_cost_dnas
      ae_attendances
      ae_cost
      pis_dispensed_items
      pis_cost
      ch_episodes
      ch_beddays
      ch_cost
      ooh_cases
      ooh_homeV
      ooh_advice
      ooh_DN
      ooh_NHS24
      ooh_other
      ooh_PCC
      ooh_consultation_time
      ooh_cost
      DN_episodes
      DN_contacts
      DN_total_duration
      DN_cost
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
      lca
      hbres
      chp
      Datazone2001
      Datazone2011
      CHP2011
      CHP2011subarea
      Cluster
      Locality
      HB
      simd2012score
      simd2012rank
      simd2012_sc_quintile
      simd2012_sc_decile
      simd2012_ca_quintile
      simd2012_ca_decile
      simd2012_hscp_quintile
      simd2012_hscp_decile
      simd2012_chp2012_quintile
      simd2012_chp2012_decile
      hbsimd2012quintile
      hbsimd2012decile
      simd2016rank
      simd2016_sc_decile
      simd2016_sc_quintile
      simd2016_HB2014_decile
      simd2016_HB2014_quintile
      simd2016_HSCP2016_decile
      simd2016_HSCP2016_quintile
      simd2016_CA2011_decile
      simd2016_CA2011_quintile
      UR8_2016
      UR6_2016
      UR3_2016
      UR2_2016
      HRI_lca
      HRI_lca_all
      HRI_hb
      HRI_scot
      HRI_lcaP
      HRI_lcaP_all
      HRI_hbP
      HRI_scotP
      SPARRA_RISK_SCORE
      Demographic_Cohort
      Service_Use_Cohort
   /zcompressed.

get file = !file + "source-individual-file-20" + !FY + ".zsav".

*************************************************************************************************************************************************.
* Erase temporary file created throughout the program.
erase file = !file + "temp-source-individual-file-1-20" + !FY + ".zsav".
