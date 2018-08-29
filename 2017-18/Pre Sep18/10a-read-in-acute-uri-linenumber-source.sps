* To create the variable SMRType for the acute data set, the line number needs to be
   * available to assign this correctly.

* Program created by Denise Hastie, July 2016.
* Program updated by Denise Hastie, September 2016.

*Last ran 17/05/18AnitaGeorge

******************************* **** UPDATE THIS BIT **** *************************************.
********************************************************************************************************.
* Create macros for file path.

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

********************************************************************************************************.
********************************************************************************************************.

GET DATA  /TYPE=TXT
   /FILE= !file + 'acute line number by uri 20' +!FY +'.csv'
   /ENCODING='UTF8'
   /DELCASE=LINE
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /IMPORTCASE=ALL
   /VARIABLES=
      uri A8
      lineno A3.
CACHE.

 * Remove any duplicates.
aggregate outfile = *
   /break uri
   /lineno = first(lineno).

save outfile = !file +'acute_line_number_by_uri_20' +!FY +'.sav'.

get file = !file +'acute_line_number_by_uri_20' +!FY +'.sav'.


* Check one case per uri.
add files file = *
   /by uri
   /first = F.

frequencies F.



