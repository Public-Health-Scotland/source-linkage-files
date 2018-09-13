* Create Deceased reference data set for PLICS.

* Read in the Deaths extract (IT ref IMT-CR-03774).
* Need to change dates into the format YYYYMMDD and add in long term condition flag markers.
* The deceased flag and the date of death are derived from two sources:

* 1.  the patient date of death on the CHI database
* 2.  the NRS death registrations. 

* Flags should have the same names as those from previous PLICS analysis files.

* Progam by Denise Hastie, June 2016.

* Create macros for file path.

* Temporary storage.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 

* Death flag files - 'home'.
define !DeathsFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/data-extracts/02-NRS-deaths/'
!enddefine.


* Read in CSV output file.

GET DATA  /TYPE=TXT
  /FILE="/conf/hscdiip/DH-Extract/death_extract_file.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PATIENT_UPIC A10
  PATIENTDoDDATEDERIVED A10.
CACHE.
EXECUTE.

save outfile = !file + 'deaths_temp.sav'.

get file = !file + 'deaths_temp.sav'.

* Create a new date variable and deceased flag.
* Note that Patient_UPI is renamed to CHI.  CHI in the PLICS analysis is infact the UPI number.  

rename variables (patient_upic = chi).

string derived_datedeath (a8).
compute derived_datedeath = concat(substr(patientdoddatederived,7,4),substr(patientdoddatederived,4,2),substr(patientdoddatederived,1,2)).
execute.

* Flag variables.
numeric deceased (f1.0).
* Initialise flag to ZERO.
compute deceased = 0.
if (derived_datedeath ne '') deceased = 1.
frequency variables = deceased.

sort cases by chi.

save outfile = !Deathsfile + 'Deceased_patient_reference_file.sav'
 /keep chi deceased derived_datedeath.

get file = !Deathsfile + 'Deceased_patient_reference_file.sav'.

erase file = !file + 'deaths_temp.sav'.




