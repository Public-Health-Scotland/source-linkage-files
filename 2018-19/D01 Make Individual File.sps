* Encoding: UTF-8.
* We create a row per chi by producing various summaries from the episode file.

* Produced, based on the original, by James McMahon.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.
get file = !File + "source-episode-file-20" + !FY + ".zsav".

* Exclude people with blank chi.
select if chi NE "".

* Declare the variables we will use to store postcode etc. data.
* Don't include DD as this data has just been taken from acute / MH.
Numeric Acute_DoB Mat_DoB MH_DoB GLS_DoB OP_DoB AE_DoB PIS_DoB OoH_DoB DN_DoB CMH_DoB NSU_DoB NRS_DoB HL1_DoB CH_DoB HC_DoB AT_DoB SDS_DoB (Date12).
String Acute_postcode Mat_postcode MH_postcode GLS_postcode OP_postcode AE_postcode PIS_postcode OoH_postcode DN_postcode CMH_postcode NSU_postcode NRS_postcode HL1_postcode CH_postcode HC_postcode AT_postcode SDS_postcode (A7).
Numeric Acute_gpprac Mat_gpprac MH_gpprac GLS_gpprac OP_gpprac AE_gpprac PIS_gpprac OoH_gpprac DN_gpprac CMH_gpprac NSU_gpprac NRS_gpprac CH_gpprac HC_gpprac AT_gpprac SDS_gpprac (F5.0).

* Set any blanks as user missing, so they will be ignored by the aggregate.
Missing Values
    Acute_postcode to SDS_postcode
    ("").
* Create a series of indicators which can be aggregated later to provide a summary for each CHI.
*************************************************************************************************************************************************.
* First Initialise all variables.
Numeric
    Acute_episodes Acute_daycase_episodes Acute_inpatient_episodes Acute_el_inpatient_episodes Acute_non_el_inpatient_episodes Acute_el_inpatient_beddays Acute_non_el_inpatient_beddays
    Acute_cost Acute_daycase_cost Acute_inpatient_cost Acute_el_inpatient_cost Acute_non_el_inpatient_cost Acute_inpatient_beddays
    Mat_episodes Mat_daycase_episodes Mat_inpatient_episodes Mat_inpatient_beddays
    Mat_cost Mat_daycase_cost Mat_inpatient_cost
    MH_episodes MH_inpatient_episodes MH_el_inpatient_episodes MH_non_el_inpatient_episodes MH_inpatient_beddays MH_el_inpatient_beddays MH_non_el_inpatient_beddays
    MH_cost MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost
    GLS_episodes GLS_inpatient_episodes GLS_el_inpatient_episodes GLS_non_el_inpatient_episodes GLS_inpatient_beddays GLS_el_inpatient_beddays GLS_non_el_inpatient_beddays
    GLS_cost GLS_inpatient_cost GLS_el_inpatient_cost GLS_non_el_inpatient_cost
    DD_NonCode9_episodes DD_NonCode9_beddays DD_Code9_episodes DD_Code9_beddays
    OP_newcons_attendances OP_newcons_dnas
    OP_cost_attend OP_cost_dnas
    AE_attendances
    AE_cost
    PIS_dispensed_items
    PIS_cost
    OoH_cases OoH_homeV OoH_advice OoH_DN OoH_NHS24 OoH_other OoH_PCC OoH_consultation_time
    OoH_cost
    DN_episodes DN_contacts
    DN_cost
    CMH_contacts
    CH_episodes CH_beddays
    CH_cost
    HC_episodes HC_personal_episodes HC_non_personal_episodes
    AT_alarms AT_telecare
    SDS_option_1 SDS_option_2 SDS_option_3
    CIJ_el
    CIJ_non_el
    CIJ_mat.

Numeric NSU (F1.0).

* Create a variable to count CIJs.
sort cases by CHI cij_marker.
add files file = *
    /by CHI cij_marker
    /First = Distinct_CIJ.

If cij_marker = "" Distinct_CIJ = 0.

Do if cij_pattype_code = 0.
    Compute CIJ_non_el = Distinct_CIJ.
Else if cij_pattype_code = 1.
    Compute CIJ_el = Distinct_CIJ.
Else if cij_pattype_code = 2.
    Compute CIJ_mat = Distinct_CIJ.
End if.

* For SMR01/02/04/01_1E: sum activity and costs per patient with an Elective/Non-Elective split.
* Acute (SMR01) section.

Do if (SMRType = "Acute-DC" OR SMRType = "Acute-IP") AND (cij_pattype NE "Maternity").
    Compute Acute_DoB = DoB.
    Compute Acute_postcode = postcode.
    Compute Acute_gpprac = gpprac.

    Compute Acute_episodes = 1.
    Compute Acute_cost = Cost_Total_Net.

    * Create Inpatient / Daycase activity, cost and bed day counts for acute elective / non-elective inpatients and day cases.
    Do if (IPDC = "I").
        * Episode count.
        Compute Acute_inpatient_episodes = 1.
        If (cij_pattype = "Elective") Acute_el_inpatient_episodes = 1.
        If (cij_pattype = "Non-Elective") Acute_non_el_inpatient_episodes = 1.

        * Beddays count.
        Compute Acute_inpatient_beddays = yearstay.
        If (cij_pattype = "Elective") Acute_el_inpatient_beddays = yearstay.
        If (cij_pattype = "Non-Elective") Acute_non_el_inpatient_beddays = yearstay.

        * Cost.
        Compute Acute_inpatient_cost = Cost_Total_Net.
        if (cij_pattype = "Elective") Acute_el_inpatient_cost = Cost_Total_Net.
        if (cij_pattype = "Non-Elective") Acute_non_el_inpatient_cost = Cost_Total_Net.
    Else if (IPDC = "D").
        * Episode count.
        Compute Acute_daycase_episodes = 1.

        * Cost.
        Compute Acute_daycase_cost = Cost_Total_Net.
    End if.

Else if (recid = "02B" OR cij_pattype = "Maternity").
    *************************************************************************************************************************************************.
    * Maternity (SMR02) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.

    Compute Mat_DoB = DoB.
    Compute Mat_postcode = postcode.
    Compute Mat_gpprac = gpprac.


    Compute Mat_episodes = 1.
    Compute Mat_cost = Cost_Total_Net.

    * Create Inpatient / Daycase activity, cost and bed day counts for Maternity.
    Do if (IPDC = "I").
        * Episode count.
        Compute Mat_inpatient_episodes = 1.

        * Beddays count.
        Compute Mat_inpatient_beddays = yearstay.


        Compute Mat_inpatient_cost = Cost_Total_Net.
    Else if (IPDC = "D").
        * Episode count.
        Compute Mat_daycase_episodes = 1.

        * Cost.
        Compute Mat_daycase_cost = Cost_Total_Net.
    End if.

Else if (recid = "04B") AND (cij_pattype NE "Maternity").
    *************************************************************************************************************************************************.
    * Mental Health (SMR04) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute MH_DoB = DoB.
    Compute MH_postcode = postcode.
    Compute MH_gpprac = gpprac.

    Compute MH_episodes = 1.
    Compute MH_cost = Cost_Total_Net.

    * Create Inpatient (no Day Case activity for acute Mental Health) activity, cost and bed day counts for acute Mental Health elective / non-elective inpatients and day cases.
    Do if (IPDC = "I").
        * Episode count.
        Compute MH_inpatient_episodes = 1.
        If (cij_pattype = "Elective") MH_el_inpatient_episodes = 1.
        If (cij_pattype = "Non-Elective") MH_non_el_inpatient_episodes = 1.

        * Beddays count.
        Compute MH_inpatient_beddays = yearstay.
        If (cij_pattype = "Elective") MH_el_inpatient_beddays = yearstay.
        If (cij_pattype = "Non-Elective") MH_non_el_inpatient_beddays = yearstay.

        * Cost.
        Compute MH_inpatient_cost = Cost_Total_Net.
        if (cij_pattype = "Elective") MH_el_inpatient_cost = Cost_Total_Net.
        if (cij_pattype = "Non-Elective") MH_non_el_inpatient_cost = Cost_Total_Net.
    End if.
Else if (SMRType = "GLS-IP").
    *************************************************************************************************************************************************.
    * Geriatric Long Stay (SMR01_1E) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute GLS_DoB = DoB.
    Compute GLS_postcode = postcode.
    Compute GLS_gpprac = gpprac.

    Compute GLS_episodes = 1.
    Compute GLS_cost = Cost_Total_Net.

    * Create Inpatient (no Day Case activity for GLS) activity, cost and bed day counts for Geriatric Long Stay elective / non-elective inpatients and day cases.
    Do if (IPDC = "I").
        * Episode count.
        Compute GLS_inpatient_episodes = 1.
        If (cij_pattype = "Elective") GLS_el_inpatient_episodes = 1.
        If (cij_pattype = "Non-Elective") GLS_non_el_inpatient_episodes = 1.

        * Beddays count.
        Compute GLS_inpatient_beddays = yearstay.
        If (cij_pattype = "Elective") GLS_el_inpatient_beddays = yearstay.
        If (cij_pattype = "Non-Elective") GLS_non_el_inpatient_beddays = yearstay.

        * Cost.
        Compute GLS_inpatient_cost = Cost_Total_Net.
        if (cij_pattype = "Elective") GLS_el_inpatient_cost = Cost_Total_Net.
        if (cij_pattype = "Non-Elective") GLS_non_el_inpatient_cost = Cost_Total_Net.
    End if.

Else if (recid = "00B").
    *************************************************************************************************************************************************.
    * Outpatients (SMR00) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.

    Compute OP_DoB = DoB.
    Compute OP_postcode = postcode.
    Compute OP_gpprac = gpprac.

    * Activity (count the attendances).
    Do if (attendance_status = 1).
        * Attended episode count.
        Compute OP_newcons_attendances = 1.

        * Cost of attended episodes.
        Compute OP_cost_attend = Cost_Total_Net.
    Else if (any(attendance_status, 5, 8)).
        * Unattended episode count.
        Compute OP_newcons_dnas = 1.

        * Cost of DNAs only.
        Compute OP_cost_dnas = Cost_Total_Net_incDNAs.
    End if.

Else if (recid = "AE2").
    *************************************************************************************************************************************************.
    * Accident and Emergency (AE2) section (sum the number of of attendances and costs associated).
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute AE_DoB = DoB.
    Compute AE_postcode = postcode.
    Compute AE_gpprac = gpprac.

    * Activity (count the attendances).
    Compute AE_attendances = 1.
    Compute AE_cost = Cost_Total_Net.

Else if (recid = "PIS").
    *************************************************************************************************************************************************.
    * Prescribing (PIS) section.
    * For Prescribing: sum the information by patient * only one row per person exists in the master PLICs file with minimal data.

    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
        append this to the end of each record for each patient.
    Compute PIS_DoB = DoB.
    Compute PIS_postcode = postcode.
    Compute PIS_gpprac = gpprac.

    Compute PIS_dispensed_items = no_dispensed_items.
    Compute PIS_cost = Cost_Total_Net.

Else if (recid = "OoH").
    *************************************************************************************************************************************************.
    * GP Out of Hours (OoH) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute OoH_DoB = DoB.
    Compute OoH_postcode = postcode.
    Compute OoH_gpprac = gpprac.

    * For activity count the number of consultations of each type.
    Do If SMRType = "OOH-HomeV".
        Compute OoH_homeV = 1.
    Else If SMRType = "OOH-Advice".
        Compute OoH_advice = 1.
    Else If SMRType = "OOH-DN".
        Compute OoH_DN = 1.
    Else If SMRType = "OOH-NHS24".
        Compute OoH_NHS24 = 1.
    Else If SMRType = "OOH-Other".
        Compute OoH_other = 1.
    Else If SMRType = "OOH-PCC".
        Compute OoH_PCC = 1.
    End If.

    * Cost (use the Cost_Total_Net).
    Compute OoH_cost = Cost_Total_Net.

    * Time.
    Compute OoH_consultation_time = DateDiff(keydate2_dateformat + keyTime2,  keydate1_dateformat + KeyTime1, "minutes").
    * Fix any dodgy records.
    if OoH_consultation_time < 0 OoH_consultation_time = 0.

Else if (recid = "DN").
    *************************************************************************************************************************************************.
    * District Nursing (DN) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute DN_DoB = DoB.
    Compute DN_postcode = postcode.
    Compute DN_gpprac = gpprac.

    * For activity count the number of episodes and the contacts.
    Compute DN_episodes = 1.
    Compute DN_contacts = TotalnoDNcontacts.

    * Cost (use the Cost_Total_Net).
    Compute DN_cost = Cost_Total_Net.

    * Time.
    * Leaving this out for now due to problems with contact duration variable.
    *Compute DN_total_duration = TotalDurationofContacts.

Else if (recid = "CMH").
    *************************************************************************************************************************************************.
    * Community Mental Health (CMH) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute CMH_DoB = DoB.
    Compute CMH_postcode = postcode.
    Compute CMH_gpprac = gpprac.

    * For activity count the number of contacts.
    Compute CMH_contacts = 1.

Else if (recid = "DD").
    *************************************************************************************************************************************************.
    * Delayed Discharge (DD) section.
    * Not taking any demographic fields from DD.

    Do if (Primary_Delay_Reason NE "9").
        * Episode Count.
        Compute DD_NonCode9_episodes = 1.

        * Bedday Count.
        Compute DD_NonCode9_beddays = yearstay.
    Else if (Primary_Delay_Reason = "9").
        * Episode Count.
        Compute DD_Code9_episodes = 1.

        * Bedday Count.
        Compute DD_Code9_beddays = yearstay.
    End if.

Else if (recid = "NSU").
    *************************************************************************************************************************************************.
    * Non-Service-User (NSU) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute NSU_DoB = DoB.
    Compute NSU_postcode = postcode.
    Compute NSU_gpprac = gpprac.

    * By definition these CHIs should have no activity but we will create a flag to make this clear.
    Compute NSU = 1.

    *************************************************************************************************************************************************.
Else if (recid = "NRS").
    Compute NRS_DoB = DoB.
    Compute NRS_postcode = postcode.
    Compute NRS_gpprac = gpprac.
    Compute NRS = 1.

    *************************************************************************************************************************************************.
Else if (recid = "HL1").
    Compute HL1_DoB = DoB.
    Compute HL1_postcode = postcode.

Else if (recid = "CH").
    *************************************************************************************************************************************************.
    * Care Home (CH) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute CH_DoB = DoB.
    Compute CH_postcode = postcode.
    Compute CH_gpprac = gpprac.

    * Episode count.
    Compute CH_episodes = 1.

    * Cost.
    Compute CH_cost = Cost_Total_Net.

    * Beddays.
    Compute CH_beddays = yearstay.
Else if (recid = "HC").
    *************************************************************************************************************************************************.
    * Home Care (HC) section.
    * For the fields that there will be a hierarchy taken, aggregate and take the last of each column and * append this to the end of each record for each patient.
    Compute HC_DoB = DoB.
    Compute HC_postcode = postcode.
    Compute HC_gpprac = gpprac.

    * Episode count.
    Compute HC_episodes = 1.

    * Hours count.
    Compute HC_total_hours = hc_hours.

    Do if SMRType = "HC-Per".
        Compute HC_personal_episodes = 1.
        Compute HC_personal_hours = hc_hours.
    Else if SMRType = "HC-Non-Per".
        Compute HC_non_personal_episodes = 1.
        Compute HC_personal_hours = hc_hours.
    End if.

Else if (recid = "AT").
    *************************************************************************************************************************************************.
    * Alarms and Telecare (AT) section.
    Compute AT_DoB = DoB.
    Compute AT_postcode = postcode.
    Compute AT_gpprac = gpprac.

    If SMRType = "AT-Alarm" AT_alarms = 1.
    If SMRType = "AT-Tele" AT_telecare = 1.

Else if (recid = "SDS").
    *************************************************************************************************************************************************.
    * Self-Directed Support (SDS) section.
    Compute SDS_DoB = DoB.
    Compute SDS_postcode = postcode.
    Compute SDS_gpprac = gpprac.

    If SMRType = "SDS-1" SDS_option_1 = 1.
    If SMRType = "SDS-2" SDS_option_2 = 1.
    If SMRType = "SDS-3" SDS_option_3 = 1.
End if.

*************************************************************************************************************************************************.
* We'll use this to get the most accurate gender we can.
Recode gender (0 = 1.5) (9 = 1.5).

* Sort data into chi and episode date order.
Sort cases by chi keydate1_dateformat keyTime1 keydate2_dateformat keyTime2.

* Now aggregate by Chi, keep all of the variables we made, we'll clean them up next.
* Also keep variables that are only dependant on CHI (as opposed to postcode) e.g. death_date, cohorts, LTC etc.
* Using Presorted so that we keep the ordering from earlier (chi, keydate1). This way, when we do 'Last', we get the most recent (non-blank) data from each record.
aggregate outfile = *
    /Presorted
    /break chi
    /gender = Mean(gender)
    /Acute_postcode Mat_postcode MH_postcode GLS_postcode OP_postcode AE_postcode PIS_postcode OoH_postcode DN_postcode CMH_postcode NSU_postcode NRS_postcode HL1_postcode CH_postcode HC_postcode AT_postcode SDS_postcode
    = Last(Acute_postcode Mat_postcode MH_postcode GLS_postcode OP_postcode AE_postcode PIS_postcode OoH_postcode DN_postcode CMH_postcode NSU_postcode NRS_postcode HL1_postcode CH_postcode HC_postcode AT_postcode SDS_postcode)
    /Acute_DoB Mat_DoB MH_DoB GLS_DoB OP_DoB AE_DoB PIS_DoB OoH_DoB DN_DoB CMH_DoB NSU_DoB NRS_DoB HL1_DoB CH_DoB HC_DoB AT_DoB SDS_DoB
    = Last(Acute_DoB Mat_DoB MH_DoB GLS_DoB OP_DoB AE_DoB PIS_DoB OoH_DoB DN_DoB CMH_DoB NSU_DoB NRS_DoB HL1_DoB CH_DoB HC_DoB AT_DoB SDS_DoB)
    /Acute_gpprac Mat_gpprac MH_gpprac GLS_gpprac OP_gpprac AE_gpprac PIS_gpprac OoH_gpprac DN_gpprac CMH_gpprac NSU_gpprac NRS_gpprac CH_gpprac HC_gpprac AT_gpprac SDS_gpprac
    = Last(Acute_gpprac Mat_gpprac MH_gpprac GLS_gpprac OP_gpprac AE_gpprac PIS_gpprac OoH_gpprac DN_gpprac CMH_gpprac NSU_gpprac NRS_gpprac CH_gpprac HC_gpprac AT_gpprac SDS_gpprac)
    /Acute_episodes Acute_daycase_episodes Acute_inpatient_episodes Acute_el_inpatient_episodes Acute_non_el_inpatient_episodes
    Acute_cost Acute_daycase_cost Acute_inpatient_cost Acute_el_inpatient_cost Acute_non_el_inpatient_cost
    Acute_inpatient_beddays Acute_el_inpatient_beddays Acute_non_el_inpatient_beddays
    = sum(Acute_episodes Acute_daycase_episodes Acute_inpatient_episodes Acute_el_inpatient_episodes Acute_non_el_inpatient_episodes
    Acute_cost Acute_daycase_cost Acute_inpatient_cost Acute_el_inpatient_cost Acute_non_el_inpatient_cost
    Acute_inpatient_beddays Acute_el_inpatient_beddays Acute_non_el_inpatient_beddays)
    /Mat_episodes Mat_daycase_episodes Mat_inpatient_episodes Mat_cost Mat_daycase_cost Mat_inpatient_cost Mat_inpatient_beddays
    = sum(Mat_episodes Mat_daycase_episodes Mat_inpatient_episodes Mat_cost Mat_daycase_cost Mat_inpatient_cost Mat_inpatient_beddays)
    /MH_episodes MH_inpatient_episodes
    MH_el_inpatient_episodes MH_non_el_inpatient_episodes
    MH_cost MH_inpatient_cost
    MH_el_inpatient_cost MH_non_el_inpatient_cost
    MH_inpatient_beddays MH_el_inpatient_beddays MH_non_el_inpatient_beddays
    = sum(MH_episodes MH_inpatient_episodes
    MH_el_inpatient_episodes MH_non_el_inpatient_episodes
    MH_cost MH_inpatient_cost
    MH_el_inpatient_cost MH_non_el_inpatient_cost
    MH_inpatient_beddays MH_el_inpatient_beddays MH_non_el_inpatient_beddays)
    /GLS_episodes GLS_inpatient_episodes
    GLS_el_inpatient_episodes GLS_non_el_inpatient_episodes
    GLS_cost GLS_inpatient_cost
    GLS_el_inpatient_cost GLS_non_el_inpatient_cost
    GLS_inpatient_beddays GLS_el_inpatient_beddays GLS_non_el_inpatient_beddays
    = sum(GLS_episodes GLS_inpatient_episodes
    GLS_el_inpatient_episodes GLS_non_el_inpatient_episodes
    GLS_cost GLS_inpatient_cost
    GLS_el_inpatient_cost GLS_non_el_inpatient_cost
    GLS_inpatient_beddays GLS_el_inpatient_beddays GLS_non_el_inpatient_beddays)
    /OP_newcons_attendances OP_newcons_dnas OP_cost_attend OP_cost_dnas
    = sum(OP_newcons_attendances OP_newcons_dnas OP_cost_attend OP_cost_dnas)
    /AE_attendances AE_cost = sum(AE_attendances AE_cost)
    /PIS_dispensed_items PIS_cost = sum(no_dispensed_items PIS_cost)
    /OoH_cases = Max(OoH_CC)
    /OoH_homeV OoH_advice OoH_DN OoH_NHS24 OoH_other OoH_PCC OoH_consultation_time OoH_cost
    = sum(OoH_homeV OoH_advice OoH_DN OoH_NHS24 OoH_other OoH_PCC OoH_consultation_time OoH_cost)
    /DD_NonCode9_episodes DD_NonCode9_beddays DD_Code9_episodes DD_Code9_beddays
    = sum(DD_NonCode9_episodes DD_NonCode9_beddays DD_Code9_episodes DD_Code9_beddays)
    /DN_episodes DN_contacts DN_cost
    = sum(DN_episodes DN_contacts DN_cost)
    /CMH_contacts
    = sum(CMH_contacts)
    /CH_episodes CH_beddays CH_cost = sum(CH_episodes CH_beddays CH_cost)
    /HC_episodes HC_personal_episodes HC_non_personal_episodes = sum(HC_episodes HC_personal_episodes HC_non_personal_episodes)
    /AT_alarms AT_telecare = sum(AT_alarms AT_telecare)
    /SDS_option_1 SDS_option_2 SDS_option_3 = sum(SDS_option_1 SDS_option_2 SDS_option_3)
    /SDS_option_4 = Max(SDS_option_4)
    /HL1_in_FY = Max(HH_in_FY)
    /CIJ_el CIJ_non_el CIJ_mat = Sum(CIJ_el CIJ_non_el CIJ_mat)
    /NSU = Max(NSU)
    /deceased death_date = First(deceased death_date)
    /arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive
    = First(arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms parkinsons refailure congen bloodbfo endomet digestive)
    /arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date
    chd_date hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date
    = First(arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date
    chd_date hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date)
    /sc_living_alone sc_support_from_unpaid_carer sc_social_worker sc_type_of_housing sc_meals sc_day_care =
    First(sc_living_alone sc_support_from_unpaid_carer sc_social_worker sc_type_of_housing sc_meals sc_day_care)
    /Demographic_Cohort Service_Use_Cohort
    = First(Demographic_Cohort Service_Use_Cohort)
    /SPARRA_Start_FY SPARRA_End_FY
    = First(SPARRA_Start_FY SPARRA_End_FY)
    /HHG_Start_FY HHG_End_FY
    = First(HHG_Start_FY HHG_End_FY).

* Do a temporary save as the above can take a while to run.
save outfile = !file + "temp-source-individual-file-1-20" + !FY + ".zsav"
    /zcompressed.
get file = !file + "temp-source-individual-file-1-20" + !FY + ".zsav".

* Clean up the gender, use the most common (by rounding the mean), if the mean is 1.5 (i.e. no gender known or equal male and females) then take it from the CHI).
Do if gender NE 1.5.
    Compute gender = rnd(gender).
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
Numeric DoB (Date12).

* Create 2 scratch variables with the possible DoBs and ages from the CHI.
Compute #CHI_DoB1 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".19", char.substr(chi, 5, 2)), EDate12).
Compute #CHI_DoB2 = Number(Concat(char.substr(chi, 1, 2), ".", char.substr(chi, 3, 2), ".20", char.substr(chi, 5, 2)), EDate12).
Compute #CHI_age1 = DateDiff(!midFY, #CHI_DoB1, "years").
Compute #CHI_age2 = DateDiff(!midFY, #CHI_DoB2, "years").

* If any of the DoBs from the dataset match the DoB in the CHI, use that (don't use if we have contradictions).
Do if any(#CHI_DoB1, Acute_DoB, Mat_DoB, MH_DoB, GLS_DoB, OP_DoB, AE_DoB, PIS_DoB, OoH_DoB, DN_DoB, CMH_DoB, NSU_DoB, NRS_DoB, HL1_DoB, CH_DoB, HC_DoB, AT_DoB, SDS_DoB)
    and Not(any(#CHI_DoB2, Acute_DoB, Mat_DoB, MH_DoB, GLS_DoB, OP_DoB, AE_DoB, PIS_DoB, OoH_DoB, DN_DoB, CMH_DoB, NSU_DoB, NRS_DoB, HL1_DoB, CH_DoB, HC_DoB, AT_DoB, SDS_DoB)).
    Compute DoB = #CHI_DoB1.
Else if Not(any(#CHI_DoB1, Acute_DoB, Mat_DoB, MH_DoB, GLS_DoB, OP_DoB, AE_DoB, PIS_DoB, OoH_DoB, DN_DoB, CMH_DoB, NSU_DoB, NRS_DoB, HL1_DoB, CH_DoB, HC_DoB, AT_DoB, SDS_DoB))
    and any(#CHI_DoB2, Acute_DoB, Mat_DoB, MH_DoB, GLS_DoB, OP_DoB, AE_DoB, PIS_DoB, OoH_DoB, DN_DoB, CMH_DoB, NSU_DoB, NRS_DoB, HL1_DoB, CH_DoB, HC_DoB, AT_DoB, SDS_DoB).
    Compute DoB = #CHI_DoB2.
End if.

Numeric age (F3.0).
* Compute age and DoB if we can.
* This method is very similar to that in C01 except we don't look at activity.
Do If (sysmis(DoB)).
    * If either of the DoBs are missing use the other one.
    * This only happens with impossible dates because of leap years.
    Do if sysmis(#CHI_DoB1) AND Not(sysmis(#CHI_DoB2)).
        Compute DoB = #CHI_DoB2.
    Else if sysmis(#CHI_DoB2) AND Not(sysmis(#CHI_DoB1)).
        Compute DoB = #CHI_DoB1.
        * If the younger age is negative, assume they are the older one.
    Else if #CHI_age2 < 0.
        Compute DoB = #CHI_DoB1.
        * Similar to the above, if the younger date makes them born after today, or the end of the FY then assume the older one.
    Else if #CHI_DoB2 > Min($time, date.DMY(31, 03, Number(!altFY, F4.0) + 1)).
        Compute DoB = #CHI_DoB1.
        * If the younger DoB means that they have an LTC (or died) before birth assume they are the older one.
    Else if #CHI_DoB2 > Min(death_date, arth_date to digestive_date).
        Compute DoB = #CHI_DoB1.
        * If the congenital defect date lines up with a DoB, assume it's correct.
    Else if any(congen_date, #CHI_DoB1, #CHI_DoB2).
        Compute DoB = congen_date.
        * If the older age makes the person older than 115, assume they are younger (oldest living person is 113).
    Else if #CHI_age1 > 115.
        Compute DoB = #CHI_DoB2.
    End if.
End If.

* If we haven't managed to deduce the age from CHI and activity, fill in from datasets.
Do if sysmis(DoB).
    Do if Not(sysmis(PIS_DoB)).
        Compute DoB = PIS_DoB.
    Else if Not(sysmis(AE_DoB)).
        Compute DoB = AE_DoB.
    Else if Not(sysmis(OoH_DoB)).
        Compute DoB = OoH_DoB.
    Else if Not(sysmis(OP_DoB)).
        Compute DoB = OP_DoB.
    Else if Not(sysmis(Acute_DoB)).
        Compute DoB = Acute_DoB.
    Else if Not(sysmis(Mat_DoB)).
        Compute DoB = Mat_DoB.
    Else if Not(sysmis(DN_DoB)).
        Compute DoB = DN_DoB.
    Else if Not(sysmis(CMH_DoB)).
        Compute DoB = CMH_DoB.
    Else if Not(sysmis(MH_DoB)).
        Compute DoB = MH_DoB.
    Else if Not(sysmis(GLS_DoB)).
        Compute DoB = GLS_DoB.
    Else if Not(sysmis(HL1_DoB)).
        Compute DoB = HL1_DoB.
    Else if Not(sysmis(CH_DoB)).
        Compute DoB = CH_DoB.
    Else if Not(sysmis(HC_DoB)).
        Compute DoB = HC_DoB.
    Else if Not(sysmis(AT_DoB)).
        Compute DoB = AT_DoB.
    Else if Not(sysmis(SDS_DoB)).
        Compute DoB = SDS_DoB.
    Else if Not(sysmis(NSU_DoB)).
        Compute DoB = NSU_DoB.
    Else if Not(sysmis(NRS_DoB)).
        Compute DoB = NRS_DoB.
    End if.
End if.

Do if sysmis(age).
    Compute age = DateDiff(!midFY, DoB, "years").
End if.

* If all postcodes are blank create a dummy postcode so we don't lose the CHI - we'll clean this up later.
* First figure out if they are all blank.
Compute #All_Blank = 1.

Do repeat postcode = acute_postcode to SDS_postcode.
    If postcode NE "" #All_Blank = 0.
End repeat.

* Use NRS_postcode to store the dummy for no other reason than it's last in the hierarchy.
If #All_Blank = 1 HL1_postcode = "XXX XXX".

* Make a postcode variable from the various postcodes labelled by the dataset they came from.
VarsToCases
    /make postcode from acute_postcode to SDS_postcode
    /Index dataset (postcode)
    /Drop Acute_dob to SDS_dob.

* Count the number of times each postcode appears for each chi.
aggregate
    /break chi postcode
    /nDistPostcodes = n(postcode).

* Give an order based on old hierarchy. This will only be used if we have a 'tie'.
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
Else if dataset = "HC_postcode".
    Compute order = 11.
Else if dataset = "AT_postcode".
    Compute order = 12.
Else if dataset = "SDS_postcode".
    Compute order = 13.
Else if dataset = "CH_postcode".
    Compute order = 14.
Else if dataset = "NSU_postcode".
    Compute order = 15.
Else if dataset = "NRS_postcode".
    Compute order = 16.
Else if dataset = "HL1_postcode".
    Compute order = 17.
End if.

* Match on to the postcode file, to get a flag letting us know if the postcode is real or not.
sort cases by postcode.
match files file = *
    /table = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
    /In PostcodeMatch
    /Keep chi to order
    /By Postcode.

* Sort the CHIs postcodes according to;.
* 1) Is it a real postcode.
* 2) How often that postcode appears with that chi.
* 3) Finally which dataset it came from (order).
sort cases by chi (A) PostcodeMatch (D) nDistPostcodes (D) Order (A).

* Use this to flag the first record as 'keep'.
add files
    /file = *
    /First = Keep
    /By Chi.

* Just keep the first record.
Select if Keep = 1.
if postcode = 'XXX XXX' postcode = "".
Crosstabs dataset by Keep
    /Cells count column.
Delete variables Keep dataset nDistPostcodes order PostcodeMatch.

*********************************************************************************.
* Do the same for gpprac.

* If all gpprac are blank create a dummy gpprac so we don't lose the CHI - we'll clean this up later.
* First figure out if they are all blank.
Compute #All_Blank = 1.

* We don't use HL1 gpprac as this doesn't come from the dataset and will have only been added from other records.
Do repeat gpprac = acute_gpprac to SDS_gpprac.
    If Not(sysmis(gpprac))  #All_Blank = 0.
End repeat.

* Use NRS_gpprac to store the dummy for no other reason than it's last in the hierarchy.
If #All_Blank = 1 SDS_gpprac = 0.

* Make a gpprac variable from the various gpprac labelled by the dataset they came from.
VarsToCases
    /make gpprac from acute_gpprac to SDS_gpprac
    /Index dataset (gpprac).

* Count the number of times each gpprac appears for each chi.
aggregate
    /break chi gpprac
    /nDistGPpracs = n(gpprac).

* Give an order based on old hierarchy. This will only be used if we have a 'tie'.
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
Else if dataset = "HC_gpprac".
    Compute order = 11.
Else if dataset = "AT_gpprac".
    Compute order = 12.
Else if dataset = "SDS_gpprac".
    Compute order = 13.
Else if dataset = "CH_gpprac".
    Compute order = 14.
Else if dataset = "NSU_gpprac".
    Compute order = 15.
Else if dataset = "NRS_gpprac".
    Compute order = 16.
Else if dataset = "HL1_gpprac".
    Compute order = 17.
End if.

* Match on to the gpprac file, to get a flag letting us know if the gpprac is real or not.
sort cases by gpprac.
match files file = *
    /table = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav"
    /In gppracMatch
    /Keep chi to order
    /By gpprac.

* Sort the CHIs gpprac according to;.
* 1) Is it a real gpprac.
* 2) How often that gpprac appears with that chi.
* 3) Finally which dataset it came from (order).
sort cases by chi (A) gppracMatch (D) nDistGPpracs (D) Order (A).

* Use this to flag the first record as 'keep'.
add files
    /file = *
    /First = Keep
    /By Chi.

Select if Keep = 1.
if gpprac = 0 gpprac = $sysmis.
Crosstabs dataset by Keep
    /Cells count column.
Delete Variables Keep dataset nDistGPpracs order gppracMatch.

* Recode all the system missing values to zero so that calculations will work.
Recode Acute_episodes to deceased (sysmis = 0).

* Create a total health cost.
Compute health_net_cost = Acute_cost + Mat_cost + MH_cost + GLS_cost + OP_cost_attend + AE_cost + PIS_cost + OoH_cost.
Compute health_net_costincDNAs = Acute_cost + Mat_cost + MH_cost + GLS_cost + OP_cost_attend + OP_cost_dnas + AE_cost + PIS_cost + OoH_cost.

* Care home and DN costs aren't included in the above as we do not have data for all LCAs / HBs (also the completeness of what we do have is questionable).
Compute health_net_costincIncomplete = health_net_cost + CH_cost + DN_cost.

* Create a year variable for time-series linking.
String year (A4).
Compute year = !FY.

* Delete the record specific DoB gpprac and postcode, and reorder others whilst we're here.
save outfile = !file + "temp-source-individual-file-2-20" + !FY + ".zsav"
    /Keep year chi gender DoB age postcode gpprac
    health_net_cost health_net_costincDNAs health_net_costincIncomplete
    deceased death_date
    ALL
    /zcompressed.

get file = !file + "temp-source-individual-file-2-20" + !FY + ".zsav".
