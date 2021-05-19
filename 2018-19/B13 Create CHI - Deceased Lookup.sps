* Encoding: UTF-8.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
* Change this to the relevant number.
* Should be '_extract_N'.
Define !Extract_Number()
    "_extract_2"
!EndDefine.

 * Unzip the file.
Host Command = ["gunzip '" + !CSDExtractLoc + !Extract_Number + "_Deaths.csv'"].

* Read in CSV output file.
GET DATA  /TYPE=TXT
   /FILE= !CSDExtractLoc + !Extract_Number + "_Deaths.csv"
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      chi A10
      death_date_NRS A10
      death_date_CHI A10.
CACHE.

Alter type death_date_NRS death_date_CHI (EDate12).
Alter type death_date_NRS death_date_CHI (Date12).

 * Keep only one record per CHI.
aggregate outfile = *
    /Break CHI
    /death_date_NRS death_date_CHI = Max(death_date_NRS death_date_CHI).

Numeric death_date (Date12).

 * Use the NRS deathdate unless it isn't there.
Compute death_date = death_date_CHI.
If Not(sysmis(death_date_NRS)) death_date = death_date_NRS.

save outfile = !SLF_Extracts + "All Deaths.zsav"
    /zcompressed.

get file = !SLF_Extracts +  "All Deaths.zsav".

* Zip back up.
Host Command = ["gzip '" + !CSDExtractLoc + !Extract_Number + "_Deaths.csv'"].

