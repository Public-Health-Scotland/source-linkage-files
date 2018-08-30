* Program to check the spilt between elective/non-elective and maternity
* for the newpattype_cis variable.  Note that this variable retain its old
* name but it based on the new CIJ definitions.

* Denise Hastie, September 2016.

* File location definitions.
define !CostedFiles()
'/conf/irf/10-PLICS-analysis-files/'
!enddefine.

* temp storage.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine.

* Get the 14/15 master PLICS file. 
get file !CostedFiles + 'masterPLICS_Costed_201415.sav'.

* Keep on Acute (inc. GLS records), Mental Health and Maternity records. 
* Note that Maternity records do not have the elective/non-elective (planned/unplanned split).

select if any(recid,'01B','02B','04B','50B').
execute.

delete variables arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd
                 hefailure ms parkinsons refailure congen bloodbfo endomet digestive
                 arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date
                 dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date
                 parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date
                 alcohol_adm submis_adm falls_adm selfharm_adm
                 april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays 
                 oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
                 april_cost may_cost june_cost july_cost august_cost sept_cost 
                 oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
                 simd2012score scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile
                 simd2012_ca_quintile simd2012_ca_decile simd2012_hscp_quintile simd2012_hscp_decile
                 simd2012_chp2012_quintile simd2012_chp2012_decile SplitChar Split_Indicator DataZone2001
                 CHP2011 CHP2011subarea
                 death_location_code death_board_occurrence place_death_occurred post_mortem deathdiag1
                 deathdiag2 deathdiag3 deathdiag4 deathdiag5 deathdiag6 deathdiag7 deathdiag8 deathdiag9
                 deathdiag10 deathdiag11 deceased derived_datedeath
                 reftype refsource attendance_status clinic_type ae_arrivaltime ae_arrivalmode ae_refsource
                 ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait ae_bodyloc ae_alcohol no_dispensed_items
                 diag1 diag2 diag3 diag4 diag5 diag6 op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4
                 discondition stadm adcon1 adcon2 adcon3 adcon4
                 Cost_Total_Net_incDNAs nhshosp commhosp.

crosstabs /tables=SMRType BY newpattype_cis
          /format=avalue tables /cells=count /count round cell.

save outfile = !file + 'el-non-el-checking.sav'.

*.
get file = !file + 'el-non-el-checking.sav'.

select if (SMRType eq 'Matern-DC').
execute.

save outfile = !file + 'matern-dc.sav'.
get file = !file + 'matern-dc.sav'.

select if (newpattype_cis ne 'Maternity').
execute.

*.
get file = !file + 'el-non-el-checking.sav'.

select if (SMRType eq 'Acute-DC').
execute.

save outfile = !file + 'acute-dc.sav'.
get file = !file + 'acute-dc.sav'.

compute flag = 0.
if (newpattype_cis eq '') flag = 1.
frequencies flag.

select if (flag eq 1).
frequencies chi.



