* Encoding: UTF-8.
* Create Deceased reference data set for PLICS.

* Read in the Deaths extract (IT ref IMT-CR-03774).
* Need to change dates into the format YYYYMMDD and add in long term condition flag markers.
* The deceased flag and the date of death are derived from two sources:

* 1.  the patient date of death on the CHI database
* 2.  the NRS death registrations.

* Flags should have the same names as those from previous PLICS analysis files.

* Program by Denise Hastie, June 2016.
*** MODIFIED BY GNW ON 18/01/19 TO REMOVE DUPLICATES (PROGRAM 19b - not necessary now).
* Program modified (slightly) by Denise Greig (nee Hastie), March 2017.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
* Change this to the relevant number.
* Should be '_extract_NUMBER'.
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

Numeric death_date (Date12).

Do if death_date_NRS = death_date_CHI.
    compute death_date = death_date_NRS.
Else if sysmiss(death_date_NRS).
    Compute death_date = death_date_CHI.
Else.
    compute death_date = death_date_NRS.
End if.

 * Only keep death records which are before the end of the FY.
Select if death_date < Date.DMY(01, 04, Number((!altFY), F4.0) + 1).

Numeric deceased (F1.0).
Do if SysMiss(death_date).
   Compute deceased = 0.
Else.
   Compute deceased = 1.
End if.

frequencies deceased.

* Code added to remove duplicates.and take the latest death_date.
aggregate outfile = *
   /break chi
   /deceased death_date = Max(deceased death_date).

save outfile = !Extracts_Alt + "Deceased_patient_reference_file-20" + !FY + ".zsav"
   /keep chi deceased death_date
   /zcompressed.

get file = !Extracts_Alt + "Deceased_patient_reference_file-20" + !FY + ".zsav".

* Zip back up.
Host Command = ["gzip '" + !CSDExtractLoc + !Extract_Number + "_Deaths.csv'"].

