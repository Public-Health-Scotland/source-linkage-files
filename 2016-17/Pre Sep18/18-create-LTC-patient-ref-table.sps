* Create LTC reference data set for PLICS.

* Read in the LTC extract (IT ref IMT-CR-03774).
* Need to change dates into the format YYYYMMDD and add in long term condition flag markers.
* LTC flags should have the same names as those from previous PLICS analysis files.

* Changed the location of the LTC file to UNIX hscdiip.  31/08/2017 DKG.

* Progam by Denise Hastie, June 2016.

* Create macros for file path.

* Temporary storage.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 

* LTC flags files - 'home'.
define !LTCFile()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.


* Read in CSV output file.

GET DATA  /TYPE=TXT
  /FILE="/conf/hscdiip/DH-Extract/SCTASK0011123_extract_1_ltc.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PATIENT_UPIC A10
  ARTHRITIS_DIAG_DATE A10
  ASTHMA_DIAG_DATE A10
  ATRIAL_FIB_DIAG_DATE A10
  CANCER_DIAG_DATE A10
  CEREBROVASC_DIS_DIAG_DATE A10
  CHRON_LIVER_DIS_DIAG_DATE A10
  COPD_DIAG_DATE A10
  DEMENTIA_DIAG_DATE A10
  DIABETES_DIAG_DATE A10
  EPILEPSY_DIAG_DATE A10
  HEART_DISEASE_DIAG_DATE A10
  HEART_FAILURE_DIAG_DATE A10
  MULT_SCLEROSIS_DIAG_DATE A10
  PARKINSONS_DIAG_DATE A10
  RENAL_FAILURE_DIAG_DATE A10
  CONGENITAL_PROB_DIAG_DATE A10
  BLOOD_AND_BFO_DIAG_DATE A10
  OTH_DIS_END_MET_DIAG_DATE A10
  OTH_DIS_DIG_SYS_DIAG_DATE A10.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

save outfile = !file + 'ltc_temp.sav'.

get file = !file + 'ltc_temp.sav'.

* Create new date variables and flags with the previous LTC marker names (where applicable) used on previous PLICS files.
* Note that Patient_UPI is renamed to CHI.  CHI in the PLICS analysis is infact the UPI number.  

rename variables (patient_upic = chi ).

string arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date 
       diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date 
       congen_date bloodbfo_date endomet_date digestive_date (a8).

compute arth_date = concat(substr(arthritis_diag_date,7,4),substr(arthritis_diag_date,4,2),substr(arthritis_diag_date,1,2)).
compute asthma_date = concat(substr(asthma_diag_date,7,4),substr(asthma_diag_date,4,2),substr(asthma_diag_date,1,2)).
compute atrialfib_date = concat(substr(atrial_fib_diag_date,7,4),substr(atrial_fib_diag_date,4,2),substr(atrial_fib_diag_date,1,2)).
compute cancer_date = concat(substr(cancer_diag_date,7,4),substr(cancer_diag_date,4,2),substr(cancer_diag_date,1,2)).
compute cvd_date = concat(substr(cerebrovasc_dis_diag_date,7,4),substr(cerebrovasc_dis_diag_date,4,2),substr(cerebrovasc_dis_diag_date,1,2)).
compute liver_date = concat(substr(chron_liver_dis_diag_date,7,4),substr(chron_liver_dis_diag_date,4,2),substr(chron_liver_dis_diag_date,1,2)).
compute copd_date = concat(substr(copd_diag_date,7,4),substr(copd_diag_date,4,2),substr(copd_diag_date,1,2)).
compute dementia_date = concat(substr(dementia_diag_date,7,4),substr(dementia_diag_date,4,2),substr(dementia_diag_date,1,2)).
compute diabetes_date = concat(substr(diabetes_diag_date,7,4),substr(diabetes_diag_date,4,2),substr(diabetes_diag_date,1,2)).
compute epilepsy_date = concat(substr(epilepsy_diag_date,7,4),substr(epilepsy_diag_date,4,2),substr(epilepsy_diag_date,1,2)).
compute chd_date = concat(substr(heart_disease_diag_date,7,4),substr(heart_disease_diag_date,4,2),substr(heart_disease_diag_date,1,2)).
compute hefailure_date = concat(substr(heart_failure_diag_date,7,4),substr(heart_failure_diag_date,4,2),substr(heart_failure_diag_date,1,2)).
compute ms_date = concat(substr(mult_sclerosis_diag_date,7,4),substr(mult_sclerosis_diag_date,4,2),substr(mult_sclerosis_diag_date,1,2)).
compute parkinsons_date = concat(substr(parkinsons_diag_date,7,4),substr(parkinsons_diag_date,4,2),substr(parkinsons_diag_date,1,2)).
compute refailure_date = concat(substr(renal_failure_diag_date,7,4),substr(renal_failure_diag_date,4,2),substr(renal_failure_diag_date,1,2)).
compute congen_date = concat(substr(congenital_prob_diag_date,7,4),substr(congenital_prob_diag_date,4,2),substr(congenital_prob_diag_date,1,2)).
compute bloodbfo_date = concat(substr(blood_and_bfo_diag_date,7,4),substr(blood_and_bfo_diag_date,4,2),substr(blood_and_bfo_diag_date,1,2)).
compute endomet_date = concat(substr(oth_dis_end_met_diag_date,7,4),substr(oth_dis_end_met_diag_date,4,2),substr(oth_dis_end_met_diag_date,1,2)).
compute digestive_date = concat(substr(oth_dis_dig_sys_diag_date,7,4),substr(oth_dis_dig_sys_diag_date,4,2),substr(oth_dis_dig_sys_diag_date,1,2)).
execute.

* Flag variables.
numeric arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure
        congen bloodbfo endomet digestive (f1.0).

* Initialise all flags to ZERO.
compute arth = 0.
compute asthma = 0.
compute atrialfib = 0.
compute cancer = 0.
compute cvd = 0.
compute liver = 0.
compute copd = 0.
compute dementia = 0.
compute diabetes = 0.
compute epilepsy = 0.
compute chd = 0.
compute hefailure = 0.
compute ms = 0.
compute parkinsons = 0.
compute refailure = 0.
compute congen = 0.
compute bloodbfo = 0.
compute endomet = 0.
compute digestive = 0.

if (arth_date ne '') arth = 1.
if (asthma_date ne '') asthma = 1.
if (atrialfib_date ne '') atrialfib = 1.
if (cancer_date ne '') cancer = 1.
if (cvd_date ne '') cvd = 1.
if (liver_date ne '') liver = 1.
if (copd_date ne '') copd = 1.
if (dementia_date ne '') dementia = 1.
if (diabetes_date ne '') diabetes = 1.
if (epilepsy_date ne '') epilepsy = 1.
if (chd_date ne '') chd = 1.
if (hefailure_date ne '') hefailure = 1.
if (ms_date ne '') ms = 1.
if (parkinsons_date ne '') parkinsons = 1.
if (refailure_date ne '') refailure = 1.
if (congen_date ne '') congen = 1.
if (bloodbfo_date ne '') bloodbfo = 1.
if (endomet_date ne '') endomet = 1.
if (digestive_date ne '') digestive = 1.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
            hefailure ms parkinsons refailure congen bloodbfo endomet digestive.

sort cases by chi.

save outfile = !LTCfile + 'LTCs_patient_reference_file.sav'
 /keep chi arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
           hefailure ms parkinsons refailure congen bloodbfo endomet digestive
           arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date 
           diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date 
           congen_date bloodbfo_date endomet_date digestive_date.

get file = !LTCfile + 'LTCs_patient_reference_file.sav'.

erase file = !file + 'ltc_temp.sav'.
erase file = !file + 'SCTASK0011123_extract_1_ltc.csv'.
