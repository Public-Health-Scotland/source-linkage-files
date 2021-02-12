* Encoding: UTF-8.
* Open processed Acute extract.
get file = !file + 'acute_for_source-20' + !FY + '.zsav'.

* Apply new costs, these are taken from the 17/18 file.
* Either the average cost per day for inpatient, or the average daycase cost for daycase.
Do if recid = "01B" and spec = "C3" and hbtreatcode = "S08000015".
    Do if location = "A111H".
        If ipdc = "D" cost_total_net = 521.38.
        If ipdc = "I" cost_total_net = 2309.26 * yearstay.
    Else if location = "A210H".
        If ipdc = "I" cost_total_net = 2460.63 * yearstay.
    End if.
End if.

* Create keydates as date variables as we need to extract the month below.
Compute keydate1_dateformat = DATE.DMY(Mod(record_keydate1, 100), Trunc(Mod(record_keydate1, 10000) / 100), Trunc(record_keydate1 / 10000)).
Compute keydate2_dateformat = DATE.DMY(Mod(record_keydate2, 100), Trunc(Mod(record_keydate2, 10000) / 100), Trunc(record_keydate2 / 10000)).

* Calculate Cost per month from beddays and cost_total_net.
* This code taken from maternity etc. distributes costs evenly by day.
Do Repeat Beddays = Apr_beddays to Mar_beddays
    /cost = Apr_cost to Mar_cost
    /MonthNum = 4 5 6 7 8 9 10 11 12 1 2 3.

    * Only re-compute monthly costs where needed.
    Do if recid = "01B" and spec = "C3" and hbtreatcode = "S08000015".

        * Deal with single day episodes (inpatient or daycase).
        Do if (keydate1_dateformat = keydate2_dateformat).
            Do if  xdate.Month(keydate1_dateformat) = MonthNum.
                Compute Cost = cost_total_net.
            Else.
                Compute Cost = 0.
            End if.
        * Deal with normal inpatient episodes.
        Else.
            Compute Cost = (Beddays / yearstay) * cost_total_net.
        End if.
    End if.
End Repeat.

 * Overwrite the data for onward processing.
save outfile = !file + 'acute_for_source-20' + !FY + '.zsav'
    /Drop keydate1_dateformat keydate2_dateformat
    /zcompressed.
