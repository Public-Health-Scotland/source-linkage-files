* Compare the SPARRA extract with the hospital only LTCs for 12/13.
* Denise Hastie, December 2014.

define !LTCfiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

* Consider the LTC CVD as this is the only LTC that I have included that does not have any prescribing data
* incorporated in to how it has been defined. 

* Create a file that only contains those flagged with CVD in SPARRA for matching in.
get file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13.sav'.
select if cvd1 eq 1.
execute.
save outfile = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13_CVD1.sav'.

get file = '/conf/linkage/output/deniseh/CHImasterPLICS_Costed_201213.sav'
 /keep chi date_death deceased_flag cvd.
select if cvd eq 1.
sort cases by chi.
match files file = *
 /file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13_CVD1.sav'
 /in = sparra
 /by chi.
execute.

delete variables EMERG ELECT DAYCASE los_emerg los_elect los_tot ed_attendance alcad drugad fallad
                 finalProb finalProbGrp cohortFlag carehome
                 asthma1 diabetes1 chd1 copd1 epilepsy1 dementia1 renalf1 cancer1 allarth1 artfib1 
                 hrtfail1 alz1 parkin1 ms1 cld1 ltc_count.

recode cvd cvd1 (sysmis = 0).
execute.

descriptives variables = cvd cvd1
 /statistics = sum.

temporary.
select if deceased_flag eq 1.
descriptives variables = cvd cvd1
 /statistics = sum.


* Look at the differences between the files.
*select if ((cvd eq 1) or (cvd1 eq 1)).
*frequency variables = sparra.

if cvd eq 1 and cvd1 eq 1 flag eq 1.
descriptives variables = flag /statistics = sum.

*get file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13.sav'.

* Create a file that has the people flagged with CVD in my file, who are not in SPARRA file.
temporary.
select if (cvd eq 1) and (cvd1 ne 1).
save outfile = !LTCfiles + 'CVDinPLICs-notSPARRA.sav'.
execute.

* Create a file that has the people flagged with CVD1 in the sparra file, but are not flagged as having 
  CVD in my file.

temporary.
select if (cvd ne 1) and (cvd1 eq 1).
save outfile = !LTCfiles + 'CVDinSPARRA-notPLICS.sav'.
execute.


* Look at list of CHI numbers (in PLICS not SPARRA).
get file !LTCfiles + 'CVDinPLICs-notSPARRA.sav'.


* Look at list of CHI numbers (in SPARRA not PLICS).
get file = !LTCfiles + 'CVDinSPARRA-notPLICS.sav'.




* Do a check with the 2013 particular file that I created after the original file that I created.
* The file cvd1213_hosp contains the UPI number for all patients (since the start of the linked catalog)
* who have had a incidence of CVD up to the end of 2013.
*get file = !LTCfiles + 'cvd1213_hosp.sav'.
* Take CHI and deceased information from the CHI master PLICS file and match this file on (as a table)
* then match on the SPARRA information.


get file = '/conf/linkage/output/deniseh/CHImasterPLICS_Costed_201213.sav'
 /keep chi date_death deceased_flag.
sort cases by chi.
match files file = *
 /table = !LTCfiles + 'cvd1213_hosp.sav'
 /rename (upi = chi)
 /drop year_1011 year_1112 year_1314 year_1415
 /by chi.
execute.
recode year_1213 (sysmis = 0).
execute.
select if year_1213 eq 1.
execute.

match files file = *
 /file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13_CVD1.sav'
 /in = sparra
 /by chi.
execute.

delete variables EMERG ELECT DAYCASE los_emerg los_elect los_tot ed_attendance alcad drugad fallad
                 finalProb finalProbGrp cohortFlag carehome
                 asthma1 diabetes1 chd1 copd1 epilepsy1 dementia1 renalf1 cancer1 allarth1 artfib1 
                 hrtfail1 alz1 parkin1 ms1 cld1 ltc_count.

rename variables (year_1213 = cvd).
recode cvd cvd1 (sysmis = 0).
execute.
descriptives variables = cvd cvd1
 /statistics = sum.


temporary.
select if (cvd eq 1) and (cvd1 ne 1).
save outfile = !LTCfiles + 'CVDinPLICs-notSPARRA.sav'.
execute.

* Create a file that has the people flagged with CVD1 in the sparra file, but are not flagged as having 
  CVD in my file.

temporary.
select if (cvd ne 1) and (cvd1 eq 1).
save outfile = !LTCfiles + 'CVDinSPARRA-notPLICS.sav'.
execute.


* Look at list of CHI numbers (in PLICS not SPARRA).
get file !LTCfiles + 'CVDinPLICs-notSPARRA.sav'.


* Look at list of CHI numbers (in SPARRA not PLICS).
get file = !LTCfiles + 'CVDinSPARRA-notPLICS.sav'.







***.

get file = !LTCfiles + 'cvd1213_hosp.sav'.
descriptives variables = year_1011 year_1112 year_1213 year_1314 year_1415
 /statistics = sum.


* IGNORE ALL OF THE BELOW JUST NOW - THIS WAS DONE BEFORE THE STUFF IMMEDIATELY PRECEEDING WAS WRITTEN.

* IGNORE THE FILE COMMENTED OUT. 
*get file = !LTCfiles + 'LTC_CVD_Hospital_Incidence_201213.sav'.

rename variables (upi = chi).
sort cases by chi.
match files file = *
 /file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13_CVD1.sav'
 /in = sparra
 /by chi.
execute.

delete variables year_1011 year_1112 year_1314 year_1415.
delete variables EMERG ELECT DAYCASE los_emerg los_elect los_tot ed_attendance alcad drugad fallad
                 finalProb finalProbGrp cohortFlag carehome
                 asthma1 diabetes1 chd1 copd1 epilepsy1 dementia1 renalf1 cancer1 allarth1 artfib1 
                 hrtfail1 alz1 parkin1 ms1 cld1 ltc_count.

rename variables (year_1213 = cvd).
recode cvd cvd1 (sysmis = 0).
execute.
descriptives variables = cvd cvd1
 /statistics = sum.

* For those in my file, not noted in SPARRA, check the year of admission.

string year_adm (a4).
compute year_adm = substr(date_adm_cvd,1,4).
execute.

compute flag1 = 0.
if (cvd eq 1 and cvd1 eq 0) flag1 = 1.
execute.
temporary.
select if flag1 eq 1.
frequency variables = year_adm.


