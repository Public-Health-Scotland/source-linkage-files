* Encoding: UTF-8.
get file = !SC_dir + "all_at_episodes_" + !LatestUpdate + ".zsav".

* Now select episodes for given FY.
select if Range(record_keydate1, !startFY, !endFY) or (record_keydate1 <= !endFY and (record_keydate2 >= !startFY or sysmis(record_keydate2))).

string year (a4).
compute year = !FY.

Alter type
    sending_location (A3)
    social_care_id (A10)
    recid (a3)
    smrtype (a10)
    postcode (a8)
    person_id (A13).

* Match on Client data.
match files file = *
    /table = !Year_dir + "Client_for_Source-20" + !FY + ".zsav"
    /By sending_location social_care_id.

* In case keydate is needed as F8.0...
alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !Year_dir + "Alarms-Telecare-for-source-20" + !FY + ".zsav"
    /Keep year
    recid
    SMRType
    chi
    dob
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
