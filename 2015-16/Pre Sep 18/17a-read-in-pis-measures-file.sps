* Read in the PIS measures file (produced by NSS IM&T).
* Program by Denise Hastie, October 2013.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Updated by Denise Hastie, June 2016.

GET DATA  /TYPE=TXT
  /FILE="/conf/hscdiip/DH-Extract/File_1_large_data_extract_FY201516.csv"
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
  paid_nic_excl_bb F7.2.
CACHE.
EXECUTE.
DATASET NAME DataSet4 WINDOW=FRONT.


rename variables (upi_number = upi). 
* Note that the row without a UPI provides the number of dispensed items and the cost associated with these. 

if (upi eq 'null') upi =''.
execute. 

sort cases  by upi.

save outfile = '/conf/hscdiip/DH-Extract/fy2015_measures.sav'.
get file = '/conf/hscdiip/DH-Extract/fy2015_measures.sav'.
