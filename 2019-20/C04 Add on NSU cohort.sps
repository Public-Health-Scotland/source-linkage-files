﻿* Encoding: UTF-8.

**********************************************************************************************************************************
Dummy file for latest year without an NSU cohort
**********************************************************************************************************************************.
*Get previous file saved at end of homelessness. 
Get file = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav" .

*save file as next temp ep file. 
Save outfile = !Year_dir + "temp-source-episode-file-4-" + !FY + ".zsav" 
/zcompressed.  

*Delete previous file. 
Erase file = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav" .

********************************************************************************************************************************
* Match on the non-service-user CHIs 
********************************************************************************************************************************
* Needs to be matched on like this to ensure no CHIs are marked as NSU when we already have activity for them.
* Get a warning here but should be fine. - Caused by the way we match on NSU.
*match files
    /file = !File + "temp-source-episode-file-3-" + !FY + ".zsav" 
    /file = !Extracts + "All_CHIs_20" + !FY + ".zsav"
    /Drop AssessmentDecisionDate.1 to HH
    /By chi.

* Set up the variables for the NSU CHIs.
* The macros are defined in C01a.
*Do if recid = "".
  *  Compute year = !FY.
    *Compute recid = "NSU".
    *Compute SMRType = "Non-User".
*End if.

*Save Temp.
*save outfile = !File + "temp-source-episode-file-4-" + !FY + ".zsav" 
/zcompressed.  

**********************************************************************************************************************************

