* Encoding: UTF-8.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.
Host Command = ["zip -mjv '" + !File + "BXX_tests_20" + !FY + ".zip' " + 
    "'" + !File + "A&E_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "acute_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "CH_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "CMH_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "DD_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "DN_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "GPOoH_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "Maternity_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "MentalHealth_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "NRS_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "Outpatient_tests_20" + !FY + ".zsav" + "' " +
    "'" + !File + "PIS_tests_20" + !FY + ".zsav" + "'"].

* Bring all the data sets together.
add files
    /file = !File + "a&e_for_source-20" + !FY + ".zsav"
    /file = !File + "acute_for_source-20" + !FY + ".zsav"
    /file = !File + "Care_Home_For_Source-20" + !FY + ".zsav"
    /file = !File + "deaths_for_source-20" + !FY + ".zsav"
    /file = !File + "DN_for_source-20" + !FY + ".zsav"
    /file = !File + "GP_OOH_for_Source-20" + !FY + ".zsav"
    /file = !File + "maternity_for_source-20" + !FY + ".zsav"
    /file = !File + "mental_health_for_source-20" + !FY + ".zsav"
    /file = !File + "outpatients_for_source-20" + !FY + ".zsav"
    /file = !File + "prescribing_file_for_source-20" + !FY + ".zsav"
    /By chi.

* All records should be sorted by CHI, if the above fails, remove the "/By chi" and run again then run the below sort.
*Sort Cases by chi.

* Check that all CHIs are valid.
Do if chi ne "".
    Do Repeat Digit = #Digit.1 to #Digit.9
        /Position = 1 to 9.
        Compute Digit = Number(char.substr(chi, Position, 1), F1.0) * (11 - Position).
    End Repeat.

    Numeric #Check_digit Valid_CHI (F1.0).
    Compute #Check_digit = Mod(11 - Mod(Sum(#Digit.1 to #Digit.9), 11), 11).

    Do If #Check_digit = 10.
        Compute Valid_CHI = 0.
    Else If #Check_digit = Number(char.substr(chi, 10, 1), F1.0).
        Compute Valid_CHI = 1.
    Else.
        Compute Valid_CHI = 0.
    End if.

    Do if Valid_CHI = 1 AND
        (Number(char.Substr(chi, 1, 2), F2.0) > 31 OR
        Number(char.Substr(chi, 3, 2), F2.0) > 12).
        Compute Valid_CHI = 2.
    End if.
End if.

Value labels Valid_CHI
    0 "Invalid check digit"
    1 "Valid CHI"
    2 "Impossible DoB in CHI".

Frequencies Valid_CHI.

* If it's not valid then set it to blank as it's no good for linking.
If any(Valid_CHI, 0, 2) chi = "".

* Create keydates as date variables.
Compute keydate1_dateformat = DATE.DMY(Mod(record_keydate1, 100), Trunc(Mod(record_keydate1, 10000) / 100), Trunc(record_keydate1 / 10000)).

* Deal with empty end dates.
Do if SysMiss(record_keydate2).
    Compute keydate2_dateformat = $sysmis.
Else.
    Compute keydate2_dateformat = DATE.DMY(Mod(record_keydate2, 100), Trunc(Mod(record_keydate2, 10000) / 100), Trunc(record_keydate2 / 10000)).
End if.

* Make them look nice.
Alter Type keydate1_dateformat keydate2_dateformat (Date12).

* Set the type of admission for Maternity records here as the variable isn't included in the datamart.
If (recid = "02B") tadm = "42".
* Correct for home births.
If (recid = "02B" and mpat = "0") tadm = "41".

* Populate SMRType for non-acute records (note GLS is included in the acute program).
Do If (recid = "02B" and any(mpat, "1", "3", "5", "7", "A")).
    Compute SMRType = "Matern-IP".
Else If (recid = "02B" and any(mpat, "2", "4", "6")).
    Compute SMRType = "Matern-DC".
Else if (recid = "02B" and mpat = "0").
    Compute SMRType = "Matern-HB".
Else If (recid = "04B").
    Compute SMRType = "Psych-IP".
Else If (recid = "00B").
    Compute SMRType = "Outpatient".
Else If (recid = "AE2").
    Compute SMRType = "A & E".
Else If (recid = "PIS").
    Compute SMRType = "PIS".
Else If (recid = "NRS").
    Compute SMRType = "NRS Deaths".
End If.


*CHECK RESULTS FROM FREQUENCY SMRTYPE.

Alter Type uri (F8.0).


 * Slight correction for cij_pattypeusing types of admission.
 * Lump the unknowns together to avoid potential confusion.
Recode cij_admtype ("Un" = "99").

 * Apply cij_pattypelogic to all records with a valid CHI number.
Do If chi NE "" AND any(recid, "01B", "04B", "GLS", "02B").
     * Maternity now also has 41 for home birth.
    Do If any(cij_admtype, "41", "42").
        Compute cij_pattype_code = 2.
    * 40 and 48 are other - 99 is our code for unknown.
    Else If Any(cij_admtype, "40", "48", "99").
        Compute cij_pattype_code = 9.
    End If.
End If.

If cij_admtype = "18" cij_pattype_code = 0.

 * Recode cij_pattype.
String cij_pattype(A13).
Recode cij_pattype_code
    (0 = "Non-Elective")
    (1 = "Elective")
    (2 = "Maternity")
    (9 = "Other")
    Into cij_pattype.



********************** Temporarily work on CIJ only records ***************************.

sort cases by CHI record_keydate1 record_keydate2.
* Only work on records that have a CIJ marker, save out others.
temporary.
select if not(any(recid, "01B", "04B", "GLS", "02B")).
save outfile = !File + "temp-source-episode-file-Non-CIJ-" + !FY + ".zsav"
    /zcompressed.

select if any(recid, "01B", "04B", "GLS", "02B").

* Fill in the blank CIJ markers.
do if (chi ne lag(chi)) AND cij_marker = "" AND chi NE "".
    compute cij_marker= "1".
end if.

* Populate ipdc for maternity records.
Do if SMRType = "Matern-IP".
    Compute ipdc = "I".
Else if SMRType = "Matern-DC".
    Compute  ipdc = "D".
End if.

* Tidy up cij_ipdc.
Do if chi NE "" and cij_ipdc = "".
    if ipdc = "I" cij_ipdc = "I".
    if (recid = "01B" and ipdc = "D") cij_ipdc = "D".
End if.

* Reset the CIJ variables after the above.
* And add dates for the start and end of the CIJ.
aggregate outfile = * MODE = ADDVARIABLES OVERWRITE = YES
    /break CHI cij_marker
    /cij_ipdc = max(cij_ipdc)
    /cij_admtype cij_pattype_code cij_pattype cij_adm_spec = First(cij_admtype cij_pattype_code cij_pattype cij_adm_spec)
    /cij_dis_spec = last(cij_dis_spec)
    /CIJ_start_date = Min(keydate1_dateformat)
    /CIJ_end_date = Max(keydate2_dateformat).

 * Clean up.
Do if cij_marker = "".
    Compute CIJ_start_date = $sysmis.
    Compute CIJ_end_date = $sysmis.
End if.

* All records with a CHI should now have a valid CIJ marker.
Temporary.
select if chi ne "".
crosstabs recid by cij_marker.

sort cases by CHI record_keydate1 record_keydate2.

add files file = *
    /file = !File + "temp-source-episode-file-Non-CIJ-" + !FY + ".zsav"
    /By CHI record_keydate1 record_keydate2.


********************** Back to full file ***************************..
********************Create cost including DNAs, & modify cost not including DNAs using cattend *****.

* Modify cost_total_net so that it zeros cost for in the cost_total_net column.
* The full cost will be held in the cost_total_net_incDNA column.
Numeric Cost_Total_Net_incDNAs (F8.2).
Compute Cost_Total_Net_incDNAs = Cost_Total_Net.

* In the Cost_Total_Net column set the cost for those with attendance status 5 or 8 (CNWs and DNAs).
If (Any(Attendance_status, 5, 8)) Cost_Total_Net = 0.

* Create a Flag for PPA (Potentially Preventable Admissions).
sort cases by chi cij_marker record_keydate1 record_keydate2.

* Acute records.
Do if any (recid, "01B", "02B", "04B", "GLS").
    * First record in CIJ.
    Do if (chi NE lag(chi) or (chi = lag(chi) and cij_marker NE lag(cij_marker))).
        * Non-elective original admission.
        Do if cij_pattype= "Non-Elective".
            Compute PPA = 0.
            * Initialise PPA flag for relevant records.


            *Set op exclusions for selection below.
            *Hyper / CHF main ops.
            Do if range (char.Substr(op1a, 1 , 3), "K01", "K50") or
                any (char.Substr(op1a, 1 , 3), "K56", "K60", "K61").
                Compute #ExcludingOperation = 1.
            Else.
                Compute #ExcludingOperation = 0.
            End If.

            *Attach conditions to episodes. With syntax below, patient can have up to five different conditions per episode.
            *ENT.
            Do if any (char.Substr(diag1, 1, 3), "H66", "J06") or
                any (char.Substr(diag1, 1, 4), "J028", "J029", "J038", "J039", "J321").
                compute PPA = 1.
                *Dental.
            Else if range (char.Substr(diag1, 1, 3), "K02", "K06") or
                char.Substr(diag1, 1, 3) = "K08".
                compute PPA = 1.
                *Conv.
            Else if any (char.Substr(diag1, 1, 3), "G40", "G41", "R56", "O15").
                compute PPA = 1.
                *Gang.
            Else if (char.Substr(diag1, 1, 3) = "R02" or
                char.Substr(diag2, 1, 3) = "R02" or
                char.Substr(diag3, 1, 3) = "R02" or
                char.Substr(diag4, 1, 3) = "R02" or
                char.Substr(diag5, 1, 3) = "R02" or
                char.Substr(diag6, 1, 3) = "R02").
                compute PPA = 1.
                *Nutridef.
            Else if any (char.Substr(diag1, 1, 3), "E40", "E41", "E43") or
                any (char.Substr(diag1, 1, 4), "E550", "E643", "M833").
                compute PPA = 1.
                *Dehyd.
            Else if char.Substr(diag1, 1, 3) = "E86" or
                any (char.Substr(diag1, 1, 4), "K522", "K528", "K529").
                compute PPA = 1.
                *Pyelon.
            Else if range (char.Substr(diag1, 1, 3), "N10", "N12").
                compute PPA = 1.
                *Perf.
            Else if any (char.Substr(diag1, 1, 4), "K250", "K251", "K252", "K254", "K255", "K256", "K260", "K261",
                "K262", "K264", "K265", "K266", "K270", "K271", "K272", "K274",
                "K275", "K276", "K280", "K281", "K282", "K284", "K285", "K286").
                compute PPA = 1.
                *Cell.
            Else if (any (char.Substr(diag1, 1, 3), "L03", "L04") or
                any (char.Substr(diag1, 1, 4), "L080", "L088", "L089", "L980"))
                and not any (char.Substr(op1a, 1 , 3), "S06", "S57", "S68", "S70", "W90", "X11").
                compute PPA = 1.
                *Pelvic.
            Else if any (char.Substr(diag1, 1, 3), "N70", "N73").
                compute PPA = 1.
                *Flu.
            Else if any (char.Substr(diag1, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag2, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag3, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag4, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag5, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag6, 1, 3), "J10", "J11", "J13") or
                (char.Substr(diag1, 1, 4) = "J181" or char.Substr(diag2, 1, 4) = "J181" or char.Substr(diag3, 1, 4) = "J181" or char.Substr(diag4, 1, 4) = "J181" or char.Substr(diag5, 1, 4) = "J181" or char.Substr(diag6, 1, 4) = "J181").
                compute PPA = 1.
                *Othvacc.
            Else if
                any (char.Substr(diag1, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
                any (char.Substr(diag2, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
                any (char.Substr(diag3, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
                any (char.Substr(diag4, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
                any (char.Substr(diag5, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
                any (char.Substr(diag6, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
                any (char.Substr(diag1, 1, 4), "A370", "A379", "B161", "B169") or
                any (char.Substr(diag2, 1, 4), "A370", "A379", "B161", "B169") or
                any(char.Substr(diag3, 1, 4), "A370", "A379", "B161", "B169") or
                any (char.Substr(diag4, 1, 4), "A370", "A379", "B161", "B169") or
                any (char.Substr(diag5, 1, 4), "A370", "A379", "B161", "B169") or
                any (char.Substr(diag6, 1, 4), "A370", "A379", "B161", "B169").
                compute PPA = 1.
                *Iron.
            Else if any (char.Substr(diag1, 1, 4), "D501", "D508", "D509").
                compute PPA = 1.
                *Asthma.
            Else if any (char.Substr(diag1, 1, 3), "J45", "J46").
                compute PPA = 1.
                *Diabetes.
            Else if any (char.Substr(diag1, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
                "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
                "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
                "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
                "E144", "E145", "E146", "E147", "E148")
                or
                any (char.Substr(diag2, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
                "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
                "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
                "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
                "E144", "E145", "E146", "E147", "E148")
                or
                any (char.Substr(diag3, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
                "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
                "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
                "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
                "E144", "E145", "E146", "E147", "E148")
                or
                any (char.Substr(diag4, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
                "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
                "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
                "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
                "E144", "E145", "E146", "E147", "E148")
                or
                any (char.Substr(diag5, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
                "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
                "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
                "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
                "E144", "E145", "E146", "E147", "E148")
                or
                any (char.Substr(diag6, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
                "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
                "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
                "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
                "E144", "E145", "E146", "E147", "E148").
                compute PPA = 1.
                *Hypert.
            Else if (char.Substr(diag1, 1, 3) = "I10" or
                char.Substr(diag1, 1, 4) = "I119") and #ExcludingOperation  =  0.
                compute PPA = 1.
                *Angina.
            Else if (char.Substr(diag1, 1, 3) = "I20")
                and not any (char.Substr(op1a, 1 , 3), "K40", "K45", "K49", "K60", "K65", "K66").
                compute PPA = 1.
                *Copd.
            Else if (range (char.Substr(diag1, 1, 3), "J41", "J44") or char.Substr(diag1, 1, 3) = "J47") or
                (char.Substr(diag1, 1, 3) = "J20" and (range (char.Substr(diag2, 1, 3), "J41", "J44") or char.Substr(diag2, 1, 3) = "J47")).
                compute PPA = 1.
                *Chf.
            Else if (char.Substr(diag1, 1, 3) = "I50" or
                char.Substr(diag1, 1, 3) = "J81" or
                char.Substr(diag1, 1, 4) = "I110") and
                #ExcludingOperation  =  0.
                compute PPA = 1.
            End if.
        End if.
    End if.
End if.

aggregate
    /Break chi cij_marker
    /cij_ppa = Max(PPA).



sort cases by chi keydate1_dateformat.

save outfile = !File + "temp-source-episode-file-1-" + !FY + ".zsav"
    /Keep year recid keydate1_dateformat keydate2_dateformat ALL
    /Drop Valid_CHI PPA
    /zcompressed.
get file = !File + "temp-source-episode-file-1-" + !FY + ".zsav".

 * Declare variables for Delay Discharge (1516 only).
Numeric Delay_End_Reason (F1.0).
String Primary_Delay_Reason (A4).
String Secondary_Delay_Reason (A4).
String DD_Quality (A3).
String DD_Responsible_LCA (A2).

 * Declare variables for Homelessness (1516 only).
String hl1_application_ref (A15).
String hl1_sending_lca (A9).
Numeric hl1_property_type (F2.0).
String hl1_reason_ftm (A10).
Numeric HH_in_FY (F1.0).
Numeric HH_ep (F1.0).
Numeric HH_6after_ep (F1.0).
Numeric HH_6before_ep (F1.0).

save outfile = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /zcompressed.

get file = !File + "temp-source-episode-file-2-" + !FY + ".zsav".

* Housekeeping.
Erase file = !File + "temp-source-episode-file-Non-CIJ-" + !FY + ".zsav".

* Zip all activity (this doesn't really save any space but tidies things up for now).
Host Command = ["zip -mjv '" + !File + "Activity_20" + !FY + ".zip' " + 
    "'" + !File + "a&e_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "acute_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "Care_Home_For_Source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "deaths_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "DN_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "maternity_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "mental_health_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "outpatients_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "prescribing_file_for_source-20" + !FY + ".zsav" + "' " +
    "'" + !File + "GP_OOH_for_Source-20" + !FY + ".zsav" + "'"].

