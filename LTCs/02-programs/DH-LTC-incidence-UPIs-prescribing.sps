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


** Prescribing data section *.
* Read in files from BO outpuat and save as SAV files.

* COPD.
GET DATA  /TYPE=TXT
  /FILE=!DataFiles + 'DH-PIS_COPD.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PatUPIC A10
  NumberofDispensedItems F2.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (PatUPIC=upi).
sort cases by upi.

aggregate outfile = *
 /break upi
 /NumberofDispensedItems = sum(NumberofDispensedItems).
execute.

save outfile = !DataFiles + 'PIS_COPD.sav'.


* Dementia.
GET DATA  /TYPE=TXT
  /FILE=!DataFiles + 'DH-PIS_Dementia.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PatUPIC A10
  NumberofDispensedItems F2.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (PatUPIC=upi).
sort cases by upi.

save outfile = !DataFiles + 'PIS_Dementia.sav'.

* Diabetes.
GET DATA  /TYPE=TXT
  /FILE=!DataFiles + 'DH-PIS_Diabetes.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PatUPIC A10
  NumberofDispensedItems F2.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (PatUPIC=upi).
sort cases by upi.

save outfile = !DataFiles + 'PIS_Diabetes.sav'.

* Heart Disease.
GET DATA  /TYPE=TXT
  /FILE=!DataFiles + 'DH-PIS_CHD.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PatUPIC A10
  NumberofDispensedItems F2.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (PatUPIC=upi).
sort cases by upi.

save outfile = !DataFiles + 'PIS_CHD.sav'.


* Heart Failure.
GET DATA  /TYPE=TXT
  /FILE=!DataFiles + 'DH-PIS_HeFailure.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PatUPIC A10
  NumberofDispensedItems F2.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (PatUPIC=upi).
sort cases by upi.

save outfile = !DataFiles + 'PIS_HeFailure.sav'.

* Renal Failure.
GET DATA  /TYPE=TXT
  /FILE=!DataFiles + 'DH-PIS_ReFailure.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PatUPIC A10
  NumberofDispensedItems F2.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (PatUPIC=upi).
sort cases by upi.

save outfile = !DataFiles + 'PIS_ReFailure.sav'.


