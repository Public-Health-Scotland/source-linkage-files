define !mplics()
'/conf/irf/10-PLICS-analysis-files/'
!enddefine.

define !temp()
'/conf/hscdiip/'
!enddefine.

* LTC flags files - 'home'.
define !LTCFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

* Death flag files - 'home'.
define !DeathsFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/data-extracts/02-NRS-deaths/'
!enddefine.

get file = !mplics + 'CHImasterPLICS_Costed_201314.sav'.

sort cases by chi.

delete variables cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver.

match files file = *
 /table = !LTCfile + 'LTCs_patient_reference_file.sav'
 /by chi.
execute.

* recode included - but this is really only applicable to records without a CHI number. 
recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
       hefailure ms parkinsons refailure congen bloodbfo endomet digestive (sysmis = 0).
execute.

match files file = *
 /table = !Deathsfile + 'Deceased_patient_reference_file-modified.sav'
 /by chi.
execute.

if sysmis(deceased) deceased = 0.
execute.

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
deceased 'Deceased flag'
derived_datedeath 'Derived Date of Death'.

save outfile = !temp + 'CHImasterPLICS_Costed_201314.sav'.