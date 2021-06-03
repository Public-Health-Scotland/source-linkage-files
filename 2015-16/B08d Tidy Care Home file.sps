* Encoding: UTF-8.
************************************************************************************************************
    NSS (ISD)
    ************************************************************************************************************
    ** AUTHOR:	James McMahon (james.mcmahon@phs.scot)
    ** Date:    	03/05/2018
    ************************************************************************************************************
    ** Amended by:
    ** Date:
    ** Changes:
    ***********************************************************************************************************.
********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

get file = !Year_dir + "Care-Home-Temp-2.zsav".

***********************************************************************************************************.
* Add dictionary information.
Value labels SendingCouncilAreaCode ClientCouncilAreaCode CareHomeCouncilAreaCode
    '01' "Aberdeen City"
    '02' "Aberdeenshire"
    '03' "Angus"
    '04' "Argyll and Bute"
    '05' "Scottish Borders"
    '06' "Clackmannanshire"
    '07' "West Dunbartonshire"
    '08' "Dumfries and Galloway"
    '09' "Dundee City"
    '10' "East Ayrshire"
    '11' "East Dunbartonshire"
    '12' "East Lothian"
    '13' "East Renfrewshire"
    '14' "City of Edinburgh"
    '15' "Falkirk"
    '16' "Fife"
    '17' "Glasgow City"
    '18' "Highland"
    '19' "Inverclyde"
    '20' "Midlothian"
    '21' "Moray"
    '22' "North Ayrshire"
    '23' "North Lanarkshire"
    '24' "Orkney Islands"
    '25' "Perth and Kinross"
    '26' "Renfrewshire"
    '27' "Shetland Islands"
    '28' "South Ayrshire"
    '29' "South Lanarkshire"
    '30' "Stirling"
    '31' "West Lothian"
    '32' "Na h-Eileanan Siar".

***********************************************************************************************************.
Rename Variables
carehomename = ch_name
ClientCouncilAreaCode = lca
ClientDoB = dob
ClientPostcode = postcode
NHSBoardofResidenceCode = hbrescode
nursing_care_provision = ch_nursing
PracticeCode = gpprac
ReasonforAdmission = ch_adm_reason
SendingCouncilAreaCode = sc_send_lca
UPINumber = chi.

alter type dob (Date12).

Compute GenderDescription = Lower(GenderDescription).
Recode GenderDescription ("male" = 1) ("female" = 2) (Else = 0) Into gender.
alter type gender (F1.0).
Delete Variables GenderDescription.



* Create a recid variable.
string recid (a3).
Compute recid = "CH".

* create variable SMRType.
string SMRType (A10).
compute SMRType = "Care-Home".

* 15. admission and discharge dates in numeric and date format.
Rename Variables
    admission = record_keydate1
    discharge = record_keydate2.

alter type record_keydate1 record_keydate2 (A10).

* In case keydate is needed as F8.0...
Compute record_keydate1 = Concat(char.Substr(record_keydate1, 1, 4), char.Substr(record_keydate1, 6, 2), char.Substr(record_keydate1, 9, 2)).
alter type record_keydate1 (F8.0).

Compute record_keydate2 = Concat(char.Substr(record_keydate2, 1, 4), char.Substr(record_keydate2, 6, 2), char.Substr(record_keydate2, 9, 2)).
alter type record_keydate2 (F8.0).

value labels ch_adm_reason
    1 'Respite'
    10 'Other'
    3 'Emergency'
    4 'Palliative Care'
    5 'Dementia'
    6 'Elderly Mental Health'
    7 'Learning Disability'
    8 'High Dependency'.

sort cases by chi record_keydate1.

* Delete variables we don't need any more.
save outfile = !Year_dir + "Care_Home_For_Source-20" + !FY + ".zsav"
    /Keep
    year
    recid
    SMRType
    record_keydate1
    record_keydate2
    chi
    gender
    dob
    Age
    postcode
    hbrescode
    lca
    gpprac
    sc_send_lca
    ch_name
    ch_nursing
    ch_adm_reason
    stay
    yearStay
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
    Apr_cost
    May_cost
    Jun_cost
    Jul_cost
    Aug_cost
    Sep_cost
    Oct_cost
    Nov_cost
    Dec_cost
    Jan_cost
    Feb_cost
    Mar_cost
    /zcompressed.
get file = !Year_dir + "Care_Home_For_Source-20" + !FY + ".zsav".

* Housekeeping.
erase file = !Year_dir + "Care-Home-Temp-1.zsav".
erase file = !Year_dir + "Care-Home-Temp-2.zsav".

* zip up the raw data.
Host Command = ["gzip '" + !Year_Extracts_dir + "Care-Home-full-extract-20" + !FY + ".csv'"].
