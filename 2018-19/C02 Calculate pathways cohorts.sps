* Encoding: UTF-8.
*Cohort Syntax.
*Andrew Mooney.
*Feb 2017.

* ModIfied for 15/16 for SLF update, DKG October 2017.


********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

*Last ran 21/05/18-AnitaGeorge.
**********************************************************************************************************************.

*2. Create the Demographic Service_Use_Cohort File.

get file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".

select If CHI ne ''.

*Mental Health ClassIfication.
compute MH_Cohort = 0.
If recid = '04B' MH_Cohort = 1.
do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If any(char.substr(x, 1,2), 'F2', 'F3') or any(char.substr(x, 1,4), 'F067', 'F070', 'F072', 'F078', 'F079').
        compute MH_Cohort = 1.
    End If.
end repeat.
* If MentalHealthProblemsClientGroup = 'Y' MH_Cohort = 1.


*Frailty ClassIfication.
compute Frail_Cohort = 0.
If (recid = 'CH' and age GE 65) Frail_Cohort = 1.
do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If (any(char.substr(x, 1,2), 'W0', 'W1') or any(char.substr(x, 1, 3), 'F00', 'F01', 'F02', 'F03', 'F05', 'I61', 'I63', 'I64', 'G20', 'G21') or any(char.substr(x, 1,4), 'R268', 'G22X') or spec = 'AB' or any(sigfac, '1E', '1D') or recid = 'GLS').
        compute Frail_Cohort  = 1.
    End If.
end repeat.
*If ElderlyFrailClientGroup = 'Y' Frail_Cohort = 1.

*Maternity ClassIfication.
compute Maternity_Cohort = 0.
If recid = '02B' Maternity_Cohort = 1.

*High CC ClassIfication.
compute High_CC_Cohort = 0.
If (Dementia = 1 or hefailure = 1 or refailure = 1 or liver = 1 or Cancer = 1) High_CC_Cohort = 1.
If (recid = 'CH' and age LT 65) High_CC_Cohort = 1.
* If PhysicalandSensoryDisabilityClientGroup = 'Y' High_CC_Cohort = 1.
If spec = 'G5' High_CC_Cohort = 1.
* If LearningDisabilityClientGroup = 'Y' High_CC_Cohort = 1.


*Medium CC ClassIfication.
compute Medium_CC_Cohort = 0.
If (CVD = 1 or COPD = 1 or CHD = 1 or Parkinsons = 1 or MS = 1) Medium_CC_Cohort = 1.


*Low CC ClassIfication.
compute Low_CC_Cohort = 0.
If (Epilepsy = 1 or Asthma = 1 or Arth = 1 or Diabetes = 1 or atrialfib = 1) Low_CC_Cohort = 1.


*Assisted Living in the Community.
compute Comm_Living_Cohort = 0.
If any (recid, 'HC-', 'HC + ', 'RSP', 'DN', 'MLS', 'INS', 'CPL', 'DC') Comm_Living_Cohort = 1.


compute Prescribing_Cost = 0.
If recid = 'PIS' Prescribing_Cost = Cost_Total_Net.


*Adult Major Conditions ClassIfication.
compute Adult_Major_Cohort = 0.
If ((Prescribing_Cost GE 500 or recid = '01B') and age GE 18) Adult_Major_Cohort = 1.


*Child Major Conditions ClassIfication.
compute Child_Major_Cohort = 0.
If ((Prescribing_Cost GE 500 or recid = '01B') and age LT 18) Child_Major_Cohort = 1.


*****************************************************************************************************************************************************
    *IDENTIfY ALL EXTERNAL (accidental) CAUSES of DEATH
    *****************************************************************************************************************************************************.
Numeric ExternalCause (F1.0).
If  range (deathdiag1, 'V01', 'Y84')
    or range (deathdiag2, 'V01', 'Y84')
    or range (deathdiag3, 'V01', 'Y84')
    or range (deathdiag4, 'V01', 'Y84')
    or range (deathdiag5, 'V01', 'Y84')
    or range (deathdiag6, 'V01', 'Y84')
    or range (deathdiag7, 'V01', 'Y84')
    or range (deathdiag8, 'V01', 'Y84')
    or range (deathdiag9, 'V01', 'Y84')
    or range (deathdiag10, 'V01', 'Y84')
    or range (deathdiag11, 'V01', 'Y84') ExternalCause = 1.


**********************************************************************************************************************************************.
*** INLCUDE FALLS IN THE COHORT
    **********************************************************************************************************************************************,

If  range (deathdiag1, 'W00', 'W19')
    or range (deathdiag2, 'W00', 'W19')
    or range (deathdiag3, 'W00', 'W19')
    or range (deathdiag4, 'W00', 'W19')
    or range (deathdiag5, 'W00', 'W19')
    or range (deathdiag6, 'W00', 'W19')
    or range (deathdiag7, 'W00', 'W19')
    or range (deathdiag8, 'W00', 'W19')
    or range (deathdiag9, 'W00', 'W19')
    or range (deathdiag10, 'W00', 'W19')
    or range (deathdiag11, 'W00', 'W19') ExternalCause = $sysmis.


**************************************************************.
*End of LIfe ClassIfication.
compute End_of_LIfe_Cohort = 0.
If (recid = 'NRS' and sysmis(ExternalCause)) End_of_LIfe_Cohort = 1.

*Substance Misuse ClassIfication.
compute Substance_Cohort = 0.

*Alcohol Codes.
do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If (any(char.substr(x, 1, 3), 'F10', 'K70', 'X45', 'X65', 'Y15', 'Y90', 'Y91') or
        any(char.substr(x, 1,4), 'E244', 'E512', 'G312', 'G621', 'G721', 'I426', 'K292', 'K860', 'O354', 'P043', 'Q860', 'T510', 'T511', 'T519', 'Y573', 'R780', 'Z502', 'Z714', 'Z721', 'K852')).
        compute Substance_Cohort = 1.
    End If.
end repeat.

*Drug Codes.
do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If (any(recid, '01B', '04B') and (any(char.substr(x, 1, 3), 'F11', 'F12', 'F13', 'F14', 'F15', 'F16', 'F18', 'F19') or any(x, 'T400', 'T401', 'T403', 'T405', 'T406', 'T407', 'T408', 'T409', 'T436'))).
        compute Substance_Cohort = 1.
    End If.
end repeat.


*Some drug codes only count If other code present in CIS i.e. T402/T404 only If F11 and T424 only If F13.
compute F11 = 0.

do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If (any(recid, '01B', '04B') and (any(char.substr(x, 1, 3), 'F11'))).
        compute F11 = 1.
    End If.
end repeat.

compute T402_T404 = 0.

do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If (any(recid, '01B', '04B') and (any(x, 'T402', 'T404'))).
        compute T402_T404 = 1.
    End If.
end repeat.

compute F13 = 0.


do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If (any(recid, '01B', '04B') and (any(char.substr(x, 1, 3), 'F11'))).
        compute F13 = 1.
    End If.
end repeat.

compute T424 = 0.

do repeat x = diag1 diag2 diag3 diag4 diag5 diag6.
    Do If (any(recid, '01B', '04B') and (any(x, 'T424'))).
        compute T424 = 1.
    End If.
end repeat.


* If DrugsandAlcoholClientGroup = 'Y' Substance_Cohort = 1.
* exe.

aggregate outfile = *
    /break CHI cis_marker
    /Comm_Living = max(Comm_Living_Cohort)
    /Adult_Major = max(Adult_Major_Cohort)
    /Child_Major = max(Child_Major_Cohort)
    /Low_CC = max(Low_CC_Cohort)
    /Medium_CC = max(Medium_CC_Cohort)
    /High_CC = max(High_CC_Cohort)
    /Substance = max(Substance_Cohort)
    /MH = max(MH_Cohort)
    /Maternity = max(Maternity_Cohort)
    /Frailty = max(Frail_Cohort)
    /End_of_LIfe = max(End_of_LIfe_Cohort)
    /F11 = max(F11)
    /T402_T404 = max(T402_T404)
    /F13 = max(F13)
    /T424 = max(T424).

If (F11 = 1 and T402_T404 = 1) or (F13 = 1 and T424 = 1) Substance = 1.


*Aggregate into Demographics.
aggregate outfile = *
    /Presorted
    /break CHI
    /Comm_Living = max(Comm_Living)
    /Adult_Major = max(Adult_Major)
    /Child_Major = max(Child_Major)
    /Low_CC = max(Low_CC)
    /Medium_CC = max(Medium_CC)
    /High_CC = max(High_CC)
    /Substance = max(Substance)
    /MH = max(MH)
    /Maternity = max(Maternity)
    /Frailty = max(Frailty)
    /End_of_LIfe = max(End_of_LIfe).


*Hierarchy of Classes.
String Demographic_Cohort (A32).
Do if End_of_Life = 1.
    Compute Demographic_Cohort = 'End of Life'.
Else if Frailty = 1.
    Compute Demographic_Cohort = 'Frailty'.
Else if High_CC = 1.
    Compute Demographic_Cohort = 'High Complex Conditions'.
Else if Maternity = 1.
    Compute Demographic_Cohort = 'Maternity and Healthy Newborns'.
Else if MH = 1.
    Compute Demographic_Cohort = 'Mental Health'.
Else if Substance = 1.
    Compute Demographic_Cohort = 'Substance Misuse'.
Else if Medium_CC = 1.
    Compute Demographic_Cohort = 'Medium Complex Conditions'.
Else if Low_CC = 1.
    Compute Demographic_Cohort = 'Low Complex Conditions'.
Else if Child_Major = 1.
    Compute Demographic_Cohort = 'Child Major Conditions'.
Else if Adult_Major = 1.
    Compute Demographic_Cohort = 'Adult Major Conditions'.
Else if Comm_Living = 1.
    Compute Demographic_Cohort = 'Assisted Living in the Community'.
Else.
    *Include a Service_Use_Cohort for other users.
    Compute Demographic_Cohort = 'Healthy and Low User'.
End if.

*Add variable label (from AM).
variable labels Demographic_Cohort 'Allocated on the basis of health status and need of care, using LTCs, diagnosis codes and other characteristics'.

save outfile = !File + 'Patient_Demographic_Cohort_' + !FY + '.zsav'
    /keep CHI Demographic_Cohort
    /zcompressed.

**********************************************************************************************************************.
**********************************************************************************************************************.
*3. Create the Service Use Service_Use_Cohort File.

get file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".

select If CHI ne ''.

sort cases by spec.

*Matching the specialty codes data to all specialty code descriptions.
match files file = *
   /table = '/conf/linkage/output/lookups/Archive/clinical/specialty/copspecs.sav'
   /by spec.


*Costs Expansion for Rules and Stats.
compute Psychiatry_Cost = 0.
compute Geriatric_Cost = 0.
compute Maternity_Cost = 0.
compute Acute_Elective_Cost = 0.
compute Acute_Emergency_Cost = 0.
compute Outpatient_Cost = 0.
compute Total_Outpatient_Cost = 0.
compute Home_Care_Cost = 0.
compute Care_Home_Cost = 0.
compute Prescribing_Cost = 0.
compute AE2_Cost = 0.
compute Hospital_Elective_Cost = 0.
compute Hospital_Emergency_Cost = 0.
compute Community_Health_Cost = 0.
If (specname = 'Geriatric Medicine' or recid = '50B' or specname = 'Psychiatry of Old Age') Geriatric_Cost = Cost_Total_Net.
If (recid = '02B' or newpattype_CIS = 'Maternity') Maternity_Cost = Cost_Total_Net.
If (recid = '04B' and specname ne 'Psychiatry of Old Age') Psychiatry_Cost = Cost_Total_Net.
If (recid = '01B' and (newpattype_CIS = 'Elective' or newCIS_ipdc = 'D') and specname ne 'Geriatric Medicine') Acute_Elective_Cost = Cost_Total_Net.
If (recid = '01B' and newpattype_CIS = 'Non-Elective' and specname ne 'Geriatric Medicine') Acute_Emergency_Cost = Cost_Total_Net.
If recid = '00B' Outpatient_Cost = Cost_Total_Net-Geriatric_Cost.
If recid = '00B' Total_Outpatient_Cost = Cost_Total_Net.
If any(recid, 'HC-', 'HC + ', 'INS', 'RSP', 'MLS', 'DC', 'CPL') Home_Care_Cost = Cost_Total_Net.
If recid = 'CH' Care_Home_Cost = Cost_Total_Net.
If any(recid, '01B', '04B', '50B', 'GLS') and newpattype_CIS = 'Elective' Hospital_Elective_Cost = Cost_Total_Net.
If any(recid, '01B', '04B', '50B', 'GLS') and newpattype_CIS = 'Non-Elective' Hospital_Emergency_Cost = Cost_Total_Net.
If recid = 'PIS' Prescribing_Cost = Cost_Total_Net.
If any(recid, 'AE2', 'OoH', 'SAS', 'N24') AE2_Cost = Cost_Total_Net.
If recid = 'DN' Community_Health_Cost = Cost_Total_Net.
If op1a ne '' Operation_Flag = 1.


*Changing the record id from SMR to the CIS stay.
alter type recid (A5).
If any (recid, '01B', '02B', '04B', '50B', 'GLS') recid = CIS_marker.


*removed from the aggregate /Unplanned_Beddays = sum(Unplanned_Beddays).
aggregate outfile = *
   /break CHI recid newCIS_ipdc newpattype_CIS
   /Total_Cost = sum(Cost_Total_Net)
   /Bed_Days = sum(yearstay)
   /Psychiatry_Cost = sum(Psychiatry_Cost)
   /Maternity_Cost = sum(Maternity_Cost)
   /Geriatric_Cost = sum(Geriatric_Cost)
   /Elective_Cost = sum(Acute_Elective_Cost)
   /Emergency_Cost = sum(Acute_Emergency_Cost)
   /Home_Care_Cost = sum(Home_Care_Cost)
   /Care_Home_Cost = sum(Care_Home_Cost)
   /Hospital_Elective_Cost = sum(Hospital_Elective_Cost)
   /Hospital_Emergency_Cost = sum(Hospital_Emergency_Cost)
   /AE2_Cost = sum(AE2_Cost)
   /Prescribing_Cost = sum(Prescribing_Cost)
   /Outpatient_Cost = sum(Outpatient_Cost)
   /Total_Outpatient_Cost = sum(Total_Outpatient_Cost)
   /Community_Health_Cost = sum(Community_Health_Cost)
   /Operation_Flag = max(Operation_Flag).


compute CIS_Attendance = 0.
compute Emergency_Instances = 0.
compute Elective_Instances = 0.
compute Elective_Inpatient_Instances = 0.
compute Elective_Daycase_Instances = 0.
compute Death_Flag = 0.


If (recid ne 'AE2' and recid ne 'PIS' and recid ne '00B' and recid ne 'NRS') CIS_Attendance = 1.
If (newpattype_CIS = 'Non-Elective') Emergency_Instances = 1.
If (newpattype_CIS = 'Elective' or newCIS_ipdc = 'D') Elective_Instances = 1.
If (newpattype_CIS = 'Elective' and newCIS_ipdc = 'I') Elective_Inpatient_Instances = 1.
If (newpattype_CIS = 'Elective' and newCIS_ipdc = 'D') Elective_Daycase_Instances = 1.
If recid = 'NRS' Death_Flag = 1.


compute Elective_Inpatient_Cost = 0.
If Elective_Inpatient_Instances = 1 Elective_Inpatient_Cost = Total_Cost.


* /Unplanned_Beddays = sum(Unplanned_Beddays).
aggregate outfile = *
    /Presorted
    /break CHI
    /Total_Cost = sum(Total_Cost)
    /Total_Beddays = sum(Bed_Days)
    /Admission = sum(CIS_Attendance)
    /Operation_Flag = max(Operation_Flag)
    /Emergency = sum(Emergency_Instances)
    /Elective = sum(Elective_Instances)
    /Elective_Inpatient = sum(Elective_Inpatient_Instances)
    /Elective_Daycase = sum(Elective_Daycase_Instances)
    /Death_Flag = max(Death_Flag)
    /Psychiatry_Cost = sum(Psychiatry_Cost)
    /Maternity_Cost = sum(Maternity_Cost)
    /Geriatric_Cost = sum(Geriatric_Cost)
    /Emergency_Cost = sum(Emergency_Cost)
    /Elective_Cost = sum(Elective_Cost)
    /Elective_Inpatient_Cost = sum(Elective_Inpatient_Cost)
    /Home_Care_Cost = sum(Home_Care_Cost)
    /Care_Home_Cost = sum(Care_Home_Cost)
    /Hospital_Elective_Cost = sum(Hospital_Elective_Cost)
    /Hospital_Emergency_Cost = sum(Hospital_Emergency_Cost)
    /AE2_Cost = sum(AE2_Cost)
    /Prescribing_Cost = sum(Prescribing_Cost)
    /Outpatient_Cost = sum(Outpatient_Cost)
    /Total_Outpatient_Cost = sum(Total_Outpatient_Cost)
    /Community_Health_Cost = sum(Community_Health_Cost).


compute Elective_Inpatient_Flag = 0.
compute Elective_Inpatient_Percentage = Elective_Inpatient_Cost / Elective_Cost.


If Elective_Inpatient_Percentage GT 0.5 Elective_Inpatient_Flag = 1.

*Create flags to be used to classIfy patients.
compute Psychiatry_Cohort = 0.
compute Maternity_Cohort = 0.
compute Geriatric_Cohort = 0.
compute Elective_Inpatient_Cohort = 0.
compute Limited_Daycases_Cohort = 0.
compute Routine_Daycase_Cohort = 0.
compute Single_Emergency_Cohort = 0.
compute Multiple_Emergency_Cohort = 0.
compute Routine_Daycase_Cohort = 0.
compute Prescribing_Cohort = 0.
compute Outpatient_Cohort = 0.
compute Residential_Care_Cohort = 0.
compute Community_Care_Cohort = 0.
compute AE2_Cohort = 0.
compute Elective_Other_Cohort = 0.
compute Other_Cohort = 0.


*Create our set of rules to classIfy HRI patients.
If (Psychiatry_Cost GT 0) Psychiatry_Cohort = 1.
If (Maternity_Cost GT 0) Maternity_Cohort = 1.
If (Geriatric_Cost GT 0) Geriatric_Cohort = 1.
If (Elective_Inpatient_Flag = 1) Elective_Inpatient_Cohort = 1.
If (Elective_Inpatient_Flag = 0 and Elective LE 3) Limited_Daycases_Cohort = 1.
If (Elective_Inpatient_Flag = 0 and Elective GE 4) Routine_Daycase_Cohort = 1.
If (Emergency = 1) Single_Emergency_Cohort = 1.
If (Emergency GE 2) Multiple_Emergency_Cohort = 1.
If (Prescribing_Cost GT 0) Prescribing_Cohort = 1.
If (Care_Home_Cost GT 0) Residential_Care_Cohort = 1.
If (Outpatient_Cost GT 0) Outpatient_Cohort = 1.
If (Home_Care_Cost GT 0 or Community_Health_Cost GT 0) Community_Care_Cohort = 1.
If (AE2_Cost GT 0) AE2_Cohort = 1.
If (Psychiatry_Cohort = 0 and Maternity_Cohort = 0 and Geriatric_Cohort = 0 and Elective_Inpatient_Cohort = 0 and
   Limited_Daycases_Cohort = 0 and Single_Emergency_Cohort = 0 and Multiple_Emergency_Cohort = 0 and
   Routine_Daycase_Cohort = 0 and Prescribing_Cohort = 0 and Outpatient_Cohort = 0 and Community_Care_Cohort = 0 and
   AE2_Cohort = 0 and Residential_Care_Cohort = 0) Other_Cohort = 1.

***********************************************************************************************************************************.

*Adjusting Cohorts based on Cost.

*Create new variables to calculate the cost for each cohort.
compute Elective_Inpatient_Cost = 0.
compute Limited_Daycases_Cost = 0.
compute Single_Emergency_Cost = 0.
compute Multiple_Emergency_Cost = 0.
compute Routine_Daycase_Cost = 0.
compute Community_Care_Cost = 0.
compute Residential_Care_Cost = 0.


*Calculate the costs for each cohort.
If (Elective_Inpatient_Cohort = 1) Elective_Inpatient_Cost = Elective_Cost.
If (Limited_Daycases_Cohort = 1) Limited_Daycases_Cost = Elective_Cost.
If (Routine_Daycase_Cohort = 1) Routine_Daycase_Cost = Elective_Cost.
If (Single_Emergency_Cohort = 1) Single_Emergency_Cost = Emergency_Cost.
If (Multiple_Emergency_Cohort = 1) Multiple_Emergency_Cost = Emergency_Cost.
If Community_Care_Cohort = 1 Community_Care_Cost = Home_Care_Cost + Community_Health_Cost.
If Residential_Care_Cohort = 1 Residential_Care_Cost = Care_Home_Cost.


Recode Total_Cost (sysmis = 0).

*Compare costs for each Service_Use_Cohort and sort each patient into the Service_Use_Cohort with the greatest cost attached.
string Service_Use_Cohort (A18).

If Total_Cost = 0 Service_Use_Cohort = 'None'.

If ((Psychiatry_Cost GT Maternity_Cost) and (Psychiatry_Cost GT Geriatric_Cost) and (Psychiatry_Cost GT Elective_Inpatient_Cost)  and
   (Psychiatry_Cost GT Limited_Daycases_Cost) and (Psychiatry_Cost GT Single_Emergency_Cost) and (Psychiatry_Cost GT Multiple_Emergency_Cost) and
   (Psychiatry_Cost GT Routine_Daycase_Cost) and (Psychiatry_Cost GT Prescribing_Cost) and (Psychiatry_Cost GT Outpatient_Cost) and
   (Psychiatry_Cost GT AE2_Cost) and (Psychiatry_Cost GT Community_Care_Cost) and (Psychiatry_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Psychiatry'.

If ((Maternity_Cost GT Psychiatry_Cost) and (Maternity_Cost GT Geriatric_Cost) and (Maternity_Cost GT Elective_Inpatient_Cost) and
   (Maternity_Cost GT Limited_Daycases_Cost) and (Maternity_Cost GT Single_Emergency_Cost) and (Maternity_Cost GT Multiple_Emergency_Cost) and
   (Maternity_Cost GT Routine_Daycase_Cost) and (Maternity_Cost GT Prescribing_Cost) and (Maternity_Cost GT Outpatient_Cost) and
   (Maternity_Cost GT AE2_Cost) and (Maternity_Cost GT Community_Care_Cost) and (Maternity_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Maternity'.

If ((Geriatric_Cost GE Psychiatry_Cost) and (Geriatric_Cost GT Maternity_Cost) and (Geriatric_Cost GT Elective_Inpatient_Cost) and
   (Geriatric_Cost GT Limited_Daycases_Cost) and (Geriatric_Cost GT Single_Emergency_Cost) and (Geriatric_Cost GT Multiple_Emergency_Cost) and
   (Geriatric_Cost GT Routine_Daycase_Cost) and (Geriatric_Cost GT Prescribing_Cost) and (Geriatric_Cost GT Outpatient_Cost) and
   (Geriatric_Cost GT AE2_Cost) and (Geriatric_Cost GT Community_Care_Cost) and (Geriatric_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Geriatric'.

If ((Elective_Inpatient_Cost GT Psychiatry_Cost) and (Elective_Inpatient_Cost GT Maternity_Cost) and (Elective_Inpatient_Cost GT Geriatric_Cost) and
   (Elective_Inpatient_Cost GT Limited_Daycases_Cost) and (Elective_Inpatient_Cost GT Single_Emergency_Cost) and
   (Elective_Inpatient_Cost GT Multiple_Emergency_Cost) and (Elective_Inpatient_Cost GT Routine_Daycase_Cost) and
   (Elective_Inpatient_Cost GT Prescribing_Cost) and (Elective_Inpatient_Cost GT Outpatient_Cost) and (Elective_Inpatient_Cost GT AE2_Cost) and
   (Elective_Inpatient_Cost GT Community_Care_Cost) and (Elective_Inpatient_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Elective Inpatient'.

If ((Limited_Daycases_Cost GT Psychiatry_Cost) and (Limited_Daycases_Cost GT Maternity_Cost) and (Limited_Daycases_Cost GT Geriatric_Cost) and
   (Limited_Daycases_Cost GT Elective_Inpatient_Cost) and (Limited_Daycases_Cost GT Single_Emergency_Cost) and
   (Limited_Daycases_Cost GT Multiple_Emergency_Cost) and (Limited_Daycases_Cost GT Routine_Daycase_Cost) and
   (Limited_Daycases_Cost GT Prescribing_Cost) and (Limited_Daycases_Cost GT Outpatient_Cost) and (Limited_Daycases_Cost GT AE2_Cost) and
   (Limited_Daycases_Cost GT Community_Care_Cost) and (Limited_Daycases_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Limited Daycases'.

If ((Routine_Daycase_Cost GT Psychiatry_Cost) and (Routine_Daycase_Cost GT Maternity_Cost) and (Routine_Daycase_Cost GT Geriatric_Cost) and
   (Routine_Daycase_Cost GT Elective_Inpatient_Cost) and (Routine_Daycase_Cost GT Limited_Daycases_Cost) and
   (Routine_Daycase_Cost GT Single_Emergency_Cost) and (Routine_Daycase_Cost GT Multiple_Emergency_Cost) and
   (Routine_Daycase_Cost GT Prescribing_Cost) and (Routine_Daycase_Cost GE Outpatient_Cost) and (Routine_Daycase_Cost GT AE2_Cost) and
   (Routine_Daycase_Cost GT Community_Care_Cost) and (Routine_Daycase_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Routine Daycase'.

If ((Single_Emergency_Cost GT Psychiatry_Cost) and (Single_Emergency_Cost GT Maternity_Cost) and (Single_Emergency_Cost GT Geriatric_Cost) and
   (Single_Emergency_Cost GT Elective_Inpatient_Cost) and (Single_Emergency_Cost GT Limited_Daycases_Cost) and
   (Single_Emergency_Cost GT Multiple_Emergency_Cost) and (Single_Emergency_Cost GT Routine_Daycase_Cost) and
   (Single_Emergency_Cost GT Prescribing_Cost) and (Single_Emergency_Cost GT Outpatient_Cost) and (Single_Emergency_Cost GT AE2_Cost) and
   (Single_Emergency_Cost GT Community_Care_Cost) and (Single_Emergency_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Single Emergency'.

If ((Multiple_Emergency_Cost GT Psychiatry_Cost) and (Multiple_Emergency_Cost GT Maternity_Cost) and (Multiple_Emergency_Cost GT Geriatric_Cost) and
   (Multiple_Emergency_Cost GT Elective_Inpatient_Cost) and (Multiple_Emergency_Cost GT Limited_Daycases_Cost) and
   (Multiple_Emergency_Cost GT Single_Emergency_Cost) and (Multiple_Emergency_Cost GT Routine_Daycase_Cost) and
   (Multiple_Emergency_Cost GT Prescribing_Cost) and (Multiple_Emergency_Cost GT Outpatient_Cost) and (Multiple_Emergency_Cost GT AE2_Cost) and
   (Multiple_Emergency_Cost GT Community_Care_Cost) and (Multiple_Emergency_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Multiple Emergency'.

If ((Prescribing_Cost GT Psychiatry_Cost) and (Prescribing_Cost GT Maternity_Cost) and (Prescribing_Cost GT Geriatric_Cost) and
   (Prescribing_Cost GT Elective_Inpatient_Cost) and (Prescribing_Cost GT Limited_Daycases_Cost) and (Prescribing_Cost GT Single_Emergency_Cost) and
   (Prescribing_Cost GT Multiple_Emergency_Cost) and (Prescribing_Cost GT Routine_Daycase_Cost) and (Prescribing_Cost GT Outpatient_Cost) and
   (Prescribing_Cost GT AE2_Cost) and (Prescribing_Cost GT Community_Care_Cost) and (Prescribing_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Prescribing'.

If ((Outpatient_Cost GT Psychiatry_Cost) and (Outpatient_Cost GT Maternity_Cost) and (Outpatient_Cost GT Geriatric_Cost) and
   (Outpatient_Cost GT Elective_Inpatient_Cost) and (Outpatient_Cost GT Limited_Daycases_Cost) and (Outpatient_Cost GT Single_Emergency_Cost) and
   (Outpatient_Cost GT Multiple_Emergency_Cost) and (Outpatient_Cost GT Routine_Daycase_Cost) and (Outpatient_Cost GT Prescribing_Cost) and
   (Outpatient_Cost GT AE2_Cost) and (Outpatient_Cost GT Community_Care_Cost) and (Outpatient_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Outpatients'.

If ((Community_Care_Cost GT Psychiatry_Cost) and (Community_Care_Cost GT Maternity_Cost) and (Community_Care_Cost GT Geriatric_Cost) and
   (Community_Care_Cost GT Elective_Inpatient_Cost) and (Community_Care_Cost GT Limited_Daycases_Cost) and
   (Community_Care_Cost GT Single_Emergency_Cost) and (Community_Care_Cost GT Multiple_Emergency_Cost) and
   (Community_Care_Cost GT Routine_Daycase_Cost) and (Community_Care_Cost GT Prescribing_Cost) and (Community_Care_Cost GT Outpatient_Cost) and
   (Community_Care_Cost GT AE2_Cost) and (Community_Care_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Community Care'.

If ((AE2_Cost GT Psychiatry_Cost) and (AE2_Cost GT Maternity_Cost) and (AE2_Cost GT Geriatric_Cost) and (AE2_Cost GT Elective_Inpatient_Cost) and
   (AE2_Cost GT Limited_Daycases_Cost) and (AE2_Cost GT Single_Emergency_Cost) and (AE2_Cost GT Multiple_Emergency_Cost) and
   (AE2_Cost GT Routine_Daycase_Cost) and (AE2_Cost GT Outpatient_Cost) and (AE2_Cost GT Prescribing_Cost) and (AE2_Cost GT Community_Care_Cost) and
   (AE2_Cost GT Residential_Care_Cost)) Service_Use_Cohort = 'Unscheduled Care'.

If ((Residential_Care_Cost GT Psychiatry_Cost) and (Residential_Care_Cost GT Maternity_Cost) and (Residential_Care_Cost GT Geriatric_Cost) and
   (Residential_Care_Cost GT Elective_Inpatient_Cost) and (Residential_Care_Cost GT Limited_Daycases_Cost) and
   (Residential_Care_Cost GT Single_Emergency_Cost) and (Residential_Care_Cost GT Multiple_Emergency_Cost) and
   (Residential_Care_Cost GT Routine_Daycase_Cost) and (Residential_Care_Cost GT Outpatient_Cost) and (Residential_Care_Cost GT Prescribing_Cost) and
   (Residential_Care_Cost GT AE2_Cost) and (Residential_Care_Cost GT Community_Care_Cost)) Service_Use_Cohort = 'Residential Care'.

If (Service_Use_Cohort = '') Service_Use_Cohort = 'Other'.

Recode Total_Beddays Total_Cost (sysmis = 0).

*1. rename variable.
rename variables Service_Use_Cohort = Service_Use_Cohort.


*2. add variable label (from AM).
variable labels Service_Use_Cohort 'Allocated based on main service type, i.e. where the highest proportion of health cost was spent in the financial year'.

save outfile = !File + 'GP_Practice_Service_Use_Cohorts_' + !FY + '.zsav'
   /keep CHI Service_Use_Cohort
   /zcompressed.


