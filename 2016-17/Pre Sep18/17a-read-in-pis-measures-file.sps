* Read in the PIS measures file (produced by NSS IM&T).
* Program by Denise Hastie, October 2013.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Updated by Denise Hastie, June 2016.
* Updated by Denise Hastie, August 2016 - to add in a new variable (DI paid GIC excl BB). 

* 2016/17 data.

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

******************************************************************************************. 

GET DATA  /TYPE=TXT
  /FILE=!file + 'SCTASK0011123_extract_3_paid_data_fy_2016.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  upi_number A10
  no_dispensed_items F3.0
  paid_nic_excl_bb F7.2
  paid_gic_excl_bb F7.2.
CACHE.
EXECUTE.

rename variables (upi_number = upi). 
* Note that the row without a UPI provides the number of dispensed items and the cost associated with these. 

if (upi eq 'null') upi =''.
execute. 

sort cases  by upi.

save outfile = !file + 'pis_' +!FY +'_measures.sav'.
get file = !file + 'pis_' +!FY +'_measures.sav'.

