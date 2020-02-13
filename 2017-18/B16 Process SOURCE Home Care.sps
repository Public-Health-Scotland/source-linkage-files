* Encoding: UTF-8.
get file = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_HC_extracts_ELoth_NLan_SLan.zsav".

Alter type social_care_id (A10) financial_year (A4).

sort cases by social_care_id sending_location.
match files file = *
    /table = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_Client_for_source.zsav"
    /By social_care_id sending_location.

Rename Variables
    hc_service_start_date = record_keydate1
    hc_service_end_date = record_keydate2
    chi_gender_code = gender
    chi_postcode = postcode
    chi_date_of_birth = dob
    seeded_chi_number = chi
    reablement = hc_reablement.

Alter type gender (F1.0) postcode (A8) hc_reablement (F1.0) hc_service_provider (F1.0).

* If the chi seeded postcode is blank use the submitted one.
If postcode = "" postcode = submitted_postcode.

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

Numeric age (F3.0).

Compute age = datediff(!midFY, dob, "years").

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

* Remove end dates which should be blank.
If end_date_missing record_keydate2 = $sysmis.

* In case keydate is needed as F8.0...
alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !File + "Home_Care_for_source-20" + !FY + ".zsav"
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
    hc_service_provider
    hc_reablement
    living_alone
    support_from_unpaid_carer
    social_worker
    housing_support
    type_of_housing
    meals
    day_care
    /zcompressed.
get file = !File + "Home_Care_for_source-20" + !FY + ".zsav".

