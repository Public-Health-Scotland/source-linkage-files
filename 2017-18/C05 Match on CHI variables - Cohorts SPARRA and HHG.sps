* Encoding: UTF-8.
********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************. 

 * Get the SPARRA and HHG files from the SPARRA team.
 * Email NSS.SPARRAOnline@nhs.net for SPARRA and  NSS.HighHealthGain@nhs.net for HHG.
 * Ask for the 12 month scores for all chis from as close to 1st April as possible.
 * Save the files in extracts as SPARRA-201718.zsav and HHG-201718.zsav.

 * For SPARRA and HHG (where available).
 * In 1617 use the 12-Month predictions from April 1st 2016 as "Start_FY" and 12-Month predictions from April 1st 2017 as "End_Fy".

match files file = !File + "temp-source-episode-file-4-" + !FY + ".zsav"
    /table = !File + "Patient_Demographic_Cohort_" + !FY + ".zsav"
    /table = !File + "GP_Practice_Service_Use_Cohorts_" + !FY+ ".zsav"
    /table = !Extracts_Alt + "SPARRA/SPARRA-20" + !FY + ".zsav"
    /Rename
    UPI_Number = chi
    SPARRA_RISK_SCORE = SPARRA_Start_FY
    /table = !Extracts_Alt + "SPARRA/SPARRA-20" + !NextFY + ".zsav"
    /Rename
    UPI_Number = chi
    SPARRA_RISK_SCORE = SPARRA_End_FY
    /table = !Extracts_Alt + "HHG/HHG-20" + !NextFY + ".zsav"
    /Rename
    UPI_Number = chi
    HHG_SCORE = HHG_End_FY
    /by CHI.
execute.

 * HHG only for 201718 onwards.
 * /table = !Extracts_Alt + "HHG/HHG-20" + !FY + ".zsav" 
   /Rename (UPI_Number = chi)

 * Make any variables which are missing.
Numeric HHG_Start_FY (F2.0).

save outfile = !File + "temp-source-episode-file-5-" + !FY + ".zsav"
   /zcompressed.

get file= !File + "temp-source-episode-file-5-" + !FY + ".zsav".
