* Encoding: UTF-8.
 * Create Homelessness flags.
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

* Sort for restructure.
Sort cases by chi AssessmentDecisionDate.

* Restructure to have single record per CHI.
casestovars
    /ID = chi
    /Drop record_keydate1 record_keydate2.

* Match to source.
match files
    /file = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /table = *
    /In = HH
    /By chi.


Numeric HH_in_FY HH_ep  HH_6after_ep  HH_6before_ep (F1.0).
Variable Labels
    HH_in_FY "CHI had an active homelessness application during this financial year"
    HH_ep "CHI had an active homelessness application at time of episode"
    HH_6after_ep "CHI had an active homelessness application at some point 6 months after the end of the episode"
    HH_6before_ep "CHI had an active homelessness application at some point 6 months prior to the start of the episode".

* I'm ignoring PIS (as the dates are not really episode dates), and CH as I'm not sure Care Homes tells us much (and the data is bad).
Do if any(recid, "00B", "01B", "GLS", "DD", "02B", "04B", "AE2", "OoH", "DN", "CMH", "NRS", "HL1").
    Compute HH_in_FY = 0.
    Compute HH_ep = 0.
    Compute HH_6after_ep = 0.
    Compute HH_6before_ep = 0.

    * May need to change the numbers here depending on the max number of episodes someone has.
    Do repeat HH_start = AssessmentDecisionDate.1 to AssessmentDecisionDate.6
        /HH_end = CaseClosedDate.1 to CaseClosedDate.6.

        * If there was an active application at any point in the FY.
        If Range(HH_start, !startFY, !endFY)
            or Range(HH_end, !startFY, !endFY)
            or Range(!startFY, HH_start, HH_end)
            or (HH_start <= !endFY and Missing(HH_end)) HH_in_FY = 1.

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

crosstabs recid by HH_in_FY.
crosstabs recid by HH_ep.
crosstabs recid by HH_6after_ep.
crosstabs recid by HH_6before_ep.

* Match on the non-service-user CHIs.
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

********************Match on LTC Changed_DoBs and dates of LTC incidence (based on hospital incidence only)*****.
*Match on LTCs Changed_DoBs and date.
match files file = *
    /table = !Extracts_Alt + "LTCs_patient_reference_file-20" + !FY + ".zsav"
    /by chi.

* Recode Changed_DoBs.
Recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd
    hefailure ms parkinsons refailure congen bloodbfo endomet digestive (sysmis = 0).

* Check age and gender before corrections.
Frequencies age gender.
Numeric Changed_DoB (F2.0).
Compute Changed_DoB = 0.

* Now we have all CHIs and LTC data try to work out a dob if it's missing, then calculate the age.
Do if chi ne "".
    * Create 2 scratch variables with the possible dobs and ages from the CHI.
    * We will overwrite existing DoBs in some cases.
    Compute #CHI_dob1 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".19", char.substr(chi, 5, 2)), EDate12).
    Compute #CHI_dob2 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".20", char.substr(chi, 5, 2)), EDate12).
    Compute #CHI_age1 = DateDiff(!midFY, #CHI_dob1, "years").
    Compute #CHI_age2 = DateDiff(!midFY, #CHI_dob2, "years").

    * If they already have a DoB which could be valid, leave it alone.
    Do if dob = #CHI_dob1.
        Compute age = #CHI_age1.
        Compute Changed_DoB = 1.
    Else if dob = #CHI_dob2.
        Compute age =  #CHI_age2.
        Compute Changed_DoB = 1.

        * If either of the dobs is missing use the other one.
        * This only happens with impossible dates because of leap years.
    Else if Sysmiss(#CHI_dob1) AND Not(Sysmiss(#CHI_dob2)).
        Compute dob = #CHI_dob2.
        Compute age = #CHI_age2.
        Compute Changed_DoB = 2.
    Else if Sysmiss(#CHI_dob2) AND Not(Sysmiss(#CHI_dob1)).
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        Compute Changed_DoB = 2.

        * If the younger age is negative, assume they are the older one.
        * We now know that age1 >= 100 and 0 <= age2 < 100.
    Else if #CHI_age2 < 0.
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        Compute Changed_DoB = 3.

        * If the younger dob means that they have activity before birth assume they are older.
    Else if #CHI_dob2 > keydate1_dateformat.
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        Compute Changed_DoB = 4.

        * If the younger dob means that they have an LTC before birth assume they are the older one.
    Else if #CHI_dob2 > Min(arth_date to digestive_date).
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        Compute Changed_DoB = 5.

        * If the person has a maternity record assume the younger date.
    Else if #CHI_age1 > 3 and recid = "02B".
        Compute dob = #CHI_dob2.
        Compute age = #CHI_age2.
        Compute Changed_DoB = 6.

        * If the person has a GLS record, and the age is broadly correct, assume the older date.
    Else if range(#CHI_age1, 50, 130) and (recid = "GLS").
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        Compute Changed_DoB = 7.

        * If the congenital defect date lines up with a dob, assume it's correct.
    Else if #CHI_dob2 = congen_date.
        Compute dob = #CHI_dob2.
        Compute age = #CHI_age2.
        Compute Changed_DoB = 8.
    Else if #CHI_dob1 = congen_date.
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        Compute Changed_DoB = 8.

        * If the older age makes the person older than 113, assume they are younger (oldest living person is 113).
    Else if #CHI_age1 > 113.
        Compute dob = #CHI_dob2.
        Compute age = #CHI_age2.
        Compute Changed_DoB = 9.
    End if.
    

    * If we still don't have an age, try and fill it in from a previous record.
    Do if sysmiss(Age) and CHI = Lag(CHI).
        * Only use the previous one if it matches the CHI.
        Do if #CHI_age1 = Lag(Age) Or #CHI_dob1 = lag(dob).
            Compute dob = #CHI_dob1.
            Compute age = #CHI_age1.
            Compute Changed_DoB = 10.
        Else if #CHI_age2 = Lag(Age) Or #CHI_dob2 = lag(dob).
            Compute dob = #CHI_dob2.
            Compute age = #CHI_age2.
            Compute Changed_DoB = 10.
        End if.
    End if.
End If.

* Fill in ages for any that are left.
Compute age = DateDiff(!midFY, dob, "years").

* If any gender codes are missing or 0 recode to CHI gender.
If chi NE "" #CHI_gender = Number(char.SUBSTR(chi, 9, 1), F1.0).

Do If sysmis(gender) OR gender = 0.
    Do If Mod(#CHI_gender, 2) = 1.
        Compute gender = 1.
    Else If Mod(#CHI_gender, 2) = 0.
        Compute gender = 2.
    End If.
End If.

Value labels Changed_DoB
    0 "No change"
    1 "Original DoB good"
    2 "Leap year DoB"
    3 "Younger dob gives negative age"
    4 "Activity before birth"
    5 "LTC before birth"
    6 "Maternity record"
    7 "GLS record"
    8 "Congen at birth"
    9 "Unrealistically old age"
    10 "Copied from previous record".

* Save here whist we work on a subset of the file.
xsave outfile = !File + "temp-source-episode-file-3-" + !FY + ".zsav"
    /Drop Changed_DoB
    /zcompressed.

* Check again - we don't expect too many changes.
Frequencies age gender Changed_DoB.

***************************************************************************************************************************.
* Determine the most appropriate death date to use.
***************************************************************************************************************************.
* Only keep relevant variables.
match files
    /file  = !File + "temp-source-episode-file-3-" + !FY + ".zsav"
    /table = !Extracts_Alt + "All Deaths.zsav"
    /Keep year recid keydate1_dateformat keydate2_dateformat SMRType CHI gender dob age
    attendance_status
    death_date death_date_NRS death_date_CHI death_date
    /By CHI.

* Remove blank CHIs for now.
Select if CHI NE "".

* Work out last activity dates.
* Don't count CMH, DN, CH as we can't be sure about the quality.
Do If Not(any(recid, "PIS", "00B", "NRS", "DN", "CMH", "CH")).
    * Normal case - valid activity.
    Compute valid_activity = keydate2_dateformat.
Else if recid = "NRS".
    * Latest record is a death record.
    Compute valid_activity = keydate1_dateformat.
    Compute death_date_NRS_ep = keydate1_dateformat.
Else if recid = "00B".
    * Outpatients - Could be a DNA.
    If attendance_status NE 8 valid_activity = keydate2_dateformat.
Else if recid = "PIS".
    * For this we'll count PIS activity as the first of the year.
    Compute valid_activity = date.dmy(1, 4, Number(!altFY, F4.0)).
End if.

* Create some Changed_DoBs.
Numeric NSU Has_NRS (F1.0).
Compute NSU = 0.
Compute Has_NRS = 0.
If recid = "NSU" NSU = 1.
If recid = "NRS" Has_NRS = 1.

* Find the latest activity for each CHI.
aggregate outfile = *
    /Break CHI NSU death_date_NRS death_date_CHI death_date
    /death_date_NRS_ep = First(death_date_NRS_ep)
    /last_activity = max(valid_activity)
    /Has_NRS = max(Has_NRS).

* Change dates to a readable form.
Alter Type last_activity death_date_NRS_ep (Date12).

* Set up some Changed_DoBs.
Numeric Activity_after_death CHI_death_date_works CHI_death_date_missing Remove_NSU Using_NRS Using_CHI Using_NRS_ep (F1.0).

* If they have an NRS death episode which works we should use this date.
Compute Using_NRS_ep = 0.
Do if Has_NRS and death_date_NRS_ep >= last_activity.
    Compute death_date = death_date_NRS_ep.
    Compute Using_NRS_ep = 1.
End if.

* Changed_DoB for activity after death.
If Datediff(last_activity, death_date, "days") GT 3 Activity_after_death = 1.
* Changed_DoB if the CHI death date is after the last activity.
If death_date_CHI >= last_activity CHI_death_date_works = 1.
* Changed_DoB if there is no CHI death date.
If sysmis(death_date_CHI) CHI_death_date_missing = 1.

* Initialise Changed_DoBs.
Compute Remove_NSU = 0.
Compute Using_NRS = 0.
Compute Using_CHI = 0.

* For checking later, record if we are using the CHI or NRS death date.
If death_date = death_date_NRS Using_NRS = 1.
If death_date = death_date_CHI and Using_NRS = 0 Using_CHI = 1.

* If they are an NSU with a death before the FY, we'll Changed_DoB them for removal.
If NSU = 1 and death_date < date.dmy(1, 4, Number(!altfy, F4.0)) Remove_NSU = 1.

* If the current death date doesn't work but the CHI death date does, use that and update the Changed_DoB so we know what happened.
If Activity_after_death and CHI_death_date_works death_date = death_date_CHI.
If Activity_after_death and CHI_death_date_works Using_CHI = 2.

* If the current death date doesn't work and the CHI death date is blank, use that and update the Changed_DoB so we know what happened.
If Activity_after_death and CHI_death_date_missing death_date = death_date_CHI.
If Activity_after_death and CHI_death_date_missing Using_CHI = 3.

* Update the Using_NRS Changed_DoB.
If Using_CHI > 0 Using_NRS = 0.

* Clear any deaths which happened after the end of the FY.
Numeric Death_after_FY (F1.0).
Compute Death_after_FY = 0.
If death_date > date.dmy(31, 3, Number(!altFY, F4.0) + 1) Death_after_FY = 1.
If death_date > date.dmy(31, 3, Number(!altFY, F4.0) + 1) death_date = $sysmis.

* Keep only CHIs with a death_date - for linking back to main file.
select if Not(sysmis(death_date)).

* Match back to SLF.
match files
    /file = !File + "temp-source-episode-file-3-" + !FY + ".zsav"
    /table = *
    /Drop death_date_NRS death_date_CHI death_date_NRS_ep last_activity Has_NRS Activity_after_death CHI_death_date_works CHI_death_date_missing
    /By CHI.

* Clear any deaths which occured before the start of the FY - allow one year if the only activity is PIS.
Numeric Remove_Death (F1.0).
Compute Remove_Death = 0.
Do if recid NE "PIS".
    If death_date < date.dmy(1, 4, Number(!altFY, F4.0) - 1) Remove_death = 2.
Else.
    If death_date < date.dmy(1, 4, Number(!altFY, F4.0) - 2) Remove_death = 1.
End if.

aggregate outfile = * Mode = AddVariables Overwrite = Yes
    /Break CHI
    /Remove_death = Max(Remove_death).

If Remove_Death NE 0 death_date = $sysmis.

* Create the deceased Changed_DoB.
Numeric deceased (F1.0).
Compute deceased = 0.
If Not(sysmis(death_date)) deceased = 1.

* Set the 'new' variables for the episodes with no CHIs.
Do if CHI = "".
    Compute death_date = $sysmis.
    Compute deceased = 0.
    Do if recid = "NRS".
        Compute death_date = keydate1_dateformat.
        Compute deceased = 1.
    End if.
End if.

* Set date 2 of NRS to be the death date.
Do if recid = "NRS".
    Compute keydate2_dateformat = death_date.
    Compute record_keydate2  = xdate.mday(death_date) + 100 * xdate.month(death_date) + 10000 * xdate.year(death_date).
End if.

* Get rid of the NSUs which have a death_date before the start of the FY.
Recode Remove_NSU (sysmis = 0).
select if Remove_NSU = 0.

save outfile = !File + "temp-source-episode-file-4-" + !FY + ".zsav"
    /Drop Remove_NSU Remove_Death Using_NRS_ep Using_NRS Using_CHI Death_after_FY
    /zcompressed.
get file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".
*****************************************************************************************************************************.
       
