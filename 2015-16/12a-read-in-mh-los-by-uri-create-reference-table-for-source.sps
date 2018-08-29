* Due to how cost and non-cost measures behave, length of stay needs to be extracted
* separately.  This program reads in the length of stay by uri.

* Program by Denise Hastie, June 2016.

* Temporary storage.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 


GET DATA  /TYPE=TXT
  /FILE="/conf/hscdiip/DH-Extract/mental_health_all_scotland_los_by_uri_extract_for_source_file_production_201516.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  UniqueRecordIdentifier A8
  LengthofStaydays F7.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

rename variables (UniqueRecordIdentifier lengthofstaydays = uri stay).

* Create one row per uri by taking the first value for length of stay.  
* Note that for records with mutliple rows, that the los is the same on each record.  Due to the way the back end works
* with regards to rendering the data in business objects, this causes multiple rows.  DH, June 2016.

aggregate outfile = *
 /break uri 
 /stay = first(stay).
execute.

sort cases by uri.

save outfile = !file + 'mh_los_by_uri.sav'
 /compressed.


get file = !file + 'mh_los_by_uri.sav'.
