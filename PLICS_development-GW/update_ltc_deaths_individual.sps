*Update masterPLICS files with:
*1. LTC flags and dates.
*2. Death flags and dates.
*3. variable labels.
*4. SIMD2016.
*5. keydate in date format.

*Created by GNW on 3/11/16.

*Run for all masterPLICS up to 1415, i.e. 1011, 1112, 1213, 1314.

*Save output to temporary space (cl-out) and then move back to irf folder.

****************************setup************************.
*Define FY.  
define !FY()
'1617'
!enddefine.

*CD to output directory.
CD '/conf/hscdiip/DH-Extract/201617/'.

*LTC flags files - 'home'.
define !LTCFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

*Death flag files - 'home'.
define !DeathsFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/data-extracts/02-NRS-deaths/'
!enddefine.

*****************************************************start here**********************************************.
*get input file .
get file='source-individual-file-20'+!FY+'.sav'.

*1. remove existing LTC flags.
delete variables arth to digestive_date.
EXECUTE.

*match on the new ltc flags and dates.
match files file = *
 /table = !LTCFile + 'LTCs_patient_reference_file.sav'
 /by chi.
execute.

* recode sysmis as zeros. 
recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
       hefailure ms parkinsons refailure congen bloodbfo endomet digestive (sysmis = 0).
execute.

*Match on deceased flags and date - this file made with program 19a (which was modified to include program 19b). 
*2. remove death dates.
delete variables deceased_flag date_death.
EXECUTE.

match files file = *
 /table = !Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.

*recode sysmis as zeros.
if sysmis(deceased) deceased = 0.
execute.

rename variables deceased=deceased_flag derived_datedeath=date_death.

*add variable labels.
variable labels 
cvd 'CVD LTC marker'
copd 'COPD LTC marker'
dementia 'Dementia LTC marker'
diabetes 'Diabetes LTC marker'
chd 'CHD LTC marker'
hefailure 'Heart Failure LTC marker'
refailure 'Renal Failure LTC marker'
epilepsy 'Epilepsy LTC marker'
asthma 'Asthma LTC marker'
atrialfib 'Atrial Fibrilliation LTC marker'
cancer 'Cancer LTC marker'
arth 'Arthritis Artherosis LTC marker' 
parkinsons 'Parkinsons LTC marker'
liver 'Chronic Liver Disease LTC marker' 
ms 'Multiple Sclerosis LTC marker'
congen 'Congenital Problems LTC marker'
bloodbfo 'Diseases of Blood and Blood Forming Organs LTC marker'
endomet 'Other Endocrine Metabolic Diseases LTC marker'
digestive 'Other Diseases of Digestive System LTC marker' 
arth_date 'Arthritis Artherosis LTC incidence date'
asthma_date 'Asthma LTC incidence date'
atrialfib_date 'Atrial Fibrilliation LTC incidence date'
cancer_date 'Cancer LTC incidence date'
cvd_date 'CVD LTC incidence date'
liver_date 'Chronic Liver Disease LTC incidence date'
copd_date 'COPD LTC incidence date'
dementia_date 'Dementia LTC incidence date'
diabetes_date 'Diabetes LTC incidence date'
epilepsy_date 'Epilepsy LTC incidence date'
chd_date 'CHD LTC incidence date'
hefailure_date 'Heart failure LTC incidence date'
ms_date 'Multiple Sclerosis LTC incidence date'
parkinsons_date 'Parkinsons LTC incidence date'
refailure_date 'Renal failure LTC incidence date'
congen_date 'Congenital Problems LTC incidence date'
bloodbfo_date 'Diseases of Blood and Blood Forming Organs LTC incidence date'
endomet_date 'Other Endocrine Metabolic Diseases LTC incidence date'
digestive_date 'Other Diseases of Digestive System LTC incidence date'
deceased_flag 'Deceased flag'
date_death 'Derived Date of Death'.

***********************************************************Add SIMD2016***********************************************************.
*sort on postcode.
 * rename variables pc7 = health_postcode.
 * sort cases by health_postcode.

*match to the simd file.
 * match files file=*
   /table '/conf/linkage/output/gemma/CHImaster_w_HRI_SIMD16/postcode_simd2016.sav'
   /by health_postcode.
 * EXECUTE.

 * rename variables health_postcode = pc7.

*resort cases by CHI and keydates.
 * sort cases by CHI record_keydate1 record_keydate2.
*************************************************************************************************************************************.

********************************************************EXTRA CODE TO ADD DATES*****************************.
*Add extra variables for dates. 
 * compute keydate1_dateformat=record_keydate1.
 * compute keydate2_dateformat=record_keydate2.
 * EXECUTE.
*rearrange variables for dates are together at the beginning of the dataset.
 * add files file=*
   /keep year to record_keydate2 keydate1_dateformat keydate2_dateformat ALL.
 * EXECUTE.

*convert variables to strings.
 * alter type keydate1_dateformat keydate2_dateformat (a8).
*compile date convert program.
 * insert file='/conf/irf/11-Development team/Dev00-PLICS-files/2015-16/convert_date.sps'.
*run date convert program.
 * convert_date indates = keydate1_dateformat keydate2_dateformat.

*******RE-ORDER VARIABLES****.
add files file=*
   /keep year to age deceased_flag date_death health_postcode to pis_cost arth to digestive_date ALL.
EXECUTE.

*save file.
save outfile='source-individual-file-20'+ !FY + '.sav'
/compressed.

get file='source-individual-file-20'+ !FY + '.sav'.



















