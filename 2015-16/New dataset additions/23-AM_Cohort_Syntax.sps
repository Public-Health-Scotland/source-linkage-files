*Cohort Syntax.
*Andrew Mooney.
*Feb 2017.

* Modified for 15/16 for SLF update, DKG October 2017.

*CD to working directory.
CD '/conf/irf/11-Development team/Dev00-PLICS-files/2015-16/'.

*Define financial year.
define !FY()
'1516'
!enddefine.


**********************************************************************************************************************.
**********************************************************************************************************************.
*1. Create the Patient Listing File.

 * get file = '/conf/hscdiip/02-Pathways/PLICS_SC_EL_20'+!FY+'.sav'.

 * select if CHI ne ''.
 * exe.

*Create a Patient flag.
 * compute Patients=1.
 * exe.

 * save outfile = 'cohort_results/Patient_Listing.sav'
   /keep CHI Patients.

**********************************************************************************************************************.
**********************************************************************************************************************.
*2. Create the Demographic Cohort File.

get file = '/conf/sourcedev/source-episode-file-20'+!FY+'.zsav'.

select if CHI ne ''.
execute.

*delete unwanted variables.
delete variables arth_date to Datazone2011.

 * match files file = *
   /table = '/conf/linkage/output/Andrem33/MATRIX/Data/Patient_Listing.sav'
   /by CHI.
 * exe.

 * select if Patients=1.
 * select if CHI ne ''.
 * exe.

*Define strings for diagnosis lengths to use in Demographic classification.
string Diag1Short Diag2Short Diag3Short Diag4Short Diag5Short Diag6Short(A2).
string Diag1Mid Diag2Mid Diag3Mid Diag4Mid Diag5Mid Diag6Mid (A3).
compute Diag1Short=substr(Diag1,1,2).
compute Diag1Mid=substr(Diag1,1,3).
compute Diag2Short=substr(Diag2,1,2).
compute Diag2Mid=substr(Diag2,1,3).
compute Diag3Short=substr(Diag3,1,2).
compute Diag3Mid=substr(Diag3,1,3).
compute Diag4Short=substr(Diag4,1,2).
compute Diag4Mid=substr(Diag4,1,3).
compute Diag5Short=substr(Diag5,1,2).
compute Diag5Mid=substr(Diag5,1,3).
compute Diag6Short=substr(Diag6,1,2).
compute Diag6Mid=substr(Diag6,1,3).



*Mental Health Classification.
compute MH_Cohort=0.
if recid='04B' MH_Cohort=1.
if any(Diag1Short,'F2','F3') MH_Cohort=1.
if any(Diag2Short,'F2','F3') MH_Cohort=1.
if any(Diag3Short,'F2','F3') MH_Cohort=1.
if any(Diag4Short,'F2','F3') MH_Cohort=1.
if any(Diag5Short,'F2','F3') MH_Cohort=1.
if any(Diag6Short,'F2','F3') MH_Cohort=1.
if any(Diag1, 'F067', 'F070', 'F072', 'F078', 'F079') MH_Cohort=1.
if any(Diag2, 'F067', 'F070', 'F072', 'F078', 'F079') MH_Cohort=1.
if any(Diag3, 'F067', 'F070', 'F072', 'F078', 'F079') MH_Cohort=1.
if any(Diag4, 'F067', 'F070', 'F072', 'F078', 'F079') MH_Cohort=1.
if any(Diag5, 'F067', 'F070', 'F072', 'F078', 'F079') MH_Cohort=1.
if any(Diag6, 'F067', 'F070', 'F072', 'F078', 'F079') MH_Cohort=1.
 * if MentalHealthProblemsClientGroup='Y' MH_Cohort=1.


*Frailty Classification.
compute Frail_Cohort=0.
if (recid='CH' and age ge 65) Frail_Cohort=1.
do repeat x=diag1 diag2 diag3 diag4 diag5 diag6.
   do if (any(substr(x,1,2),'W0','W1') or any(substr(x,1,3),'F00','F01','F02','F03','F05','I61','I63','I64','G20','G21') or any(substr(x,1,4),'R268','G22X') or spec='AB' or any(sigfac,'1E','1D') or recid='GLS').
      compute Frail_Cohort =1.
   end if.
end repeat. 
*if ElderlyFrailClientGroup='Y' Frail_Cohort=1.


*Maternity Classification.
compute Maternity_Cohort=0.
if recid='02B' Maternity_Cohort=1.


*High CC Classification.
compute High_CC_Cohort=0.
if (Dementia=1 or hefailure=1 or refailure=1 or liver=1 or Cancer=1) High_CC_Cohort=1.
if (recid='CH' and age lt 65) High_CC_Cohort=1.
 * if PhysicalandSensoryDisabilityClientGroup='Y' High_CC_Cohort=1.
if spec='G5' High_CC_Cohort=1.
 * if LearningDisabilityClientGroup='Y' High_CC_Cohort=1.


*Medium CC Classification.
compute Medium_CC_Cohort=0.
if (CVD=1 or COPD=1 or CHD=1 or Parkinsons=1 or MS=1) Medium_CC_Cohort=1.


*Low CC Classification.
compute Low_CC_Cohort=0.
if (Epilepsy=1 or Asthma=1 or Arth=1 or Diabetes=1 or atrialfib=1) Low_CC_Cohort=1.

*Assisted Living in the Community.
compute Comm_Living_Cohort=0.
if any (recid,'HC-','HC+','RSP','DN','MLS','INS','CPL','DC') Comm_Living_Cohort=1.


compute Prescribing_Cost=0.
if recid='PIS' Prescribing_Cost=Cost_Total_Net.


*Adult Major Conditions Classification.
compute Adult_Major_Cohort=0.
if ((Prescribing_Cost ge 500 or recid='01B') and age ge 18) Adult_Major_Cohort=1.


*Child Major Conditions Classification.
compute Child_Major_Cohort=0.
if ((Prescribing_Cost ge 500 or recid='01B') and age lt 18) Child_Major_Cohort=1.
execute.

*cleanup.
delete variables arth to Diag6Mid.

*****************************************************************************************************************************************************
*IDENTIFY ALL EXTERNAL (accidental) CAUSES of DEATH
*****************************************************************************************************************************************************.
string externalcause(a1).
if  range (deathdiag1,'V01','Y84') 
  or range (deathdiag2,'V01','Y84')
  or range (deathdiag3,'V01','Y84')
  or range (deathdiag4,'V01','Y84')
  or range (deathdiag5,'V01','Y84')
  or range (deathdiag6,'V01','Y84') 
  or range (deathdiag7,'V01','Y84')
  or range (deathdiag8,'V01','Y84')
  or range (deathdiag9,'V01','Y84') 
  or range (deathdiag10,'V01','Y84')
  or range (deathdiag11,'V01','Y84') externalcause = '1'.


**********************************************************************************************************************************************.
*** INLCUDE FALLS IN THE COHORT
**********************************************************************************************************************************************,

if  range (deathdiag1,'W00','W19') 
  or range (deathdiag2,'W00','W19')
  or range (deathdiag3,'W00','W19')
  or range (deathdiag4,'W00','W19')
  or range (deathdiag5,'W00','W19')
  or range (deathdiag6,'W00','W19') 
  or range (deathdiag7,'W00','W19')
  or range (deathdiag8,'W00','W19')
  or range (deathdiag9,'W00','W19') 
  or range (deathdiag10,'W00','W19')
  or range (deathdiag11,'W00','W19') externalcause = ''.


**************************************************************.

*End of Life Classification.
compute End_of_Life_Cohort=0.
if (recid='NRS' and externalcause='') End_of_Life_Cohort=1.


*Substance Misuse Classification.
compute Substance_Cohort=0.

*Alcohol Codes.
do repeat x=diag1 diag2 diag3 diag4 diag5 diag6.
   do if (any(substr(x,1,3),'F10','K70','X45','X65','Y15','Y90','Y91') or
      any(substr(x,1,4),'E244','E512','G312','G621','G721','I426','K292','K860','O354','P043','Q860','T510','T511','T519','Y573','R780','Z502','Z714','Z721','K852')).
      compute Substance_Cohort=1.
   end if.
end repeat.

*Drug Codes.
do repeat x=diag1 diag2 diag3 diag4 diag5 diag6.
   do if (any(recid,'01B', '04B') and (any(substr(x,1,3),'F11', 'F12', 'F13', 'F14', 'F15', 'F16', 'F18', 'F19') or any(x, 'T400', 'T401', 'T403', 'T405', 'T406', 'T407', 'T408', 'T409', 'T436'))).
      compute Substance_Cohort=1.
   end if.
end repeat.

*Some drug codes only count if other code present in CIS i.e. T402/T404 only if F11 and T424 only if F13.
compute F11=0.


do repeat x=diag1 diag2 diag3 diag4 diag5 diag6.
   do if (any(recid,'01B', '04B') and (any(substr(x,1,3),'F11'))).
      compute F11=1.
   end if.
end repeat.


compute T402_T404=0.


do repeat x=diag1 diag2 diag3 diag4 diag5 diag6.
   do if (any(recid,'01B', '04B') and (any(x,'T402','T404'))).
      compute T402_T404=1.
   end if.
end repeat.

compute F13=0.

do repeat x=diag1 diag2 diag3 diag4 diag5 diag6.
   do if (any(recid,'01B', '04B') and (any(substr(x,1,3),'F11'))).
      compute F13=1.
   end if.
end repeat.


compute T424=0.


do repeat x=diag1 diag2 diag3 diag4 diag5 diag6.
   do if (any(recid,'01B', '04B') and (any(x,'T424'))).
      compute T424=1.
   end if.
end repeat.

 * if DrugsandAlcoholClientGroup='Y' Substance_Cohort=1.
 * exe.

aggregate outfile = *
   /break CHI cis_marker
   /Comm_Living=max(Comm_Living_Cohort)
   /Adult_Major=max(Adult_Major_Cohort)
   /Child_Major=max(Child_Major_Cohort)
   /Low_CC=max(Low_CC_Cohort)
   /Medium_CC=max(Medium_CC_Cohort)
   /High_CC=max(High_CC_Cohort)
   /Substance=max(Substance_Cohort)
   /MH=max(MH_Cohort)
   /Maternity=max(Maternity_Cohort)
   /Frailty=max(Frail_Cohort)
   /End_of_Life=max(End_of_Life_Cohort)
   /F11=max(F11)
   /T402_T404=max(T402_T404)
   /F13=max(F13)
   /T424=max(T424).

if F11=1 and T402_T404=1 Substance=1.
if F13=1 and T424=1 Substance=1.


*Aggregate into Demographics.
aggregate outfile = *
   /break CHI
   /Comm_Living=max(Comm_Living)
   /Adult_Major=max(Adult_Major)
   /Child_Major=max(Child_Major)
   /Low_CC=max(Low_CC)
   /Medium_CC=max(Medium_CC)
   /High_CC=max(High_CC)
   /Substance=max(Substance)
   /MH=max(MH)
   /Maternity=max(Maternity)
   /Frailty=max(Frailty)
   /End_of_Life=max(End_of_Life).

*Hierarchy of Classes - Bottom is higher in hierarchy.
string Demographic_Cohort (A50).
if Comm_Living=1 Demographic_Cohort='Assisted Living in the Community'.
if Adult_Major=1 Demographic_Cohort='Adult Major Conditions'.
if Child_Major=1 Demographic_Cohort='Child Major Conditions'.
if Low_CC=1 Demographic_Cohort='Low Complex Conditions'.
if Medium_CC=1 Demographic_Cohort='Medium Complex Conditions'.
if Substance=1 Demographic_Cohort='Substance Misuse'.
if MH=1 Demographic_Cohort='Mental Health'.
if Maternity=1 Demographic_Cohort='Maternity and Healthy Newborns'.
if High_CC=1 Demographic_Cohort='High Complex Conditions'.
if Frailty=1 Demographic_Cohort='Frailty'.
if End_of_Life=1 Demographic_Cohort='End of Life'.


*Include a Cohort for other users.
if Demographic_Cohort='' Demographic_Cohort='Healthy and Low User'.

*extra syntax added by GNW - modifications for adding variable to source linkage files.
*1. shorten width of cohort variable.
alter type Demographic_Cohort (a=amin).

*2. add variable label (from AM).
variable labels Demographic_Cohort 'Allocated on the basis of health status and need of care, using LTCs, diagnosis codes and other characteristics'.

save outfile = '/conf/sourcedev/Patient_Demographic_Cohort_' + !FY + '.zsav'
   /keep CHI Demographic_Cohort
   /zcompressed.

**********************************************************************************************************************.
**********************************************************************************************************************.
*3. Create the Service Use Cohort File.

 * get file = '/conf/hscdiip/02-Pathways/PLICS_SC_EL_201516.sav'.
get file = '/conf/sourcedev/source-episode-file-20'+!FY+'.zsav'.

select if CHI ne ''.

 * match files file = *
   /table = '/conf/linkage/output/Andrem33/MATRIX/Data/Patient_Listing.sav'
   /by CHI.
 * exe.

 * select if Patients=1.
 * exe.

sort cases by spec.

*Matching the specialty codes data to all specialty code descriptions.
match files file = *
/table='/conf/linkage/output/lookups/Archive/clinical/specialty/copspecs.sav'
/by spec.


*Costs Expansion for Rules and Stats.
compute Psychiatry_Cost=0.
compute Geriatric_Cost=0.
compute Maternity_Cost=0.
compute Acute_Elective_Cost=0.
compute Acute_Emergency_Cost=0.
compute Outpatient_Cost=0.
compute Total_Outpatient_Cost=0.
compute Home_Care_Cost=0.
compute Care_Home_Cost=0.
compute Prescribing_Cost=0.
compute AE2_Cost=0.
compute Hospital_Elective_Cost=0.
compute Hospital_Emergency_Cost=0.
compute Community_Health_Cost=0.
if (specname='Geriatric Medicine' or recid='50B' or specname='Psychiatry of Old Age') Geriatric_Cost=Cost_Total_Net.
if (recid='02B' or newpattype_CIS='Maternity') Maternity_Cost=Cost_Total_Net.
if (recid='04B' and specname ne 'Psychiatry of Old Age') Psychiatry_Cost=Cost_Total_Net.
if (recid='01B' and (newpattype_CIS='Elective' or newCIS_ipdc='D') and specname ne 'Geriatric Medicine') Acute_Elective_Cost=Cost_Total_Net.
if (recid='01B' and newpattype_CIS='Non-Elective' and specname ne 'Geriatric Medicine') Acute_Emergency_Cost=Cost_Total_Net.
if recid='00B' Outpatient_Cost=Cost_Total_Net-Geriatric_Cost.
if recid='00B' Total_Outpatient_Cost=Cost_Total_Net.
if any(recid,'HC-','HC+', 'INS', 'RSP', 'MLS', 'DC', 'CPL') Home_Care_Cost=Cost_Total_Net.
if recid='CH' Care_Home_Cost=Cost_Total_Net.
if any(recid,'01B','04B','50B','GLS') and newpattype_CIS='Elective' Hospital_Elective_Cost=Cost_Total_Net.
if any(recid,'01B','04B','50B','GLS') and newpattype_CIS='Non-Elective' Hospital_Emergency_Cost=Cost_Total_Net.
if recid='PIS' Prescribing_Cost=Cost_Total_Net.
if recid='AE2' AE2_Cost=Cost_Total_Net.
if recid='DN' Community_Health_Cost=Cost_Total_Net.
if op1a ne '' Operation_Flag=1.


*Changing the record id from SMR to the CIS stay.
alter type recid (A5).
if any (recid,'01B','02B','04B','50B','GLS') recid=CIS_marker.


*removed from the aggregate /Unplanned_Beddays=sum(Unplanned_Beddays).
aggregate outfile = *
   /break CHI recid newCIS_ipdc newpattype_CIS
   /Total_Cost=sum(Cost_Total_Net)
   /Bed_Days=sum(yearstay)
   /Psychiatry_Cost=sum(Psychiatry_Cost)
   /Maternity_Cost=sum(Maternity_Cost)
   /Geriatric_Cost=sum(Geriatric_Cost)
   /Elective_Cost=sum(Acute_Elective_Cost)
   /Emergency_Cost=sum(Acute_Emergency_Cost)
   /Home_Care_Cost=sum(Home_Care_Cost)
   /Care_Home_Cost=sum(Care_Home_Cost)
   /Hospital_Elective_Cost=sum(Hospital_Elective_Cost)
   /Hospital_Emergency_Cost=sum(Hospital_Emergency_Cost)
   /AE2_Cost=sum(AE2_Cost)
   /Prescribing_Cost=sum(Prescribing_Cost)
   /Outpatient_Cost=sum(Outpatient_Cost)
   /Total_Outpatient_Cost=sum(Total_Outpatient_Cost)
   /Community_Health_Cost=sum(Community_Health_Cost)
   /Operation_Flag=max(Operation_Flag).

compute CIS_Attendance=0.
compute Emergency_Instances=0.
compute Elective_Instances=0.
compute Elective_Inpatient_Instances=0.
compute Elective_Daycase_Instances=0.
compute Death_Flag=0.


if (recid ne 'AE2' and recid ne 'PIS' and recid ne '00B' and recid ne 'NRS') CIS_Attendance=1.
if (newpattype_CIS='Non-Elective') Emergency_Instances=1.
if (newpattype_CIS='Elective' or newCIS_ipdc='D') Elective_Instances=1.
if (newpattype_CIS='Elective' and newCIS_ipdc='I') Elective_Inpatient_Instances=1.
if (newpattype_CIS='Elective' and newCIS_ipdc='D') Elective_Daycase_Instances=1.
if recid='NRS' Death_Flag=1.

compute Elective_Inpatient_Cost=0.
if Elective_Inpatient_Instances=1 Elective_Inpatient_Cost=Total_Cost.


* /Unplanned_Beddays=sum(Unplanned_Beddays).
aggregate outfile = *
   /break CHI
   /Total_Cost=sum(Total_Cost)
   /Total_Beddays=sum(Bed_Days)
   /Admission=sum(CIS_Attendance)
   /Operation_Flag=max(Operation_Flag)
   /Emergency=sum(Emergency_Instances)
   /Elective=sum(Elective_Instances)
   /Elective_Inpatient=sum(Elective_Inpatient_Instances)
   /Elective_Daycase=sum(Elective_Daycase_Instances)
   /Death_Flag=max(Death_Flag)
   /Psychiatry_Cost=sum(Psychiatry_Cost)
   /Maternity_Cost=sum(Maternity_Cost)
   /Geriatric_Cost=sum(Geriatric_Cost)
   /Emergency_Cost=sum(Emergency_Cost)
   /Elective_Cost=sum(Elective_Cost)
   /Elective_Inpatient_Cost=sum(Elective_Inpatient_Cost)
   /Home_Care_Cost=sum(Home_Care_Cost)
   /Care_Home_Cost=sum(Care_Home_Cost)
   /Hospital_Elective_Cost=sum(Hospital_Elective_Cost)
   /Hospital_Emergency_Cost=sum(Hospital_Emergency_Cost)
   /AE2_Cost=sum(AE2_Cost)
   /Prescribing_Cost=sum(Prescribing_Cost)
   /Outpatient_Cost=sum(Outpatient_Cost)
   /Total_Outpatient_Cost=sum(Total_Outpatient_Cost)
   /Community_Health_Cost=sum(Community_Health_Cost).


compute Elective_Inpatient_Flag=0.
compute Elective_Inpatient_Percentage=Elective_Inpatient_Cost/Elective_Cost.


if Elective_Inpatient_Percentage gt 0.5 Elective_Inpatient_Flag=1.



*Create flags to be used to classify patients.
compute Psychiatry_Cohort=0.
compute Maternity_Cohort=0.
compute Geriatric_Cohort=0.
compute Elective_Inpatient_Cohort=0.
compute Limited_Daycases_Cohort=0.
compute Routine_Daycase_Cohort=0.
compute Single_Emergency_Cohort=0.
compute Multiple_Emergency_Cohort=0.
compute Routine_Daycase_Cohort=0.
compute Prescribing_Cohort=0.
compute Outpatient_Cohort=0.
compute Residential_Care_Cohort=0.
compute Community_Care_Cohort=0.
compute AE2_Cohort=0.
compute Elective_Other_Cohort=0.
compute Other_Cohort=0.


*Create our set of rules to classify HRI patients.
if (Psychiatry_Cost gt 0) Psychiatry_Cohort=1.
if (Maternity_Cost gt 0) Maternity_Cohort=1.
if (Geriatric_Cost gt 0) Geriatric_Cohort=1.
if (Elective_Inpatient_Flag=1) Elective_Inpatient_Cohort=1.
if (Elective_Inpatient_Flag=0 and Elective le 3) Limited_Daycases_Cohort=1.
if (Elective_Inpatient_Flag=0 and Elective ge 4) Routine_Daycase_Cohort=1.
if (Emergency=1) Single_Emergency_Cohort=1.
if (Emergency ge 2) Multiple_Emergency_Cohort=1.
if (Prescribing_Cost gt 0) Prescribing_Cohort=1.
if (Care_Home_Cost gt 0) Residential_Care_Cohort=1.
if (Outpatient_Cost gt 0) Outpatient_Cohort=1.
if (Home_Care_Cost gt 0 or Community_Health_Cost gt 0) Community_Care_Cohort=1.
if (AE2_Cost gt 0) AE2_Cohort=1.
if (Psychiatry_Cohort=0 and Maternity_Cohort=0 and Geriatric_Cohort=0 and Elective_Inpatient_Cohort=0 and 
   Limited_Daycases_Cohort=0 and Single_Emergency_Cohort=0 and Multiple_Emergency_Cohort=0 and 
   Routine_Daycase_Cohort=0 and Prescribing_Cohort=0 and Outpatient_Cohort=0 and Community_Care_Cohort=0 and 
   AE2_Cohort=0 and Residential_Care_Cohort=0) Other_Cohort=1.


save outfile =  '/conf/sourcedev/GP_Practice_Cohort_Updated_With_Pattype_'+!FY+'.zsav'
   /zcompressed.

***********************************************************************************************************************************.

*Adjusting Cohorts based on Cost.

get file = '/conf/sourcedev/GP_Practice_Cohort_Updated_With_Pattype_'+!FY+'.zsav'.

*Create new variables to calculate the cost for each cohort.
compute Elective_Inpatient_Cost=0.
compute Limited_Daycases_Cost=0.
compute Single_Emergency_Cost=0.
compute Multiple_Emergency_Cost=0.
compute Routine_Daycase_Cost=0.
compute Community_Care_Cost=0.
compute Residential_Care_Cost=0.


*Calculate the costs for each cohort.
if (Elective_Inpatient_Cohort=1) Elective_Inpatient_Cost=Elective_Cost.
if (Limited_Daycases_Cohort=1) Limited_Daycases_Cost=Elective_Cost.
if (Routine_Daycase_Cohort=1) Routine_Daycase_Cost=Elective_Cost.
if (Single_Emergency_Cohort=1) Single_Emergency_Cost=Emergency_Cost.
if (Multiple_Emergency_Cohort=1) Multiple_Emergency_Cost=Emergency_Cost.
if Community_Care_Cohort=1 Community_Care_Cost=Home_Care_Cost+Community_Health_Cost.
if Residential_Care_Cohort=1 Residential_Care_Cost=Care_Home_Cost.


recode Total_Cost (sysmis=0).

*Compare costs for each cohort and sort each patient into the cohort with the greatest cost attached.
string Cohort (A50).
if Total_Cost=0 Cohort='None'.
if ((Psychiatry_Cost gt Maternity_Cost) and (Psychiatry_Cost gt Geriatric_Cost) and (Psychiatry_Cost gt Elective_Inpatient_Cost)  and 
   (Psychiatry_Cost gt Limited_Daycases_Cost) and (Psychiatry_Cost gt Single_Emergency_Cost) and (Psychiatry_Cost gt Multiple_Emergency_Cost) and 
   (Psychiatry_Cost gt Routine_Daycase_Cost) and (Psychiatry_Cost gt Prescribing_Cost) and (Psychiatry_Cost gt Outpatient_Cost) and 
   (Psychiatry_Cost gt AE2_Cost) and (Psychiatry_Cost gt Community_Care_Cost) and (Psychiatry_Cost gt Residential_Care_Cost)) Cohort='Psychiatry'.
if ((Maternity_Cost gt Psychiatry_Cost) and (Maternity_Cost gt Geriatric_Cost) and (Maternity_Cost gt Elective_Inpatient_Cost) and 
   (Maternity_Cost gt Limited_Daycases_Cost) and (Maternity_Cost gt Single_Emergency_Cost) and (Maternity_Cost gt Multiple_Emergency_Cost) and 
   (Maternity_Cost gt Routine_Daycase_Cost) and (Maternity_Cost gt Prescribing_Cost) and (Maternity_Cost gt Outpatient_Cost) and 
   (Maternity_Cost gt AE2_Cost) and (Maternity_Cost gt Community_Care_Cost) and (Maternity_Cost gt Residential_Care_Cost)) Cohort='Maternity'.
if ((Geriatric_Cost ge Psychiatry_Cost) and (Geriatric_Cost gt Maternity_Cost) and (Geriatric_Cost gt Elective_Inpatient_Cost) and 
   (Geriatric_Cost gt Limited_Daycases_Cost) and (Geriatric_Cost gt Single_Emergency_Cost) and (Geriatric_Cost gt Multiple_Emergency_Cost) and 
   (Geriatric_Cost gt Routine_Daycase_Cost) and (Geriatric_Cost gt Prescribing_Cost) and (Geriatric_Cost gt Outpatient_Cost) and 
   (Geriatric_Cost gt AE2_Cost) and (Geriatric_Cost gt Community_Care_Cost) and (Geriatric_Cost gt Residential_Care_Cost)) Cohort='Geriatric'.
if ((Elective_Inpatient_Cost gt Psychiatry_Cost) and (Elective_Inpatient_Cost gt Maternity_Cost) and (Elective_Inpatient_Cost gt Geriatric_Cost) and 
   (Elective_Inpatient_Cost gt Limited_Daycases_Cost) and (Elective_Inpatient_Cost gt Single_Emergency_Cost) and 
   (Elective_Inpatient_Cost gt Multiple_Emergency_Cost) and (Elective_Inpatient_Cost gt Routine_Daycase_Cost) and 
   (Elective_Inpatient_Cost gt Prescribing_Cost) and (Elective_Inpatient_Cost gt Outpatient_Cost) and (Elective_Inpatient_Cost gt AE2_Cost) and 
   (Elective_Inpatient_Cost gt Community_Care_Cost) and (Elective_Inpatient_Cost gt Residential_Care_Cost)) Cohort='Elective Inpatient'.
if ((Limited_Daycases_Cost gt Psychiatry_Cost) and (Limited_Daycases_Cost gt Maternity_Cost) and (Limited_Daycases_Cost gt Geriatric_Cost) and 
   (Limited_Daycases_Cost gt Elective_Inpatient_Cost) and (Limited_Daycases_Cost gt Single_Emergency_Cost) and 
   (Limited_Daycases_Cost gt Multiple_Emergency_Cost) and (Limited_Daycases_Cost gt Routine_Daycase_Cost) and 
   (Limited_Daycases_Cost gt Prescribing_Cost) and (Limited_Daycases_Cost gt Outpatient_Cost) and (Limited_Daycases_Cost gt AE2_Cost) and 
(Limited_Daycases_Cost gt Community_Care_Cost) and (Limited_Daycases_Cost gt Residential_Care_Cost)) Cohort='Limited Daycases'.
if ((Routine_Daycase_Cost gt Psychiatry_Cost) and (Routine_Daycase_Cost gt Maternity_Cost) and (Routine_Daycase_Cost gt Geriatric_Cost) and 
   (Routine_Daycase_Cost gt Elective_Inpatient_Cost) and (Routine_Daycase_Cost gt Limited_Daycases_Cost) and 
   (Routine_Daycase_Cost gt Single_Emergency_Cost) and (Routine_Daycase_Cost gt Multiple_Emergency_Cost) and 
   (Routine_Daycase_Cost gt Prescribing_Cost) and (Routine_Daycase_Cost ge Outpatient_Cost) and (Routine_Daycase_Cost gt AE2_Cost) and 
   (Routine_Daycase_Cost gt Community_Care_Cost) and (Routine_Daycase_Cost gt Residential_Care_Cost)) Cohort='Routine Daycase'.
if ((Single_Emergency_Cost gt Psychiatry_Cost) and (Single_Emergency_Cost gt Maternity_Cost) and (Single_Emergency_Cost gt Geriatric_Cost) and 
   (Single_Emergency_Cost gt Elective_Inpatient_Cost) and (Single_Emergency_Cost gt Limited_Daycases_Cost) and 
   (Single_Emergency_Cost gt Multiple_Emergency_Cost) and (Single_Emergency_Cost gt Routine_Daycase_Cost) and 
   (Single_Emergency_Cost gt Prescribing_Cost) and (Single_Emergency_Cost gt Outpatient_Cost) and (Single_Emergency_Cost gt AE2_Cost) and 
   (Single_Emergency_Cost gt Community_Care_Cost) and (Single_Emergency_Cost gt Residential_Care_Cost)) Cohort='Single Emergency'.
if ((Multiple_Emergency_Cost gt Psychiatry_Cost) and (Multiple_Emergency_Cost gt Maternity_Cost) and (Multiple_Emergency_Cost gt Geriatric_Cost) and 
   (Multiple_Emergency_Cost gt Elective_Inpatient_Cost) and (Multiple_Emergency_Cost gt Limited_Daycases_Cost) and 
   (Multiple_Emergency_Cost gt Single_Emergency_Cost) and (Multiple_Emergency_Cost gt Routine_Daycase_Cost) and 
   (Multiple_Emergency_Cost gt Prescribing_Cost) and (Multiple_Emergency_Cost gt Outpatient_Cost) and (Multiple_Emergency_Cost gt AE2_Cost) and 
   (Multiple_Emergency_Cost gt Community_Care_Cost) and (Multiple_Emergency_Cost gt Residential_Care_Cost)) Cohort='Multiple Emergency'.
if ((Prescribing_Cost gt Psychiatry_Cost) and (Prescribing_Cost gt Maternity_Cost) and (Prescribing_Cost gt Geriatric_Cost) and 
   (Prescribing_Cost gt Elective_Inpatient_Cost) and (Prescribing_Cost gt Limited_Daycases_Cost) and (Prescribing_Cost gt Single_Emergency_Cost) and 
   (Prescribing_Cost gt Multiple_Emergency_Cost) and (Prescribing_Cost gt Routine_Daycase_Cost) and (Prescribing_Cost gt Outpatient_Cost) and 
   (Prescribing_Cost gt AE2_Cost) and (Prescribing_Cost gt Community_Care_Cost) and (Prescribing_Cost gt Residential_Care_Cost)) Cohort='Prescribing'.
if ((Outpatient_Cost gt Psychiatry_Cost) and (Outpatient_Cost gt Maternity_Cost) and (Outpatient_Cost gt Geriatric_Cost) and 
   (Outpatient_Cost gt Elective_Inpatient_Cost) and (Outpatient_Cost gt Limited_Daycases_Cost) and (Outpatient_Cost gt Single_Emergency_Cost) and 
   (Outpatient_Cost gt Multiple_Emergency_Cost) and (Outpatient_Cost gt Routine_Daycase_Cost) and (Outpatient_Cost gt Prescribing_Cost) and 
   (Outpatient_Cost gt AE2_Cost) and (Outpatient_Cost gt Community_Care_Cost) and (Outpatient_Cost gt Residential_Care_Cost)) Cohort='Outpatients'.
if ((Community_Care_Cost gt Psychiatry_Cost) and (Community_Care_Cost gt Maternity_Cost) and (Community_Care_Cost gt Geriatric_Cost) and 
   (Community_Care_Cost gt Elective_Inpatient_Cost) and (Community_Care_Cost gt Limited_Daycases_Cost) and 
   (Community_Care_Cost gt Single_Emergency_Cost) and (Community_Care_Cost gt Multiple_Emergency_Cost) and 
   (Community_Care_Cost gt Routine_Daycase_Cost) and (Community_Care_Cost gt Prescribing_Cost) and (Community_Care_Cost gt Outpatient_Cost) and 
   (Community_Care_Cost gt AE2_Cost) and (Community_Care_Cost gt Residential_Care_Cost)) Cohort='Community Care'.
if ((AE2_Cost gt Psychiatry_Cost) and (AE2_Cost gt Maternity_Cost) and (AE2_Cost gt Geriatric_Cost) and (AE2_Cost gt Elective_Inpatient_Cost) and 
   (AE2_Cost gt Limited_Daycases_Cost) and (AE2_Cost gt Single_Emergency_Cost) and (AE2_Cost gt Multiple_Emergency_Cost) and 
   (AE2_Cost gt Routine_Daycase_Cost) and (AE2_Cost gt Outpatient_Cost) and (AE2_Cost gt Prescribing_Cost) and (AE2_Cost gt Community_Care_Cost) and 
   (AE2_Cost gt Residential_Care_Cost)) Cohort='A&E'.
if ((Residential_Care_Cost gt Psychiatry_Cost) and (Residential_Care_Cost gt Maternity_Cost) and (Residential_Care_Cost gt Geriatric_Cost) and 
   (Residential_Care_Cost gt Elective_Inpatient_Cost) and (Residential_Care_Cost gt Limited_Daycases_Cost) and 
   (Residential_Care_Cost gt Single_Emergency_Cost) and (Residential_Care_Cost gt Multiple_Emergency_Cost) and 
   (Residential_Care_Cost gt Routine_Daycase_Cost) and (Residential_Care_Cost gt Outpatient_Cost) and (Residential_Care_Cost gt Prescribing_Cost) and 
   (Residential_Care_Cost gt AE2_Cost) and (Residential_Care_Cost gt Community_Care_Cost)) Cohort='Residential Care'.
if (Cohort='') Cohort='Other'.


*Want to remove any patients who don't fit within our Service Use Classification.
*select if Cohort ne 'Other'.
*exe.

recode Total_Beddays Total_Cost (sysmis=0).

sort cases by CHI (a).

*extra syntax added by GNW - modifications for adding variable to source linkage files.
*1. rename variable.
rename variables Cohort = Service_Use_Cohort.

*1. shorten width of cohort variable.
alter type Service_Use_Cohort (a=amin).

*2. add variable label (from AM).
variable labels Service_Use_Cohort 'Allocated based on main service type, i.e. where the highest proportion of health cost was spent in the financial year'.

save outfile = '/conf/sourcedev/GP_Practice_Service_Use_Cohorts_' + !FY + '.zsav'
   /keep CHI Service_Use_Cohort
   /zcompressed.

*save outfile = '/conf/irf/11-Development team/GP_Practice_Service_Use_Cohorts_' + !FY + '.sav'
   /keep CHI Service_Use_Cohort.

get file ='/conf/sourcedev/GP_Practice_Service_Use_Cohorts_'+!FY+'.zsav'.

*get file = '/conf/irf/11-Development team/GP_Practice_Service_Use_Cohorts_' + !FY + '.sav'.














