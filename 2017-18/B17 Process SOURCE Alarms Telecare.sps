* Encoding: UTF-8.
Insert file ="/conf/irf/11-Development team/Dev00-PLICS-files/2017-18/A01 Set up Macros (1718).sps".

get file = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_AT_extracts_ELoth_NLan_only.zsav".

Rename Variables
service_start_date = record_keydate1
service_end_date = record_keydate2
chi_gender_code = gender
chi_postcode = postcode
chi_date_of_birth = dob
seeded_chi_number = chi.

Alter type gender (F1.0) postcode (A8).

String Year (A4).
Compute Year = !FY.

string recid (a3).
Compute recid eq 'AT'.

* Use service_type to create the SMRType.
string SMRType (a10).
Do if service_type = "1".
    compute SMRType = 'AT-Alarm'.
Else if service_type = "2".
    compute SMRType = "AT-Tele".
End if.

Numeric age (F3.0).

Compute age = datediff(!midFY, dob, "years").

String sc_send_lca (A2).
Recode sending_location
    ("100" = "01")
    ("110" = "02")
    ("120" = "03")
    ("130" = "04")
    ("150" = "06")
    ("170" = "08")
    ("180" = "09")
    ("190" = "10")
    ("200" = "11")
    ("210" = "12")
    ("220" = "13")
    ("230" = "14")
    ("235" = "32")
    ("240" = "15")
    ("250" = "16")
    ("260" = "17")
    ("270" = "18")
    ("280" = "19")
    ("290" = "20")
    ("300" = "21")
    ("310" = "22")
    ("320" = "23")
    ("330" = "24")
    ("340" = "25")
    ("350" = "26")
    ("355" = "05")
    ("360" = "27")
    ("370" = "28")
    ("380" = "29")
    ("390" = "30")
    ("395" = "07")
    ("400" = "31")
    into sc_send_lca.

!AddLCADictionaryInfo LCA = sc_send_lca.

* In case keydate is needed as F8.0...
alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !File + "Alarms-Telecare-for-source-20" + !FY + ".zsav"
    /Keep Year
    recid
    SMRType
    chi
    dob
    age
    gender
    postcode
    sc_send_lca
    record_keydate1
    record_keydate2
    /zcompressed.
get file = !File + "Alarms-Telecare-for-source-20" + !FY + ".zsav".
