* IRF Producing list of UPIs for patients with a specific long term condition.
* This work is to create SPSS lists of UPIs with a flag variable that will be used in 
* the addition of long term condition flags to the master PLICs and CHI master PLICs 
* analysis files. 

* Program structure created by Denise Hastie, February 2014.
* Addition of record types and diagnosis code selection by Peter McClurg, Information Analyst, June 2014.

* Define file path for saving interim files and output.

define !DataFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/data/'
!enddefine.

* Output files.
define !OutputFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/output/'
!enddefine.

 
***** READING ALL SMR1/01 RECORDS FROM LINKED DATABASE *****.
***** Reading two date ranges ( linked positions ) for ICD9 and ICD10 diagnosis positions ( 01A/04A/50A ONLY )***
***** Reading one date range ( no need to specify as all start on or after Q2 1996 for (01B/04B/50B)***.

input program.
data list file='/conf/linkage/catalog/catalog_31052014.cis'
 /recid 25-27(a) sdoa 9-14 sdod 17-22.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
do  if (recid eq '01A' and sdod <=199603).
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 274-277(A) 
                      DIAG2 280-283(A) DIAG3 286-289(A) DIAG4 292-295(A) DIAG5 298-301(A) DIAG6 304-307(A).
end case.
else if(recid eq '01A' and sdod>199603).
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 273-276(A) 
                      DIAG2 279-282(A) DIAG3 285-288(A) DIAG4 291-294(A) DIAG5 297-300(A) DIAG6 303-306(A).
end case.
else if(recid eq '01B').
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 388-391(A) 
                      DIAG2 394-397(A) DIAG3 400-403(A) DIAG4 406-409(A) DIAG5 412-415(A) DIAG6 418-421(A).
end case.
else if (recid eq '04A' and sdod<=199603).
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 274-277(A) 
                      DIAG2 280-283(A) DIAG3 286-289(A) DIAG4 292-295(A) DIAG5 298-301(A) DIAG6 304-307(A).
end case.
else if(recid eq '04A' and sdod>199603).
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 273-276(A) 
                      DIAG2 279-282(A) DIAG3 285-288(A) DIAG4 291-294(A) DIAG5 297-300(A) DIAG6 303-306(A).
end case.
else if (recid eq '04B').
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 388-391(A) 
                      DIAG2 394-397(A) DIAG3 400-403(A) DIAG4 406-409(A) DIAG5 412-415(A) DIAG6 418-421(A).
end case.
else if (recid eq '50A' and sdod<=199603).
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 274-277(A) 
                      DIAG2 280-283(A) DIAG3 286-289(A) DIAG4 292-295(A) DIAG5 298-301(A) DIAG6 304-307(A).
end case.
else if(recid eq '50A' and sdod>199603).
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 273-276(A) 
                      DIAG2 279-282(A) DIAG3 285-288(A) DIAG4 291-294(A) DIAG5 297-300(A) DIAG6 303-306(A).
end case.
else if (recid eq '50B').
reread.
DATA LIST / LINKNO 1-8 (A) RECID 25-27 (A) UPI 84-93(A)
                      DATE_ADM 9-16(A) DATE_DIS 17-24(A) DIAG1 388-391(A) 
                      DIAG2 394-397(A) DIAG3 400-403(A) DIAG4 406-409(A) DIAG5 412-415(A) DIAG6 418-421(A).
end case.
end if.
end input program.
EXECUTE.         

 * string year_adm year_dis(a6).
string month_adm month_dis(a4). 
compute month_adm=substr(date_adm,3,6).
compute month_dis=substr(date_dis,3,6).
execute.

if (month_adm ge '1004' and month_adm le '1103') year_adm=201011.
if (month_adm ge '1104' and month_adm le '1203') year_adm=201112.
if (month_adm ge '1204' and month_adm le '1303') year_adm=201213.
if (month_dis ge '1004' and month_dis le '1103') year_dis=201011.
if (month_dis ge '1104' and month_dis le '1203') year_dis=201112.
if (month_dis ge '1204' and month_dis le '1303') year_dis=201213.
execute.
alter type year_adm year_dis(f6.0).

***********************************************************
Question: Can I use less executes from line 89 - 101?
***********************************************************.

save outfile=!DataFiles + 'Extract1.sav'
/keep linkno recid upi date_adm year_adm date_dis year_dis diag1 diag2 diag3 diag4 diag5 diag6.

**********************************************************
Creating strings for diagnosis codes ( 3 length )
**********************************************************.

get file=!DataFiles + 'Extract1.sav'.

string diag13 diag23 diag33 diag43 diag53 diag63(a3).

compute diag13=substr(diag1,1,3).
compute diag23=substr(diag2,1,3).
compute diag33=substr(diag3,1,3).
compute diag43=substr(diag4,1,3).
compute diag53=substr(diag5,1,3).
compute diag63=substr(diag6,1,3).
execute.

**********************************************************
Renaming diagnosis codes ( 4 length )
**********************************************************.

rename variables (diag1 diag2 diag3 diag4 diag5 diag6=diag14 diag24 diag34 diag44 diag54 diag64).

****************************************************************************************************
Selecting patients with CEREBROVASCULAR DISEASE (CVD) with a marker '1'
ICD9 CODES 430-438 OR ICD10 CODES I60-I69,G45
****************************************************************************************************.

Compute CVD=0.
If ((diag13 ge'430' and diag13 le'438') or (diag13 ge'I60' and diag13 le'I69') or (diag13='G45')) or
   ((diag23 ge'430' and diag23 le'438') or (diag23 ge'I60' and diag23 le'I69') or (diag23='G45')) or
   ((diag33 ge'430' and diag33 le'438') or (diag33 ge'I60' and diag33 le'I69') or (diag33='G45')) or
   ((diag43 ge'430' and diag43 le'438') or (diag43 ge'I60' and diag43 le'I69') or (diag43='G45')) or
   ((diag53 ge'430' and diag53 le'438') or (diag53 ge'I60' and diag53 le'I69') or (diag53='G45')) or
   ((diag63 ge'430' and diag63 le'438') or (diag63 ge'I60' and diag63 le'I69') or (diag63='G45')) 
CVD=1.
*execute.

****************************************************************************************************
Selecting patients with CHRONIC OBSTRUCTIVE PULMONARY DISEASE (COPD) with a marker '1'
ICD9 CODES 494,496 OR ICD10 CODES J41-J44,J47
****************************************************************************************************.

Compute COPD=0.
If ((diag13='494' or diag13='496') or (diag13 ge'J41' and diag13 le'J44') or diag13='J47') or 
   ((diag23='494' or diag23='496') or (diag23 ge'J41' and diag23 le'J44') or diag23='J47') or 
   ((diag33='494' or diag33='496') or (diag33 ge'J41' and diag33 le'J44') or diag33='J47') or 
   ((diag43='494' or diag43='496') or (diag43 ge'J41' and diag43 le'J44') or diag43='J47') or 
   ((diag53='494' or diag53='496') or (diag53 ge'J41' and diag53 le'J44') or diag53='J47') or 
   ((diag63='494' or diag63='496') or (diag63 ge'J41' and diag63 le'J44') or diag63='J47')
COPD=1.
*execute.

****************************************************************************************************
Selecting patients with DEMENTIA (DEMENTIA) with a marker '1'
ICD9 CODES 290.0,290.1,290.2,290.4,290.8,290.9 or ICD10 CODES F00-F03, F05.1
( Note: 290.3 is the only other code between 290.0 and 290.9 )
****************************************************************************************************.

Compute DEMENTIA=0.
If (((diag14 ge'2900' and diag14 le'2909') and (diag14<>'2903')) or (diag13 ge'F00' and diag13 le'F03') or (diag14='F051')) or
   (((diag24 ge'2900' and diag24 le'2909') and (diag24<>'2903')) or (diag23 ge'F00' and diag23 le'F03') or (diag24='F051')) or
   (((diag34 ge'2900' and diag34 le'2909') and (diag34<>'2903')) or (diag33 ge'F00' and diag33 le'F03') or (diag34='F051')) or
   (((diag44 ge'2900' and diag44 le'2909') and (diag44<>'2903')) or (diag43 ge'F00' and diag43 le'F03') or (diag44='F051')) or
   (((diag54 ge'2900' and diag54 le'2909') and (diag54<>'2903')) or (diag53 ge'F00' and diag53 le'F03') or (diag54='F051')) or
   (((diag64 ge'2900' and diag64 le'2909') and (diag64<>'2903')) or (diag63 ge'F00' and diag63 le'F03') or (diag64='F051'))
DEMENTIA=1.
*execute.


****************************************************************************************************
Selecting patients with DIABETES (DIABETES) with a marker '1'
ICD9 CODE 250 OR ICD10 CODES E10-E14.
****************************************************************************************************.

Compute DIABETES=0.
If ((diag13='250') or (diag13 ge'E10' and diag13 le'E14')) or
   ((diag23='250') or (diag23 ge'E10' and diag23 le'E14')) or
   ((diag33='250') or (diag33 ge'E10' and diag33 le'E14')) or
   ((diag43='250') or (diag43 ge'E10' and diag43 le'E14')) or
   ((diag53='250') or (diag53 ge'E10' and diag53 le'E14')) or
   ((diag63='250') or (diag63 ge'E10' and diag63 le'E14'))  
DIABETES=1.
*execute.

****************************************************************************************************
Selecting patients with HEART DISEASE (CHD) with a marker '1'
ICD9 CODE 410-414 OR ICD10 CODES I20-I25.
****************************************************************************************************.

Compute CHD=0.
If ((diag13 ge'410' and diag13 le'414') or (diag13 ge'I20' and diag13 le'I25')) or
   ((diag23 ge'410' and diag23 le'414') or (diag23 ge'I20' and diag23 le'I25')) or
   ((diag33 ge'410' and diag33 le'414') or (diag33 ge'I20' and diag33 le'I25')) or
   ((diag43 ge'410' and diag43 le'414') or (diag43 ge'I20' and diag43 le'I25')) or
   ((diag53 ge'410' and diag53 le'414') or (diag53 ge'I20' and diag53 le'I25')) or
   ((diag63 ge'410' and diag63 le'414') or (diag63 ge'I20' and diag63 le'I25')) 
CHD=1.
*execute.

****************************************************************************************************
Selecting patients with HEART FAILURE (HeFailure) with a marker '1'
ICD9 CODE 428 OR ICD10 CODES 150.0, 150.1 OR 150.9.
****************************************************************************************************.

Compute HeFailure=0.
If ((diag13='428') OR (diag14='1500' or diag14='I501' or diag14='I509')) or 
   ((diag23='428') OR (diag24='1500' or diag24='I501' or diag24='I509')) or 
   ((diag33='428') OR (diag34='1500' or diag34='I501' or diag34='I509')) or 
   ((diag43='428') OR (diag44='1500' or diag44='I501' or diag44='I509')) or 
   ((diag53='428') OR (diag54='1500' or diag54='I501' or diag54='I509')) or 
   ((diag63='428') OR (diag64='1500' or diag64='I501' or diag64='I509'))
HeFailure=1.
*execute.

****************************************************************************************************
Selecting patients with RENAL FAILURE (ReFailure) with a marker '1'
ICD9 CODES 582,585,403.9 or 404.9 OR ICD10 CODES N03,N18,N19,I12 or I13.
****************************************************************************************************.

*****************start of test of code**********
Calculating ReFailure using long code to compare 
************************************************.
 * Temporary.
 * compute RetestFailure=0.
 * If ((diag13='582')or(diag13='585')or(diag14='4039')or(diag14='4049')or(diag13='N03')or(diag13='N18')or(diag13='N19')or(diag13='I12')or(diag13='I13')) or
   ((diag23='582')or(diag23='585')or(diag24='4039')or(diag24='4049')or(diag23='N03')or(diag23='N18')or(diag23='N19')or(diag23='I12')or(diag23='I13')) or
   ((diag33='582')or(diag33='585')or(diag34='4039')or(diag34='4049')or(diag33='N03')or(diag33='N18')or(diag33='N19')or(diag33='I12')or(diag33='I13')) or
   ((diag43='582')or(diag43='585')or(diag44='4039')or(diag44='4049')or(diag43='N03')or(diag43='N18')or(diag43='N19')or(diag43='I12')or(diag43='I13')) or
   ((diag53='582')or(diag53='585')or(diag54='4039')or(diag54='4049')or(diag53='N03')or(diag53='N18')or(diag53='N19')or(diag53='I12')or(diag53='I13')) or
   ((diag63='582')or(diag63='585')or(diag64='4039')or(diag64='4049')or(diag63='N03')or(diag63='N18')or(diag63='N19')or(diag63='I12')or(diag63='I13'))
RetestFailure=1.
 * Frequency variables=RetestFailure
/order=analysis.
 * execute.
******************end of test of code **********.

Compute ReFailure=0.
if ((diag13='582'|diag13='585'|diag13='N03'|diag13='N18'|diag13='N19'|diag13='I12'|diag13='I13')or(diag14='4039'|diag14='4049')) or
   ((diag23='582'|diag23='585'|diag23='N03'|diag23='N18'|diag23='N19'|diag23='I12'|diag23='I13')or(diag24='4039'|diag24='4049')) or
   ((diag33='582'|diag33='585'|diag33='N03'|diag33='N18'|diag33='N19'|diag33='I12'|diag33='I13')or(diag34='4039'|diag34='4049')) or
   ((diag43='582'|diag43='585'|diag43='N03'|diag43='N18'|diag43='N19'|diag43='I12'|diag43='I13')or(diag44='4039'|diag44='4049')) or
   ((diag53='582'|diag53='585'|diag53='N03'|diag53='N18'|diag53='N19'|diag53='I12'|diag53='I13')or(diag54='4039'|diag54='4049')) or
   ((diag63='582'|diag63='585'|diag63='N03'|diag63='N18'|diag63='N19'|diag63='I12'|diag63='I13')or(diag64='4039'|diag64='4049'))
ReFailure=1.
execute.
alter type CVD COPD Dementia Diabetes CHD HeFailure ReFailure(F1.0).

save outfile=!DataFiles + '7diag_Hospital_incidence.sav'.

****************************************************************************************
* End of diagnostic coding.
****************************************************************************************

***********************************************
Create Files ( First date of Admission )
***********************************************.

*******************************************
CVD ( Cerebrovascular Disease )
*******************************************.

Temporary.
Select if CVD=1.
Select if UPI<>''.
Aggregate outfile=!Datafiles + 'CVD_Hospital_incidence.sav'
 /break UPI
 /date_adm_CVD=First(date_adm).
execute.

 * get file=!Datafiles + 'CVD_Hospital_incidence.sav'.
*******************************************
COPD ( Chronic Obstructive Pulmonary Disease 
*******************************************.

Temporary.
Select if COPD=1.
Select if UPI<>''.
Aggregate outfile=!Datafiles + 'COPD_Hospital_incidence.sav'
 /break UPI
 /date_adm_COPD=First(date_adm).
execute.

*******************************************
Dementia ( Dementia )
*******************************************.
Temporary.
Select if DEMENTIA=1.
Select if UPI<>''.
Aggregate outfile=!Datafiles + 'DEMENTIA_Hospital_incidence.sav'
 /break UPI
 /date_adm_DEMENTIA=First(date_adm).
execute.


*******************************************
Diabetes ( Diabetes )
*******************************************.
Temporary.
Select if DIABETES=1.
Select if UPI<>''.
Aggregate outfile=!Datafiles + 'DIABETES_Hospital_incidence.sav'
 /break UPI
 /date_adm_DIABETES=First(date_adm).
execute.

*******************************************
CHD ( Heart Disease )
*******************************************.

Temporary.
Select if CHD=1.
Select if UPI<>''.
Aggregate outfile=!Datafiles + 'CHD_Hospital_incidence.sav'
 /break UPI
 /date_adm_CHD=First(date_adm).
execute.


*******************************************
HeFailure ( Heart Failure )
*******************************************.

Temporary.
Select if HeFailure=1.
Select if UPI<>''.
Aggregate outfile=!Datafiles + 'HeFailure_Hospital_incidence.sav'
 /break UPI
 /date_adm_HeFailure=First(date_adm).
execute.

*******************************************
ReFailure ( Renal Failure )
*******************************************.

Temporary.
Select if ReFailure=1.
Select if UPI<>''.
Aggregate outfile=!Datafiles + 'ReFailure_Hospital_incidence.sav'
 /break UPI
 /date_adm_ReFailure=First(date_adm).
execute.

*********************************************************************
Create three financial years for each LTC Marker ( 3 x 7 = 21 files ).
*********************************************************************.

***1. CVD***.


get file=!DataFiles + 'CVD_Hospital_incidence.sav'.
Temporary.
Select if ((date_adm_CVD<='20110331') and (date_adm_CVD>='20100401')).
save outfile=!DataFiles + 'LTC_CVD_Hospital_Incidence_201011.sav'
/Keep UPI.
execute.
Temporary.
Select if (date_adm_CVD<='20120331') and (date_adm_CVD>='20110401').
save outfile=!DataFiles + 'LTC_CVD_Hospital_Incidence_201112.sav'
/Keep UPI.
Execute.
Temporary.
Select if (date_adm_CVD<='20130331') and (date_adm_CVD>='20120401').
save outfile=!DataFiles + 'LTC_CVD_Hospital_Incidence_201213.sav'
/Keep UPI.
execute.

***2. COPD***.
get file=!DataFiles + 'COPD_Hospital_incidence.sav'.
Temporary.
Select if ((date_adm_COPD<='20110331') and (date_adm_COPD>='20100401')).
save outfile=!DataFiles + 'LTC_COPD_Hospital_Incidence_201011.sav'
/Keep UPI.
execute.
Temporary.
Select if (date_adm_COPD<='20120331') and (date_adm_COPD>='20110401').
save outfile=!DataFiles + 'LTC_COPD_Hospital_Incidence_201112.sav'
/Keep UPI.
Execute.
Temporary.
Select if (date_adm_COPD<='20130331') and (date_adm_COPD>='20120401').
save outfile=!DataFiles + 'LTC_COPD_Hospital_Incidence_201213.sav'
/Keep UPI.
execute.

***3. DEMENTIA***.
get file=!DataFiles + 'DEMENTIA_Hospital_incidence.sav'.
Select if ((date_adm_DEMENTIA<='20110331') and (date_adm_DEMENTIA>='20100401')).
save outfile=!DataFiles + 'LTC_DEMENTIA_Hospital_Incidence_201011.sav'
/Keep UPI.
execute.
Temporary.
Select if (date_adm_DEMENTIA<='20120331') and (date_adm_DEMENTIA>='20110401').
save outfile=!DataFiles + 'LTC_DEMENTIA_Hospital_Incidence_201112.sav'
/Keep UPI.
Execute.
Temporary.
Select if (date_adm_DEMENTIA<='20130331') and (date_adm_DEMENTIA>='20120401').
save outfile=!DataFiles + 'LTC_DEMENTIA_Hospital_Incidence_201213.sav'
/Keep UPI.
execute.

***4. DIABETES***.
get file=!DataFiles + 'DIABETES_Hospital_incidence.sav'.
Temporary.
Select if ((date_adm_DIABETES<='20110331') and (date_adm_DIABETES>='20100401')).
save outfile=!DataFiles + 'LTC_DIABETES_Hospital_Incidence_201011.sav'
/Keep UPI.
execute.
Temporary.
Select if (date_adm_DIABETES<='20120331') and (date_adm_DIABETES>='20110401').
save outfile=!DataFiles + 'LTC_DIABETES_Hospital_Incidence_201112.sav'
/Keep UPI.
Execute.
Temporary.
Select if (date_adm_DIABETES<='20130331') and (date_adm_DIABETES>='20120401').
save outfile=!DataFiles + 'LTC_DIABETES_Hospital_Incidence_201213.sav'
/Keep UPI.
execute.

***5. CHD***.
get file=!DataFiles + 'CHD_Hospital_incidence.sav'.
Temporary.
Select if ((date_adm_CHD<='20110331') and (date_adm_CHD>='20100401')).
save outfile=!DataFiles + 'LTC_CHD_Hospital_Incidence_201011.sav'
/Keep UPI.
execute.
Temporary.
Select if (date_adm_CHD<='20120331') and (date_adm_CHD>='20110401').
save outfile=!DataFiles + 'LTC_CHD_Hospital_Incidence_201112.sav'
/Keep UPI.
Execute.
Temporary.
Select if (date_adm_CHD<='20130331') and (date_adm_CHD>='20120401').
save outfile=!DataFiles + 'LTC_CHD_Hospital_Incidence_201213.sav'
/Keep UPI.
execute.

***6. HeFailure***.
get file=!DataFiles + 'HeFailure_Hospital_incidence.sav'.
Temporary.
Select if ((date_adm_HeFailure<='20110331') and (date_adm_HeFailure>='20100401')).
save outfile=!DataFiles + 'LTC_HeFailure_Hospital_Incidence_201011.sav'
/Keep UPI.
execute.
Temporary.
Select if (date_adm_HeFailure<='20120331') and (date_adm_HeFailure>='20110401').
save outfile=!DataFiles + 'LTC_HeFailure_Hospital_Incidence_201112.sav'
/Keep UPI.
Execute.
Temporary.
Select if (date_adm_HeFailure<='20130331') and (date_adm_HeFailure>='20120401').
save outfile=!DataFiles + 'LTC_HeFailure_Hospital_Incidence_201213.sav'
/Keep UPI.
execute.

***7. ReFailure***.
get file=!DataFiles + 'ReFailure_Hospital_incidence.sav'.
Temporary.
Select if ((date_adm_ReFailure<='20110331') and (date_adm_ReFailure>='20100401')).
save outfile=!DataFiles + 'LTC_ReFailure_Hospital_Incidence_201011.sav'
/Keep UPI.
execute.
Temporary.
Select if (date_adm_ReFailure<='20120331') and (date_adm_ReFailure>='20110401').
save outfile=!DataFiles + 'LTC_ReFailure_Hospital_Incidence_201112.sav'
/Keep UPI.
Execute.
Temporary.
Select if (date_adm_ReFailure<='20130331') and (date_adm_ReFailure>='20120401').
save outfile=!DataFiles + 'LTC_ReFailure_Hospital_Incidence_201213.sav'
/Keep UPI.
execute.


**********************************************************************
End of Hospital Incidences.
**********************************************************************.














**********************************************************************
SENSE CHECKING OF DATA.
**********************************************************************.

 * get file=!DataFiles +'LTC_ReFailure_Hospital_Incidence_201213.sav'.
 * get file=!DataFiles +'LTC_ReFailure_Hospital_Incidence_201112.sav'.
 * get file=!DataFiles +'LTC_ReFailure_Hospital_Incidence_201011.sav'.
 * get file=!DataFiles +'LTC_HeFailure_Hospital_Incidence_201213.sav'.
 * get file=!DataFiles +'LTC_HeFailure_Hospital_Incidence_201112.sav'.
 * get file=!DataFiles +'LTC_HeFailure_Hospital_Incidence_201011.sav'.
 * get file=!DataFiles +'LTC_CHD_Hospital_Incidence_201213.sav'.
 * get file=!DataFiles +'LTC_CHD_Hospital_Incidence_201112.sav'.
 * get file=!DataFiles +'LTC_CHD_Hospital_Incidence_201011.sav'.
 * get file=!DataFiles +'LTC_DIABETES_Hospital_Incidence_201213.sav'.
 * get file=!DataFiles +'LTC_DIABETES_Hospital_Incidence_201112.sav'.
 * get file=!DataFiles +'LTC_DIABETES_Hospital_Incidence_201011.sav'.
 * get file=!DataFiles +'LTC_DEMENTIA_Hospital_Incidence_201213.sav'.
 * get file=!DataFiles +'LTC_DEMENTIA_Hospital_Incidence_201112.sav'.
 * get file=!DataFiles +'LTC_DEMENTIA_Hospital_Incidence_201011.sav'.
 * get file=!DataFiles +'LTC_COPD_Hospital_Incidence_201213.sav'.
 * get file=!DataFiles +'LTC_COPD_Hospital_Incidence_201112.sav'.
 * get file=!DataFiles +'LTC_COPD_Hospital_Incidence_201011.sav'.
 * get file=!DataFiles +'LTC_CVD_Hospital_Incidence_201213.sav'.
 * get file=!DataFiles +'LTC_CVD_Hospital_Incidence_201112.sav'.
 * get file=!DataFiles +'LTC_CVD_Hospital_Incidence_201011.sav'.

 * get file=!DataFiles+ '7diag_Hospital_incidence.sav'.























