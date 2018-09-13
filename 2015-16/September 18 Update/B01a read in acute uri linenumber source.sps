* Encoding: UTF-8.
* To create the variable SMRType for the acute data set, the line number needs to be
   * available to assign this correctly.

* Program created by Denise Hastie, July 2016.
* Program updated by Denise Hastie, September 2016.

*Last ran 17/05/18AnitaGeorge

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA /TYPE=TXT
   /FILE= !Extracts + 'Acute-line-number-by-URI-20' + !FY + '.csv'
   /ENCODING='UTF8'
   /DELCASE=LINE
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      uri A8
      lineno A3.
CACHE.

 * Remove any duplicates.
aggregate outfile = *
   /break uri
   /lineno = first(lineno).

save outfile = !file + 'acute_line_number_by_uri_20' + !FY + '.zsav'
   /zcompressed.

get file = !file + 'acute_line_number_by_uri_20' + !FY + '.zsav'.


