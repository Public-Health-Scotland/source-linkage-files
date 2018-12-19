* Encoding: UTF-8.
* We create a row per chi by producing various summaries from the episode file.

* Produced, based on the original, by James McMahon.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.
get file = !File + "source-episode-file-20" + !FY + ".zsav".

* Exclude people with blank chi.
select if chi ne "".
exe.
* Sort data into chi and episode date order.
Sort cases by chi keydate1_dateformat keyTime1 keydate2_dateformat keyTime2.

* Declare the variables we will use to store postcode etc. data.
* Don't include DD as this data has just been taken from acute / MH.
Numeric Acute_dob Mat_dob MH_dob GLS_dob OP_dob AE_dob PIS_dob CH_dob OoH_dob DN_dob CMH_dob NSU_dob NRS_dob (Date12).
String Acute_postcode Mat_postcode MH_postcode GLS_postcode OP_postcode AE_postcode PIS_postcode CH_postcode OoH_postcode DN_postcode CMH_postcode NSU_postcode NRS_postcode(A7).
Numeric Acute_gpprac Mat_gpprac MH_gpprac GLS_gpprac OP_gpprac AE_gpprac PIS_gpprac CH_gpprac OoH_gpprac DN_gpprac CMH_gpprac NSU_gpprac NRS_gpprac (F5.0).

* Set any blanks as user missing, so they will be ignored by the aggregate.
Missing Values
    Acute_postcode Mat_postcode MH_postcode GLS_postcode OP_postcode AE_postcode PIS_postcode CH_postcode OoH_postcode DN_postcode CMH_postcode NSU_postcode CMH_postcode NRS_postcode
    ("").
* Create a series of indicators which can be aggregated later to provide a summary for each CHI.
*************************************************************************************************************************************************.
* For SMR01/02/04/01_1E: sum activity and costs per patient with an Elective/Non-Elective split.
* Acute (SMR01) section.

Do if (smrtype eq "Acute-DC" OR smrtype eq "Acute-IP") AND (newpattype_cis ne "Maternity").
    Compute Acute_dob = dob.
    Compute Acute_postcode = postcode.
    Compute Acute_gpprac = gpprac.

    * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
    * Activity (count the episodes).
    compute Acute_episodes = 1.
    compute Acute_daycase_episodes = 0.
    compute Acute_inpatient_episodes = 0.
    compute Acute_el_inpatient_episodes = 0.
    compute Acute_non_el_inpatient_episodes = 0.

    if (IPDC = "D") Acute_daycase_episodes = 1.
    if (IPDC = "I") Acute_inpatient_episodes = 1.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") Acute_non_el_inpatient_episodes = 1.
    if (newpattype_CIS = "Elective" and IPDC = "I") Acute_el_inpatient_episodes = 1.

    * Cost (use the Cost_Total_Net).
    compute Acute_cost = Cost_Total_Net.
    compute Acute_daycase_cost = 0.
    compute Acute_inpatient_cost = 0.
    compute Acute_el_inpatient_cost = 0.
    compute Acute_non_el_inpatient_cost = 0.

    if (IPDC = "D") Acute_daycase_cost = Cost_Total_Net.
    if (IPDC = "I") Acute_inpatient_cost = Cost_Total_Net.
    if (newpattype_CIS = "Elective" and IPDC = "I") Acute_el_inpatient_cost = Cost_Total_Net.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") Acute_non_el_inpatient_cost = Cost_Total_Net.

    *Beddays for inpatients (use the yearstay).
    compute Acute_inpatient_beddays = 0.
    compute Acute_el_inpatient_beddays = 0.
    compute Acute_non_el_inpatient_beddays = 0.

    if (IPDC = "I") Acute_inpatient_beddays = yearstay.
    if (newpattype_CIS = "Elective" and IPDC = "I") Acute_el_inpatient_beddays = yearstay.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") Acute_non_el_inpatient_beddays = yearstay.

Else if (newpattype_cis eq "Maternity").
    *************************************************************************************************************************************************.
    * Maternity (SMR02) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute Mat_dob  = dob.
    Compute Mat_postcode = postcode.
    Compute Mat_gpprac = gpprac.

    * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
    * Activity (count the episodes).
    compute Mat_episodes = 1.
    compute Mat_daycase_episodes = 0.
    compute Mat_inpatient_episodes = 0.

    if (IPDC = "I") Mat_inpatient_episodes = 1.
    if (IPDC = "D") Mat_daycase_episodes = 1.

    * Cost (use the Cost_Total_Net).
    compute Mat_cost = Cost_Total_Net.
    compute Mat_daycase_cost = 0.
    compute Mat_inpatient_cost = 0.

    if (IPDC = "D") Mat_daycase_cost = Cost_Total_Net.
    if (IPDC = "I") Mat_inpatient_cost = Cost_Total_Net.

    *Beddays for inpatients (use the yearstay).
    compute Mat_inpatient_beddays = 0.

    if (IPDC = "I") Mat_inpatient_beddays = yearstay.

Else if (recid eq "04B") AND (newpattype_cis ne "Maternity").
    *************************************************************************************************************************************************.
    * Mental Health (SMR04) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute MH_dob  = dob.
    Compute MH_postcode = postcode.
    Compute MH_gpprac = gpprac.

    * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
    * Activity (count the episodes).
    compute MH_episodes = 1.
    compute MH_daycase_episodes = 0.
    compute MH_inpatient_episodes = 0.
    compute MH_el_inpatient_episodes = 0.
    compute MH_non_el_inpatient_episodes = 0.

    if (IPDC = "D") MH_daycase_episodes = 1.
    if (IPDC = "I") MH_inpatient_episodes = 1.
    if (newpattype_CIS = "Elective" and IPDC = "I") MH_el_inpatient_episodes = 1.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") MH_non_el_inpatient_episodes = 1.

    * Cost (use the Cost_Total_Net).
    compute MH_cost = Cost_Total_Net.
    compute MH_inpatient_cost = 0.
    compute MH_daycase_cost = 0.
    compute MH_el_inpatient_cost = 0.
    compute MH_non_el_inpatient_cost = 0.

    if (IPDC = "D") MH_daycase_cost = Cost_Total_Net.
    if (IPDC = "I") MH_inpatient_cost = Cost_Total_Net.
    if (newpattype_CIS = "Elective" and IPDC = "I") MH_el_inpatient_cost = Cost_Total_Net.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") MH_non_el_inpatient_cost = Cost_Total_Net.

    *Beddays for inpatients (use the yearstay).
    compute MH_inpatient_beddays = 0.
    compute MH_el_inpatient_beddays = 0.
    compute MH_non_el_inpatient_beddays = 0.

    if (IPDC = "I") MH_inpatient_beddays = yearstay.
    if (newpattype_CIS = "Elective" and IPDC = "I") MH_el_inpatient_beddays = yearstay.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") MH_non_el_inpatient_beddays = yearstay.

Else if (smrtype eq "GLS-IP").
    *************************************************************************************************************************************************.
    * Geriatric Long Stay (SMR01_1E) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute GLS_dob  = dob.
    Compute GLS_postcode = postcode.
    Compute GLS_gpprac = gpprac.

    * Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
    * Activity (count the episodes).
    compute GLS_episodes = 1.
    compute GLS_daycase_episodes = 0.
    compute GLS_inpatient_episodes = 0.
    compute GLS_el_inpatient_episodes = 0.
    compute GLS_non_el_inpatient_episodes = 0.


    if (IPDC = "D") GLS_daycase_episodes = 1.
    if (IPDC = "I") GLS_inpatient_episodes = 1.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") GLS_non_el_inpatient_episodes = 1.
    if (newpattype_CIS = "Elective" and IPDC = "I") GLS_el_inpatient_episodes = 1.

    * Cost (use the Cost_Total_Net).
    compute GLS_cost = Cost_Total_Net.
    compute GLS_daycase_cost = 0.
    compute GLS_inpatient_cost = 0.
    compute GLS_el_inpatient_cost = 0.
    compute GLS_non_el_inpatient_cost = 0.

    if (IPDC = "D") GLS_daycase_cost = Cost_Total_Net.
    if (IPDC = "I") GLS_inpatient_cost = Cost_Total_Net.
    if (newpattype_CIS = "Elective" and IPDC = "I") GLS_el_inpatient_cost = Cost_Total_Net.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") GLS_non_el_inpatient_cost = Cost_Total_Net.

    *Beddays for inpatients (use the yearstay).
    compute GLS_inpatient_beddays = 0.
    compute GLS_el_inpatient_beddays = 0.
    compute GLS_non_el_inpatient_beddays = 0.

    if (IPDC = "I") GLS_inpatient_beddays = yearstay.
    if (newpattype_CIS = "Elective" and IPDC = "I") GLS_el_inpatient_beddays = yearstay.
    if (newpattype_CIS = "Non-Elective" and IPDC = "I") GLS_non_el_inpatient_beddays = yearstay.

Else if (recid eq "00B").
    *************************************************************************************************************************************************.
    * Outpatients (SMR00) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.

    Compute OP_dob  = dob.
    Compute OP_postcode = postcode.
    Compute OP_gpprac = gpprac.

    * Activity (count the attendances).
    compute OP_newcons_attendances = 0.
    compute OP_newcons_dnas = 0.

    if (attendance_status = 1) OP_newcons_attendances = 1.
    if (any(attendance_status, 5, 8)) OP_newcons_dnas = 1.

    * Cost.
    Compute OP_cost_attend = Cost_Total_Net.

    * Cost (for DNAs).
    compute OP_cost_dnas = 0.
    if (any(attendance_status, 5, 8)) OP_cost_dnas = Cost_Total_Net_incDNAs.

Else if (recid eq "AE2").
    *************************************************************************************************************************************************.
    * Accident and Emergency (AE2) section (sum the number of of attendances and costs associated).
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute AE_dob  = dob.
    Compute AE_postcode = postcode.
    Compute AE_gpprac = gpprac.

    * Activity (count the attendances).
    compute AE_attendances = 1.
    compute AE_cost = Cost_Total_Net.

Else if (recid eq "PIS").
    *************************************************************************************************************************************************.
    * Prescribing (PIS) section.
    * For Prescribing: sum the information by patient * only one row per person exists in the master PLICs file with minimal data.

    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute PIS_dob  = dob.
    Compute PIS_postcode = postcode.
    Compute PIS_gpprac = gpprac.

    Compute PIS_dispensed_items = no_dispensed_items.
    Compute PIS_cost = Cost_Total_Net.

Else if (recid = "CH").
    *************************************************************************************************************************************************.
    * Care Home (CH) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute CH_dob  = dob.
    Compute CH_postcode = postcode.
    Compute CH_gpprac = gpprac.

    * Count the number of distinct episodes.
    compute CH_episodes = 1.

    * Cost (use the Cost_Total_Net).
    compute CH_cost = Cost_Total_Net.

    *Beddays for residents (use the yearstay).
    compute CH_beddays = yearstay.

Else if (recid = "OoH").
    *************************************************************************************************************************************************.
    * GP Out of Hours (OoH) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute OoH_dob  = dob.
    Compute OoH_postcode = postcode.
    Compute OoH_gpprac = gpprac.

    * For activity count the number of consultations of each type.
    Do If SMRtype = "OOH-HomeV".
        Compute OoH_homeV = 1.
    Else If SMRtype = "OOH-Advice".
        Compute OoH_advice = 1.
    Else If SMRtype = "OOH-DN".
        Compute OoH_DN = 1.
    Else If SMRtype = "OOH-NHS24".
        Compute OoH_NHS24 = 1.
    Else If SMRtype = "OOH-Other".
        Compute OoH_other = 1.
    Else If SMRtype = "OOH-PCC".
        Compute OoH_PCC = 1.
    End If.

    * Cost (use the Cost_Total_Net).
    compute OoH_cost = Cost_Total_Net.

    * Time.
    compute OoH_consultation_time = DateDiff(keydate2_dateformat + keyTime2,  keydate1_dateformat + KeyTime1, "minutes").
    if OoH_consultation_time < 0 OoH_consultation_time = 0.

Else if (recid = "DN").
    *************************************************************************************************************************************************.
    * District Nursing (DN) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute DN_dob  = dob.
    Compute DN_postcode = postcode.
    Compute DN_gpprac = gpprac.

    * For activity count the number of episodes and the contacts.
    Compute DN_episodes = 1.
    Compute DN_contacts = TotalnoDNcontacts.

    * Cost (use the Cost_Total_Net).
    compute DN_cost = Cost_Total_Net.

    * Time.
    * Leaving this out for now due to problems with contact duration variable.
    *compute DN_total_duration = TotalDurationofContacts.

Else if (recid = "CMH").
    *************************************************************************************************************************************************.
    * Community Mental Health (CMH) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute CMH_dob = dob.
    Compute CMH_postcode = postcode.
    Compute CMH_gpprac = gpprac.

    * For activity count the number of contacts.
    Compute CMH_contacts = 1.

 * Else if (recid = "DD").
    *************************************************************************************************************************************************.
    * Delayed Discharge (DD) section.
    * Not taking any demographic fields from DD.

    * For activity count the number of episodes for code 9 and non code 9 reasons.
 *     If Primary_Delay_Reason NE "9" DD_NonCode9_episodes = 1.
 *     If Primary_Delay_Reason EQ "9" DD_Code9_episodes = 1.

    * For beddays count the number for code 9 and non code 9 reasons.
 *     If Primary_Delay_Reason NE "9" DD_NonCode9_beddays = yearstay.
 *     If Primary_Delay_Reason EQ "9" DD_Code9_beddays = yearstay.
Else if (recid = "NSU").
    *************************************************************************************************************************************************.
    * Non-Service-User (NSU) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute NSU_dob  = dob.
    Compute NSU_postcode = postcode.
    Compute NSU_gpprac = gpprac.

    * By definition these chis should have no activity but we will create a flag to make this clear.
    Compute NSU = 1.

*************************************************************************************************************************************************.
 Else if (recid = "NRS").
End if.

* We"ll use this to get the most accurate gender we can.
Recode gender (0 = 1.5) (9 = 1.5).
 Compute NRS_dob  = dob.
    Compute NRS_postcode = postcode.
    Compute NRS_gpprac = gpprac.
Compute NRS = 1.

 * Now aggregate by Chi, keep all of the variables we made, we'll clean them up next.
 * Also keep variables that are only dependant on CHI (as opposed to postcode) e.g. death_date, cohorts, LTC etc.
 * Using Presorted so that we keep the ordering from earlier (chi, keydate1). This way, when we do 'Last', we get the most recent (non-blank) data from each record.
aggregate outfile = *
    /Presorted
    /break chi
    /gender = Mean(gender)
    /Acute_postcode Mat_postcode MH_postcode GLS_postcode OP_postcode AE_postcode PIS_postcode CH_postcode OoH_postcode DN_postcode CMH_postcode NSU_postcode NRS_postcode
    = Last(Acute_postcode Mat_postcode MH_postcode GLS_postcode OP_postcode AE_postcode PIS_postcode CH_postcode OoH_postcode DN_postcode CMH_postcode NSU_postcode NRS_postcode)
    /Acute_dob Mat_dob MH_dob GLS_dob OP_dob AE_dob PIS_dob CH_dob OoH_dob DN_dob CMH_dob NSU_dob NRS_dob
    = Last(Acute_dob Mat_dob MH_dob GLS_dob OP_dob AE_dob PIS_dob CH_dob OoH_dob DN_dob CMH_dob NSU_dob NRS_dob)
    /Acute_gpprac Mat_gpprac MH_gpprac GLS_gpprac OP_gpprac AE_gpprac PIS_gpprac CH_gpprac OoH_gpprac DN_gpprac CMH_gpprac NSU_gpprac NRS_gpprac
    = Last(Acute_gpprac Mat_gpprac MH_gpprac GLS_gpprac OP_gpprac AE_gpprac PIS_gpprac CH_gpprac OoH_gpprac DN_gpprac CMH_gpprac NSU_gpprac NRS_gpprac)
    /Acute_episodes Acute_daycase_episodes Acute_inpatient_episodes Acute_el_inpatient_episodes Acute_non_el_inpatient_episodes
    Acute_cost Acute_daycase_cost Acute_inpatient_cost Acute_el_inpatient_cost Acute_non_el_inpatient_cost
    Acute_inpatient_beddays Acute_el_inpatient_beddays Acute_non_el_inpatient_beddays
    = sum(Acute_episodes Acute_daycase_episodes Acute_inpatient_episodes Acute_el_inpatient_episodes Acute_non_el_inpatient_episodes
    Acute_cost Acute_daycase_cost Acute_inpatient_cost Acute_el_inpatient_cost Acute_non_el_inpatient_cost
    Acute_inpatient_beddays Acute_el_inpatient_beddays Acute_non_el_inpatient_beddays)
    /Mat_episodes Mat_daycase_episodes Mat_inpatient_episodes Mat_cost Mat_daycase_cost Mat_inpatient_cost Mat_inpatient_beddays
    = sum(Mat_episodes Mat_daycase_episodes Mat_inpatient_episodes Mat_cost Mat_daycase_cost Mat_inpatient_cost Mat_inpatient_beddays)
    /MH_episodes MH_daycase_episodes MH_inpatient_episodes
    MH_el_inpatient_episodes MH_non_el_inpatient_episodes
    MH_cost MH_daycase_cost MH_inpatient_cost
    MH_el_inpatient_cost MH_non_el_inpatient_cost
    MH_inpatient_beddays MH_el_inpatient_beddays MH_non_el_inpatient_beddays
    = sum(MH_episodes MH_daycase_episodes MH_inpatient_episodes
    MH_el_inpatient_episodes MH_non_el_inpatient_episodes
    MH_cost MH_daycase_cost MH_inpatient_cost
    MH_el_inpatient_cost MH_non_el_inpatient_cost
    MH_inpatient_beddays MH_el_inpatient_beddays MH_non_el_inpatient_beddays)
    /GLS_episodes GLS_daycase_episodes GLS_inpatient_episodes
    GLS_el_inpatient_episodes GLS_non_el_inpatient_episodes
    GLS_cost GLS_daycase_cost GLS_inpatient_cost
    GLS_el_inpatient_cost GLS_non_el_inpatient_cost
    GLS_inpatient_beddays GLS_el_inpatient_beddays GLS_non_el_inpatient_beddays
    = sum(GLS_episodes GLS_daycase_episodes GLS_inpatient_episodes
    GLS_el_inpatient_episodes GLS_non_el_inpatient_episodes
    GLS_cost GLS_daycase_cost GLS_inpatient_cost
    GLS_el_inpatient_cost GLS_non_el_inpatient_cost
    GLS_inpatient_beddays GLS_el_inpatient_beddays GLS_non_el_inpatient_beddays)
    /OP_newcons_attendances OP_newcons_dnas OP_cost_attend OP_cost_dnas
    = sum(OP_newcons_attendances OP_newcons_dnas OP_cost_attend OP_cost_dnas)
    /AE_attendances AE_cost = sum(AE_attendances AE_cost)
    /PIS_dispensed_items PIS_cost = sum(no_dispensed_items PIS_cost)
    /CH_episodes CH_beddays CH_cost = sum(CH_episodes CH_beddays CH_cost)
    /OoH_cases = Max(OoH_CC)
    /OoH_homeV OoH_advice OoH_DN OoH_NHS24 OoH_other OoH_PCC OoH_consultation_time OoH_cost
    = sum(OoH_homeV OoH_advice OoH_DN OoH_NHS24 OoH_other OoH_PCC OoH_consultation_time OoH_cost)
    /DN_episodes DN_contacts DN_cost
    = sum(DN_episodes DN_contacts DN_cost)
    /CMH_contacts
    = sum(CMH_contacts)
    /deceased death_date = First(deceased death_date)
    /NSU = Max(NSU)
    /arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive
    arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date
    chd_date hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date
    = First(arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive
    arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date
    chd_date hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date)
    /Demographic_Cohort Service_Use_Cohort = First(Demographic_Cohort Service_Use_Cohort)
    /SPARRA_Start_FY SPARRA_End_FY = First(SPARRA_Start_FY SPARRA_End_FY).

 * Do a temporary save as the above can take a while to run.
save outfile = !file + "temp-source-individual-file-1-20" + !FY + ".zsav"
   /zcompressed.
get file = !file + "temp-source-individual-file-1-20" + !FY + ".zsav".

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
   "1" "Male"
   "2" "Female".

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
* 8 - Community Mental Health
* 8 - Mental health 
* 9 - Geriatric long stay
* 10 - Care Homes
* 11 - NSU.

* Date of birth hierarchy.
Numeric dob (Date12).

* Create 2 scratch variables with the possible dobs and ages from the CHI.
Compute #CHI_dob1 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".19", char.substr(chi, 5, 2)), EDate12).
Compute #CHI_dob2 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".20", char.substr(chi, 5, 2)), EDate12).
Compute #CHI_age1 = DateDiff(!midFY, #CHI_dob1, "years").
Compute #CHI_age2 = DateDiff(!midFY, #CHI_dob2, "years").

 * If any of the dobs from the dataset match the dob in the CHI, use that (don't use if we have contradictions).
Do if any(#CHI_dob1, Acute_dob, Mat_dob, MH_dob, GLS_dob, OP_dob, AE_dob, PIS_dob, CH_dob, OoH_dob, DN_dob, CMH_dob, NSU_dob,NRS_dob)
    and Not(any(#CHI_dob2, Acute_dob, Mat_dob, MH_dob, GLS_dob, OP_dob, AE_dob, PIS_dob, CH_dob, OoH_dob, DN_dob, CMH_dob, NSU_dob,NRS_dob)).
    Compute dob = #CHI_dob1.
Else if Not(any(#CHI_dob1, Acute_dob, Mat_dob, MH_dob, GLS_dob, OP_dob, AE_dob, PIS_dob, CH_dob, OoH_dob, DN_dob, CMH_dob, NSU_dob,NRS_dob))
    and any(#CHI_dob2, Acute_dob, Mat_dob, MH_dob, GLS_dob, OP_dob, AE_dob, PIS_dob, CH_dob, OoH_dob, DN_dob, CMH_dob, NSU_dob,NRS_dob).
    Compute dob = #CHI_dob2.
End if.

Numeric age (F3.0).
* Compute age and dob if we can.
 * This method is very similar to that in C01 except we don't look at activity.
Do If (sysmis(dob)).
    * If either of the dobs are missing use the other one.
    * This only happens with impossible dates because of leap years.
    Do if Sysmiss(#CHI_dob1) AND Not(sysmis(#CHI_dob2)).
        Compute dob = #CHI_dob2.
    Else if Sysmiss(#CHI_dob2) AND Not(sysmis(#CHI_dob1)).
        Compute dob = #CHI_dob1.
        * If the younger age is negative, assume they are the older one.
    Else if #CHI_age2 < 0.
        Compute dob = #CHI_dob1.
        * Similar to the above, if the younger date makes them born after today, or the end of the FY then assume the older one.
    Else if #CHI_dob2 > Min($time, date.dmy(31, 03, Number(!altFY, F4.0) + 1)).
        Compute dob = #CHI_dob1.
        * If the younger dob means that they have an LTC (or died) before birth assume they are the older one.
    Else if #CHI_dob2 > Min(death_date, arth_date to digestive_date).
        Compute dob = #CHI_dob1.
        * If the congenital defect date lines up with a dob, assume it's correct.
    Else if any(congen_date, #CHI_dob1, #CHI_dob2).
        Compute dob = congen_date.
        * If the older age makes the person older than 115, assume they are younger (oldest living person is 113).
    Else if #CHI_age1 > 115.
        Compute dob = #CHI_dob2.
    End if.
End If.

 * If we haven't managed to deduce the age from CHI and activity, fill in from datasets.
Do if sysmis(dob).
    Do if Not(sysmis(PIS_dob)).
        Compute dob = PIS_dob.
    Else if Not(sysmis(AE_dob)).
        Compute dob = AE_dob.
    Else if Not(sysmis(OoH_dob)).
        Compute dob = OoH_dob.
    Else if Not(sysmis(OP_dob)).
        Compute dob = OP_dob.
    Else if Not(sysmis(Acute_dob)).
        Compute dob = Acute_dob.
    Else if Not(sysmis(Mat_dob)).
        Compute dob = Mat_dob.
    Else if Not(sysmis(DN_dob)).
        Compute dob = DN_dob.
    Else if Not(sysmis(CMH_dob)).
        Compute dob = CMH_dob.
    Else if Not(sysmis(MH_dob)).
        Compute dob = MH_dob.
    Else if Not(sysmis(GLS_dob)).
        Compute dob = GLS_dob.
    Else if Not(sysmis(CH_dob)).
        Compute dob = CH_dob.
    Else if Not(sysmis(NSU_dob)).
        Compute dob = NSU_dob.
 Else if Not(sysmis(NRS_dob)).
        Compute dob = NRS_dob.
    End if.
End if.

Do if sysmis(age).
    Compute age = DateDiff(!midFY, dob, "years").
End if.

Frequencies age.

 * If all postcodes are blank create a dummy postcode so we don't lose the CHI - we'll clean this up later. 
 * First firgure out if they are all blank.
compute #All_Blank = 1.

Do repeat postcode =  acute_postcode to NRS_postcode.
    If postcode NE "" #All_Blank = 0.
End repeat.

 * Use NRS_postcode to store the dummy for no other reason than it's last in the heirarchy.
If #All_Blank = 1 NRS_postcode = "XXX XXX".

 * Make a postcode variable from the various postcodes labled by the dataset they came from.
VarsToCases
    /make postcode from acute_postcode to NRS_postcode
    /Index dataset (postcode).

 * Count the number of times each postcode appears for each chi.
aggregate
    /break chi postcode
    /ndistpostcodes = n(postcode).

 * Give an order based on old heirarchy. This will only be used if we have a 'tie'.
Do if dataset = "PIS_postcode".
    Compute order = 1.
Else if dataset = "AE_postcode".
    Compute order = 2.
Else if dataset = "OoH_postcode".
    Compute order = 3.
Else if dataset = "OP_postcode".
    Compute order = 4.
Else if dataset = "Acute_postcode".
    Compute order = 5.
Else if dataset = "Mat_postcode".
    Compute order = 6.
Else if dataset = "DN_postcode".
    Compute order = 7.
Else if dataset = "CMH_postcode".
    Compute order = 8.
Else if dataset = "MH_postcode".
    Compute order = 9.
Else if dataset = "GLS_postcode".
    Compute order = 10.
Else if dataset = "CH_postcode".
    Compute order = 11.
Else if dataset = "NSU_postcode".
    Compute order = 12.
Else if dataset = "NRS_postcode".
    Compute order = 13.
End if.

 * Match on to the postcode file, to get a flag letting us know if the postcode is real or not.
sort cases by postcode.
match files file = *
    /table = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
    /In PostcodeMatch
    /Keep chi to order
    /By Postcode.

 * Sort the chis postcodes according to;
 * 1) Is it a real postcode.
 * 2) How often that postcode appears with that chi.
 * 3) Finally which dataset it came from (order). 
sort cases by chi (A) PostcodeMatch (D) ndistpostcodes (D) Order (A).

 * Use this to flag the first record as 'keep'.
add files
    /file = *
    /First = Keep
    /By Chi
    /Drop dataset ndistpostcodes order PostcodeMatch.

 * Just keep the first record.
Select if Keep = 1.

*********************************************************************************.
 * Do the same for gpprac.

* If all gppracs are blank create a dummy gpprac so we don't lose the CHI - we'll clean this up later. 
 * First firgure out if they are all blank.
compute #All_Blank = 1.

Do repeat gpprac =  acute_gpprac to NRS_gpprac.
    If Not(sysmis(gpprac))  #All_Blank = 0.
End repeat.

 * Use NRS_gpprac to store the dummy for no other reason than it's last in the heirarchy.
If #All_Blank = 1 NRS_gpprac = 0.

 * Make a gpprac variable from the various gpprac labled by the dataset they came from.
VarsToCases
    /make gpprac from acute_gpprac to NRS_gpprac
    /Index dataset (gpprac)
    /Drop Keep.

 * Count the number of times each gpprac appears for each chi.
aggregate
    /break chi gpprac
    /ndistgppracs = n(gpprac).

 * Give an order based on old heirarchy. This will only be used if we have a 'tie'.
Do if dataset = "PIS_gpprac".
    Compute order = 1.
Else if dataset = "AE_gpprac".
    Compute order = 2.
Else if dataset = "OoH_gpprac".
    Compute order = 3.
Else if dataset = "OP_gpprac".
    Compute order = 4.
Else if dataset = "Acute_gpprac".
    Compute order = 5.
Else if dataset = "Mat_gpprac".
    Compute order = 6.
Else if dataset = "DN_gpprac".
    Compute order = 7.
Else if dataset = "CMH_gpprac".
    Compute order = 8.
Else if dataset = "MH_gpprac".
    Compute order = 9.
Else if dataset = "GLS_gpprac".
    Compute order = 10.
Else if dataset = "CH_gpprac".
    Compute order = 11.
Else if dataset = "NSU_gpprac".
    Compute order = 12.
Else if dataset = "NRS_gpprac".
    Compute order = 13.
End if.

 * Match on to the gpprac file, to get a flag letting us know if the gpprac is real or not.
sort cases by gpprac.
match files file = *
    /table = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav"
    /In gppracMatch
    /Keep chi to order 
    /By gpprac.

 * Sort the chis gppracs according to;
 * 1) Is it a real gpprac.
 * 2) How often that gpprac appears with that chi.
 * 3) Finally which dataset it came from (order). 
sort cases by chi (A) gppracMatch (D) ndistgppracs (D) Order (A).

 * Use this to flag the first record as 'keep'.
add files
    /file = *
    /First = Keep
    /By Chi
    /Drop dataset ndistgppracs order gppracMatch.


frequencies postcode.

if postcode='XXX XXX' postcode=''.
if gpprac=0 gpprac=$sysmis.
exe.

Select if Keep = 1.

 * Tidy up counter variables.
Alter Type
    Acute_episodes to Acute_non_el_inpatient_episodes
    Acute_inpatient_beddays to Acute_non_el_inpatient_beddays
    Mat_episodes to Mat_inpatient_episodes
    Mat_inpatient_beddays
    MH_daycase_episodes to MH_non_el_inpatient_episodes
    MH_inpatient_beddays to MH_non_el_inpatient_beddays
    GLS_episodes to GLS_non_el_inpatient_episodes
    GLS_inpatient_beddays to GLS_non_el_inpatient_beddays
    OP_newcons_attendances OP_newcons_dnas
    AE_attendances
    PIS_dispensed_items
    CH_episodes CH_beddays
    OoH_cases to OoH_consultation_time
    DN_episodes DN_contacts
    CMH_contacts (F8.0).

* Recode all the system missing values to zero so that calculations will work.
Recode Acute_episodes to DN_cost (sysmis = 0).

* Create a total health cost.
compute health_net_cost = Acute_cost + Mat_cost + MH_cost + GLS_cost + OP_cost_attend + AE_cost + PIS_cost + OoH_cost.
compute health_net_costincDNAs = Acute_cost + Mat_cost + MH_cost + GLS_cost + OP_cost_attend + OP_cost_dnas + AE_cost + PIS_cost + OoH_cost.

* Care home and DN costs aren't included in the above as we do not have data for all LCAs / HBs (also the completness of what we do have is questionable).
compute health_net_costincIncomplete = health_net_cost + CH_cost + DN_cost.

 * Create a year variable for time-series linking.
String year (A4).
Compute year = !FY.

* Delete the record specific dob gpprac and postcode, and reorder others whilst we're here.
save outfile =!file + "temp-source-individual-file-2-20" + !FY + ".zsav"
   /Drop Acute_dob to NRS_dob
      Keep
   /Keep year chi gender dob age postcode gpprac
      health_net_cost health_net_costincDNAs health_net_costincIncomplete
      deceased death_date
      ALL
   /zcompressed.

get file = !file + "temp-source-individual-file-2-20" + !FY + ".zsav".
