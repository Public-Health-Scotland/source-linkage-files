* Encoding: UTF-8.

get file = !File + "temp-source-episode-file-1-" + !FY + ".zsav"
    /Keep year recid keydate1_dateformat keydate2_dateformat CIJ_start_date CIJ_end_date
    chi gender dob age gpprac postcode lca datazone
    hbtreatcode location spec tadm
    cij_marker cij_ipdc cij_admtype cij_pattype_code cij_pattype cij_adm_spec cij_dis_spec cij_ppa.

* Keep records that have a chi, and a cij_marker.
select if chi NE "".
select if any(recid, "01B", "02B", "04B", "GLS").

 * Do a temp save here as it speeds things up (because SPSS is weird).
save outfile =  !File + "slf_reduced_for_DD.zsav"
    /zcompressed.
get file =  !File + "slf_reduced_for_DD.zsav".

* Create a copy of the CIJ marker.
String temp_cij_marker (A5).
Compute temp_cij_marker = cij_marker.

* Set blank to be user missing (important for later).
Missing Values temp_cij_marker ("     ").

* Add all files together.
add files
    /File = *
    /File = !Extracts + "DD_LinkageFile-20" + !FY + ".zsav"
    /By CHI.

* Create an order variable to make DD records appear after others.
if any(recid, "00B", "01B", "02B", "04B", "GLS") order = 1.
if recid = "DD" order = 2.

* Remove any DD records which don't match a chi in the file.
sort cases by chi order.

Select If Not(recid = "DD" AND CHI NE lag(CHI)).

save outfile = !File + "DD_Temp-1.zsav"
    /zcompressed.

get file = !File + "DD_Temp-1.zsav".

* Sort so that DD is roughly where we expect it to fit.
sort cases by chi keydate1_dateformat order.

* Capture the Mental Health delays with no end dates.
Do if chi = lag(chi) and recid = "DD" and lag(recid) = "04B" and sysmiss(keydate2_dateformat)
    and sysmiss(lag(keydate2_dateformat)) and keydate1_dateformat GE lag(CIJ_start_date) - time.days(1).
    Compute Flag_8 = 1.
    If keydate1_dateformat GE lag(CIJ_start_date) Flag_8 = 2.
    Compute temp_cij_marker = lag(temp_cij_marker).
    Compute CIJ_start_date = lag(CIJ_start_date).
    Compute CIJ_end_date = lag(CIJ_end_date).
End if.

* Use Min and Max CIJ dates to fill in temp_cij_marker - where possible - DD episodes with no CIJ.
Do if chi = lag(chi) and missing(temp_cij_marker).
    * Create flags simply to check rows where CIJ markers are being added.
    * don't expect any of these.
    compute Flag_1 = 0.
    Do if keydate1_dateformat = lag(keydate2_dateformat) and recid ne "DD".
        compute temp_cij_marker = lag(temp_cij_marker).
        Compute CIJ_start_date = lag(CIJ_start_date).
        Compute CIJ_end_date = lag(CIJ_end_date).
        compute Flag_1 = 1.
    Else if recid = "DD".
        Compute Flag_2 = 0.
        Compute Flag_3 = 0.
        Compute Flag_4 = 0.
        Compute no_cij = 0.
        * Flag DD records which fit entirely within a CIJ. Allow one day.
        Do if (keydate1_dateformat GE lag(CIJ_start_date) - time.days(1)) and (keydate2_dateformat LE lag(CIJ_end_date) + time.days(1)).
            compute temp_cij_marker = lag(temp_cij_marker).
            compute Flag_2 = 1.
            If (keydate1_dateformat GE lag(CIJ_start_date)) and (keydate2_dateformat LE lag(CIJ_end_date)) Flag_2 = 2.
            compute Flag_6 = 0.
            * If we know the date has changed flag it and work out how off that dates are.
            Do if Ammended_Dates = 1.
                Compute Flag_6 = 1.
                Compute days_wrong = DateDiff(lag(CIJ_end_date), keydate2_dateformat, "days").
            End if.
            * If DD record date starts within hospital dates but ends afterwards.
        Else if Range(keydate1_dateformat, lag(CIJ_start_date) - time.days(1), lag(CIJ_end_date) + time.days(1)) and keydate2_dateformat GT lag(CIJ_end_date).
            Compute Flag_3 = 1.
            If Range(keydate1_dateformat, lag(CIJ_start_date), lag(CIJ_end_date)) and keydate2_dateformat GT lag(CIJ_end_date) Flag_3 = 2.
            Compute days_wrong = DateDiff(keydate2_dateformat, lag(CIJ_end_date), "days").
            Compute Flag_7 = 0.
            Compute Flag_9 = 0.
            * If we know the date has changed flag it and work out how off that dates are.
            Do if Ammended_Dates = 1 AND xdate.month(MonthFlag) = xdate.month(lag(CIJ_end_date)).
                Compute Flag_7 = 1.
                If Range(keydate1_dateformat, lag(CIJ_start_date), lag(CIJ_end_date)) Flag_7 = 2.
                Compute temp_cij_marker = lag(temp_cij_marker).
                * Don't make the dates give it a negative stay (in cases where the match was +- 1 day).
                Compute keydate2_dateformat = Max(keydate1_dateformat, lag(CIJ_end_date)).
                * If it's only one day out then we'll count it as matching the CIJ.
            Else if days_wrong = 1.
                Compute Flag_9 = 1.
                Compute temp_cij_marker = lag(temp_cij_marker).
            End if.
        End if.
    End if.
End if.

* Sort in the opposite direction.
sort cases by chi (A) keydate1_dateformat (D) order (A).
* If DD record date ends within CIJ dates but starts before.
Do if recid = 'DD' and chi = lag(chi) and missing(temp_cij_marker).
    Compute Flag_4 = 0.
    Do if keydate1_dateformat LE lag(CIJ_start_date) and Range(keydate2_dateformat, lag(CIJ_start_date) - time.days(1), lag(CIJ_end_date) + time.days(1)).
        Compute Flag_4 = 1.
        Compute days_wrong = DateDiff(lag(CIJ_start_date), keydate1_dateformat, "days").
        If keydate1_dateformat LE lag(CIJ_start_date) and Range(keydate2_dateformat, lag(CIJ_start_date), lag(CIJ_end_date)) Flag_4 = 2.
        Compute Flag_10 = 0.
        * If it's only one day out, count it as matching the CIJ.
        Do if days_wrong = 1.
            Compute Flag_10 = 1.
            Compute temp_cij_marker = lag(temp_cij_marker).
        End if.
    End if.
End if.

* Set the CIJ variables (for the DD's we have assigned a CIJ).
* Also take other variables of use.
Missing Values Postcode datazone LCA (" ").

sort cases by CHI temp_cij_marker order.
aggregate outfile = * MODE = ADDVARIABLES OVERWRITE = YES
    /Presorted
    /break CHI temp_cij_marker
    /CIJ_start_date CIJ_end_date cij_ipdc cij_admtype cij_pattype_code cij_pattype cij_adm_spec cij_dis_spec cij_ppa
    = First(CIJ_start_date CIJ_end_date cij_ipdc cij_admtype cij_pattype_code cij_pattype cij_adm_spec cij_dis_spec cij_ppa)
    /DD_gender DD_dob DD_age DD_gpprac DD_postcode DD_lca DD_datazone
    = Last(gender dob age gpprac postcode lca datazone).

 * Fill in the variables for the DD.
 * This will keep the value which was on the DD record if it was there, otherwise it will be filled in from the latest episode in the CIJ to have valid data.
Do if recid = "DD".
    Compute gender = DD_gender.
    Compute dob = DD_dob.
    Compute age = DD_age.
    Compute gpprac = DD_gpprac.
    Compute postcode = DD_postcode.
    Compute lca = DD_lca.
    Compute datazone = DD_datazone.
End if.

* Sort back to a 'normal' order.
sort cases by chi keydate1_dateformat order.
* If we didn't match the DD to a CIJ it won't have this info.
* Use the info from the closest CIJ to the DD.
Do if recid = "DD" and chi = lag(chi).
    If Missing(gender) gender = lag(DD_gender).
    If Missing(dob) dob = lag(DD_dob).
    If Missing(age) age = lag(DD_age).
    If Missing(gpprac) gpprac = lag(DD_gpprac).
    If Missing(postcode) postcode = lag(DD_postcode).
    If Missing(lca) lca = lag(DD_lca).
    If Missing(datazone) datazone = lag(DD_datazone).
End if.

* Labels for the flags (just for info now).
Variable labels
    Flag_1 "1 - CIJ added to non-DD record"
    Flag_2 "2 - CIJ added to DD that falls within CIJ period"
    Flag_3 "3 - DD record that starts within CIJ period but ends after"
    Flag_4 "4 - DD record that starts before CIJ period but ends during"
    Flag_6 "6 - DD that matches CIJ but had end-date changed"
    Flag_7 "7 - DD with changed dates pushing it over the CIJ dates"
    Flag_8 "8 - DD records linked to MH with no end dates"
    no_cij "no-CIJ attached".

* Flag DDs which don't seem to have an associated hospital stay.
if missing(temp_cij_marker) and recid = "DD" no_cij = 1.

save outfile = !File + "DD_Temp-2.zsav"
    /zcompressed.
get file = !File + "DD_Temp-2.zsav".

select if recid = "DD".

* Group the flags into a single quality variable.
* There is a matrix showing the map between DD_Quality and the flags.
* See - \\Freddy\DEPT\PHIBCS\PHI\Health & Social Care\Topics\Linkage\Reference Files\DD flags matrix.xlsx.
String DD_Quality (A3).
Variable Labels DD_Quality "Indication of how well a delay episode could be matched to a CIJ episode".
Value Labels DD_quality
    "1"	"Accurate Match - (1)"
    "1P"	"Accurate Match (allowing +-1 day) - (1P)"
    "1A"	"Accurate Match (has an assumed  end date) - (1A)"
    "1AP"	"Accurate Match (allowing +-1 day and has an assumed end date) - (1AP)"
    "2"	"Starts in CIJ - (2)"
    "2D"	"Starts in CIJ (ends one day after) - (2D)"
    "2DP"	"Starts in CIJ (allowing +-1 day and ends one day after) - (2DP)"
    "2A"	"Starts in CIJ (Accurate Match after correcting assumed end date) - (2A)"
    "2AP"	"Starts in CIJ (Accurate Match (allowing +-1 day) after correcting assumed end date) - (2AP)"
    "3"	"Ends in CIJ - (3)"
    "3D"	"Ends in CIJ (starts one day before) - (3D)"
    "3DP"	"Ends in CIJ (allowing +-1 day and starts one day before) - (3DP)"
    "4"	"Matches unended MH record - (4)"
    "4P"	"Matches unended MH record (allowing -1 day) - (4P)"
    "-"           "No Match (We don't keep these)".

Do if recid = "DD".
    Do if Flag_2 = 2 and Flag_6 = 0.
        Compute DD_Quality = "1".
    Else if Flag_2 = 1 and Flag_6 = 0.
        Compute DD_Quality = "1P".
    Else if Flag_2 = 2 and Flag_6 = 1.
        Compute DD_Quality = "1A".
    Else if Flag_2 = 1 and Flag_6 = 1.
        Compute DD_Quality = "1AP".
    Else if any(Flag_4, 1, 2) and Flag_10 = 0.
        Compute DD_Quality = "3".
    Else if Flag_4 = 2 and Flag_10 = 1.
        Compute DD_Quality = "3D".
    Else if Flag_4 = 1 and Flag_10 = 1.
        Compute DD_Quality = "3DP".
    Else if any(Flag_3, 1, 2) and Flag_7 = 0 and Flag_9 = 0.
        Compute DD_Quality = "2".
    Else if Flag_3 = 2 and Flag_7 = 0 and Flag_9 = 1.
        Compute DD_Quality = "2D".
    Else if Flag_3 = 1 and Flag_7 = 0 and Flag_9 = 1.
        Compute DD_Quality = "2DP".
    Else if Flag_3 = 2 and Flag_7 = 2.
        Compute DD_Quality = "2A".
    Else if Flag_3 = 1 and Flag_7 = 1.
        Compute DD_Quality = "2AP".
    Else if Flag_8 = 2.
        Compute DD_Quality = "4".
    Else if Flag_8 = 1.
        Compute DD_Quality = "4P".
    Else.
        Compute DD_Quality = "-".
    End if.
End if.

* Final checks before the DD records are ready to be separated and added back to source.
crosstabs DD_Quality by no_cij.
Frequencies DD_Quality no_cij.

sort cases by LCA.
Split file Separate by LCA.

Frequencies DD_Quality.

aggregate
    /Presorted
    /break lca
    /UnMatched = SUM(no_cij)
    /DDs = N.

compute pct_unmatched = UnMatched / DDs * 100.
Frequencies pct_unmatched.

Split file off.
* Drop records which are no good.
Select if DD_Quality NE "-".

sort cases by chi keydate1_dateformat.

* Save out records with changed end dates to feed back to the DD team.
Temporary.
Select if any(Flag_7, 1, 2).
save outfile = !File + "DD episodes with corrected end-dates - 20" + !FY + ".zsav"
    /Rename (keydate1_dateformat keydate2_dateformat = RDD Delay_End_Date)
    /keep year chi DD_Responsible_LCA RDD Delay_End_Date temp_cij_marker cij_ipdc cij_admtype cij_pattype_code cij_pattype cij_adm_spec cij_dis_spec
    MONTHFLAG OriginalAdmissionDate Delay_End_Reason Primary_Delay_Reason Secondary_Delay_Reason
    /zcompressed.


* This Python program will call the 'BedDaysPerMonth' macro (Defined in A01) for each month in FY order.
Begin Program.
from calendar import month_name
import spss

#Loop through the months by number in FY order
for month in (4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3):
    #To show what is happening print some stuff to the screen
    print(month, month_name[month])

    #Set up the syntax
    syntax = "!BedDaysPerMonth Month_abbr = " + month_name[month][:3]

    #Set DelayedDischarge to 1 so that the macro uses the correct methodology
    syntax += " DelayedDischarge = 1."

    #print the syntax to the screen
    print(syntax)

    #run the syntax
    spss.Submit(syntax)
End Program.

* Compute stay and yearstay.
Compute yearstay = Sum(Apr_beddays to Mar_beddays).
Compute stay = datediff(keydate2_dateformat, keydate1_dateformat, "days").

* Set the cij_marker back to the usual name.
Compute cij_marker = temp_cij_marker.

* Set the SMRType based on whether we matched a CIJ or not.
Do if no_cij = 1.
    Compute SMRType = "DD-No CIJ".
Else.
    Compute SMRType = "DD-CIJ".
End if.

* Set the IPDC variable to be I (inpatient).
String ipdc (A1).
Compute ipdc = "I".

* Create record_keydate as numeric.
Compute record_keydate1 = xdate.mday(keydate1_dateformat) + 100 * xdate.month(keydate1_dateformat) + 10000 * xdate.year(keydate1_dateformat).
Compute record_keydate2 = xdate.mday(keydate2_dateformat) + 100 * xdate.month(keydate2_dateformat) + 10000 * xdate.year(keydate2_dateformat).
alter type record_keydate1 record_keydate2 (F8.0).

save outfile = !File + "DD_for_source-20" + !FY + ".zsav"
    /Keep year recid SMRType chi gender dob age gpprac postcode lca
    keydate1_dateformat keydate2_dateformat record_keydate1 record_keydate2 CIJ_start_date CIJ_end_date
    hbtreatcode to cij_marker
    Delay_End_Reason Primary_Delay_Reason Secondary_Delay_Reason DD_Responsible_LCA
    ipdc cij_ipdc cij_admtype cij_pattype_code cij_pattype cij_adm_spec cij_dis_spec cij_ppa
    DD_Quality stay yearstay
    Apr_beddays to Mar_beddays
    /zcompressed.

get file = !File + "DD_for_source-20" + !FY + ".zsav".

* New DD variables.
* Delay_End_Reason Primary_Delay_Reason Secondary_Delay_Reason and DD_Quality DD_Responsible_LCA
    *********************************************************************************************************************.
* Match back into source.
add files
    /File =  !File + "temp-source-episode-file-1-" + !FY + ".zsav"
    /File =  !File + "DD_for_source-20" + !FY + ".zsav"
    /by chi keydate1_dateformat.

save outfile = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /zcompressed.
get file = !File + "temp-source-episode-file-2-" + !FY + ".zsav".

Erase File = !File + "DD_Temp-1.zsav".
Erase File = !File + "DD_Temp-2.zsav".

* Think before deleting this one as it takes a while to create... may be worth leaving it till later to delete.
Erase file = !File + "slf_reduced_for_DD.zsav".

