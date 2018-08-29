* 2016/17 data.
* Creating an aggregated master PLICs file with one row per client.
* Note that clients will be excluded.
* The aggregated file will contain the following data sets:
   * SMR00 - Outpatients
   * SMR01 - Acute inpatients/day cases
   * SMR02 - Maternity
   * SMR04 - Mental Health
   * SMR01_1E - Geriatric Long Stay
   * Accident & Emergency
   * Prescribing
   * GP OOH - GP Out of Hours
   * DN - District Nursing
   * Care Homes

* Program created by Denise Hastie, October 2013.
* Program updated by Denise Hastie, May 2015 to reflect changes made in Julie's costed files.
* Program updated by Denise Hastie, August 2016 to make the addition of LTCs be in line with the master PLICS file for 14/15.
* Deceased flag will also be updated. The geography and deprivation section has also been changed to be the same as the * updated version of the 14/15 master plics SPSS program.

* Changing file paths and where appropriate names to Source linkage files. Denise Greig, October 2017.

*************************************************************************************************************************************************.

* Episode file location.
define !EpisodeFiles()
   '/conf/sourcedev/'
!enddefine.

* Network area whilst preparing file.
define !file()
   '/conf/sourcedev/'
!enddefine.

*define FY.
define !FY()
   '1617'
!enddefine.

Define !FYMidpoint()
   20160930
!EndDefine.


get file = !EpisodeFiles + 'source-episode-file-20' + !FY + '.zsav'.

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
select if (substr(chi, 1, 2) ge '01' and substr(chi, 1, 2) le '31' AND chi ne ' ').

 * Sort data into chi and episode date order.
Sort cases by chi keydate1_dateformat.

 * Declare the variables we will sue to store postcode etc. data.
Numeric acute_dob mat_dob mentalh_dob gls_dob op_dob ae_dob pis_dob ch_dob ooh_dob DN_dob (F8.0).
String acute_postcode mat_postcode mentalh_postcode gls_postcode op_postcode ae_postcode pis_postcode ch_postcode ooh_postcode DN_postcode (A7).
String acute_prac mat_prac mentalh_prac gls_prac op_prac ae_prac pis_prac ch_prac ooh_prac DN_prac (A5).

 * Set any blanks as user missing, so they will be ignored by the aggregate. 
Missing Values acute_postcode To DN_postcode ("       ")
   /acute_prac To DN_prac ("     ").

*************************************************************************************************************************************************.
* For SMR01/02/04/01_1E: sum activity and costs per patient with an Elective/Non-Elective split.
* Acute (SMR01) section.

Do if (smrtype eq 'Acute-DC' OR smrtype eq 'Acute-IP') AND (newpattype_cis ne 'Maternity').
   Compute acute_dob = dob.
   Compute acute_postcode = pc7.
   Compute acute_prac = gpprac.

   * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
   * Activity (count the episodes).
   compute acute_episodes = 1.
   compute acute_daycase_episodes = 0.
   compute acute_inpatient_episodes = 0.
   compute acute_el_inpatient_episodes = 0.
   compute acute_non_el_inpatient_episodes = 0.

   if (IPDC = 'D') acute_daycase_episodes = 1.
   if (IPDC = 'I') acute_inpatient_episodes = 1.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') acute_non_el_inpatient_episodes = 1.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') acute_el_inpatient_episodes = 1.

   * Cost (use the Cost_Total_Net).
   compute acute_cost = Cost_Total_Net.
   compute acute_daycase_cost = 0.
   compute acute_inpatient_cost = 0.
   compute acute_el_inpatient_cost = 0.
   compute acute_non_el_inpatient_cost = 0.

   if (IPDC = 'D') acute_daycase_cost = Cost_Total_Net.
   if (IPDC = 'I') acute_inpatient_cost = Cost_Total_Net.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') acute_el_inpatient_cost = Cost_Total_Net.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') acute_non_el_inpatient_cost = Cost_Total_Net.

   *Beddays for inpatients (use the yearstay).
   compute acute_inpatient_beddays = 0.
   compute acute_el_inpatient_beddays = 0.
   compute acute_non_el_inpatient_beddays = 0.

   if (IPDC = 'I') acute_inpatient_beddays = yearstay.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') acute_el_inpatient_beddays = yearstay.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') acute_non_el_inpatient_beddays = yearstay.

Else if (newpattype_cis eq 'Maternity').
   *************************************************************************************************************************************************.
   * Maternity (SMR02) section.
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
      append this to the end of each record for each patient.
   Compute mat_dob  = dob.
   Compute mat_postcode = pc7.
   Compute mat_prac = gpprac.

   * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
   * Activity (count the episodes).
   compute mat_episodes = 1.
   compute mat_daycase_episodes = 0.
   compute mat_inpatient_episodes = 0.

   if (IPDC = 'I') mat_inpatient_episodes = 1.
   if (IPDC = 'D') mat_daycase_episodes = 1.

   * Cost (use the Cost_Total_Net).
   compute mat_cost = Cost_Total_Net.
   compute mat_daycase_cost = 0.
   compute mat_inpatient_cost = 0.

   if (IPDC = 'D') mat_daycase_cost = Cost_Total_Net.
   if (IPDC = 'I') mat_inpatient_cost = Cost_Total_Net.

   *Beddays for inpatients (use the yearstay).
   compute mat_inpatient_beddays = 0.

   if (IPDC = 'I') mat_inpatient_beddays = yearstay.

Else if (recid eq '04B') AND (newpattype_cis ne 'Maternity').
   *************************************************************************************************************************************************.
   * Mental Health (SMR04) section.
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
      append this to the end of each record for each patient.
   Compute mentalh_dob  = dob.
   Compute mentalh_postcode = pc7.
   Compute mentalh_prac = gpprac.

   * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
   * Activity (count the episodes).
   compute mentalh_episodes = 1.
   compute mentalh_daycase_episodes = 0.
   compute mentalh_inpatient_episodes = 0.
   compute mentalh_el_inpatient_episodes = 0.
   compute mentalh_non_el_inpatient_episodes = 0.

   if (IPDC = 'D') mentalh_daycase_episodes = 1.
   if (IPDC = 'I') mentalh_inpatient_episodes = 1.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') mentalh_el_inpatient_episodes = 1.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') mentalh_non_el_inpatient_episodes = 1.

   * Cost (use the Cost_Total_Net).
   compute mentalh_cost = Cost_Total_Net.
   compute mentalh_inpatient_cost = 0.
   compute mentalh_daycase_cost = 0.
   compute mentalh_el_inpatient_cost = 0.
   compute mentalh_non_el_inpatient_cost = 0.

   if (IPDC = 'D') mentalh_daycase_cost = Cost_Total_Net.
   if (IPDC = 'I') mentalh_inpatient_cost = Cost_Total_Net.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') mentalh_el_inpatient_cost = Cost_Total_Net.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') mentalh_non_el_inpatient_cost = Cost_Total_Net.

   *Beddays for inpatients (use the yearstay).
   compute mentalh_inpatient_beddays = 0.
   compute mentalh_el_inpatient_beddays = 0.
   compute mentalh_non_el_inpatient_beddays = 0.

   if (IPDC = 'I') mentalh_inpatient_beddays = yearstay.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') mentalh_el_inpatient_beddays = yearstay.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') mentalh_non_el_inpatient_beddays = yearstay.

Else if (smrtype eq 'GLS-IP').
   *************************************************************************************************************************************************.
   * Geriatric Long Stay (SMR01_1E) section.
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
      append this to the end of each record for each patient.
   Compute gls_dob  = dob.
   Compute gls_postcode = pc7.
   Compute gls_prac = gpprac.

   * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
   * Activity (count the episodes).
   compute gls_episodes = 1.
   compute gls_daycase_episodes = 0.
   compute gls_inpatient_episodes = 0.
   compute gls_el_inpatient_episodes = 0.
   compute gls_non_el_inpatient_episodes = 0.


   if (IPDC = 'D') gls_daycase_episodes = 1.
   if (IPDC = 'I') gls_inpatient_episodes = 1.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') gls_non_el_inpatient_episodes = 1.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') gls_el_inpatient_episodes = 1.

   * Cost (use the Cost_Total_Net).
   compute gls_cost = Cost_Total_Net.
   compute gls_daycase_cost = 0.
   compute gls_inpatient_cost = 0.
   compute gls_el_inpatient_cost = 0.
   compute gls_non_el_inpatient_cost = 0.

   if (IPDC = 'D') gls_daycase_cost = Cost_Total_Net.
   if (IPDC = 'I') gls_inpatient_cost = Cost_Total_Net.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') gls_el_inpatient_cost = Cost_Total_Net.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') gls_non_el_inpatient_cost = Cost_Total_Net.

   *Beddays for inpatients (use the yearstay).
   compute gls_inpatient_beddays = 0.
   compute gls_el_inpatient_beddays = 0.
   compute gls_non_el_inpatient_beddays = 0.

   if (IPDC = 'I') gls_inpatient_beddays = yearstay.
   if (newpattype_CIS = 'Elective' and IPDC = 'I') gls_el_inpatient_beddays = yearstay.
   if (newpattype_CIS = 'Non-Elective' and IPDC = 'I') gls_non_el_inpatient_beddays = yearstay.

Else if (recid eq '00B').
   *************************************************************************************************************************************************.
   * Outpatients (SMR00) section.
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
      append this to the end of each record for each patient.

   Compute op_dob  = dob.
   Compute op_postcode = pc7.
   Compute op_prac = gpprac.

   * Activity (count the attendances).
   compute op_newcons_attendances = 0.
   compute op_newcons_dnas = 0.

   if (attendance_status eq '1') op_newcons_attendances = 1.
   if (attendance_status ne '1') op_newcons_dnas = 1.

   * Cost.
   Compute op_cost_attend = Cost_Total_Net.

   * Cost (for DNAs).
   compute op_cost_dnas = 0.
   if (attendance_status gt '1') op_cost_dnas = Cost_Total_Net_incDNAs.

Else if (recid eq 'AE2').
   *************************************************************************************************************************************************.
   * Accident and Emergency (AE2) section (sum the number of of attendances and costs associated).
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
      append this to the end of each record for each patient.
   Compute ae_dob  = dob.
   Compute ae_postcode = pc7.
   Compute ae_prac = gpprac.

   * Activity (count the attendances).
   compute ae_attendances = 1.
   compute ae_cost = Cost_Total_Net.

Else if (recid eq 'PIS').
   *************************************************************************************************************************************************.
   * Prescribing (PIS) section.
   * For Prescribing: sum the information by patient * only one row per person exists in the master PLICs file with minimal data.

   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
      append this to the end of each record for each patient.
   Compute pis_dob  = dob.
   Compute pis_postcode = pc7.
   Compute pis_prac = gpprac.

   Compute pis_dispensed_items = no_dispensed_items.
   Compute pis_cost = Cost_Total_Net.

Else if (recid = 'CH').
   *************************************************************************************************************************************************.
   * Care Home (CH) section.
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
   Compute ch_dob  = dob.
   Compute ch_postcode = pc7.
   Compute ch_prac = gpprac.

   * Count the number of distinct episodes.
   compute ch_episodes = 1.

   * Cost (use the Cost_Total_Net).
   compute ch_cost = Cost_Total_Net.

   *Beddays for residents (use the yearstay).
   compute ch_beddays = yearstay.

Else if (recid = 'OoH').
   *************************************************************************************************************************************************.
   * GP Out of Hours (OoH) section.
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
   Compute ooh_dob  = dob.
   Compute ooh_postcode = pc7.
   Compute ooh_prac = gpprac.

   * For activity count the number of consultations of each type.
   Do If SMRtype = "OOH-HomeV".
      Compute ooh_homeV = 1.
   Else If SMRtype = "OOH-Advice".
      Compute ooh_advice = 1.
   Else If SMRtype = "OOH-DN".
      Compute ooh_DN = 1.
   Else If SMRtype = "OOH-NHS24".
      Compute ooh_NHS24 = 1.
   Else If SMRtype = "OOH-Other".
      Compute ooh_other = 1.
   Else If SMRtype = "OOH-PCC".
      Compute ooh_PCC = 1.
   End If.

   * Cost (use the Cost_Total_Net).
   compute ooh_cost = Cost_Total_Net.

   * Time.
   compute ooh_consultation_time = DateDiff(keydate2_dateformat + keyTime2,  keydate1_dateformat + KeyTime1, "minutes").
   if ooh_consultation_time < 0 ooh_consultation_time = 0.

Else if (recid = 'DN').
   *************************************************************************************************************************************************.
   * District Nursing (DN) section.
   * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
   Compute DN_dob  = dob.
   Compute DN_postcode = pc7.
   Compute DN_prac = gpprac.

   * For activity count the number of episodes and the contacts.
   Compute DN_episodes = 1.
   Compute DN_contacts = TotalnoDNcontacts.

   * Cost (use the Cost_Total_Net).
   compute DN_cost = Cost_Total_Net.

   * Time.
   compute DN_total_duration = TotalDurationofContacts.
End if.

*************************************************************************************************************************************************.
 * We'll use this to get the most accurate gender we can.
Recode gender (0 = 1.5) (9 = 1.5).

 * Now aggregate by Chi, keep all of the variables we made, we'll clean them up next.
 * Also keep variables that are only dependant on CHI (as opposed to postcode) e.g. deat_date, cohorts, LTC etc.
 * Using Presorted so that we keep the ordering from earlier (chi, keydate1).
aggregate outfile = *
   /Presorted
   /break chi
   /gender = Mean(gender)
   /acute_postcode mat_postcode mentalh_postcode gls_postcode op_postcode ae_postcode pis_postcode ch_postcode ooh_postcode DN_postcode
      = Last(acute_postcode mat_postcode mentalh_postcode gls_postcode op_postcode ae_postcode pis_postcode ch_postcode ooh_postcode DN_postcode)
   /acute_dob mat_dob mentalh_dob gls_dob op_dob ae_dob pis_dob ch_dob ooh_dob DN_dob
      = Last(acute_dob mat_dob mentalh_dob gls_dob op_dob ae_dob pis_dob ch_dob ooh_dob DN_dob)
   /acute_prac mat_prac mentalh_prac gls_prac op_prac ae_prac pis_prac ch_prac ooh_prac DN_prac
      =Last(acute_prac mat_prac mentalh_prac gls_prac op_prac ae_prac pis_prac ch_prac ooh_prac DN_prac)
   /acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
      acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost
      acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays
      = sum(acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
      acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost
      acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays)
   /mat_episodes mat_daycase_episodes mat_inpatient_episodes mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays
      = sum(mat_episodes mat_daycase_episodes mat_inpatient_episodes mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays)
   /mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes
      mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
      mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost
      mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost
      mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays = sum(mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes
      mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
      mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost
      mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost
      mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays)
   /gls_episodes gls_daycase_episodes gls_inpatient_episodes
      gls_el_inpatient_episodes gls_non_el_inpatient_episodes
      gls_cost gls_daycase_cost gls_inpatient_cost
      gls_el_inpatient_cost gls_non_el_inpatient_cost
      gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays = sum(gls_episodes gls_daycase_episodes gls_inpatient_episodes
      gls_el_inpatient_episodes gls_non_el_inpatient_episodes
      gls_cost gls_daycase_cost gls_inpatient_cost
      gls_el_inpatient_cost gls_non_el_inpatient_cost
      gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays)
   /op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas
      = sum(op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas)
   /ae_attendances ae_cost = sum(ae_attendances ae_cost)
   /pis_dispensed_items pis_cost = sum(no_dispensed_items pis_cost)
   /ch_episodes ch_beddays ch_cost = sum(ch_episodes ch_beddays ch_cost)
   /ooh_cases = Max(ooh_CC)
   /ooh_homeV ooh_advice ooh_DN ooh_NHS24 ooh_other ooh_PCC ooh_consultation_time ooh_cost
      = sum(ooh_homeV ooh_advice ooh_DN ooh_NHS24 ooh_other ooh_PCC ooh_consultation_time ooh_cost)
   /DN_episodes DN_contacts DN_total_duration DN_cost
      = sum(DN_episodes DN_contacts DN_total_duration DN_cost)
   /deceased_flag date_death = First(deceased derived_datedeath)
   /arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive
      arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date
      chd_date hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date
      = First(arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive
      arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date
      chd_date hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date)
   /Demographic_Cohort Service_Use_Cohort = First(Demographic_Cohort Service_Use_Cohort)
   /SPARRA_RISK_SCORE = First(SPARRA_RISK_SCORE).

 * Do a temporary save.
save outfile = !file + 'temp-source-individual-file-20' + !FY + '.zsav'
   /zcompressed.
get file = !file + 'temp-source-individual-file-20' + !FY + '.zsav'.

* Clean up the gender, use the most common (by rounding the mean), if the mean is 1.5 (i.e. no gender known or equal male and females) then take it from the CHI).
Do if gender NE 1.5.
   Compute gender = Rnd(gender).
Else.
   Do if Mod(number(char.substr(chi, 9, 1), F1.0), 2) = 1.
      Compute gender = 1.
   Else.
      Compute gender = 2.
   End If.
End If.

Alter type gender (F1.0).
Value Labels gender
   '1' "Male"
   '2' "Female".

* From all the different data sources that we have in the file, a hierarchy will be created for how 
* Postcode, GP Practice and Date of Birth will be assigned.
* Note that due to the minimum data extract that for PIS data, GP Practice is not available. This was 
 not included in the request for the extract so that multiple rows for patients would be avoided and 
 also because the GP Practice that is held in PIS is the GP Practice of the PRESCRIBER not the patient.
* In most cases this will be the GP Practice of the patient but this is not always the case.

*The hierarchy has been decided based on what health service would most likely be used by patients.
* 1 - Prescribing (except for GP Practice - added in for GP Practice August 2016)
* 2 - Accident and Emergency 
* 3 - OOH
* 4 - Outpatients 
* 5 - Acute 
* 6 - Maternity 
* 7 - District Nursing
* 8 - Mental health 
* 9 - Geriatric long stay
* 10 - Care Homes.

* Date of birth hierarchy.
Numeric dob (F8.0).

Do if Not(SYSMISS(pis_dob)).
   Compute dob = pis_dob.
Else if Not(SYSMISS(ae_dob)).
   Compute dob = ae_dob.
Else if Not(SYSMISS(ooh_dob)).
   Compute dob = ooh_dob.
Else if Not(SYSMISS(op_dob)).
   Compute dob = op_dob.
Else if Not(SYSMISS(acute_dob)).
   Compute dob = acute_dob.
Else if Not(SYSMISS(mat_dob)).
   Compute dob = mat_dob.
Else if Not(SYSMISS(DN_dob)).
   Compute dob = DN_dob.
Else if Not(SYSMISS(mentalh_dob)).
   Compute dob = mentalh_dob.
Else if Not(SYSMISS(gls_dob)).
   Compute dob = gls_dob.
Else if Not(SYSMISS(ch_dob)).
   Compute dob = ch_dob.
End if.

Numeric age (F3.0).
compute age= trunc((!FYMidpoint - dob) / 10000).

* Postcode hierarchy.
* Have updated the syntax for the recording of postcode as null had been recorded for an unknown postcode 
* in the PIS extract. These null postcodes will be set as blank and then the rest of the hierarchy will 
* be applied. DH 25 March 2014.
String postcode (A7).
Do if (pis_postcode ne 'null' AND pis_postcode ne '').
   compute postcode = pis_postcode.
Else if (ae_postcode ne '').
   Compute postcode = ae_postcode.
Else if (ooh_postcode ne '').
   Compute postcode = ooh_postcode.
Else if (op_postcode ne '').
   Compute postcode = op_postcode.
Else if (acute_postcode ne '').
   Compute postcode=acute_postcode.
Else if (mat_postcode ne '').
   Compute postcode = mat_postcode.
Else if (DN_postcode ne '').
   Compute postcode = DN_postcode.
Else if (mentalh_postcode ne '').
   Compute postcode = mentalh_postcode.
Else if (gls_postcode ne '').
   Compute postcode = gls_postcode.
Else if (ch_postcode ne '').
   Compute postcode = ch_postcode.
End if.

* GP Practice hierarchy.
* Prescribing will need to be added once updated extracts are available. DH August 2016.
* Prescriber GP Practice now added to this hierarchy as first in the list. DH, August 2016.
String gpprac (A5).
Do if (pis_prac ne 'null' AND pis_prac ne '').
   compute gpprac = pis_prac.
Else if (ae_prac ne '').
   Compute gpprac = ae_prac.
Else if (ooh_prac ne '').
   Compute gpprac = ooh_prac.
Else if (op_prac ne '').
   Compute gpprac = op_prac.
Else if (mat_prac ne '').
   Compute gpprac = mat_prac.
Else if (DN_prac ne '').
   Compute gpprac = DN_prac.
Else if (mentalh_prac ne '').
   Compute gpprac = mentalh_prac.
Else if (gls_prac ne '').
   Compute gpprac = gls_prac.
Else if (ch_prac ne '').
   Compute gpprac = ch_prac.
End if.

* Recode all the system missing values to zero so that calculations will work.
Recode acute_episodes to DN_cost (sysmis = 0).

* Create a total health cost.
compute health_net_cost = acute_cost + mat_cost + mentalh_cost + gls_cost + op_cost_attend + ae_cost + pis_cost + ooh_cost.
compute health_net_costincDNAs = acute_cost + mat_cost + mentalh_cost + gls_cost + op_cost_dnas + ae_cost + pis_cost + ooh_cost.
compute health_net_costincIncomplete = health_net_cost + ch_cost + DN_cost.


* Delete the record specific dob gpprac and postcode.
* Do a temporary save.
save outfile = !file + 'temp-source-individual-file-20' + !FY + '.zsav'
   /Drop acute_postcode to DN_postcode
      acute_dob to DN_dob
      acute_prac to DN_prac
   /Keep chi gender dob age postcode gpprac
      health_net_cost health_net_costincDNAs health_net_costincIncomplete
      deceased_flag date_death
      ALL
   /zcompressed.

get file = !file + 'temp-source-individual-file-20' + !FY + '.zsav'.


sort cases by postcode.
* Geography and deprivation columns need to be matched on by postcode (to be in line with * the master PLICs file).
match files file = *
   /table = '/conf/linkage/output/lookups/Unicode/Deprivation/postcode_2018_1_all_simd_carstairs.sav'
   /Rename (pc7 Datazone2001_simd2012 Datazone2011_simd2016 = postcode Datazone2001 Datazone2011)
   /Keep Chi to SPARRA_RISK_SCORE
      Datazone2001 Datazone2011
      simd2012score to simd2012_chp2012_decile
      simd2016rank to simd2016_CA2011_quintile
   /by postcode.

match files file = *
   /table = '/conf/irf/05-lookups/04-geography/geographies-for-PLICS-updated2018.sav'
   /rename pc7 = postcode
   /Drop SplitChar Split_Indicator HSCP2016
   /by postcode.

Value Labels HB2014
      'S08000015' "Ayrshire and Arran"
      'S08000016' "Borders"
      'S08000017' "Dumfries and Galloway"
      'S08000018' "Fife"
      'S08000019' "Forth Valley"
      'S08000020' "Grampian"
      'S08000021' "Greater Glasgow and Clyde"
      'S08000022' "Highland"
      'S08000023' "Lanarkshire"
      'S08000024' "Lothian"
      'S08000025' "Orkney"
      'S08000026' "Shetland"
      'S08000027' "Tayside"
      'S08000028' "Western Isles".

string lca (a2).
Do if postcode NE ''.
   Do if (CA2011 eq 'S12000005').
      Compute lca = '06'.
   Else if (CA2011 eq 'S12000006').
      Compute lca = '08'.
   Else if (CA2011 eq 'S12000008').
      Compute lca = '10'.
   Else if (CA2011 eq 'S12000010').
      Compute lca = '12'.
   Else if (CA2011 eq 'S12000011').
      Compute lca = '13'.
   Else if (CA2011 eq 'S12000013').
      Compute lca = '32'.
   Else if (CA2011 eq 'S12000014').
      Compute lca = '15'.
   Else if (CA2011 eq 'S12000015').
      Compute lca = '16'.
   Else if (CA2011 eq 'S12000017').
      Compute lca = '18'.
   Else if (CA2011 eq 'S12000018').
      Compute lca = '19'.
   Else if (CA2011 eq 'S12000019').
      Compute lca = '20'.
   Else if (CA2011 eq 'S12000020').
      Compute lca = '21'.
   Else if (CA2011 eq 'S12000021').
      Compute lca = '22'.
   Else if (CA2011 eq 'S12000023').
      Compute lca = '24'.
   Else if (CA2011 eq 'S12000024').
      Compute lca = '25'.
   Else if (CA2011 eq 'S12000026').
      Compute lca = '05'.
   Else if (CA2011 eq 'S12000027').
      Compute lca = '27'.
   Else if (CA2011 eq 'S12000028').
      Compute lca = '28'.
   Else if (CA2011 eq 'S12000029').
      Compute lca = '29'.
   Else if (CA2011 eq 'S12000030').
      Compute lca = '30'.
   Else if (CA2011 eq 'S12000033').
      Compute lca = '01'.
   Else if (CA2011 eq 'S12000034').
      Compute lca = '02'.
   Else if (CA2011 eq 'S12000035').
      Compute lca = '04'.
   Else if (CA2011 eq 'S12000036').
      Compute lca = '14'.
   Else if (CA2011 eq 'S12000038').
      Compute lca = '26'.
   Else if (CA2011 eq 'S12000039').
      Compute lca = '07'.
   Else if (CA2011 eq 'S12000040').
      Compute lca = '31'.
   Else if (CA2011 eq 'S12000041').
      Compute lca = '03'.
   Else if (CA2011 eq 'S12000042').
      Compute lca = '09'.
   Else if (CA2011 eq 'S12000044').
      Compute lca = '23'.
   Else if (CA2011 eq 'S12000045').
      Compute lca = '11'.
   Else if (CA2011 eq 'S12000046').
      Compute lca = '17'.
   End If.
End if.

Value Labels lca
      '01' "Aberdeen City"
      '02' "Aberdeenshire"
      '03' "Angus"
      '04' "Argyll & Bute"
      '05' "Scottish Borders"
      '06' "Clackmannanshire"
      '07' "West Dunbartonshire"
      '08' "Dumfries & Galloway"
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
      '25' "Perth & Kinross"
      '26' "Renfrewshire"
      '27' "Shetland Islands"
      '28' "South Ayrshire"
      '29' "South Lanarkshire"
      '30' "Stirling"
      '31' "West Lothian"
      '32' "Na h-Eileanan Siar".

rename variables (CHP_2012 HB2014 postcode = chp hbres health_postcode).
rename variables (simd2012_hb2014_quintile simd2012_hb2014_decile = hbsimd2012quintile hbsimd2012decile).

 * Match on Urban / Rural classifications.
sort cases by Datazone2011.
match files file = *
   /table = "/conf/linkage/output/lookups/Unicode/Geography/Urban Rural Classification/datazone2011_urban_rural_2016.sav"
   /Keep Chi to lca
      UR8_2016 UR6_2016 UR3_2016 UR2_2016
   /by Datazone2011.

* Create a year variable, similar to the master PLICs file - in case analysts require to add * together the CHI master PLICS files.
string year (a4).
compute year = !FY.

Value Labels year
   '1011' "2010/11"
   '1112' "2011/12"
   '1213' "2012/13"
   '1314' "2013/14"
   '1415' "2014/15"
   '1516' "2015/16"
   '1617' "2016/17"
   '1718' "2017/18"
   '1819' "2018/19"
   '1920' "2019/20"
   '2021' "2020/21"
   '2122' "2021/22"
   '2223' "2022/23"
   '2324' "2023/24"
   '2425' "2024/25".

sort cases by chi.

save outfile = !file + 'source-individual-file-20' + !FY + '.zsav'
   /zcompressed.
get file = !file + 'source-individual-file-20' + !FY + '.zsav'.

* - run the code for the individual file for locality and cluster addition. (22).
* - run the code to determine HRI columns. (25).

match files files = *
   /table = !file + 'HRI_lookup_' + !FY + '.sav'
   /by chi.

rename variables (LCAflag = HRI_lca) (LCAflag_all = HRI_lca_all) (HBflag = HRI_hb) (Scotflag = HRI_scot) (lcaP = HRI_lcaP) (lcaBP = HRI_lcaP_all) (hbP = HRI_hbP) (ScotP = HRI_scotP).

alter type
   HRI_lca to HRI_Scot (F1.0)
   HRI_lcaP to HRI_ScotP (F3.2).
 
 * Tidy up variable types.
alter type
   acute_episodes to acute_non_el_inpatient_episodes acute_inpatient_beddays to acute_non_el_inpatient_beddays
   mat_episodes to mat_inpatient_episodes mat_inpatient_beddays
   mentalh_episodes to mentalh_non_el_inpatient_episodes mentalh_inpatient_beddays to mentalh_non_el_inpatient_beddays
   gls_episodes to gls_daycase_episodes gls_non_el_inpatient_episodes gls_inpatient_beddays to gls_non_el_inpatient_beddays
   op_newcons_attendances op_newcons_dnas
   ae_attendances
   pis_dispensed_items
   ch_episodes ch_beddays
   ooh_cases to ooh_PCC
   DN_episodes DN_contacts (F8.0).

 * Add variable lables.
Variable Labels
   year "Financial Year"
   gender "Gender"
   dob "Date of birth"
   gpprac "GP practice code"
   lca "Local Council Authority"
   health_net_cost "Total net cost"
   health_net_costincDNAs "Total net cost including 'did not attend'"
   health_net_costincIncomplete "Total net cost including CH and DN (not DNAs)"
   acute_episodes "Number of acute episodes"
   acute_daycase_episodes "Number of acute day case episodes"
   acute_inpatient_episodes "Number of acute inpatient episodes"
   acute_el_inpatient_episodes "Number of elective inpatient episodes"
   acute_non_el_inpatient_episodes "Number of non-elective inpatient episodes"
   acute_cost "Cost of acute activity"
   acute_daycase_cost "Cost of acute day case activity"
   acute_inpatient_cost "Cost of acute inpatient activity"
   acute_el_inpatient_cost "Cost of acute elective inpatient activity"
   acute_non_el_inpatient_cost "Cost of acute non-elective inpatient activity"
   acute_inpatient_beddays "Number of acute inpatient bed days"
   acute_el_inpatient_beddays "Number of acute elective inpatient bed days"
   acute_non_el_inpatient_beddays "Number of acute non-elective inpatient bed days"
   mat_episodes "Number of  maternity episodes"
   mat_daycase_episodes "Number of maternity day case episodes"
   mat_inpatient_episodes "Number of maternity inpatient episodes"
   mat_cost "Cost of maternity activity"
   mat_daycase_cost "Cost of maternity day case activity"
   mat_inpatient_cost "Cost of maternity inpatient activity"
   mat_inpatient_beddays "Number of maternity inpatient bed days"
   mentalh_episodes "Number of mental health episodes"
   mentalh_daycase_episodes "Number of mental health day case episodes"
   mentalh_inpatient_episodes "Number of mental health inpatient episodes"
   mentalh_el_inpatient_episodes "Number of mental health elective inpatient episodes"
   mentalh_non_el_inpatient_episodes "Number of mental health non-elective inpatient episodes"
   mentalh_cost "Cost of mental health activity"
   mentalh_daycase_cost "Cost of mental health day case activity"
   mentalh_inpatient_cost "Cost of mental health inpatient activity"
   mentalh_el_inpatient_cost "Cost of mental health elective inpatient activity"
   mentalh_non_el_inpatient_cost "Cost of mental health non-elective inpatient activity"
   mentalh_inpatient_beddays "Number of mental health inpatient bed days"
   mentalh_el_inpatient_beddays "Number of mental health elective inpatient bed days"
   mentalh_non_el_inpatient_beddays "Number of mental health non-elective inpatient bed days"
   gls_episodes "Number of geriatric long stay episodes"
   gls_daycase_episodes "Number of geriatric long stay day case episodes"
   gls_inpatient_episodes "Number of geriatric long stay inpatient episodes"
   gls_el_inpatient_episodes "Number of geriatric long stay elective inpatient episodes"
   gls_non_el_inpatient_episodes "Number of geriatric long stay non-elective inpatient episodes"
   gls_cost "Cost of geriatric long stay activity"
   gls_daycase_cost "Cost of geriatric long stay day case activity"
   gls_inpatient_cost "Cost of geriatric long stay inpatient activity"
   gls_el_inpatient_cost "Cost of geriatric long stay elective inpatient activity"
   gls_non_el_inpatient_cost "Cost of geriatric long stay non-elective inpatient activity"
   gls_inpatient_beddays "Number of geriatric long stay inpatient bed days"
   gls_el_inpatient_beddays "Number of geriatric long stay elective inpatient bed days"
   gls_non_el_inpatient_beddays "Number of geriatric long stay non-elective inpatient bed days"
   op_newcons_attendances "Number of new outpatient attendances"
   op_newcons_dnas "Number of new outpatient appointments"
   op_cost_attend "Cost of new outpatient attendances"
   op_cost_dnas "Cost of new outpatient appointments"
   ae_attendances "Number of A&E attendances"
   ae_cost "Cost of A&E attendances"
   pis_dispensed_items "Number of prescribing items dispensed"
   pis_cost "Cost of prescribing items dispensed "
   ch_episodes	"Number of distinct Care Home episodes"
   ch_cost	"Cost of Care Home stays"
   ch_beddays	"Number of Care Home beddays"
   ooh_cases	"Number of GP OoH cases (multiple consultations per case)"
   ooh_homeV	"Number of GP OoH Home visit consultations"
   ooh_advice	"Number of GP OoH Doctor / Nurse advice consultations"
   ooh_DN	"Number of GP OoH District Nurse consultations"
   ooh_NHS24	"Number of GP OoH NHS24 consultations"
   ooh_other	"Number of GP OoH Other consultations"
   ooh_PCC	"Number of GP OoH Primary Care Centre / Emergency Primary Care Centre consultations"
   ooh_cost	"Cost of all GP OoHs"
   ooh_consultation_time	"Total time for GP OoH Consultations"
   DN_episodes	"Number of District Nursing episodes (consultations more than 7-days apart)"
   DN_contacts	"Number of District Nursing contact"
   DN_cost	"Cost of District Nursing"
   DN_total_duration	"Total Duration of all District Nursing contacts"
   HRI_lca "HRIs in LCA excluding District Nursing and Care Home costs"
   HRI_lca_all	"HRIs in LCA including all costs"
   HRI_hb "HRIs in HB excluding District Nursing and Care Home costs"
   HRI_scot "HRIs in Scotland excluding District Nursing and Care Home costs"
   HRI_lcaP "Cumulative percent in LCA excluding District Nursing and Care Home costs"
   HRI_lcaP_all	"Cumulative percent in LCA including all costs"
   HRI_hbP "Cumulative percent in HB excluding District Nursing and Care Home costs"
   HRI_scotP "Cumulative percent in Scotland excluding District Nursing and Care Home costs".

sort cases by chi.
save outfile = !file + 'source-individual-file-20' + !FY + '.zsav'
   /Keep
      year
      chi
      gender
      dob
      age
      health_postcode
      gpprac
      health_net_cost
      health_net_costincDNAs
      health_net_costincIncomplete
      deceased_flag
      date_death
      acute_episodes
      acute_daycase_episodes
      acute_inpatient_episodes
      acute_el_inpatient_episodes
      acute_non_el_inpatient_episodes
      acute_cost
      acute_daycase_cost
      acute_inpatient_cost
      acute_el_inpatient_cost
      acute_non_el_inpatient_cost
      acute_inpatient_beddays
      acute_el_inpatient_beddays
      acute_non_el_inpatient_beddays
      mat_episodes
      mat_daycase_episodes
      mat_inpatient_episodes
      mat_cost
      mat_daycase_cost
      mat_inpatient_cost
      mat_inpatient_beddays
      mentalh_episodes
      mentalh_daycase_episodes
      mentalh_inpatient_episodes
      mentalh_el_inpatient_episodes
      mentalh_non_el_inpatient_episodes
      mentalh_cost
      mentalh_daycase_cost
      mentalh_inpatient_cost
      mentalh_el_inpatient_cost
      mentalh_non_el_inpatient_cost
      mentalh_inpatient_beddays
      mentalh_el_inpatient_beddays
      mentalh_non_el_inpatient_beddays
      gls_episodes
      gls_daycase_episodes
      gls_inpatient_episodes
      gls_el_inpatient_episodes
      gls_non_el_inpatient_episodes
      gls_cost
      gls_daycase_cost
      gls_inpatient_cost
      gls_el_inpatient_cost
      gls_non_el_inpatient_cost
      gls_inpatient_beddays
      gls_el_inpatient_beddays
      gls_non_el_inpatient_beddays
      op_newcons_attendances
      op_newcons_dnas
      op_cost_attend
      op_cost_dnas
      ae_attendances
      ae_cost
      pis_dispensed_items
      pis_cost
      ch_episodes
      ch_beddays
      ch_cost
      ooh_cases
      ooh_homeV
      ooh_advice
      ooh_DN
      ooh_NHS24
      ooh_other
      ooh_PCC
      ooh_consultation_time
      ooh_cost
      DN_episodes
      DN_contacts
      DN_total_duration
      DN_cost
      arth
      asthma
      atrialfib
      cancer
      cvd
      liver
      copd
      dementia
      diabetes
      epilepsy
      chd
      hefailure
      ms
      parkinsons
      refailure
      congen
      bloodbfo
      endomet
      digestive
      arth_date
      asthma_date
      atrialfib_date
      cancer_date
      cvd_date
      liver_date
      copd_date
      dementia_date
      diabetes_date
      epilepsy_date
      chd_date
      hefailure_date
      ms_date
      parkinsons_date
      refailure_date
      congen_date
      bloodbfo_date
      endomet_date
      digestive_date
      lca
      hbres
      chp
      Datazone2001
      Datazone2011
      CHP2011
      CHP2011subarea
      Cluster
      Locality
      HB
      simd2012score
      simd2012rank
      simd2012_sc_quintile
      simd2012_sc_decile
      simd2012_ca_quintile
      simd2012_ca_decile
      simd2012_hscp_quintile
      simd2012_hscp_decile
      simd2012_chp2012_quintile
      simd2012_chp2012_decile
      hbsimd2012quintile
      hbsimd2012decile
      simd2016rank
      simd2016_sc_decile
      simd2016_sc_quintile
      simd2016_HB2014_decile
      simd2016_HB2014_quintile
      simd2016_HSCP2016_decile
      simd2016_HSCP2016_quintile
      simd2016_CA2011_decile
      simd2016_CA2011_quintile
      UR8_2016
      UR6_2016
      UR3_2016
      UR2_2016
      HRI_lca
      HRI_lca_all
      HRI_hb
      HRI_scot
      HRI_lcaP
      HRI_lcaP_all
      HRI_hbP
      HRI_scotP
      SPARRA_RISK_SCORE
      Demographic_Cohort
      Service_Use_Cohort
   /zcompressed.

get file = !file + 'source-individual-file-20' + !FY + '.zsav'.

*************************************************************************************************************************************************.
* Erase temporary file created throughout the program.
erase file = !file + 'temp-source-individual-file-20' + !FY + '.zsav'.
