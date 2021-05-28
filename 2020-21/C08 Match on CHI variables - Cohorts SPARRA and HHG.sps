* Encoding: UTF-8.
********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************. 

 * Get the SPARRA and HHG files from the SPARRA team.
 * Email phs.sparraonline@phs.scot for SPARRA and  phs.highhealthgain@phs.scot for HHG.
 * Ask for the 12 month scores for all chis from as close to 1st April as possible.
 * Save the files in extracts as SPARRA-201718.zsav and HHG-201718.zsav.

 * For SPARRA and HHG (where available).
 * In 1617 use the 12-Month predictions from April 1st 2016 as "Start_FY" and 12-Month predictions from April 1st 2017 as "End_Fy".

match files file = !Year_dir + "temp-source-episode-file-6-" + !FY + ".zsav"
    /table = !Cohort_dir + "Demographic_Cohorts_" + !FY + ".zsav"
    /table = !Cohort_dir + "Service_Use_Cohorts_" + !FY+ ".zsav"
    /table = !SPARRA_dir + "SPARRA-20" + !FY + ".zsav"
    /Rename
    UPI_Number = chi
    SPARRA_RISK_SCORE = SPARRA_Start_FY
    /table = !HHG_dir + "HHG-20" + !FY + ".zsav"
    /Rename
    UPI_Number = chi
    HHG_SCORE = HHG_Start_FY
    /Drop Psychiatry_Cost Maternity_Cost Geriatric_Cost Elective_Inpatient_Cost Limited_Daycases_Cost Single_Emergency_Cost
    Multiple_Emergency_Cost Routine_Daycase_Cost Outpatient_Cost Prescribing_Cost AE2_Cost
    /Drop End_of_Life Frailty High_CC Maternity MH Substance Medium_CC Low_CC Child_Major Adult_Major Comm_Living
    /by CHI.

Numeric SPARRA_End_FY HHG_End_FY (F2.0).

save outfile = !Year_dir + "temp-source-episode-file-7-" + !FY + ".zsav"
   /zcompressed.

get file= !Year_dir + "temp-source-episode-file-7-" + !FY + ".zsav".

*Not including 'NextFY' as 2122 file does not exist.
