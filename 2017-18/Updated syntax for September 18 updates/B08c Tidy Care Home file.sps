* Encoding: UTF-8.
************************************************************************************************************
NSS (ISD)
************************************************************************************************************
** AUTHOR:	James McMahon (j.mcmahon1@nhs.net)
** Date:    	03/05/2018
************************************************************************************************************
** Amended by:
** Date:
** Changes:
***********************************************************************************************************.
********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

get file = !File + "Care-Home-Temp-4.zsav".

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
 * 1. Financial year.
Variable Labels year 'Financial Year'.

 * 2. Sending LCA.
Rename Variables SendingCouncilAreaCode = sc_send_lca.
Variable Labels sc_send_lca 'Social care data sending local authority'.

 * 4. Practice code.
Rename Variables PracticeCode = gpprac.
Variable Labels gpprac 'GP Practice code'.

 * 6. UPI / CHI number - rename and make sure this is a 10-char string.
Rename Variables UPINumber = chi.
Variable Labels chi 'Community Health Index number'.

 * 7. Age.
Variable Labels age 'Age of patient at midpoint of financial year'.

 * 8. DOB - get into numeric format.
Rename Variables ClientDoB = dob.
alter type dob (Date12).

 * 9. Gender - Recode to number, male = 1, female = 2.
Compute GenderDescription = Lower(GenderDescription).
Recode GenderDescription ("male" = 1) ("female" = 2) (Else = 0) Into gender.
alter type gender (F1.0).
Variable Labels gender 'Gender'.
Delete Variables GenderDescription.

 * 10 - HB residence.
Rename Variables NHSBoardofResidenceCode = hbrescode.

 * 11. client_lca.
Rename Variables ClientCouncilAreaCode = lca.

 * 13. client postcode - check same format as pc7 in source.
 * make sure that postcodes with 5 characters have a double space in the middle.
Rename Variables ClientPostcode = postcode.

 * 14. Create a recid variable.
string recid (a3).
Compute recid eq 'CH'.

 * create variable SMRType.
string SMRType (a10).
compute SMRType = 'Care-Home'.

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

 * 16 Care Home name. 
Rename Variables carehomename = ch_name.

Variable Labels ch_name 'Name of care home where the client/service user resides'.

 * 17. care home lca.
Rename Variables CareHomeCouncilAreaCode = ch_lca.

Variable Labels ch_lca 'Care home local authority'.

 * 18. reason for admission.
Rename Variables ReasonforAdmission = ch_admreas.

value labels ch_admreas
1 'Respite'
10 'Other'
3 'Emergency'
4 'Palliative Care'
5 'Dementia'
6 'Elderly Mental Health' 
7 'Learning Disability'
8 'High Dependency'.

Variable Labels ch_admreas 'Primary reason for admission to a care home'.

 * 19. Costing variables.
Rename Variables FinYearCostofEpisode = cost_total_net.

sort cases by chi record_keydate1.

 * Delete variables we don't need any more.
save outfile = !File + "Care_Home_For_Source-20" + !FY + ".zsav"
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
    ch_lca
    ch_admreas
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
get file = !File + "Care_Home_For_Source-20" + !FY + ".zsav".

 * Housekeeping.
erase file = !File + "Care-Home-Temp-1.zsav".
erase file = !File + "Care-Home-Temp-2.zsav".
erase file = !File + "Care-Home-Temp-3.zsav".
erase file = !File + "Care-Home-Temp-4.zsav".

* zip up the raw data.
Host Command = ["zip -m '" + !Extracts + "Care-Home-full-extract-20" + !FY + ".zip' '" +
   !Extracts + "Care-Home-full-extract-20" + !FY + ".csv'"].
Host Command = ["zip -m '" + !Extracts + "Care-Home-Lookup-20" + !FY + ".zip' '" +
   !Extracts + "Care_home_lookup-20" + !FY + ".sav'"].

 * Number of new variables = 4
   care home admission reason
   sending LCA
   care home LCA
   care home name




