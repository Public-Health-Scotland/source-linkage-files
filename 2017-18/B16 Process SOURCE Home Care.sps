* Encoding: UTF-8.
get file = !SC_dir + "all_hc_episodes_" + !LatestUpdate + ".zsav".

* Now select episodes for given FY.
select if Range(hc_service_start_date, !startFY, !endFY) or (hc_service_start_date <= !endFY and (hc_service_end_date >= !startFY or sysmis(hc_service_end_date))).

* Convert from R factor which is a labelled numeric in SPSS.
Alter type sc_latest_submission (A6).
compute sc_latest_submission = ValueLabel(sc_latest_submission).

* Remove any episodes where the latest submission was before the current year and the record started earlier with an open end date.
Do if Number(!altFY, F4.0) > Number(char.substr(sc_latest_submission, 1, 4), F4.0).
    Compute old_open_record = sysmis(hc_service_end_date) AND hc_service_start_date < !startFY.
End if.

Select if sysmis(old_open_record).

Alter type
    sending_location (A3)
    social_care_id (A10)
    postcode (A8)
    reablement (F1.0)
    hc_service_provider (F1.0).

Recode reablement (SYSMIS = 9).

sort cases by sending_location social_care_id.

* Match on Client data.
match files file = *
    /table = !Year_dir + "Client_for_Source-20" + !FY + ".zsav"
    /By sending_location social_care_id.

Rename Variables
    hc_service_start_date = record_keydate1
    hc_service_end_date = record_keydate2
    reablement = hc_reablement
    hc_service_provider = hc_provider.

String Year (A4).
Compute Year = !FY.

string recid (A3).
Compute recid = "HC".

* Use hc_service to create the SMRType.
string SMRType (A10).
Do if hc_service = 1.
    compute SMRType = "HC-Non-Per".
Else if hc_service = 2.
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

Define !keep_correct_hours (fin_year = !tokens(1)).
    Rename variables
        !Concat("hc_hours_", !unquote(!fin_year), "Q1") = hc_hours_q1
        !Concat("hc_hours_", !unquote(!fin_year), "Q2") = hc_hours_q2
        !Concat("hc_hours_", !unquote(!fin_year), "Q3") = hc_hours_q3
        !Concat("hc_hours_", !unquote(!fin_year), "Q4") = hc_hours_q4
        !Concat("hc_cost_", !unquote(!fin_year), "Q1") = hc_cost_q1
        !Concat("hc_cost_", !unquote(!fin_year), "Q2") = hc_cost_q2
        !Concat("hc_cost_", !unquote(!fin_year), "Q3") = hc_cost_q3
        !Concat("hc_cost_", !unquote(!fin_year), "Q4") = hc_cost_q4.
!EndDefine.

!keep_correct_hours fin_year = !altFY.

* Create annual hours variable.
Compute hc_hours_annual = sum(hc_hours_q1 to hc_hours_q4).

* Create annual cost (cost_total_net).
Compute cost_total_net = sum(hc_cost_q1 to hc_cost_q4).

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
    hc_hours_annual
    hc_hours_q1
    hc_hours_q2
    hc_hours_q3
    hc_hours_q4
    cost_total_net
    hc_cost_q1
    hc_cost_q2
    hc_cost_q3
    hc_cost_q4
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
