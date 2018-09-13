* Read in the PIS patient information file (produced by NSS IM&T).
* Program by Denise Hastie, October 2013.
* Updated by Denise Hastie, April 2015.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Updated by Denise Hastie, June 2016.

GET DATA  /TYPE=TXT
  /FILE="/conf/hscdiip/DH-Extract/File_2_large_data_extract_FY201516.csv"
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
  patient_postcode A7.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (upi_number = upi). 
* Remove the row with null as the upi. 

select if (upi ne 'null').
execute. 

sort cases  by upi.

save outfile = '/conf/hscdiip/DH-Extract/fy2015_patients.sav'.
get file = '/conf/hscdiip/DH-Extract/fy2015_patients.sav'.



