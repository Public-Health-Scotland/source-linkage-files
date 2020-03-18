* Encoding: UTF-8.

*********************************************************************************************************************
 * Link Homelessness to source
*********************************************************************************************************************
 * Create Homelessness flags.
 * Unzip the homelessness file.
Host command = ["unzip '" + !File + "Activity.zip' 'homelessness_for_source-20" + !FY + ".zsav' -d '" + !File + "'"].

get file = !File + "homelessness_for_source-20" + !FY + ".zsav"
    /Keep CHI record_keydate1 record_keydate2.

Select if CHI ne "".

* Bring back the AssessmentDecisionDate in date format.
Compute AssessmentDecisionDate = DATE.DMY(Mod(record_keydate1, 100), Trunc(Mod(record_keydate1, 10000) / 100), Trunc(record_keydate1 / 10000)).
* Deal with empty end dates.
Do if SysMiss(record_keydate2).
    Compute CaseClosedDate = $sysmis.
Else.
    Compute CaseClosedDate = DATE.DMY(Mod(record_keydate2, 100), Trunc(Mod(record_keydate2, 10000) / 100), Trunc(record_keydate2 / 10000)).
End if.
Alter type AssessmentDecisionDate CaseClosedDate (Date12).

 * Work out what the maximum number of records per person was.
 * We need this later.
aggregate
    /Presorted
    /Break CHI
    /num_records = n.

aggregate
    /max_records = max(num_records).

 * Assuming it must be <=9.
Alter Type max_records (F1.0).

 * Ugly hack because SPSS...
 * Take the max_records number and generate two macros using this.
 * However the way to do this without Python is to write out to a new file.
do if $casenum = 1.
    write out = !File + "Temp macro definitions.sps"
        /"Define !maxAssesment() !Concat('AssessmentDecisionDate.', '" max_records "') !EndDefine."
        /"Define !maxClose() !Concat('CaseClosedDate.', '" max_records "') !EndDefine.".
end if.

* Sort for restructure.
Sort cases by chi AssessmentDecisionDate.

 * Run the file we created above which should define the two macros.
include !File + "Temp macro definitions.sps".

* Restructure to have single record per CHI.
casestovars
    /ID = chi
    /Drop record_keydate1 record_keydate2 num_records max_records.

* Match to source.
match files
    /file = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /table = *
    /In = HH_in_FY
    /By chi.

 * Housekeeping.
 * Don't need this as it's still in the zip archive too.
Erase file = !File + "homelessness_for_source-20" + !FY + ".zsav".
Erase file = !File + "Temp macro definitions.sps".

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
    Do repeat HH_start = AssessmentDecisionDate.1 to !maxAssesment
        /HH_end = CaseClosedDate.1 to !maxClose.

        * If there was an active application during episode.
        * HH started during episode or HH ended during episode or HH was ongoing at start of episode.
        If Range(HH_start, keydate1_dateformat, keydate2_dateformat)
            or Range(HH_end, keydate1_dateformat, keydate2_dateformat)
            or Range(keydate1_dateformat, HH_start, HH_end)
            or (HH_start <= keydate2_dateformat and Missing(HH_end)) HH_ep = 1.

        * If there was an active application in the 6 months after the discharge of the episode.
        If Range(HH_start, keydate2_dateformat + time.days(180), keydate2_dateformat + time.days(1))
            or Range(HH_end, keydate2_dateformat + time.days(180), keydate2_dateformat + time.days(1))
            or Range(keydate2_dateformat + time.days(180), HH_start, HH_end)
            or (HH_start <= keydate2_dateformat + time.days(180) and Missing(HH_end)) HH_6after_ep = 1.

        * If the was an active episode in the 6 mo (180 days) prior.
        If Range(HH_start, keydate1_dateformat - time.days(180), keydate1_dateformat - time.days(1))
            or Range(HH_end, keydate1_dateformat - time.days(180), keydate1_dateformat - time.days(1))
            or Range(keydate1_dateformat - time.days(180), HH_start, HH_end)
            or (HH_start <= keydate1_dateformat and Missing(HH_end)) HH_6before_ep = 1.
    End Repeat.
End if.

If recid = 'HL1' and chi = '' HH_in_FY = 1 . 

********************************************************************************************************************************
* Match on the non-service-user CHIs.
********************************************************************************************************************************
* Needs to be matched on like this to ensure no CHIs are marked as NSU when we already have activity for them.
* Get a warning here but should be fine. - Caused by the way we match on NSU.
match files
    /file = * 
    /file = !Extracts + "All_CHIs_20" + !FY + ".zsav"
    /Drop AssessmentDecisionDate.1 to HH
    /By chi.

* Set up the variables for the NSU CHIs.
* The macros are defined in C01a.
Do if recid = "".
    Compute year = !FY.
    Compute recid = "NSU".
    Compute SMRType = "Non-User".
End if.

*Save Temp.
save outfile = !File + "temp-source-episode-file-3-" + !FY + ".zsav" 
/zcompressed.  



