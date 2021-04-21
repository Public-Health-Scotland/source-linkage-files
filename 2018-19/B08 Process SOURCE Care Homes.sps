* Encoding: UTF-8.
get file = !Extracts_Alt + "All Care Home episodes.zsav".

* Adjust discharge dates according to death dates.
* Match on the death dates from the deceased lookup (year specific).
match files file = *
    /table = !Extracts_Alt + "All Deaths.zsav"
    /by = chi.

* Create a flag to identify the last record where an episode has been split.
add files file = *
    /last = last_scem_ep
    /by chi scem.

* Flag to identify which episodes were changed and why.
Compute changed_dis_date = 0.

* Episodes where the death_date is within 1-5 days of the dis date.
do if range(datediff(sc_date_2, death_date "days"), 1, 5).
    * Some tracking variables.
    Compute days_after_death = datediff(sc_date_2, death_date "days").
    Compute changed_dis_date = 1.
    * Create new variables for now, this will overwrite in the final version.
    Compute new_sc_date_2 = death_date.
    If last_scem_ep new_record_keydate2 = death_date.
* Episodes not affected by the above but where the CHI death date fits the criteria (most CHIs have the same death date so this is a small number).
else if range(datediff(sc_date_2, death_date_CHI "days"), 1, 5).
    Compute days_after_death = datediff(sc_date_2, death_date_CHI "days").
    Compute changed_dis_date = 2.
    Compute new_sc_date_2 = death_date_CHI.
    If last_scem_ep new_record_keydate2 = death_date_CHI.
end if.

* Now select episodes for given FY, need to do this now as discharge dates may have been moved out of the FY above.
select if Range(record_keydate1, !startFY, !endFY) or (record_keydate1 < !startFY and (record_keydate2 >= !startFY or sysmis(record_keydate2))).

* Match on Client data.
match files file = *
    /table = !File + "Client_for_Source-20" + !FY + ".zsav"
    /By sending_location social_care_id.

String Year (A4).
Compute Year = !FY.

string recid (a3).
Compute recid eq 'CH'.

string SMRType (a10).
compute SMRType = 'Care-Home'.

Numeric age (F3.0).
Compute age = datediff(!midFY, dob, "years").

* Uses sending_location and recodes into sc_sending_location using actual codes.
!Create_sc_sending_location.

* Work out bed days per month.
* Create a dummy end date for those with a blank end date.
Compute #dummy_discharge_date = record_keydate2.
If missing(#dummy_discharge_date) #dummy_discharge_date = !endFY + time.days(1).

Begin Program.
from calendar import month_name
import spss

#Loop through the months by number in FY order
for month in (4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3):
    #To show what is happening print some stuff to the screen
    print(month, month_name[month])

    #Set up the syntax
    syntax = "!BedDaysPerMonth Month_abbr = " + month_name[month][:3]

    #Use the correct admission and discharge variables
    syntax += " AdmissionVar = record_keydate1 DischargeVar = #dummy_discharge_date."

    #print the syntax to the screen
    print(syntax)

    #run the syntax
    spss.Submit(syntax)
End Program.

Numeric yearstay stay (F7.0).
compute yearstay = apr_beddays + may_beddays + jun_beddays + jul_beddays + aug_beddays + sep_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
* Work out total length of stay.
* Get the time before this FY, add it to yearstay (round to ignore the .33 for daycases) and then add on any days after this FY.
* Note those without end dates are given 365 as yearstay so will get 365 days for this FY in stay too.
* It's a bit complicated so that it can handle the episodes with no end date.
Compute stay = Max(datediff(!startFY, record_keydate1, "days"), 0) + Rnd(yearstay) + Max(datediff(record_keydate2, !endFY + time.days(1), "days"), 0).

* Match on the costs lookup.
sort cases by year ch_nursing.
match files
    /file = *
    /Table = !Extracts_Alt + "Costs/Cost_CH_Lookup.sav"
    /rename nursing_care_provision = ch_nursing
    /By year ch_nursing.

* Costs.
* Declare Variables.
Numeric apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost (F8.2).
* Calculate Cost per month from beddays and daily cost.
* We're only doing this for over 65s.
Do Repeat Beddays = Apr_beddays to Mar_beddays
    /Cost = Apr_cost to Mar_cost.
    Do if Age >= 65 or missing(age).
        Compute Cost = Beddays * Cost_Per_Day.
    End if.
End Repeat.

Compute cost_total_net = Sum(apr_cost to mar_cost).

* In case keydate is needed as F8.0...
alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

* To be changed later.
* Just to match existing files.
Alter type ch_provider (A1).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !File + "care_home_for_source-20" + !FY + ".zsav"
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
    sc_date_1
    sc_date_2
    scem
    sc_latest_submission
    ch_name
    ch_adm_reason
    ch_provider
    ch_nursing
    yearstay
    stay
    cost_total_net
    Apr_beddays
    May_beddays
    Jun_beddays
    Jul_beddays
    Aug_beddays
    Sep_beddays
    Oct_beddays
    Nov_beddays
    Dec_beddays
    Jan_beddays
    Feb_beddays
    Mar_beddays
    apr_cost
    may_cost
    jun_cost
    jul_cost
    aug_cost
    sep_cost
    oct_cost
    nov_cost
    dec_cost
    jan_cost
    feb_cost
    mar_cost
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    /zcompressed.
get file = !File + "care_home_for_source-20" + !FY + ".zsav".
