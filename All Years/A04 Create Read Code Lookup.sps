* Encoding: UTF-8.
************************************************************************************************************
   NSS (ISD)
   ************************************************************************************************************
   ** AUTHOR:	James McMahon (james.mcmahon@phs.scot)
   ** Date:    	01/08/2018
   ************************************************************************************************************
   ** Amended by: Jennifer Thom 
   ** Date: 23/3/21
   ** Changes: Moved over into all years folder - no changes to syntax. 
   ************************************************************************************************************.
********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in Read code lookup.
* To get a new Read code lookup file Email NSS.isdGeneralPractice. Although the file shouldn't change from year to year.
* Save ReadCodes.csv to \\irf\05-lookups.

GET DATA  /TYPE=TXT
   /FILE= !Lookup + "../ReadCodes.csv"
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      ReadCode A5
      Description A70.
CACHE.

* Sort and save, set Description to upper case for matching.
Sort cases by ReadCode.
Compute Description = Upper(Description).

save outfile = !Lookup + "../ReadCodeLookup.zsav"
   /zcompressed.
