* Encoding: UTF-8.


***************************************************************************************************************************.
* Determine the most appropriate death date to use.
***************************************************************************************************************************.
*Get file from previous syntax. 
Get file = !Year_dir + "temp-source-episode-file-5-" + !FY + ".zsav". 

* Only keep relevant variables.
match files
    /file  = *
    /table = !Deaths_dir + "all_deaths.zsav"
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
    /file = !Year_dir + "temp-source-episode-file-5-" + !FY + ".zsav"
    /table = *
    /Drop death_date_NRS death_date_CHI death_date_NRS_ep last_activity Has_NRS Activity_after_death CHI_death_date_works CHI_death_date_missing
    /By CHI.

* Clear any deaths which occurred before the start of the FY - allow one year if the only activity is PIS.
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

save outfile = !Year_dir + "temp-source-episode-file-6-" + !FY + ".zsav"
    /Drop Remove_NSU Remove_Death Using_NRS_ep Using_NRS Using_CHI Death_after_FY
    /zcompressed.
get file = !Year_dir + "temp-source-episode-file-6-" + !FY + ".zsav".
*****************************************************************************************************************************.
