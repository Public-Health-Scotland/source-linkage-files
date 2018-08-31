* LTC files.
define !LTCfiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.


get file  = !LTCFiles + 'cvd1011_hosp.sav'.

delete variables year_1213 year_1112 year_1314 year_1415.
rename variables (upi year_1011 = chi cvd).
execute.
match files file = *
 /file= !LTCFiles + 'copd1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = copd).
execute.
match files file = *
 /file = !LTCFiles + 'dementia1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = dementia).
execute.
match files file = *
 /table = !LTCFiles + 'diabetes1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = diabetes).
execute.
match files file = *
 /table = !LTCFiles + 'chd1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = chd).
execute.
match files file = *
 /table = !LTCFiles + 'hefailure1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = hefailure).
execute.
match files file = *
 /table = !LTCFiles + 'refailure1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = refailure).
execute.
match files files = *
 /table = !LTCFiles + 'epilepsy1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = epilepsy).
execute.
match files files = *
 /table = !LTCFiles + 'asthma1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = asthma).
execute.
match files files = *
 /table = !LTCFiles + 'atrialfib1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = atrialfib).
execute.
match files files = *
 /table = !LTCFiles + 'alzheimers1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = alzheimers).
execute.
match files files = *
 /table = !LTCFiles + 'cancer1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = cancer).
execute.
match files files = *
 /table = !LTCFiles + 'arth1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = arth).
execute.
match files files = *
 /table = !LTCFiles + 'parkinsons1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = parkinsons).
execute.
match files files = *
 /table = !LTCFiles + 'liver1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = liver).
execute.
match files files = *
 /table = !LTCFiles + 'ms1011_hosp.sav'
 /rename (upi = chi) 
 /drop year_1213 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1011 = ms).
execute.

recode cvd copd dementia diabetes chd hefailure refailure 
       epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms (sysmis=0).
execute.


save outfile = !LTCfiles + 'allltcs_1011.sav'
/keep chi cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib alzheimers cancer arth parkinsons liver ms
date_adm_cvd date_adm_copd date_adm_dementia date_adm_diabetes date_adm_chd date_adm_hefailure date_adm_refailure date_adm_epilepsy
date_adm_asthma date_adm_atrialfib date_adm_alzheimers date_adm_cancer date_adm_arth date_adm_parkinsons date_adm_liver date_adm_ms.
get file = !LTCfiles + 'allltcs_1011.sav'.

