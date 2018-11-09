* Encoding: UTF-8.
 * Match on the non-service-user CHIs.
 * Needs to be matched on like this to ensure no CHIs are marked as NSU when we already have activity for them.
 * Get a warning here but should be fine. - Caused by the way we match on NSU.

 * We don't have an NSU extract for 2018/19 yet, should get one at end of FY.

 * match files
    /file = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /file = !Extracts + "All_CHIs_20" + !FY + ".zsav"
    /By chi.
*execute.

* Set up the variables for the NSU CHIs.
* The macros are defined in C01a.
 * Do if recid = "".
 *     Compute year = !FY.
 *     Compute recid = "NSU".
 *     Compute SMRType = "Non-User".
 * End if.

********************Match on LTC flags and dates of LTC incidence (based on hospital incidence only)*****.
*Match on LTCs, deceased flags and date.
match files file = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /Rename(death_date = DN_death_date)
    /table = !Extracts_Alt + "LTCs_patient_reference_file-20" + !FY + ".zsav"
    /table = !Extracts_Alt + "Deceased_patient_reference_file-20" + !FY + ".zsav"
    /by chi.
*execute.

* Recode flags.
Recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd
   hefailure ms parkinsons refailure congen bloodbfo endomet digestive
   deceased (sysmis = 0).

 * Now we have all CHIs and LTC data try to work out a dob if it's missing, then calculate the age.
Do If (~SysMiss(dob)).
    Compute age = DateDiff(!midFY, dob, "years").
Else if chi ne "".
    * Create 2 scratch variables with the possible dobs and ages from the CHI.
    Compute #CHI_dob1 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".19", char.substr(chi, 5, 2)), EDate12).
    Compute #CHI_dob2 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".20", char.substr(chi, 5, 2)), EDate12).
    Compute #CHI_age1 = DateDiff(!midFY, #CHI_dob1, "years").
    Compute #CHI_age2 = DateDiff(!midFY, #CHI_dob2, "years").
    * If either of the dobs is missing use the other one.
    * This only happens with impossible dates because of leap years.
    Do if Sysmiss(#CHI_dob1) AND ~Sysmiss(#CHI_dob2).
        Compute dob = #CHI_dob2.
        Compute age = #CHI_age2.
    Else if Sysmiss(#CHI_dob2) AND ~Sysmiss(#CHI_dob1).
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        * If the younger age is negative, assume they are the older one.
    Else if #CHI_age2 < 0.
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        * If the younger dob means that they have activity before birth assume they are older.
    Else if #CHI_dob2 > keydate1_dateformat.
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        * If the younger dob means that they have an LTC before birth assume they are the older one.
    Else if #CHI_dob2 > Min(arth_date to digestive_date).
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
        * If the congenital defect date lines up with a dob, assume it's correct.
    Else if #CHI_dob2 = congen_date.
        Compute dob = #CHI_dob2.
        Compute age = #CHI_age2.
    Else if #CHI_dob1 = congen_date.
        Compute dob = #CHI_dob1.
        Compute age = #CHI_age1.
      * If the older age makes the person older than 115, assume they are younger (oldest living person is 113).
    Else if #CHI_age1 > 115.
        Compute dob = #CHI_dob2.
        Compute age = #CHI_age2.
    End if.
    * If we still don't have an age, try and fill it in from a previous record.
    Do if (sysmiss(Age) OR age = 999) and Chi = Lag(Chi).
        * Only use the previous one if it matches the CHI.
        Do if #CHI_age1 = Lag(Age) Or #CHI_dob1 = lag(dob).
            Compute dob = #CHI_dob1.
            Compute age = #CHI_age1.
        Else if #CHI_age2 = Lag(Age) Or #CHI_dob2 = lag(dob).
            Compute dob = #CHI_dob2.
            Compute age = #CHI_age2.
        End if.
    End if.
End If.

frequencies age.

 * If any gender codes are missing or 0 recode to CHI gender.
If chi NE "" #CHI_gender = Number(char.SUBSTR(chi, 9, 1), F1.0).

Do If sysmis(gender) OR gender = 0.
   Do If Mod(#CHI_gender, 2) = 1.
      Compute gender = 1.
   Else If Mod(#CHI_gender, 2) = 0.
      Compute gender = 2.
   End If.
End If.

frequencies gender.

********************** update deceased flag and death date using the NRS records ***********************.
 * Note that the deaths file is out-of-date, therefore there are some cases where NRS record exists with date of death, but deceased flag is 0, because this person wasn't in the deceased file.
Do If (CHI NE "").
    Do if recid = "NRS".
        Compute deceased = 1.
        Compute death_date = keydate1_dateformat.
    Else if recid = "DN" and ~Sysmiss(DN_death_date).
        Compute deceased = 1.
        Compute death_date = DN_death_date.
    End if.
End If.

 * Propagate the changes to the rest of the file.
Aggregate outfile=* mode addvariables overwrite=yes
   /Presorted
   /Break CHI
   /deceased = max(deceased)
   /death_date = max(death_date).

 * Update flag and date for blank CHIs.
Do If (chi = " " and recid = "NRS").
   Compute deceased = 1.
   Compute death_date = keydate1_dateformat.
End If.

 * Clean up any deaths which are now outside of the FY.
 * Only needed when updating older files using newer death extracts.
Do If death_date >= Date.DMY(1, 4, Number(!altFY, F4.0) + 1).
   Compute death_date = $sysmis.
   Compute deceased = 0.
End if.   

save outfile = !File + "temp-source-episode-file-3-" + !FY + ".zsav"
    /Drop DN_death_date DateofDeath99
   /zcompressed.

*********************************************************************************.
* Code to identify potentially erroneous dates and replace them with the date of death registered.
Get file = !File + "temp-source-episode-file-3-" + !FY + ".zsav".

* Select records with chi nos.
select if chi NE "".

* Choose records which have activity after death_date is recorded. Records with difference in 7 days between activity and death date is rejected.
select if (death_date LT keydate2_dateformat).

sort cases by chi keydate2_dateformat.
Aggregate
    /Presorted
    /Break chi
    /recid_1 = last(recid)
    /death_date_1 = First(death_date)
    /keydate2_dateformat_1 = last(keydate2_dateformat).

Do if ((recid  = "00B") and (attendance_status = 8 ) and (keydate2_dateformat_1 = keydate2_dateformat)).
    if (chi = lag (chi) and (death_date LT lag(keydate2_dateformat))) Flag = 1.
    if (chi NE lag(chi)) and (death_date LT keydate2_dateformat_1) Flag = 1.
Else if ((recid = "00B" ) and (attendance_status NE 8 ) and (death_date LT keydate2_dateformat_1)).
    Compute Flag = 1.
Else if (recid = "PIS" and death_date LT Date.DMY(1, 4, Number(!altFY, F4.0))).
    Compute Flag = 1.
Else if (death_date LT keydate2_dateformat_1 ).
    Compute Flag = 1.
End if.

Select if Flag = 1.

*aggregate to find last record of activity.
aggregate outfile = *
    /Presorted
    /break chi
    /death_date = Last(death_date)
    /recid = Last(recid)
    /keydate1_dateformat = Last(keydate1_dateformat)
    /keydate2_dateformat = Last(keydate2_dateformat)
    /deathdiag1 to deathdiag11 = Last(deathdiag1 to deathdiag11)
    /deceased = Last(deceased).

select if (DateDiff(keydate2_dateformat, death_date, "days") GT 7).

* Match registered deaths with derived date of death.
match files file = *
    /table = !File + "Death_Date_Registered-20" + !FY + ".zsav"
    /by chi.

* Replace death_date with the latest registered dates of death.
if (death_date + time.days(7) LT Datedeath_GRO) death_date = Datedeath_GRO.

* Some PIS records still have death before start of FY.
If (recid = "PIS" and death_date LT Date.DMY(1, 4, Number(!altFY, F4.0))) death_date = $sysmis.

* If (recid NE "PIS" and (DateDiff(keydate2_dateformat, death_date, "days") LT 7)) death_date = $sysmis.

Select if ~SysMiss(death_date).

save outfile = !File + "Deaths to modify-20" + !FY + ".zsav"
    /Drop Datedeath_GRO
    /Rename (Death_date = Datedeath_GRO)
    /Keep chi Datedeath_GRO
    /zcompressed.

match files file = !File + "temp-source-episode-file-3-" + !FY + ".zsav"
    /Table = !File + "Deaths to modify-20" + !FY + ".zsav"
    /By chi.

* If we have a new death_date to use (Datedeath_GRO) then update it.
* If we updated the date, amend the NRS keydate2 to the new date.
Do If ~SysMiss(Datedeath_GRO).
    Compute death_date = Datedeath_GRO.
    Do If recid = "NRS".
        Compute keydate2_dateformat = Datedeath_GRO.
        Compute record_keydate2 = Number(Replace(String(Datedeath_GRO, Sdate12), "/", ""), F8.0).
    End if.
End if.

* Clean up any deaths which are now outside of the FY.
If death_date GE Date.DMY(1, 4, Number(!altFY, F4.0) + 1) death_date = $sysmis.

* Recalculate deceased.
Do if (~Sysmiss(death_date)).
    Compute deceased = 1.
Else.
    Compute deceased = 0.
End if.

save outfile = !File + "temp-source-episode-file-4-" + !FY + ".zsav"
    /Drop Datedeath_GRO
    /zcompressed.
get file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".
*****************************************************************************************************************************.
       
