* Encoding: UTF-8.
get file = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_AT_extracts_ELoth_NLan_only.zsav".

Alter type social_care_id (A10) financial_year (A4).

sort cases by social_care_id sending_location.
match files file = *
    /table = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_Client_for_source.zsav"
    /By social_care_id sending_location.

Rename Variables
    service_start_date = record_keydate1
    service_end_date = record_keydate2
    chi_gender_code = gender
    sumbitted_postcode = postcode
    chi_date_of_birth = dob
    seeded_chi_number = chi.

Alter type gender (F1.0) postcode (A8).

 * Prefer the submitted postcode but if this is blank then use the CHI seeded postocde.
If postcode = "" postcode = chi_postcode.

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

 * Uses sending_location and recodes into sc_sending_location using actual codes.
!Create_sc_sending_location.

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
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    /zcompressed.
get file = !File + "Alarms-Telecare-for-source-20" + !FY + ".zsav".
