* Create Deceased reference data set for PLICS.

* Read in the Deaths extract (IT ref IMT-CR-03774).
* Need to change dates into the format YYYYMMDD and add in long term condition flag markers.
* The deceased flag and the date of death are derived from two sources:

* 1.  the patient date of death on the CHI database
   * 2.  the NRS death registrations.

* Flags should have the same names as those from previous PLICS analysis files.

* Progam by Denise Hastie, June 2016.
*** MODIFIED BY GNW ON 18/01/19 TO REMOVE DUPLICATES (PROGRAM 19b - not necessary now).
* Program modified (slightly) by Denise Greig (nee Hastie), March 2017.

* Create macros for file path.

define !Extract()
   '/conf/hscdiip/DH-Extract/20180515/'
!enddefine.


define !Outfile()
   '/conf/sourcedev/James/Temp/'
!enddefine.


* Read in CSV output file.

GET DATA  /TYPE=TXT
   /FILE=!Extract + 'SCTASK0045835_extract_2_death_data.csv'
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

save outfile = !Outfile + 'deaths_temp.zsav'
   /zcompressed.

get file =  !Outfile + 'deaths_temp.zsav'.

* Create a new date variable and deceased flag.
* Note that Patient_UPI is renamed to CHI.  CHI in the PLICS analysis is infact the UPI number.

rename variables (patient_upic = chi).

string derived_datedeath (a8).
compute derived_datedeath = concat(substr(patientdoddatederived,7,4),substr(patientdoddatederived,4,2),substr(patientdoddatederived,1,2)).

numeric deceased (f1.0).
* Initialise flag to ZERO.
compute deceased = 0.
if (derived_datedeath ne '') deceased = 1.
frequencies deceased.

* Code added to remove duplicates.
aggregate outfile = *
   /break chi
   /deceased derived_datedeath = Max(deceased derived_datedeath).

save outfile = !Outfile+ 'Deceased_patient_reference_file.zsav'
   /keep chi deceased derived_datedeath
   /zcompressed.

get file = !Outfile + 'Deceased_patient_reference_file.zsav'.

erase file = !Outfile+ 'deaths_temp.zsav'.





