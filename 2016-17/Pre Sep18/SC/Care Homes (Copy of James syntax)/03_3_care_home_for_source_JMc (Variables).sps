************************************************************************************************************
NSS (ISD)
************************************************************************************************************
** AUTHOR:	James McMahon (j.mcmahon1@nhs.net)
** Date:    	03/05/2018
************************************************************************************************************
** Amended by:
** Date:
** Changes:
************************************************************************************************************.
get file= "CareHomeTemp.zsav".

***********************************************************************************************************.
 * Add dictionary information.
insert file = "d1_Add_LCACode_dict.sps".
!Add_LCACode_dict vars = SendingCouncilAreaCode ClientCouncilAreaCode CareHomeCouncilAreaCode.

***********************************************************************************************************.
 * 1. Financial year.
Rename Variables FinancialYear = year.
alter type year (A4).
Compute year = Concat(char.substr(year, 3, 2), string(number(char.substr(year, 3, 2), F2.0) + 1, F2.0)).

Variable Labels year 'Year'.

 * 2. Sending LCA.
Rename Variables SendingCouncilAreaCode = sc_send_lca.
Variable Labels sc_send_lca 'Social care data sending local authority'.


 * 3. HB practice code.
Rename Variables PracticeNHSBoardCode = hbpraccode.
Variable Labels hbpraccode 'NHS Board of GP Practice'.


 * 4. Practice code - ensure this is a 6-char string and rename.
Rename Variables PracticeCode = prac.
Variable Labels prac 'GP Practice code'.

 * 6. UPI / CHI number - rename and make sure this is a 10-char string.
Rename Variables UPINumber = chi.
Variable Labels chi 'Community Health Index number'.

 * 7. Age.
Rename Variables AgeatMidpointofFinancialYear = age.
Variable Labels age 'Age of patient at midpoint of financial year'.

 * 8. DOB - get into numeric format.
Rename Variables ClientDoB = dob.

alter type dob (Sdate10).
alter type dob (A10).
Compute dob = Concat(char.Substr(dob, 1, 4), char.Substr(dob, 6, 2), char.Substr(dob, 9, 2)).
alter type dob (F8.0).

 * 9. Gender - Recode to number, male = 1, female = 2.
Recode GenderDescription ("Male" = 1) ("Female" = 2) (Else = 9) Into gender.
alter type gender (F1.0).
Variable Labels gender 'Gender'.
Delete Variables GenderDescription.

 * 10 - HB residence.
Rename Variables NHSBoardofResidenceCode = hbrescode.

 * 11. client_lca.
Rename Variables ClientCouncilAreaCode = lca.

 * 12. client DZ.
Rename Variables ClientDataZone2001 = DataZone2001.
Rename Variables ClientDataZone2011 = DataZone2011.

Alter type DataZone2001 DataZone2011 (A27). 

 * 13. client postcode - check same format as pc7 in source.
 * make sure that postcodes with 5 characters have a double space in the middle.
Rename Variables ClientPostcode = pc7.

 * 14. Create a recid variable.
string recid (a3).
Compute recid eq 'CH'.

 * create variable SMRType.
string SMRType (a10).
compute SMRType = 'Care-Home'.

 * 15. admission and discharge dates in numeric and date format.
Rename Variables admission = record_keydate1 discharge = record_keydate2.

Compute keydate1_dateformat = record_keydate1.
Compute keydate2_dateformat = record_keydate2.

alter type record_keydate1 record_keydate2 (A10) keydate1_dateformat keydate2_dateformat (Date10).

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
Rename Variables
   April_cost = april_cost
   May_cost = may_cost
   June_cost = june_cost
   July_cost = july_cost
   August_cost = august_cost
   September_cost = sept_cost
   October_cost = oct_cost
   November_cost = nov_cost
   December_cost = dec_cost
   January_cost = jan_cost
   February_cost = feb_cost
   March_cost = mar_cost
   April_beddays = april_beddays
   May_beddays = may_beddays
   June_beddays = june_beddays
   July_beddays = july_beddays
   August_beddays = august_beddays
   September_beddays = sept_beddays
   October_beddays = oct_beddays
   November_beddays = nov_beddays
   December_beddays = dec_beddays
   January_beddays = jan_beddays
   February_beddays = feb_beddays
   March_beddays = mar_beddays.
	
Rename Variables FinYearCostofEpisode = cost_total_net.
Compute Cost_Total_Net_incDNAs = cost_total_net.

 * Delete variables we don't need any more.
save outfile =  "CareHomeForSource.zsav"
   /Drop counter NursingCareProvision CareHomeAdmissionDate CareHomeDischargeDate CareHomePostcode AgeGroup CostofEpisode
   /zcompressed.

 * delete old file.
erase file = 'CareHomeTemp.zsav'.


