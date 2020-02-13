* Encoding: UTF-8.
get file = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_CH_extracts_ELoth_NLan_SLan.zsav".

Alter type social_care_id (A10) financial_year (A4).

sort cases by social_care_id sending_location.
match files file = *
    /table = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_Client_for_source.zsav"
    /By social_care_id sending_location.

Rename Variables
    ch_admission_date = record_keydate1
    ch_discharge_date = record_keydate2
    chi_gender_code = gender
    chi_postcode = postcode
    chi_date_of_birth = dob
    reason_for_admission = ch_adm_reason
    seeded_chi_number = chi.

Alter type nursing_care_provision (F1.0) gender (F1.0) postcode (A8) ch_name (A73).

 * If the chi seeded postcode is blank use the submitted one.
If postcode = "" postcode = submitted_postcode.

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

*******************************************************************************************************.
SPSSINC TRANS RESULT = ch_name Type = 73
   /FORMULA "string.capwords(ch_name)".

Sort Cases by ch_postcode ch_name.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName CareHomeCouncilAreaCode = ch_postcode ch_name ch_lca)
    /In = AccurateData1
    /By ch_postcode ch_name.
Frequencies AccurateData1.
* 35.8% Match the lookup.

 * Guess some possible names for ones which don't match the lookup.
String TestName1 TestName2(A73).
Do if AccurateData1 = 0.
    * Try adding 'Care Home' or 'Nursing Home' on the end.
   Compute TestName1 = Concat(Rtrim(ch_name), " Care Home").
   Compute TestName2 = Concat(Rtrim(ch_name), " Nursing Home").
    * If they have the above name ending already, try removing / replacing it.
   Do if char.index(ch_name, "Care Home") > 1.
      Compute TestName1 = Strunc(ch_name, char.index(ch_name, "Care Home") - 1).
      Compute TestName2 = Replace(ch_name, "Care Home", "Nursing Home").
   Else if char.index(ch_name, "Nursing Home") > 1.
      Compute TestName1 = Strunc(ch_name, char.index(ch_name, "Nursing Home") - 1).
      Compute TestName2 = Replace(ch_name, "Nursing Home", "Care Home").
   Else if char.index(ch_name, "Nursing") > 1.
      Compute TestName1 = Strunc(ch_name, char.index(ch_name, "Nursing") - 1).
      Compute TestName2 = Replace(ch_name, "Nursing", "Care Home").
   * If ends in brackets replace it.
   Else if char.index(ch_name, "(") > 1.
      Compute TestName1 = Concat(Rtrim(Strunc(ch_name, char.index(ch_name, "(") - 1)), " Care Home").
      Compute TestName2 = Concat(Rtrim(Strunc(ch_name, char.index(ch_name, "(") - 1)), " Nursing Home").
   End if.
End if.

*******************************************************************************************************.
 * Check if TestName1 makes the record match the lookup.
Sort Cases by ch_postcode TestName1.
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /Rename (CareHomeName CareHomePostcode = TestName1 ch_postcode)
   /In = TestName1Correct
   /By ch_postcode TestName1.

*******************************************************************************************************.
 * Check if TestName2 makes the record match the lookup.
Sort Cases by ch_postcode TestName2.
match files
   /file = *
   /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
   /Rename (CareHomeName CareHomePostcode = TestName2 ch_postcode)
   /In = TestName2Correct
   /By ch_postcode TestName2.

 * If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 AND TestName2Correct = 0.
   Compute ch_name = TestName1.
Else If TestName2Correct = 1 AND TestName1Correct = 0.
   Compute ch_name = TestName2.
End If.
Frequencies TestName1Correct TestName2Correct.

*******************************************************************************************************.
* See which match now.
Sort Cases by ch_postcode ch_name CareHomeCouncilAreaCode .
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name)
    /In = AccurateData2
    /By ch_postcode ch_name.
Frequencies AccurateData2.
* 54.9% Match the lookup.
Delete Variables TestName1 TestName2 TestName1Correct TestName2Correct AccurateData1 AccurateData2.

 * Add dictionary info.
!AddLCADictionaryInfo LCA = sc_send_lca ch_lca.

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

Descriptives apr_beddays to stay.

* Match on the costs lookup.
sort cases by year nursing_care_provision.
match files
    /file = *
    /Table = !Extracts_Alt + "Costs/Cost_CH_Lookup.sav"
    /By year nursing_care_provision.

Rename Variables
nursing_care_provision = ch_nursing.

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

Value Labels ch_adm_reason
    1 'Respite'
    2 'Intermediate Care (includes Step Up/Step Down)'
    3 'Emergency'
    4 'Palliative Care'
    5 'Dementia'
    6 'Elderly Mental Health'
    7 'Learning Disability'
    8 'High Dependency'
    9 'Choice'
    10 'Other'.

Value Labels ch_nursing
    0 'No'
    1 'Yes'.

Value Labels ch_provider
    1 'Local Authority / Health & Social Care Partnership'
    2 'Private'
    3 'Other Local Authority'
    4 'Third Sector'
    5 'NHS Board'
    6 'Other'.

* In case keydate is needed as F8.0...
alter type record_keydate1 record_keydate2 (SDATE10).
alter type record_keydate1 record_keydate2 (A10).

Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

sort cases by chi record_keydate1 record_keydate2.

save outfile = !File + "Care_Home_For_Source-20" + !FY + ".zsav"
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
get file = !File + "Care_Home_For_Source-20" + !FY + ".zsav".
