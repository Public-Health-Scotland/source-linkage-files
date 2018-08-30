* Program to 'sort' the GP Practice on prescribing data for all the master and CHI master PLICS 
* analysis files.

* Program by Denise Hastie, August/September 2016.

define !CostedFiles()
'/conf/irf/10-PLICS-analysis-files/'
!enddefine.

* temp storage.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine.


******* Master PLICS analysis files *******.
* Check that the cost variable and is cost cost_total_net.
* 2010/11.
get file = !CostedFiles + 'masterPLICS_Costed_201011.sav'.
select if (recid ne 'PIS').
frequency variables = recid.
add files file = *
 /file = !file + 'prescribing_file_for_plics-201011.sav'.
execute.
sort cases by chi record_keydate1 record_keydate2.
save outfile = !CostedFiles + 'masterPLICS_Costed_201011.sav'.

* 2011/12.
get file = !file + 'masterPLICS_Costed_201112.sav'.
select if (recid ne 'PIS').
frequency variables = recid.
add files file = *
 /file = !file + 'prescribing_file_for_plics-201112.sav'.
execute.
sort cases by chi record_keydate1 record_keydate2.
save outfile = !CostedFiles + 'masterPLICS_Costed_201112.sav'.

* 2012/13.
get file = !CostedFiles + 'masterPLICS_Costed_201213.sav'.
select if (recid ne 'PIS').
frequency variables = recid.
add files file = *
 /file = !file + 'prescribing_file_for_plics-201213.sav'.
execute.
sort cases by chi record_keydate1 record_keydate2.
save outfile = !CostedFiles + 'masterPLICS_Costed_201213.sav'.

* 2013/14.
get file = !CostedFiles + 'masterPLICS_Costed_201314.sav'.
select if (recid ne 'PIS').
frequency variables = recid.
add files file = *
 /file = !file + 'prescribing_file_for_plics-201314.sav'.
execute.
sort cases by chi record_keydate1 record_keydate2.
save outfile = !CostedFiles + 'masterPLICS_Costed_201314.sav'.

* 2014/15.
get file = !CostedFiles + 'masterPLICS_Costed_201415.sav'.
select if (recid ne 'PIS').
frequency variables = recid.
add files file = *
 /file = !file + 'prescribing_file_for_plics-201415.sav'.
execute.
sort cases by chi record_keydate1 record_keydate2.
save outfile = !CostedFiles + 'masterPLICS_Costed_201415.sav'.


******* CHI Master PLICS analysis files *******.
* Double check the variables names. * Method should be totally fine.

* Will need to remove any deceased flag columns and add in the new ones (based on extract received from IT
* for the 2014/15 update.

* Work through this update.  if all successful then copy and amend the SPSS syntax for the other 4 years worth of data. 


*2010/11.
get file = !CostedFiles + 'CHImasterPLICS_Costed_201011.sav'.
delete variables no_dispensed_items pis_cost.
sort cases by chi.
match files file = *
 /table = !file + 'prescribing_file_for_plics_201011.sav'
 /rename (any variables as required)
 /by chi.
execute.


* Create a total health cost.
compute health_net_cost = acute_cost + mat_cost + mentalh_cost + gls_cost + op_cost_attend + ae_cost + pis_cost.
compute health_net_costincDNAs = acute_cost + mat_cost + mentalh_cost + gls_cost + op_cost_dnas + ae_cost + pis_cost.
compute health_net_cost2 = acute_cost + mat_cost + mentalh_cost + gls_cost + op_cost_attend + ae_cost + pis_cost.
execute.
if (health_net_cost eq health_net_cost2) cost_check = 1.
if sysmis(cost_check) cost_check = 0.
frequency variables = cost_check.

* GP Practice hierarchy.
* Prescriber GP Practice now added to this heirarchy as first in the list.  DH, August 2016.
string gpprac (a5).
if (gpprac eq '' and pis_prac ne '') gpprac = pis_prac.
if (gpprac eq '' and ae_prac ne '') gpprac = ae_prac.
if (gpprac eq '' and op_prac ne '') gpprac = op_prac.
if (gpprac eq '' and acute_prac ne '') gpprac = acute_prac.
if (gpprac eq '' and mat_prac ne '') gpprac = mat_prac.
if (gpprac eq '' and mentalh_prac ne '') gpprac = mentalh_prac.
if (gpprac eq '' and gls_prac ne '') gpprac = gls_prac.
execute.

*************************************************************************************************************************************************.
* Add on a death marker and the date of death (where applicable).
* Note that date of death has been extracted by UPI for calendar year 2010 onwards.
sort cases by chi.

match files file = *
 /table = !Deathsfile + 'Deceased_patient_reference_file-modified.sav'
 /by chi.
execute.

if sysmis(deceased) deceased = 0.
execute.

rename variables (deceased = deceased_flag).

*************************************************************************************************************************************************.
* Add in LTC markers. 
*************************************************************************************************************************************************.
*sort cases by chi.

* Match on the LTC flags and the date of LTC incidence (note this is based on hospital incidence only). 

match files file = *
 /table = !LTCfile + 'LTCs_patient_reference_file.sav'
 /by chi.
execute.

* recode included - but this is really only applicable to records without a CHI number. 
recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
       hefailure ms parkinsons refailure congen bloodbfo endomet digestive (sysmis = 0).
execute.

* rename this variable to be consistent with out years files. 
rename variables (derived_datedeath = date_death).

* check what variables are not required in the save command - perhaps double check geographies with Andrew.  I would 
* propose leaving the current geographies as they are.  
save outfile = !file + 'CHImasterPLICS_Costed_201011.sav' 
 /keep year CHI gender dob health_postcode gpprac
       health_net_cost health_net_costincDNAs
       acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
       acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost
       acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays
       mat_episodes mat_daycase_episodes mat_inpatient_episodes 
       mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays 
       mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
       mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost
       mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays
       gls_episodes gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes gls_non_el_inpatient_episodes
       gls_cost gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost
       gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays
       op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas
       ae_attendances ae_cost pis_dispensed_items pis_cost
       deceased_flag date_death
       arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
       hefailure ms parkinsons refailure congen bloodbfo endomet digestive
       arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date 
       diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date 
       congen_date bloodbfo_date endomet_date digestive_date
       hbres lca datazone chp
       simd2012score scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile 
       simd2012_ca_quintile simd2012_ca_decile simd2012_hscp_quintile simd2012_hscp_decile
       simd2012_chp2012_quintile simd2012_chp2012_decile SplitChar Split_Indicator
       DataZone2001 CHP2011 CHP2011subarea
 /compressed.

get file = !file + 'CHImasterPLICS_Costed_201011.sav'.
save outfile = !CostedFiles + 'CHImasterPLICS_Costed_201011.sav'.
get file = !CostedFiles + 'CHImasterPLICS_Costed_201011.sav'.



