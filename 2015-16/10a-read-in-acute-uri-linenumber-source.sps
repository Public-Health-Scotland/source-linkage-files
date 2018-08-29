* To create the variable SMRType for the acute data set, the line number needs to be 
* available to assign this correctly.

* Program created by Denise Hastie, July 2016.
* Program updated by Denise Hastie, September 2016. 



GET DATA  /TYPE=TXT
  /FILE="/conf/hscdiip/DH-Extract/acute_line_number_by_uri_201516.csv"
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
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

sort cases by uri. 

aggregate outfile = * 
 /break uri
 /lineno = first(lineno). 
execute.

save outfile = '/conf/hscdiip/DH-Extract/acute_line_number_by_uri_201516.sav'.

get file = '/conf/hscdiip/DH-Extract/acute_line_number_by_uri_201516.sav'.




* Check. 
aggregate outfile = * mode=addvariables
 /break uri 
 /new_lineno = first(lineno). 
execute.

if new_lineno eq lineno flag = 1.
frequency variables = flag.



