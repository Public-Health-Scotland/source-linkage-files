* Encoding: UTF-8.
insert file = "pass.sps".

GET DATA
  /TYPE=ODBC
  /CONNECT= !Connect_sc
  /SQL='SELECT sending_location, social_care_id, period, '+
    'sds_start_date, sds_end_date, sds_option_1, sds_option_2, sds_option_3 '+
    'FROM social_care_2.sds '+
    'WHERE (financial_year = 2017) '+
    'ORDER BY sending_location, social_care_id'
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

Alter type
    sending_location (A3)
    social_care_id (A10)
    sds_option_1 sds_option_2 sds_option_3 (F1.0).

* Match on the demographics data (chi, gender, dob and postcode).
match files file = *
    /table = !SC_dir + "sc_demographics_lookup_" + !LatestUpdate + ".zsav"
    /by sending_location social_care_id.

* Match on Client data.
match files file = *
    /table = !Year_dir + "Client_for_Source-20" + !FY + ".zsav"
    /By sending_location social_care_id.

Do if sysmis(sds_start_date).
    Compute sds_start_date = !StartFY.
End if.

Rename Variables
    sds_start_date = record_keydate1
    sds_end_date = record_keydate2.

String sc_latest_submission (A6).
Compute sc_latest_submission = "2017Q4".

* Restructure to create one line per SDS option.
varstocases
    /make received from sds_option_1 sds_option_2 sds_option_3
    /Index sds_option.

* Drop the lines that don't have any useful data.
Select if received = 1.

String Year (A4).
Compute Year = !FY.

string recid (a3).
Compute recid eq 'SDS'.

* Use service_type to create the SMRType.
string SMRType (a10).
Do if sds_option = 1.
    Compute SMRType = "SDS-1".
Else if sds_option = 2.
    Compute SMRType = "SDS-2".
Else if sds_option = 3.
    Compute SMRType = "SDS-3".
End if.

 *  Derive age from dob.
Numeric age (F3.0).
Compute age = datediff(!midFY, dob, "years").

* Include the sc_id as a unique person identifier (first merge with sending loc).
String person_id (A13).
Compute person_id = concat(sending_location, "-", social_care_id).

 * Uses sending_location and recodes into sc_sending_location using actual codes.
!Create_sc_sending_location.

aggregate 
    /break social_care_id
    /n_packages = n.

Numeric sds_option_4 (F1.0).
Recode n_packages (1 = 0) (2 Thru Hi = 1) into sds_option_4.

* In case keydate is needed as F8.0...
alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !Year_dir + "SDS-for-source-20" + !FY + ".zsav"
    /Keep Year
    recid
    SMRType
    chi
    dob
    age
    gender
    postcode
    record_keydate1
    record_keydate2
    sc_send_lca
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    sds_option_4
    /zcompressed.
get file = !Year_dir + "SDS-for-source-20" + !FY + ".zsav".
