* LTC files.
define !LTCfiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

get file  = !LTCFiles + 'cvd1213_hosp.sav'.

delete variables year_1011 year_1112 year_1314 year_1415.
rename variables (upi year_1213 = chi cvd).
execute.
match files file = *
 /file= !LTCFiles + 'copd1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = copd).
execute.
match files file = *
 /file = !LTCFiles + 'dementia1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = dementia).
execute.
match files file = *
 /table = !LTCFiles + 'diabetes1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = diabetes).
execute.
match files file = *
 /table = !LTCFiles + 'chd1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = chd).
execute.
match files file = *
 /table = !LTCFiles + 'hefailure1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = hefailure).
execute.
match files file = *
 /table = !LTCFiles + 'refailure1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = refailure).
execute.
match files files = *
 /table = !LTCFiles + 'epilepsy1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = epilepsy).
execute.
match files files = *
 /table = !LTCFiles + 'asthma1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = asthma).
execute.
match files files = *
 /table = !LTCFiles + 'atrialfib1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = atrialfib).
execute.
match files files = *
 /table = !LTCFiles + 'alzheimers1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = alzheimers).
execute.
match files files = *
 /table = !LTCFiles + 'cancer1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = cancer).
execute.
match files files = *
 /table = !LTCFiles + 'arth1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = arth).
execute.
match files files = *
 /table = !LTCFiles + 'parkinsons1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = parkinsons).
execute.
match files files = *
 /table = !LTCFiles + 'liver1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = liver).
execute.
match files files = *
 /table = !LTCFiles + 'ms1213_hosp.sav'
 /rename (upi = chi) 
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = ms).
execute.

recode cvd copd dementia diabetes chd hefailure refailure 
       epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms (sysmis=0).
execute.

save outfile = !LTCfiles + 'allltcs_1213.sav'
/keep chi cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms
date_adm_cvd date_adm_copd date_adm_dementia date_adm_diabetes date_adm_chd date_adm_hefailure date_adm_refailure date_adm_epilepsy
date_adm_asthma date_adm_atrialfib date_adm_alzheimers date_adm_cancer date_adm_arth date_adm_parkinsons date_adm_liver date_adm_ms.
get file = !LTCfiles + 'allltcs_1213.sav'.

