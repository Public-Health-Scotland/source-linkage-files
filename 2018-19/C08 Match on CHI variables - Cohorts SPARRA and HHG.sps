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

match files file = !File + "temp-source-episode-file-6-" + !FY + ".zsav"
    /table = !File + "Demographic_Cohorts_" + !FY + ".zsav"
    /table = !File + "Service_Use_Cohorts_" + !FY+ ".zsav"
    /table = !Extracts_Alt + "SPARRA/SPARRA-20" + !FY + ".zsav"
    /Rename
    UPI_Number = chi
    SPARRA_RISK_SCORE = SPARRA_Start_FY
    /table = !Extracts_Alt + "HHG/HHG-20" + !FY + ".zsav"
    /Rename
    UPI_Number = chi
    HHG_SCORE = HHG_Start_FY
    /table = !Extracts_Alt + "SPARRA/SPARRA-20" + !NextFY + ".zsav"
    /Rename
    UPI_Number = chi
    SPARRA_RISK_SCORE = SPARRA_End_FY
    /table = !Extracts_Alt + "HHG/HHG-20" + !NextFY + ".zsav"
    /Rename
    UPI_Number = chi
    HHG_SCORE = HHG_End_FY
    /Drop Psychiatry_Cost Maternity_Cost Geriatric_Cost Elective_Inpatient_Cost Limited_Daycases_Cost Single_Emergency_Cost
    Multiple_Emergency_Cost Routine_Daycase_Cost Outpatient_Cost Prescribing_Cost AE2_Cost
    /Drop End_of_Life Frailty High_CC Maternity MH Substance Medium_CC Low_CC Child_Major Adult_Major Comm_Living
    /by CHI.

save outfile = !File + "temp-source-episode-file-7-" + !FY + ".zsav"
    /zcompressed.

get file= !File + "temp-source-episode-file-7-" + !FY + ".zsav".
