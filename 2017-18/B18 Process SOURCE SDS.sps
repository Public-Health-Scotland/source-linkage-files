* Encoding: UTF-8.
get file = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_SDS_extracts_ELoth_NLan_SLan.zsav"
    /Drop sds_option_1_net_value sds_option_2_net_value sds_option_3_net_value sds_option_1_gross_value sds_option_2_gross_value sds_option_3_gross_value sds_total_net_value sds_total_gross_value.

Alter type social_care_id (A10) financial_year (A4).

sort cases by social_care_id sending_location.
match files file = *
    /table = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_Client_for_source.zsav"
    /By social_care_id sending_location.

Rename Variables
    sds_start_date = record_keydate1
    sds_end_date = record_keydate2
    chi_gender_code = gender
    submitted_postcode = postcode
    chi_date_of_birth = dob
    seeded_chi_number = chi.

Alter type gender (F1.0) postcode (A8) sds_option_1 sds_option_2 sds_option_3 (F1.0).

 * Prefer the submitted postcode but if this is blank then use the CHI seeded postcode.
If postcode = "" postcode = chi_postcode.

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

Numeric age (F3.0).

Compute age = datediff(!midFY, dob, "years").

 * Uses sending_location and recodes into sc_sending_location using actual codes.
!Create_sc_sending_location.

* Set missing start dates to the start of the year.
If start_date_missing record_keydate1 = !startFY.

* Remove end dates which should be blank.
If end_date_missing record_keydate2 = $sysmis.

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

save outfile = !File + "SDS-for-source-20" + !FY + ".zsav"
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
get file = !File + "SDS-for-source-20" + !FY + ".zsav".
