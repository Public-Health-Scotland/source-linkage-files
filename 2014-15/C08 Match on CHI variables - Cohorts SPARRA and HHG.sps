* Encoding: UTF-8.
********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

*There is no SPARRA or HHG for 2011/12 until 2014/15 .
*Still need to match in demographic cohorts/service use cohorts and read in variables to keep consistent, therefore, .
*        - read in temp file 6.
*       - Match on Demographic cohorts and service use cohorts.
*       - add variables to keep consistent and save as temp 7  .

**********************************************************************************************************.

match files file = !Year_dir + "temp-source-episode-file-6-" + !FY + ".zsav"
    /table = !Cohort_dir + "Demographic_Cohorts_" + !FY + ".zsav"
    /table = !Cohort_dir + "Service_Use_Cohorts_" + !FY+ ".zsav"
    /table = !SPARRA_dir + "SPARRA-20" + !NextFY + ".zsav"
    /Rename
    UPI_Number = chi
    SPARRA_RISK_SCORE = SPARRA_End_FY
    /Drop Psychiatry_Cost Maternity_Cost Geriatric_Cost Elective_Inpatient_Cost Limited_Daycases_Cost Single_Emergency_Cost
    Multiple_Emergency_Cost Routine_Daycase_Cost Outpatient_Cost Prescribing_Cost AE2_Cost
    /Drop End_of_Life Frailty High_CC Maternity MH Substance Medium_CC Low_CC Child_Major Adult_Major Comm_Living
    /by CHI.

* Declare variables for SPARRA and HHG which are not avaliable. 
Numeric 
    SPARRA_Start_FY (F8.0) 
    HHG_Start_FY(F2.0) 
    HHG_End_FY(F2.0).

save outfile = !Year_dir + "temp-source-episode-file-7-" + !FY + ".zsav"
   /zcompressed.

get file= !Year_dir + "temp-source-episode-file-7-" + !FY + ".zsav".


**********************************************************************************************************.

