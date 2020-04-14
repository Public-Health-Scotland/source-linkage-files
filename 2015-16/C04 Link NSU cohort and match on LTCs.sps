* Encoding: UTF-8.
****************************************************************************************************************************
* Match on the non-service-user CHIs.
*****************************************************************************************************************************
* Needs to be matched on like this to ensure no CHIs are marked as NSU when we already have activity for them.
* Get a warning here but should be fine. - Caused by the way we match on NSU.
match files
    /file = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /file = !Extracts + "All_CHIs_20" + !FY + ".zsav"
    /By chi.

* Set up the variables for the NSU CHIs.
* The macros are defined in C01a.
Do if recid = "".
    Compute year = !FY.
    Compute recid = "NSU".
    Compute SMRType = "Non-User".
End if.

***************************************************************************************************************************
Match on LTC Changed_DoBs and dates of LTC incidence (based on hospital incidence only)
***************************************************************************************************************************.
*Match on LTCs Changed_DoBs and date.
match files file = *
    /table = !Extracts_Alt + "LTCs_patient_reference_file-20" + !FY + ".zsav"
    /by chi.

* Recode Changed_DoBs.
Recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd
    hefailure ms parkinsons refailure congen bloodbfo endomet digestive (sysmis = 0).

* Check age and gender before corrections.

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
save outfile = !File + "temp-source-episode-file-3-" + !FY + ".zsav"
    /Drop Changed_DoB
    /zcompressed.
