﻿* Encoding: UTF-8.

*********************************************************************************************************************
 * Link Homelessness to source
*********************************************************************************************************************
 * Create Homelessness flags.
 * Unzip the homelessness file.
Host command = ["unzip " +!Year_dir + "Activity_20" + !FY + ".zip homelessness_for_source-20" + !FY + ".zsav -d " + !Year_dir].

get file = !Year_dir + "homelessness_for_source-20" + !FY + ".zsav"
    /Keep CHI record_keydate1.

Select if CHI ne "".

* Bring back the AssessmentDecisionDate in date format.
Compute AssessmentDecisionDate = DATE.DMY(Mod(record_keydate1, 100), Trunc(Mod(record_keydate1, 10000) / 100), Trunc(record_keydate1 / 10000)).

 * Work out what the maximum number of records per person was.
 * We need this later.
aggregate
    /Presorted
    /Break CHI
    /num_records = n.

aggregate
    /max_records = max(num_records).

 * Assuming it must be <=9.
Alter Type max_records (AMIN).

 * Ugly hack because SPSS...
 * Take the max_records number and generate two macros using this.
 * However the way to do this without Python is to write out to a new file.
do if $casenum = 1.
    write out = !Year_dir + "Temp macro definitions.sps"
        /"Define !maxAssessment() !Concat('AssessmentDecisionDate.', '" max_records "') !EndDefine.".
end if.

* Sort for restructure.
Sort cases by chi AssessmentDecisionDate.

 * Run the file we created above which should define the two macros.
include !Year_dir + "Temp macro definitions.sps".

* Restructure to have single record per CHI.
casestovars
    /ID = chi
    /Drop record_keydate1 num_records max_records
    /autofix = no.

* Match to source.
match files
    /file = !Year_dir + "temp-source-episode-file-2-" + !FY + ".zsav"
    /table = *
    /In = HH_in_FY
    /By chi.

 * Housekeeping.
 * Don't need this as it's still in the zip archive too.
Erase file = !Year_dir + "homelessness_for_source-20" + !FY + ".zsav".
Erase file = !Year_dir + "Temp macro definitions.sps".

Numeric HH_ep  HH_6after_ep  HH_6before_ep (F1.0).
Variable Labels
    HH_in_FY "CHI had an active homelessness application during this financial year"
    HH_ep "CHI had an active homelessness application at time of episode"
    HH_6after_ep "CHI had an active homelessness application at some point 6 months after the end of the episode"
    HH_6before_ep "CHI had an active homelessness application at some point 6 months prior to the start of the episode".

* I'm ignoring PIS (as the dates are not really episode dates), and CH as I'm not sure Care Homes tells us much (and the data is bad).
Do if any(recid, "00B", "01B", "GLS", "DD", "02B", "04B", "AE2", "OoH", "DN", "CMH", "NRS", "HL1").
    Compute HH_ep = 0.
    Compute HH_6after_ep = 0.
    Compute HH_6before_ep = 0.

    * May need to change the numbers here depending on the max number of episodes someone has.
    Do repeat AssessmentDecisionDate = AssessmentDecisionDate.1 to !maxAssessment.
        * If there was an application decision made during episode.
        * HH started during episode.
        If Range(AssessmentDecisionDate, keydate1_dateformat, keydate2_dateformat) HH_ep = 1.

        * If there was an application decision made in the 6 months (180 days) after the episode discharged.
        If Range(AssessmentDecisionDate, keydate2_dateformat + time.days(180), keydate2_dateformat + time.days(1)) HH_6after_ep = 1.

        * If the was an application decision made in the 6 months prior to admission.
        If Range(AssessmentDecisionDate, keydate1_dateformat - time.days(180), keydate1_dateformat - time.days(1)) HH_6before_ep = 1.
    End Repeat.
End if.

If recid = 'HL1' and chi = '' HH_in_FY = 1 . 

*Save Temp.
save outfile = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav" 
   /keep year to cij_delay HH_in_FY to HH_6before_ep
   /zcompressed.
