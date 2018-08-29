* Read in the PIS patient information file (produced by NSS IM&T).
* Program by Denise Hastie, October 2013.
* Updated by Denise Hastie, April 2015.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Updated by Denise Hastie, June 2016.
* Updated by Denise Hastie, August 2016 - to include prescriber practice code.  


* Whilst it is the prescriber practice code which is available, it is thought that most
* patients will get prescription from a GP within the practice they usually attend.  So in a
* similar way that postcode is determined, the GP Practice Code is determined in the same manner.
* DH August 2016.

define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 

* Extract files - 'home'.
define !Extracts()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

*define macro for FY.
define !FY()
'1617'
!enddefine.
 
******************************************************************************************************.
GET DATA  /TYPE=TXT
  /FILE=!file + 'SCTASK0011123_extract_4_fy_2016.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  upi_number A10
  date_of_birth A10
  gender A1
  patient_postcode A7
  praccode A5.
CACHE.
EXECUTE.

rename variables (upi_number praccode = upi prac). 
alter type prac (a6). 

* Remove the row with null as the upi. 

select if (upi ne 'null').
execute. 

sort cases  by upi.

save outfile = !file + 'pis_' +!FY +'_patients.sav'.
get file = !file + 'pis_' +!FY +'_patients.sav'.




