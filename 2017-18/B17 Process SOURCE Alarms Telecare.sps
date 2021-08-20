* Encoding: UTF-8.
insert file = "pass.sps".

GET DATA
  /TYPE=ODBC
  /CONNECT= !Connect_sc
  /SQL='SELECT sending_location, social_care_id, period, service_type, '+
    'service_start_date, service_end_date '+
    'FROM social_care_2.equipment '+
    'WHERE (financial_year = 2017) '+
    'ORDER BY sending_location, social_care_id'
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

Alter type
    sending_location (A3)
    social_care_id (A10).

* Match on the demographics data (chi, gender, dob and postcode).
match files file = *
    /table = !SC_dir + "sc_demographics_lookup_" + !LatestUpdate + ".zsav"
    /by sending_location social_care_id.

* Match on Client data.
match files file = *
    /table = !Year_dir + "Client_for_Source-20" + !FY + ".zsav"
    /By sending_location social_care_id.

Do if sysmis(service_start_date).
    Compute service_start_date = !StartFY.
End if.

Rename Variables
    service_start_date = record_keydate1
    service_end_date = record_keydate2.

String sc_latest_submission (A6).
Compute sc_latest_submission = "2017Q4".

String Year (A4).
Compute Year = !FY.

string recid (a3).
Compute recid = 'AT'.

* Use service_type to create the SMRType.
string SMRType (a10).
Do if service_type = "1".
    compute SMRType = 'AT-Alarm'.
Else if service_type = "2".
    compute SMRType = "AT-Tele".
End if.

 *  Derive age from dob.
Numeric age (F3.0).
Compute age = datediff(!midFY, dob, "years").

* Include the sc_id as a unique person identifier (first merge with sending loc).
String person_id (A13).
Compute person_id = concat(sending_location, "-", social_care_id).

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

save outfile = !Year_dir + "Alarms-Telecare-for-source-20" + !FY + ".zsav"
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
    person_id
    sc_latest_submission
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    /zcompressed.

get file = !Year_dir + "Alarms-Telecare-for-source-20" + !FY + ".zsav".
