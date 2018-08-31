* LTC files.
define !LTCfiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.


get file  = !LTCFiles + 'cvd1314_hosp.sav'.

delete variables year_1011 year_1112 year_1213 year_1415.
rename variables (upi year_1314 = chi cvd).
execute.
match files file = *
 /file= !LTCFiles + 'copd1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = copd).
execute.
match files file = *
 /file = !LTCFiles + 'dementia1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = dementia).
execute.
match files file = *
 /table = !LTCFiles + 'diabetes1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = diabetes).
execute.
match files file = *
 /table = !LTCFiles + 'chd1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = chd).
execute.
match files file = *
 /table = !LTCFiles + 'hefailure1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = hefailure).
execute.
match files file = *
 /table = !LTCFiles + 'refailure1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = refailure).
execute.
match files files = *
 /table = !LTCFiles + 'epilepsy1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = epilepsy).
execute.
match files files = *
 /table = !LTCFiles + 'asthma1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = asthma).
execute.
match files files = *
 /table = !LTCFiles + 'atrialfib1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = atrialfib).
execute.
match files files = *
 /table = !LTCFiles + 'alzheimers1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = alzheimers).
execute.
match files files = *
 /table = !LTCFiles + 'cancer1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = cancer).
execute.
match files files = *
 /table = !LTCFiles + 'arth1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = arth).
execute.
match files files = *
 /table = !LTCFiles + 'parkinsons1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = parkinsons).
execute.
match files files = *
 /table = !LTCFiles + 'liver1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = liver).
execute.
match files files = *
 /table = !LTCFiles + 'ms1314_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1213 year_1415
 /by chi.
execute.
rename variables (year_1314 = ms).
execute.

recode cvd copd dementia diabetes chd hefailure refailure 
       epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms (sysmis=0).
execute.


save outfile = !LTCFiles + 'allltcs_1314.sav'
/keep chi cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms
date_adm_cvd date_adm_copd date_adm_dementia date_adm_diabetes date_adm_chd date_adm_hefailure date_adm_refailure date_adm_epilepsy
date_adm_asthma date_adm_atrialfib date_adm_alzheimers date_adm_cancer date_adm_arth date_adm_parkinsons date_adm_liver date_adm_ms.
get file = !LTCFiles + 'allltcs_1314.sav'.



