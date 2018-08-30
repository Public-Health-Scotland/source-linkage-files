* Output file location.
define !CostedFiles()
'/conf/hscdiip/01-Source-linkage-files/'
!enddefine.

* Network area whilst preparing file.
define !file()
'/conf/sourcedev/'
!enddefine.

* define path to LTC file'.
define !LTCFile()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

* Death flag files - 'home'.
define !DeathsFile()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

*define FY.
define !FY()
'1617'
!enddefine.

get file = !CostedFiles + 'source-individual-file-20' + !FY + '.sav'.

delete variables deceased_flag date_death arth asthma atrialfib cancer cvd liver copd dementia diabetes 
                 epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive 
                 arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date
                 diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date 
                 congen_date bloodbfo_date endomet_date digestive_date. 

sort cases by chi.

match files file = *
 /table = !Deathsfile + 'Deceased_patient_reference_file.sav'
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


frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes 
            epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive 
            arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date
            diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date 
            congen_date bloodbfo_date endomet_date digestive_date. 

* as there are dates that are beyond the end of the time period in this episode file, the values for the
* LTC markers must be made 0 and the dates removed.  
if (arth_date gt '20170331') arth eq 0.
if (asthma_date gt '20170331') asthma eq 0.
if (atrialfib_date gt '20170331') atrialfib eq 0.
if (cancer_date gt '20170331') cancer eq 0.
if (cvd_date gt '20170331') cvd eq 0.
if (liver_date gt '20170331') liver eq 0.
if (copd_date gt '20170331') copd eq 0.
if (dementia_date gt '20170331') dementia eq 0.
if (diabetes_date gt '20170331') diabetes eq 0.
if (epilepsy_date gt '20170331') epilepsy eq 0.
if (chd_date gt '20170331') chd eq 0.
if (hefailure_date gt '20170331') hefailure eq 0.
if (ms_date gt '20170331') ms eq 0.
if (parkinsons_date gt '20170331') parkinsons eq 0.
if (refailure_date gt '20170331') refailure eq 0.
if (congen_date gt '20170331') congen eq 0.
if (bloodbfo_date gt '20170331') bloodbfo eq 0.
if (endomet_date gt '20170331') endomet eq 0.
if (digestive_date gt '20170331') digestive eq 0.
execute.

if (arth_date gt '20170331') arth_date eq ''.
if (asthma_date gt '20170331') asthma_date eq ''.
if (atrialfib_date gt '20170331') atrialfib_date eq ''.
if (cancer_date gt '20170331') cancer_date eq ''.
if (cvd_date gt '20170331') cvd_date eq ''.
if (liver_date gt '20170331') liver_date eq ''.
if (copd_date gt '20170331') copd_date eq ''.
if (dementia_date gt '20170331') dementia_date eq ''.
if (diabetes_date gt '20170331') diabetes_date eq ''.
if (epilepsy_date gt '20170331') epilepsy_date eq ''.
if (chd_date gt '20170331') chd_date eq ''.
if (hefailure_date gt '20170331') hefailure_date eq ''.
if (ms_date gt '20170331') ms_date eq ''.
if (parkinsons_date gt '20170331') parkinsons_date eq ''.
if (refailure_date gt '20170331') refailure_date eq ''.
if (congen_date gt '20170331') congen_date eq ''.
if (bloodbfo_date gt '20170331') bloodbfo_date eq ''.
if (endomet_date gt '20170331') endomet_date eq ''.
if (digestive_date gt '20170331') digestive_date eq ''.
execute.



frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes 
            epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive 
            arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date
            diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date 
            congen_date bloodbfo_date endomet_date digestive_date. 

rename variables (derived_datedeath = date_death).

save outfile = '/conf/irf/source-individual-file-20' + !FY + '.sav'
 /keep year chi gender dob age deceased_flag date_death pc7 gpprac health_net_cost health_net_costincDNAs
       acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes
       acute_non_el_inpatient_episodes acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost
       acute_non_el_inpatient_cost acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays
       mat_episodes mat_daycase_episodes mat_inpatient_episodes mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays
       mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
       mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost
       mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays 
       gls_episodes gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes gls_non_el_inpatient_episodes
       gls_cost gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost gls_inpatient_beddays
       gls_el_inpatient_beddays gls_non_el_inpatient_beddays 
       op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas ae_attendances ae_cost pis_dispensed_items pis_cost
       arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen
       bloodbfo endomet digestive arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date
       diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date
       endomet_date digestive_date 
       hbres lca chp DataZone2001 DataZone2011 CHP2011 CHP2011subarea simd2012score simd2012rank simd2012_sc_quintile simd2012_sc_decile
       simd2012_ca_quintile simd2012_ca_decile simd2012_hscp_quintile simd2012_hscp_decile simd2012_chp2012_quintile simd2012_chp2012_decile
       hbsimd2012quintile hbsimd2012decile HRI_lca HRI_hb HRI_scot HRI_lcaP HRI_hbP HRI_scotP simd2016rank simd2016_sc_decile simd2016_sc_quintile
       simd2016_HB2014_decile simd2016_HB2014_quintile simd2016_HSCP2016_decile  simd2016_HSCP2016_quintile simd2016_CA2011_decile
       simd2016_CA2011_quintile UR8_2013_2014 UR6_2013_2014 UR3_2013_2014 UR2_2013_2014 Cluster Locality DatazoneYear Demographic_Cohort
       Service_Use_Cohort
 /compressed.
