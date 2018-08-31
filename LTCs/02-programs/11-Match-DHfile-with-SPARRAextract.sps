* Compare the SPARRA extract with the hospital only LTCs for 12/13.
* Denise Hastie, November 2014.

define !LTCfiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

get file = !LTCfiles + 'chd1213_hosp.sav'.
rename variables (year_1213 = chd).
save outfile = !LTCfiles + 'chd_hosp1213_only.sav'
 /keep upi chd.

get file = !LTCfiles + 'LTC_COPD_Hospital_Incidence_201213.sav'.
compute copd = 1.
execute.
save outfile = !LTCfiles + 'LTC_COPD_Hospital_Incidence_201213.sav'.

get file = !LTCfiles + 'LTC_CVD_Hospital_Incidence_201213.sav'.
compute cvd = 1.
execute.
save outfile = !LTCfiles + 'LTC_CVD_Hospital_Incidence_201213.sav'.

get file = !LTCfiles + 'LTC_DEMENTIA_Hospital_Incidence_201213.sav'.
compute dementia = 1.
execute.
save outfile = !LTCfiles + 'LTC_DEMENTIA_Hospital_Incidence_201213.sav'.

get file = !LTCfiles + 'LTC_DIABETES_Hospital_Incidence_201213.sav'.
compute diabetes = 1.
execute.
save outfile = !LTCfiles + 'LTC_DIABETES_Hospital_Incidence_201213.sav'.

get file = !LTCfiles + 'LTC_HeFailure_Hospital_Incidence_201213.sav'.
compute hefailure = 1.
execute.
save outfile = !LTCfiles + 'LTC_HeFailure_Hospital_Incidence_201213.sav'.

get file = !LTCfiles + 'LTC_ReFailure_Hospital_Incidence_201213.sav'.
compute refailure = 1.
execute.
save outfile = !LTCfiles + 'LTC_ReFailure_Hospital_Incidence_201213.sav'.


***.

get file = !LTCfiles + 'LTC_CHD_Hospital_Incidence_201213.sav'.
match files files = *
 /file = !LTCfiles + 'LTC_COPD_Hospital_Incidence_201213.sav'
 /by upi.
execute.
match files file = *
 /file = !LTCfiles + 'LTC_CVD_Hospital_Incidence_201213.sav'
 /by upi.
execute.
match files file = *
 /file = !LTCfiles + 'LTC_DEMENTIA_Hospital_Incidence_201213.sav'
 /by upi.
execute.
match files file = *
 /file = !LTCfiles + 'LTC_DIABETES_Hospital_Incidence_201213.sav'
 /by upi.
execute.
match files file = *
 /file = !LTCfiles + 'LTC_HeFailure_Hospital_Incidence_201213.sav'
 /by upi.
execute.
match files file = *
 /file = !LTCfiles + 'LTC_ReFailure_Hospital_Incidence_201213.sav'
 /by upi.
execute.


recode chd copd cvd dementia diabetes hefailure refailure (sysmis = 0).
execute.

*match in sparra file.
get file = !LTCfiles + 'chd_hosp1213_only.sav'.
match files file = *
 /file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13.sav'
 /rename = (chi = upi)
 /in = sparra
 /by upi.
execute.

select if (chd eq 1 | chd1 eq 1).
execute.

recode chd copd cvd dementia diabetes hefailure refailure 
       asthma1 diabetes1 chd1 copd1 cvd1 epilepsy1 dementia1 renalf1 cancer1 allarth1 artfib1 
       hrtfail1 alz1 parkin1 ms1 cld1 (sysmis = 0).
execute.

descriptives variables = chd copd cvd dementia diabetes hefailure refailure 
                        chd1 copd1 cvd1 dementia1 diabetes1 hrtfail1 renalf1
 /statistics = sum.


* Try matching the sparra extract to the CHI master PLICS file.
* Just to have a look but note that this is not comparing like with like apart from one condition.  

get file = '/conf/linkage/output/deniseh/CHImasterPLICS_Costed_201213.sav'.
sort cases by chi.
match files file = *
 /file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13.sav'
 /in = sparra
 /by chi.
execute.

recode chd copd cvd dementia diabetes hefailure refailure 
       asthma1 diabetes1 chd1 copd1 cvd1 epilepsy1 dementia1 renalf1 cancer1 allarth1 artfib1 
       hrtfail1 alz1 parkin1 ms1 cld1 (sysmis = 0).
execute.

descriptives variables = chd copd cvd dementia diabetes hefailure refailure 
                        chd1 copd1 cvd1 dementia1 diabetes1 hrtfail1 renalf1
 /statistics = sum.


get file = '/conf/linkage/output/deniseh/CHImasterPLICS_Costed_201213.sav'.
sort cases by chi.
match files file = *
 /table =  !LTCfiles + 'chd_hosp1213_only.sav'
 /rename = (chd = chd_new)
 /rename = (upi = chi)
 /by chi.
match files file = *
 /file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13.sav'
 /in = sparra
 /by chi.
execute.

descriptives variables = chd chd_new chd1
 /statistics = sum.
