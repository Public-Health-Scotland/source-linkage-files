define !DataFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.



get file = !DataFiles + 'dementia1213_hosp.sav'.

get file = '/conf/linkage/output/deniseh/CHImasterPLICS_Costed_201213.sav'
 /keep chi date_death deceased_flag.
sort cases by chi.
match files file = *
 /table = !DataFiles + 'chd1213_hosp.sav'
 /rename (upi = chi)
 /drop date_adm_chd year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = chd).
recode chd (sysmis = 0).
frequency variables = chd. 

get file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13.sav'.

temporary.
select if cvd1 eq 1.
frequency variables = cvd1.

temporary.
select if chd1 eq 1.
frequency variables = chd1.

temporary.
select if dementia1 eq 1.
frequency variables = dementia1.

get file = '/conf/linkage/output/deniseh/CHImasterPLICS_Costed_201213.sav'
 /keep chi date_death deceased_flag.
sort cases by chi.
match files file = *
 /table = !DataFiles + 'dementia1213_hosp.sav'
 /rename (upi = chi)
 /drop date_adm_dementia year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
rename variables (year_1213 = dementia).
recode dementia (sysmis = 0).
frequency variables = dementia. 
