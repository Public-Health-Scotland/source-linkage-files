﻿* Encoding: UTF-8.
get file = !Extracts_Alt + "/Delayed_Discharges/Jul16_Dec20DD_LinkageFile.zsav".

Rename Variables
    HealthLocationCode = location
    SpecialtyCode = spec
    RDD = keydate1_dateformat
    Delay_End_Date = keydate2_dateformat
    PatientPostcode = postcode.

* Drop any records with obviously bad dates.
Select if (keydate1_dateformat LE keydate2_dateformat) or keydate2_dateformat EQ date.dmy(1,1,1900).

String recid (A3) SMRType (A10) year (A4).
Compute recid = "DD".
Compute SMRType = "DelayedDis".
Value Labels recid
    "DD" "Delayed Discharge episode".
Compute year = !FY.

alter type location (A7).

alter type postcode (A8).

alter type MonthFlag (MOYR8).

* Recode the Local Authority to match source coding.
String DD_Responsible_LCA (A2).
Variable Labels DD_Responsible_LCA "Local Authority assigned responsibility for the delay".
Do If la = "Aberdeen City".
    Compute DD_Responsible_LCA = "01".
Else If la = "Aberdeenshire".
    Compute DD_Responsible_LCA = "02".
Else If la = "Angus".
    Compute DD_Responsible_LCA = "03".
Else If la = "Argyll & Bute".
    Compute DD_Responsible_LCA = "04".
Else If la = "Scottish Borders".
    Compute DD_Responsible_LCA = "05".
Else If la = "Clackmannanshire".
    Compute DD_Responsible_LCA = "06".
Else If la = "West Dunbartonshire".
    Compute DD_Responsible_LCA = "07".
Else If la = "Dumfries & Galloway".
    Compute DD_Responsible_LCA = "08".
Else If la = "Dundee City".
    Compute DD_Responsible_LCA = "09".
Else If la = "East Ayrshire".
    Compute DD_Responsible_LCA = "10".
Else If la = "East Dunbartonshire".
    Compute DD_Responsible_LCA = "11".
Else If la = "East Lothian".
    Compute DD_Responsible_LCA = "12".
Else If la = "East Renfrewshire".
    Compute DD_Responsible_LCA = "13".
Else If la = "City of Edinburgh".
    Compute DD_Responsible_LCA = "14".
Else If la = "Falkirk".
    Compute DD_Responsible_LCA = "15".
Else If la = "Fife".
    Compute DD_Responsible_LCA = "16".
Else If la = "Glasgow City".
    Compute DD_Responsible_LCA = "17".
Else If la = "Highland".
    Compute DD_Responsible_LCA = "18".
Else If la = "Inverclyde".
    Compute DD_Responsible_LCA = "19".
Else If la = "Midlothian".
    Compute DD_Responsible_LCA = "20".
Else If la = "Moray".
    Compute DD_Responsible_LCA = "21".
Else If la = "North Ayrshire".
    Compute DD_Responsible_LCA = "22".
Else If la = "North Lanarkshire".
    Compute DD_Responsible_LCA = "23".
Else If la = "Orkney".
    Compute DD_Responsible_LCA = "24".
Else If la = "Perth & Kinross".
    Compute DD_Responsible_LCA = "25".
Else If la = "Renfrewshire".
    Compute DD_Responsible_LCA = "26".
Else If la = "Shetland".
    Compute DD_Responsible_LCA = "27".
Else If la = "South Ayrshire".
    Compute DD_Responsible_LCA = "28".
Else If la = "South Lanarkshire".
    Compute DD_Responsible_LCA = "29".
Else If la = "Stirling".
    Compute DD_Responsible_LCA = "30".
Else If la = "West Lothian".
    Compute DD_Responsible_LCA = "31".
Else If la = "Comhairle nan Eilean Siar".
    Compute DD_Responsible_LCA = "32".
End If.

!AddLCADictionaryInfo LCA = DD_Responsible_LCA.

* Recode the hb treat code to match source.
String hbtreatcode (A9).
Do If hb = "NHS Ayrshire & Arran".
    Compute hbtreatcode = "S08000015".
Else If hb = "NHS Borders".
    Compute hbtreatcode = "S08000016".
Else If hb = "NHS Dumfries & Galloway".
    Compute hbtreatcode = "S08000017".
Else If hb = "NHS Fife".
    Compute hbtreatcode = "S08000018".
Else If hb = "NHS Forth Valley".
    Compute hbtreatcode = "S08000019".
Else If hb = "NHS Grampian".
    Compute hbtreatcode = "S08000020".
Else If hb = "NHS Greater Glasgow & Clyde".
    Compute hbtreatcode = "S08000021".
Else If hb = "NHS Highland".
    Compute hbtreatcode = "S08000022".
Else If hb = "NHS Lanarkshire".
    Compute hbtreatcode = "S08000023".
Else If hb = "NHS Lothian".
    Compute hbtreatcode = "S08000024".
Else If hb = "NHS Orkney".
    Compute hbtreatcode = "S08000025".
Else If hb = "NHS Shetland".
    Compute hbtreatcode = "S08000026".
Else If hb = "NHS Tayside".
    Compute hbtreatcode = "S08000027".
Else If hb = "NHS Western Isles".
    Compute hbtreatcode = "S08000028".
End If.

!AddHB2018DictionaryInfo HB = hbtreatcode.

*Add labels to Delay end reason.
alter type Delay_End_Reason (F1.0).
Value Labels Delay_End_Reason
    1 "Placement (to a residential / nursing home)"
    2 "Discharge home with home care"
    3 "Discharge home"
    4 "Death - The patient is deceased"
    5 "Not fit for discharge".
Variable Width Delay_End_Reason (5).

* Add labels to Delay Reasons.
Missing Values Primary_Delay_Reason Secondary_Delay_Reason ("    ").

Value Labels Primary_Delay_Reason
    '11A' "Assessment (11A)"
    '11B' "Assessment (11B)"
    '23C' "Funding (23C)"
    '23D' "Funding (23D)"
    '24A' "Place Availability (24A)"
    '24B' "Place Availability (24B)"
    '24C' "Place Availability (24C)"
    '24D' "Place Availability (24D)"
    '24E' "Place Availability (24E)"
    '24F' "Place Availability (24F)"
    '27A' "Place Availability (27A)"
    '25A' "Care Arrangements (25A)"
    '25D' "Care Arrangements (25D)"
    '25E' "Care Arrangements (25E)"
    '25F' "Care Arrangements (25F)"
    '51' "Legal/Financial (51)"
    '52' "Legal/Financial (52)"
    '61' "Disagreements (61)"
    '67' "Disagreements (67)"
    '71' "Other (71)"
    '72' "Other (72)"
    '73' "Other (73)"
    '74' "Other (74)"
    '44' "Transport (44)"
    '9' "Complex Needs (9)"
    '100' "Unpublished (100)".

Value Labels Secondary_Delay_Reason
    '24DX' "Place Availability (24DX)"
    '24EX' "Place Availability (24EX)"
    '26X' "Place Availability (26X)"
    '46X' "Place Availability (46X)"
    '25X' "Care Arrangements (25X)"
    '51X' "Legal/Financial (51X)"
    '71X' "Other (71X)".

Numeric Ammended_Dates No_End_Date Correct_dates (F1.0).
* Use end of month as date for records where we don't have an end date (but we think they have ended).
* Flag these records.
Do if keydate2_dateformat = Date.DMY(1, 1, 1900).
    Compute keydate2_dateformat = Date.DMY(1, xdate.month(MonthFlag) + 1, xdate.year(MonthFlag)) - time.days(1).
    Compute Ammended_Dates = 1.
Else.
    Compute Ammended_Dates = 0.
End if.

* Flag the records that don't have an end date.
* Unless they are Mental Health (any of the specs could be MH), as these are the only ones we could match.
Do if SysMiss(keydate2_dateformat) AND Not(any(spec, "CC", "G1", "G2", "G21", "G22", "G3", "G4", "G5", "G6", "G61", "G62", "G63")).
    Compute No_End_Date = 1.
Else.
    Compute No_End_Date = 0.
End if.

Compute #StartFY = Date.DMY(01, 04, Number(!altFY, F4.0)).
Compute #EndFY = Date.DMY(31, 03, Number(!altFY, F4.0) + 1).

* Flag records to keep that have an start or end of delay which falls in the correct FY.
Do if  (Range(keydate1_dateformat, #StartFY, #EndFY) OR Range(keydate2_dateformat, #StartFY, #EndFY) OR
    Sysmiss(keydate2_dateformat) AND any(spec, "CC", "G1", "G2", "G21", "G22", "G3", "G4", "G5", "G6", "G61", "G62", "G63")).
    Compute Correct_Dates = 1.
Else.
    Compute Correct_Dates = 0.
End if.

* Keep only records which have an end date (except Mental Health) and fall within our dates.
Select if Correct_Dates = 1 AND No_End_Date = 0.

sort cases by chi keydate1_dateformat keydate2_dateformat.

save outfile = !Extracts + "DD_LinkageFile-20" + !FY + ".zsav"
    /Drop hb la Correct_Dates No_End_Date
    /zcompressed.

get file = !Extracts + "DD_LinkageFile-20" + !FY + ".zsav".



