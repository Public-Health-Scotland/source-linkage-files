* IRF Producing list of UPIs for patients with a specific long term condition.
* This work is to create SPSS lists of UPIs with a flag variable that will be used in 
* the addition of long term condition flags to the master PLICs and CHI master PLICs 
* analysis files. 

* Created by Denise Hastie, May 2014.

* Define file path for saving interim files and output.
* Interim files.  This shouldn't be necessary - but just adding in.

define !DataFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/data/'
!enddefine.

* Output files.
define !OutputFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/output/'
!enddefine.

* CVD.
* Note that there isn't any prescribing information available specifically for CVD.
* This file will be saved with a new file name for consistency with the other LTC files.

get file = !DataFiles + 'cvd_hosp.sav'.

delete variables year_adm_cvd.

numeric cvd (f1.0).
compute cvd = 1.
execute.

rename variables (upi = chi).

save outfile = !OutputFiles + 'CVD.sav'.

* COPD.
get file = !DataFiles + 'copd_hosp.sav'.

sort cases by upi.

match files file = *
 /file = !DataFiles + 'PIS_COPD.sav'
 /by upi.
execute.

numeric copd (f1.0).
compute copd = 1.
execute.

delete variables year_adm_copd NumberofDispensedItems.
rename variables (upi = chi).

select if (chi ne 'Pat UPI [C').
execute.

save outfile = !OutputFiles + 'COPD.sav'.

* Dementia.
get file = !DataFiles + 'dementia_hosp.sav'.

sort cases by upi.

match files file = *
 /file = !DataFiles + 'PIS_Dementia.sav'
 /by upi.
execute.

numeric dementia (f1.0).
compute dementia = 1.
execute.

delete variables year_adm_dementia NumberofDispensedItems.
rename variables (upi = chi).

select if (chi ne '').
execute.

save outfile = !OutputFiles + 'Dementia.sav'.


* Diabetes.
get file = !DataFiles + 'diabetes_hosp.sav'.

sort cases by upi.

match files file = *
 /file = !DataFiles + 'PIS_Diabetes.sav'
 /by upi.
execute.

numeric diabetes (f1.0).
compute diabetes = 1.
execute.

* I have forgot to rename a variable in the hospital incidence program.
delete variables year_adm_cvd NumberofDispensedItems.
rename variables (upi = chi).

select if (chi ne '').
execute.

save outfile = !OutputFiles + 'Diabetes.sav'.
*get file = !OutputFiles + 'Diabetes.sav'.

* Heart Disease.
get file = !DataFiles + 'chd_hosp.sav'.

sort cases by upi.

match files file = *
 /file = !DataFiles + 'PIS_CHD.sav'
 /by upi.
execute.

numeric chd (f1.0).
compute chd = 1.
execute.

delete variables year_adm_chd NumberofDispensedItems.
rename variables (upi = chi).

select if (chi ne '').
execute.

save outfile = !OutputFiles + 'CHD.sav'.

* Heart Failure.
get file = !DataFiles + 'hefailure_hosp.sav'.

sort cases by upi.

match files file = *
 /file = !DataFiles + 'PIS_HeFailure.sav'
 /by upi.
execute.

numeric refailure (f1.0).
compute refailure = 1.
execute.

delete variables year_adm_hefailure NumberofDispensedItems.
rename variables (upi = chi).

select if (chi ne '').
execute.

save outfile = !OutputFiles + 'HeFailure.sav'.

* Renal Failure.
get file = !DataFiles + 'refailure_hosp.sav'.

sort cases by upi.

match files file = *
 /file = !DataFiles + 'PIS_ReFailure.sav'
 /by upi.
execute.

numeric hefailure (f1.0).
compute hefailure = 1.
execute.

* I have forgot to rename a variable in the hospital incidence program.
delete variables year_adm_hefailure NumberofDispensedItems.
rename variables (upi = chi).

select if (chi ne '').
execute.

save outfile = !OutputFiles + 'ReFailure.sav'.

