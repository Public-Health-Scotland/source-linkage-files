* Due to how cost and non-cost measures behave, length of stay needs to be extracted
* separately.  This program reads in the length of stay by uri.

* Program by Denise Hastie, June 2016.


********************************************************************************************************.
********************************************************************************************************.
define !file()
   '/conf/sourcedev/Anita_temp/'
!enddefine.

* Extract files - 'home'.
define !Extracts()
   '/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

*define macro for FY.
define !FY()
   '1718'
!enddefine.


**********************************************************************************************************.

GET DATA  /TYPE=TXT
   /FILE= !file +'mental health all scotland los by uri extract for source file production 20'+!FY+'.csv'
   /ENCODING='UTF8'
   /DELCASE=LINE
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /IMPORTCASE=ALL
   /VARIABLES=
      uri A8
      stay F7.0.
CACHE.


* Create one row per uri by taking the first value for length of stay.
* Note that for records with mutliple rows, that the los is the same on each record.  Due to the way the back end works
   * with regards to rendering the data in business objects, this causes multiple rows.  DH, June 2016.

aggregate outfile = *
   /break uri
   /stay = first(stay).

save outfile = !file + 'mh_los_by_uri.zsav'
   /zcompressed.




