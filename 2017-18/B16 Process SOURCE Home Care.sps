* Encoding: UTF-8.
insert file = "pass.sps".

GET DATA
  /TYPE=ODBC
  /CONNECT= !Connect_sc
  /SQL='SELECT sending_location, social_care_id, period, '+
    'hc_service_provider, hc_service, reablement, '+
    'hc_service_start_date, hc_service_end_date, hc_hours_derived  '+
    'FROM social_care_2.homecare '+
    'WHERE (financial_year = 2017) '+
    'ORDER BY sending_location, social_care_id'
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

Alter type
    sending_location (A3)
    social_care_id (A10)
    reablement (F1.0)
    hc_service_provider (F1.0).

Recode reablement (SYSMIS = 9).

* Match on the demographics data (chi, gender, dob and postcode).
match files file = *
    /table = !SC_dir + "sc_demographics_lookup_" + !LatestUpdate + ".zsav"
    /by sending_location social_care_id.

* Match on Client data.
match files file = *
    /table = !Year_dir + "Client_for_Source-20" + !FY + ".zsav"
    /By sending_location social_care_id.

Rename Variables
    hc_service_start_date = record_keydate1
    hc_service_end_date = record_keydate2
    reablement = hc_reablement
    hc_service_provider = hc_provider
    hc_hours_derived = hc_hours.

String sc_latest_submission (A6).
Compute sc_latest_submission = "2017Q4".

String Year (A4).
Compute Year = !FY.

string recid (a3).
Compute recid eq 'HC'.

* Use hc_service to create the SMRType.
string SMRType (a10).
Do if hc_service = "1".
    compute SMRType = 'HC-Non-Per'.
Else if hc_service = "2".
    compute SMRType = "HC-Per".
Else.
    compute SMRType = "HC-Unknown".
End if.

 *  Derive age from dob.
Numeric age (F3.0).
Compute age = datediff(!midFY, dob, "years").

* Include the sc_id as a unique person identifier (first merge with sending loc).
String person_id (A13).
Compute person_id = concat(sending_location, "-", social_care_id).

 * Uses sending_location and recodes into sc_sending_location using actual codes.
!Create_sc_sending_location.

Value Labels hc_provider
    1 'Local Authority / Health & Social Care Partnership / NHS Board'
    2 'Private'
    3 'Other Local Authority'
    4 'Third Sector'
    5 'Other'.

Value Labels hc_reablement
    0 'No'
    1 'Yes'
    9 'Not Known'.

* In case keydate is needed as F8.0...
alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !Year_dir + "Home_Care_for_source-20" + !FY + ".zsav"
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
    hc_hours
    hc_provider
    hc_reablement
    person_id
    sc_latest_submission
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    /zcompressed.
get file = !Year_dir + "Home_Care_for_source-20" + !FY + ".zsav".
