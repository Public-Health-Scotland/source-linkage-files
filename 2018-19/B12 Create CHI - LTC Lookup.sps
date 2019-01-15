* Encoding: UTF-8.
* Create LTC reference data set for PLICS.

* Read in the LTC extract (IT ref IMT-CR-03774).
* Need to change dates into the format YYYYMMDD and add in long term condition flag markers.
* LTC flags should have the same names as those from previous PLICS analysis files.

* Program by Denise Hastie, June 2016.

*Last ran 16/05/18-AnitaGeorge.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
* Change this to the relevant number.
* Should be '_extract_NUMBER'.
Define !Extract_Number()
	"_extract_1"
!EndDefine.

 * Unzip the file.
Host Command = ["gunzip '" + !CSDExtractLoc + !Extract_Number + "_LTCs.csv'"].

* Read in CSV output file.
GET DATA  /TYPE=TXT
   /FILE= !CSDExtractLoc + !Extract_Number + "_LTCs.csv"
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      chi A10
      arth_date A10
      asthma_date A10
      atrialfib_date A10
      cancer_date A10
      cvd_date A10
      liver_date A10
      copd_date A10
      dementia_date A10
      diabetes_date A10
      epilepsy_date A10
      chd_date A10
      hefailure_date A10
      ms_date A10
      parkinsons_date A10
      refailure_date A10
      congen_date A10
      bloodbfo_date A10
      endomet_date A10
      digestive_date A10.
CACHE.

Alter Type arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date chd_date 
hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date (EDate12).

Alter Type arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date chd_date 
hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date (Date12).

* Flag variables.
numeric arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure
   congen bloodbfo endomet digestive (F1.0).

* Set flags to 1 or 0 based on FY, also clear the date if outside of FY.
Do Repeat LTC = arth to digestive
   /LTC_date = arth_date to digestive_date.
   Do if SysMiss(LTC_date) OR LTC_date >= Date.DMY(01, 04, Number((!altFY), F4.0) + 1).
      Compute LTC = 0.
      Compute LTC_date = $sysmis.
   Else.
      Compute LTC = 1.
   End if.
End Repeat.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive.

sort cases by chi.

save outfile = !Extracts_Alt + "LTCs_patient_reference_file-20" + !FY + ".zsav"
   /keep chi arth to digestive
      arth_date to digestive_date
   /zcompressed.

get file = !Extracts_Alt + "LTCs_patient_reference_file-20" + !FY + ".zsav".

* Zip back up.
Host Command = ["gzip '" + !CSDExtractLoc + !Extract_Number + "_LTCs.csv'"].
