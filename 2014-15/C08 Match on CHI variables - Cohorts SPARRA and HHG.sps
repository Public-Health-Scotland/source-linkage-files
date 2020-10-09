* Encoding: UTF-8.
********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

There is no SPARRA or HHG for 2011/12 until 2014/15 
Still need to match in demographic cohorts/service use cohorts and read in variables to keep consistent, therefore, 
        - read in temp file 6
        - Match on Demographic cohorts and service use cohorts
        - add variables to keep consistent and save as temp 7  

**********************************************************************************************************.

match files file = !File + "temp-source-episode-file-6-" + !FY + ".zsav"
    /table = !File + "Demographic_Cohorts_" + !FY + ".zsav"
    /table = !File + "Service_Use_Cohorts_" + !FY+ ".zsav"
    /Drop Psychiatry_Cost Maternity_Cost Geriatric_Cost Elective_Inpatient_Cost Limited_Daycases_Cost Single_Emergency_Cost
    Multiple_Emergency_Cost Routine_Daycase_Cost Outpatient_Cost Prescribing_Cost AE2_Cost
    /Drop End_of_Life Frailty High_CC Maternity MH Substance Medium_CC Low_CC Child_Major Adult_Major Comm_Living
    /by CHI.

Numeric SPARRA_End_FY HHG_End_FY (F2.0).

save outfile = !File + "temp-source-episode-file-7-" + !FY + ".zsav"
   /zcompressed.

get file= !File + "temp-source-episode-file-7-" + !FY + ".zsav".


**********************************************************************************************************.

