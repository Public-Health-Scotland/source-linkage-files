* Encoding: UTF-8.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

 * Unzip the file.
Host Command = ["gunzip " + !Deaths_extract_file].

* Read in CSV output file.
GET DATA  /TYPE=TXT
   /FILE= !Deaths_extract_file
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

save outfile = !Deaths_dir + "all_deaths" + !LatestUpdate + ".zsav"
    /zcompressed.

get file = !Deaths_dir +  "all_deaths" + !LatestUpdate + ".zsav".

* Zip back up.
Host Command = ["gzip " + !Deaths_extract_file + "'"].
