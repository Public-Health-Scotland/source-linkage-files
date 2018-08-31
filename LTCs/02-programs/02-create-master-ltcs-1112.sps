* LTC files.
define !LTCfiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.


get file  = !LTCFiles + 'cvd1112_hosp.sav'.

delete variables year_1213 year_1011 year_1314 year_1415.
rename variables (upi year_1112 = chi cvd).
execute.
match files file = *
 /file= !LTCFiles + 'copd1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = copd).
execute.
match files file = *
 /file = !LTCFiles + 'dementia1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = dementia).
execute.
match files file = *
 /table = !LTCFiles + 'diabetes1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = diabetes).
execute.
match files file = *
 /table = !LTCFiles + 'chd1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = chd).
execute.
match files file = *
 /table = !LTCFiles + 'hefailure1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = hefailure).
execute.
match files file = *
 /table = !LTCFiles + 'refailure1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = refailure).
execute.
match files files = *
 /table = !LTCFiles + 'epilepsy1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = epilepsy).
execute.
match files files = *
 /table = !LTCFiles + 'asthma1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = asthma).
execute.
match files files = *
 /table = !LTCFiles + 'atrialfib1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = atrialfib).
execute.
match files files = *
 /table = !LTCFiles + 'alzheimers1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = alzheimers).
execute.
match files files = *
 /table = !LTCFiles + 'cancer1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = cancer).
execute.
match files files = *
 /table = !LTCFiles + 'arth1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = arth).
execute.
match files files = *
 /table = !LTCFiles + 'parkinsons1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = parkinsons).
execute.
match files files = *
 /table = !LTCFiles + 'liver1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = liver).
execute.
match files files = *
 /table = !LTCFiles + 'ms1112_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1011 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1112 = ms).
execute.

recode cvd copd dementia diabetes chd hefailure refailure 
       epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms (sysmis=0).
execute.


save outfile = !LTCfiles + 'allltcs_1112.sav'
/keep chi cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms
date_adm_cvd date_adm_copd date_adm_dementia date_adm_diabetes date_adm_chd date_adm_hefailure date_adm_refailure date_adm_epilepsy
date_adm_asthma date_adm_atrialfib date_adm_alzheimers date_adm_cancer date_adm_arth date_adm_parkinsons date_adm_liver date_adm_ms.
get file = !LTCfiles + 'allltcs_1112.sav'.


