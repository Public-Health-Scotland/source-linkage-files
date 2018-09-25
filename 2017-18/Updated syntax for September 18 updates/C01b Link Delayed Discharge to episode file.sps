* Encoding: UTF-8.

get file = !File + "temp-source-episode-file-1-" + !FY + ".zsav"
    /Keep year recid keydate1_dateformat keydate2_dateformat
    chi gender dob age gpprac postcode lca DataZone2011
    hbtreatcode location spec tadm
    CIS_marker newCIS_ipdc newCIS_admtype newpattype_CIScode newpattype_CIS CIJadm_spec CIJdis_spec CIS_PPA.

 * Keep records that have a chi, and a CIS_marker.
select if chi NE "".
select if any(recid, "01B", "02B", "04B", "GLS").

 * Create a copy of the CIS marker.
String new_CIS (A5).
Compute new_CIS = CIS_marker.

 * Set blank to be user missing (important for later).
Missing Values new_CIS ("     ").

 * Aggregate to get the dates of the CIS episode.
 * This usually takes a while to run.
aggregate
   /break chi new_CIS
   /keydate3_dateformat = Min(keydate1_dateformat)
   /keydate4_dateformat = Max(keydate2_dateformat).

save outfile = !File + "temp-source-episode-with-CIS-dates.zsav"
   /zcompressed.
get file = !File + "temp-source-episode-with-CIS-dates.zsav".

 * Add all files together.
add files 
   /File = *
   /File = !Extracts + "DD_LinkageFile-20" + !FY + ".zsav".

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
                and sysmiss(lag(keydate2_dateformat)) and keydate1_dateformat GE lag(keydate3_dateformat) - time.days(1).
    Compute Flag8 = 1.
    If keydate1_dateformat GE lag(keydate3_dateformat) Flag8 = 2.
    Compute new_CIS = lag(new_CIS).
    Compute keydate3_dateformat = lag(keydate3_dateformat).
    Compute keydate4_dateformat = lag(keydate4_dateformat).
End if.

* Use Min and Max CIS dates to fill in new_CIS - where possible - DD episodes with no CIS.
Do if chi = lag(chi) and missing(new_CIS).
    * Create flags simply to check rows where CIS markers are being added.
    * don't expect any of these.
    compute flag1 = 0.
    Do if keydate1_dateformat = lag(keydate2_dateformat) and recid ne "DD".
        compute new_CIS = lag(new_CIS).
        Compute keydate3_dateformat = lag(keydate3_dateformat).
        Compute keydate4_dateformat = lag(keydate4_dateformat).
        compute flag1 = 1.
    Else if recid = "DD".
        Compute Flag2 = 0.
        Compute Flag3 = 0.
        Compute Flag4 = 0.
        Compute NoCIS = 0.
        * Flag DD records which fit entirely within a CIS episode. Allow one day.
        Do if (keydate1_dateformat GE lag(keydate3_dateformat) - time.days(1)) and (keydate2_dateformat LE lag(keydate4_dateformat) + time.days(1)).
            compute new_CIS = lag(new_CIS).
            Compute keydate3_dateformat = lag(keydate3_dateformat).
            Compute keydate4_dateformat = lag(keydate4_dateformat).
            compute flag2 = 1.
            If (keydate1_dateformat GE lag(keydate3_dateformat)) and (keydate2_dateformat LE lag(keydate4_dateformat)) flag2 = 2.
            compute Flag6 = 0.
            * If we know the date has changed flag it and work out how off that dates are.
            Do if Ammended_Dates = 1.
                Compute Flag6 = 1.
                Compute DaysWrong = DateDiff(lag(keydate4_dateformat), keydate2_dateformat, "days").
            End if.
            * If DD record date starts within hospital dates but ends afterwards.
        Else if Range(keydate1_dateformat, lag(keydate3_dateformat) - time.days(1), lag(keydate4_dateformat) + time.days(1)) and keydate2_dateformat GT lag(keydate4_dateformat).
            Compute flag3 = 1.
            If Range(keydate1_dateformat, lag(keydate3_dateformat), lag(keydate4_dateformat)) and keydate2_dateformat GT lag(keydate4_dateformat) flag3 = 2.
            Compute DaysWrong = DateDiff(keydate2_dateformat, lag(keydate4_dateformat), "days").
            Compute Flag7 = 0.
            Compute Flag9 = 0.
            * If we know the date has changed flag it and work out how off that dates are.
            Do if Ammended_Dates = 1 AND xdate.month(MonthFlag) = xdate.month(lag(keydate4_dateformat)).
                Compute Flag7 = 1.
                If Range(keydate1_dateformat, lag(keydate3_dateformat), lag(keydate4_dateformat)) Flag7 = 2.
                Compute new_CIS = lag(new_CIS).
                Compute keydate3_dateformat = lag(keydate3_dateformat).
                Compute keydate4_dateformat = lag(keydate4_dateformat).
                * Don't make the dates give it a negative stay (in cases where the match was +- 1 day).
                Compute keydate2_dateformat = Max(keydate1_dateformat, lag(keydate4_dateformat)).
            * If it's only one day out then we'll count it as matching the CIS.
            Else if DaysWrong = 1.
                Compute Flag9 = 1.
                Compute new_CIS = lag(new_CIS).
                Compute keydate3_dateformat = lag(keydate3_dateformat).
                Compute keydate4_dateformat = lag(keydate4_dateformat).
            End if.
        End if.
    End if.
End if.

 * Sort in the opposite direction.
sort cases by chi (A) keydate1_dateformat (D) order (A).
* If DD record date ends within CIS dates but starts before.
Do if recid = 'DD' and chi = lag(chi) and missing(new_CIS).
    Compute Flag4 = 0.
    Do if keydate1_dateformat LE lag(keydate3_dateformat) and Range(keydate2_dateformat, lag(keydate3_dateformat) - time.days(1), lag(keydate4_dateformat) + time.days(1)).
        Compute flag4 = 1.
        Compute DaysWrong = DateDiff(lag(keydate3_dateformat), keydate1_dateformat, "days").
        If keydate1_dateformat LE lag(keydate3_dateformat) and Range(keydate2_dateformat, lag(keydate3_dateformat), lag(keydate4_dateformat)) flag4 = 2.
        Compute Flag10 = 0.
        * If it's only one day out, count it as matching the CIS.
        Do if DaysWrong = 1.
            Compute Flag10 = 1.
            Compute new_CIS = lag(new_CIS).
            Compute keydate3_dateformat = lag(keydate3_dateformat).
            Compute keydate4_dateformat = lag(keydate4_dateformat).
        End if.
    End if.
End if.

 * Set the CIJ variables (for the DD's we have assigned a CIS).
 * Also take other variables of use.
Missing Values Postcode ("       ")
    /DataZone2011 ("        ")
    /LCA ("  ").
sort cases by CHI new_CIS order.
aggregate outfile = * MODE = ADDVARIABLES OVERWRITE = YES
    /Presorted
    /break CHI new_CIS
    /newcis_ipdc newcis_admtype newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec CIS_PPA
    = First(newcis_ipdc newcis_admtype newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec CIS_PPA)
    /DD_gender DD_dob DD_age DD_gpprac DD_postcode DD_lca DD_DataZone2011
    = Last(gender dob age gpprac postcode lca DataZone2011).

 * Fill in the variables for the DD.
Do if recid = "DD".
    Compute gender = DD_gender.
    Compute dob = DD_dob.
    Compute age = DD_age.
    Compute gpprac = DD_gpprac.
    Compute postcode = DD_postcode.
    Compute lca = DD_lca.
    Compute DataZone2011 = DD_DataZone2011.
End if.

* Sort back to a 'normal' order.
sort cases by chi keydate1_dateformat order.
 * If we didn't match the DD to a CIS it won't have this info.
 * Use the info from the closest CIS to the DD.
Do if recid = "DD" and chi = lag(chi).
    If Missing(gender) gender = lag(DD_gender).
    If Missing(dob) dob = lag(DD_dob).
    If Missing(age) age = lag(DD_age).
    If Missing(gpprac) gpprac = lag(DD_gpprac).
    If Missing(postcode) postcode = lag(DD_postcode).
    If Missing(lca) lca = lag(DD_lca).
    If Missing(DataZone2011) DataZone2011 = lag(DD_DataZone2011).
End if.

 * Labels for the flags (just for info now).
Variable labels
Flag1 "1 - CIS added to non-DD record"
Flag2 "2 - CIS added to DD that falls within CIS period"
Flag3 "3 - DD record that starts within CIS period but ends after"
Flag4 "4 - DD record that starts before CIS period but ends during"
Flag6 "6 - DD that matches CIS but had end-date changed"
Flag7 "7 - DD with changed dates pushing it over the CIS dates"
Flag8 "8 - DD records linked to MH with no end dates"
NoCIS "no-CIS attached".

 * Flag DDs which don't seem to have an associated hospital stay.
if missing(new_CIS) and recid = "DD" NoCIS = 1.

save outfile = !File + "DD_Temp-2.zsav"
   /zcompressed.
get file = !File + "DD_Temp-2.zsav".

select if recid = "DD".

 * Group the flags into a single quality variable.
 * There is a matrix showing the map between DD_Quality and the flags.
 * See - \\Freddy\DEPT\PHIBCS\PHI\Health & Social Care\Topics\Linkage\Reference Files\DD flags matrix.xlsx.
String DD_Quality (A3).
Variable Labels DD_Quality "Indication of how well a delay episode could be matched to a CIS episode".
Value Labels DD_quality
    "1"	"Accurate Match - (1)"
    "1P"	"Accurate Match (allowing +-1 day) - (1P)"
    "1A"	"Accurate Match (has an assumed  end date) - (1A)"
    "1AP"	"Accurate Match (allowing +-1 day and has an assumed end date) - (1AP)"
    "2"	"Starts in CIS - (2)"
    "2D"	"Starts in CIS (ends one day after) - (2D)"
    "2DP"	"Starts in CIS (allowing +-1 day and ends one day after) - (2DP)"
    "2A"	"Starts in CIS (Accurate Match after correcting assumed end date) - (2A)"
    "2AP"	"Starts in CIS (Accurate Match (allowing +-1 day) after correcting assumed end date) - (2AP)"
    "3"	"Ends in CIS - (3)"
    "3D"	"Ends in CIS (starts one day before) - (3D)"
    "3DP"	"Ends in CIS (allowing +-1 day and starts one day before) - (3DP)"
    "4"	"Matches unended MH record - (4)"
    "4P"	"Matches unended MH record (allowing -1 day) - (4P)"
    "-"           "No Match (We don't keep these)".

Do if recid = "DD".
    Do if flag2 = 2 and flag6 = 0.
        Compute DD_Quality = "1".
    Else if flag2 = 1 and flag6 = 0.
        Compute DD_Quality = "1P".
    Else if flag2 = 2 and flag6 = 1.
        Compute DD_Quality = "1A".
    Else if flag2 = 1 and flag6 = 1.
        Compute DD_Quality = "1AP".
    Else if any(flag4, 1, 2) and flag10 = 0.
        Compute DD_Quality = "3".
    Else if flag4 = 2 and flag10 = 1.
        Compute DD_Quality = "3D".
    Else if flag4 = 1 and flag10 = 1.
        Compute DD_Quality = "3DP".
    Else if any(flag3, 1, 2) and flag7 = 0 and flag9 = 0.
        Compute DD_Quality = "2".
    Else if flag3 = 2 and flag7 = 0 and flag9 = 1.
        Compute DD_Quality = "2D".
    Else if flag3 = 1 and flag7 = 0 and flag9 = 1.
        Compute DD_Quality = "2DP".
    Else if flag3 = 2 and flag7 = 2.
        Compute DD_Quality = "2A".
    Else if flag3 = 1 and flag7 = 1.
        Compute DD_Quality = "2AP".
    Else if flag8 = 2.
        Compute DD_Quality = "4".
    Else if flag8 = 1.
        Compute DD_Quality = "4P".
    Else.
        Compute DD_Quality = "-".
    End if.
End if.

 * Final checks before the DD records are ready to be separated and added back to source.
crosstabs DD_Quality by NoCIS.
Frequencies DD_Quality NoCIS.

sort cases by LCA.
Split file Seperate by LCA.

Frequencies DD_Quality.

aggregate
    /Presorted
    /break lca
    /UnMatched = SUM(NoCIS)
    /DDs = N.

compute pct_unmatched = UnMatched / DDs * 100.
Frequencies pct_unmatched.

Split file off.
 * Drop records which are no good.
Select if DD_Quality NE "-".

sort cases by chi keydate1_dateformat.

 * Save out records with changed end dates to feed back to the DD team. 
Temporary.
Select if any(flag7, 1, 2).
save outfile = !File + "DD episodes with corrected end-dates - 20" + !FY + ".zsav"
    /Rename (keydate1_dateformat keydate2_dateformat keydate3_dateformat keydate4_dateformat = RDD Delay_End_Date CIS_Start_Date CIS_End_Date)
    /keep year chi lca RDD Delay_End_Date new_CIS newcis_ipdc newcis_admtype newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec
    MONTHFLAG OriginalAdmissionDate Delay_End_Reason Primary_Delay_Reason Secondary_Delay_Reason
    /zcompressed.

 * Count the beddays.
 * Similar method to that used in Care homes.
 * 1) Declare an SPSS macro which will set the beddays for each month.
 * 2) Use python to run the macro with the correct parameters.
 * This means that different month lengths and leap years are handled correctly.
Define !BedDaysPerMonth (Month = !Tokens(1) 
   /MonthNum = !Tokens(1) 
   /DaysInMonth = !Tokens(1) 
   /Year = !Tokens(1))

 * Store the start and end date of the given month.
Compute #StartOfMonth = Date.DMY(1, !MonthNum, !Year).
Compute #EndOfMonth = Date.DMY(!DaysInMonth, !MonthNum, !Year).

 * Create the names of the variables e.g. April_beddays and April_cost.
!Let !BedDays = !Concat(!Month, "_beddays").

 * Create variables for the month.
Numeric !BedDays (F2.0).

 * Go through all possibilities to decide how many days to be allocated.
Do if keydate1_dateformat LE #StartOfMonth.
   Do if keydate2_dateformat GE #EndOfMonth.
      Compute !BedDays = !DaysInMonth.
   Else.
      Compute !BedDays = DateDiff(keydate2_dateformat, #StartOfMonth, "days").
   End If.
Else if keydate1_dateformat LT #EndOfMonth.
   Do if keydate2_dateformat GE #EndOfMonth.
      Compute !BedDays = DateDiff(#EndOfMonth, keydate1_dateformat, "days").
   Else.
      Compute !BedDays = DateDiff(keydate2_dateformat, keydate1_dateformat, "days").
   End If.
Else.
   Compute !BedDays = 0.
End If.

 * Months after the discharge date will end up with negatives.
If !BedDays < 0 !BedDays = 0.
!EndDefine.

 * This python program will call the macro for each month with the right variables.
 * They will also be in FY order.
Begin Program.
from calendar import month_name, monthrange
from datetime import date
import spss

#Set the financial year, this line reads the first variable ('year')
fin_year = int((int(spss.Cursor().fetchone()[0]) // 100) + 2000)

#This line generates a 'dictionary' which will hold all the info we need for each month
#month_name is a list of all the month names and just needs the number of the month
#(m < 4) + 2015 - This will set the year to be 2015 for April onwards and 2016 other wise
#monthrange takes a year and a month number and returns 2 numbers, the first and last day of the month, we only need the second.
months = {m: [month_name[m], (m < 4) + fin_year, monthrange((m < 4) + fin_year, m)[1]]  for m in range(1,13)}
print(months) #Print to the output window so you can see how it works

#This will make the output look a bit nicer
print("\n\n***This is the syntax that will be run:***")

#This loops over the months above but first sorts them by year, meaning they are in correct FY order
for month in sorted(months.items(), key=lambda x: x[1][1]):
   syntax = "!BedDaysPerMonth Month = " + month[1][0][:3]
   syntax += " MonthNum = " + str(month[0])
   syntax += " DaysInMonth = " + str(month[1][2])
   syntax += " Year = " + str(month[1][1]) + "."
   
   print(syntax)
   spss.Submit(syntax)
End Program.

 * Compute stay and yearstay.
Compute yearstay = Sum(apr_beddays to mar_beddays).
Compute stay = datediff(keydate2_dateformat, keydate1_dateformat, "days").

 * Set the cis_marker back to the usual name.
Compute cis_marker = new_CIS.

 * Set the SMRType based on whether we matched a CIS or not.
Do if NoCIS = 1.
    Compute SMRType = "DD-No CIS".
Else.
    Compute SMRType = "DD-CIS".
End if.

 * Create record_keydate as numeric.
Compute record_keydate1 = xdate.mday(keydate1_dateformat) + 100 * xdate.month(keydate1_dateformat) + 10000 * xdate.year(keydate1_dateformat).
Compute record_keydate2 = xdate.mday(keydate2_dateformat) + 100 * xdate.month(keydate2_dateformat) + 10000 * xdate.year(keydate2_dateformat).
alter type record_keydate1 record_keydate2 (F8.0).

save outfile = !File + "DD_for_source-20" + !FY + ".zsav"
    /Keep year recid SMRType chi gender dob age gpprac postcode lca
    keydate1_dateformat keydate2_dateformat record_keydate1 record_keydate2
    hbtreatcode to cis_marker
    Delay_End_Reason Primary_Delay_Reason Secondary_Delay_Reason
    newcis_ipdc newcis_admtype newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec
    DD_Quality stay yearstay
    Apr_beddays to Mar_beddays
    /zcompressed.

get file = !File + "DD_for_source-20" + !FY + ".zsav".

 * New DD variables.
 * Delay_End_Reason Primary_Delay_Reason Secondary_Delay_Reason and DD_Quality
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
Erase file = !File + "temp-source-episode-with-CIS-dates.zsav".

