* IRF Producing list of UPIs for patients with a specific long term condition.
* This work is to create SPSS lists of UPIs with a flag variable that will be used in 
* the addition of long term condition flags to the master PLICs and CHI master PLICs 
* analysis files. 

* Created by Denise Hastie, 05 May 2014.

* Updated to include the full date of admission.
* Updated by Denise Hastie, 21 May 2014.

* Updated to create files for 2010/11, 2011/12 and 2012/13.  Do not want hospital incidence cases
* for 2011/12 flagged in 2010/11 for example.  Denise Hastie, 26 May 2014.

* Not happy with outputs - reunning against latest version of the catalog. 
* Updated by Denise Hastie, November 2014. 
* Updated by Denise Hastie, December 2014. 

* Define file path for saving interim files and output.
* Interim files.  This shouldn't be necessary - but just adding in.

define !DataFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

* Output files.
define !OutputFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/04-output/'
!enddefine.


** Linked catalog section *.

* Read in acute, mental health and geriatric long stay records from the linked catalog. 

input program.
data list file='/conf/linkage/catalog/catalog_29112014.cis'
 /recid 25-27(a) sdoa 9-14 sdod 17-22.
do  if (recid eq '01A' and sdod le 199603).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) year_dis 17-20(a) diag1 274-277(a) 
            diag2 280-283(a) diag3 286-289(a) diag4 292-295(a) diag5 298-301(a) diag6 304-307(a).
end case.
else if(recid eq '01A' and sdod ge 199604).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 273-276(a) 
            diag2 279-282(a) diag3 285-288(a) diag4 291-294(a) diag5 297-300(a) diag6 303-306(a).
end case.
else if (recid eq '01B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 388-391(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
else if (recid eq '04A' and sdod le 199603).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 274-277(a) 
            diag2 280-283(a) diag3 286-289(a) diag4 292-295(a) diag5 298-301(a) diag6 304-306(a).
end case.
else if(recid eq '04B' and sdod ge 199604).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 273-276(a) 
            diag2 279-282(a) diag3 285-288(a) diag4 291-294(a) diag5 297-300(a) diag6 303-307(a).
end case.
else if(recid eq '04B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 388-391(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
else if (recid eq '50A' and sdod le 199603).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 274-277(a) 
            diag2 280-283(a) diag3 286-289(a) diag4 292-295(a) diag5 298-301(a) diag6 304-306(a).
end case.
else if(recid eq '50A' and sdod ge 199604).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 273-276(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
else if(recid eq '50B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 388-391(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
end if.
end input program.
execute.           

* create 3 character length diagnosis codes.
string d1c13 d2c13 d3c13 d4c13 d5c13 d6c13 (a3).
compute d1c13 = substr(diag1,1,3).
compute d2c13 = substr(diag2,1,3).
compute d3c13 = substr(diag3,1,3).
compute d4c13 = substr(diag4,1,3).
compute d5c13 = substr(diag5,1,3).
compute d6c13 = substr(diag6,1,3).
execute.

rename variables (diag1 diag2 diag3 diag4 diag5 diag6 = d1c14 d2c14 d3c14 d4c14 d5c14 d6c14).

* Create a marker for Cerebrovascular Disease (CVD) ICD codes: 430-438; I60-I69, G45.
compute cvd = 0.
if ((d1c13 ge '430' and d1c13 le '438') or (d1c13 ge 'I60' and d1c13 le 'I69') or (d1c13 eq 'G45') or
    (d2c13 ge '430' and d2c13 le '438') or (d2c13 ge 'I60' and d2c13 le 'I69') or (d2c13 eq 'G45') or
    (d3c13 ge '430' and d3c13 le '438') or (d3c13 ge 'I60' and d3c13 le 'I69') or (d3c13 eq 'G45') or
    (d4c13 ge '430' and d4c13 le '438') or (d4c13 ge 'I60' and d4c13 le 'I69') or (d4c13 eq 'G45') or
    (d5c13 ge '430' and d5c13 le '438') or (d5c13 ge 'I60' and d5c13 le 'I69') or (d5c13 eq 'G45') or
    (d6c13 ge '430' and d6c13 le '438') or (d6c13 ge 'I60' and d6c13 le 'I69') or (d6c13 eq 'G45')) cvd = 1.

* Create a marker for Chronic Obstructive Pulmonary Disease (COPD) ICD codes: 494, 496; J41-J44, J47.

compute copd = 0.
if ((d1c13 eq '494') or (d1c13 eq '496') or (d1c13 ge 'J41' and d1c13 le 'J44') or (d1c13 eq 'J47') or 
    (d2c13 eq '494') or (d2c13 eq '496') or (d2c13 ge 'J41' and d2c13 le 'J44') or (d2c13 eq 'J47') or 
    (d3c13 eq '494') or (d3c13 eq '496') or (d3c13 ge 'J41' and d3c13 le 'J44') or (d3c13 eq 'J47') or
    (d4c13 eq '494') or (d4c13 eq '496') or (d4c13 ge 'J41' and d4c13 le 'J44') or (d4c13 eq 'J47') or
    (d5c13 eq '494') or (d5c13 eq '496') or (d5c13 ge 'J41' and d5c13 le 'J44') or (d5c13 eq 'J47') or 
    (d6c13 eq '494') or (d6c13 eq '496') or (d6c13 ge 'J41' and d6c13 le 'J44') or (d6c13 eq 'J47')) copd = 1. 

* Create a marker for Dementia ICD codes: 290.0-290.4, 209.8, 209.9; F00-F03;F05.1.
* Note that there are no codes 2905-2907 so a range of codes can be used in the selection (checked ICD9 manual).

compute dementia = 0.
if ((d1c14 ge '2900' and d1c14 le '2909') or (d1c13 ge 'F01' and d1c13 le 'F03') or (d1c14 eq 'F051') or
    (d2c14 ge '2900' and d2c14 le '2909') or (d2c13 ge 'F01' and d2c13 le 'F03') or (d2c14 eq 'F051') or
    (d3c14 ge '2900' and d3c14 le '2909') or (d3c13 ge 'F01' and d3c13 le 'F03') or (d3c14 eq 'F051') or
    (d4c14 ge '2900' and d4c14 le '2909') or (d4c13 ge 'F01' and d4c13 le 'F03') or (d4c14 eq 'F051') or
    (d5c14 ge '2900' and d5c14 le '2909') or (d5c13 ge 'F01' and d5c13 le 'F03') or (d5c14 eq 'F051') or
    (d6c14 ge '2900' and d6c14 le '2909') or (d6c13 ge 'F01' and d6c13 le 'F03') or (d6c14 eq 'F051')) dementia = 1.

* Create a marker for Diabetes ICD codes: 250; E10-E14.
compute diabetes = 0.
if ((d1c13 eq '250') or (d1c13 ge 'E10' and d1c13 le 'E14') or
    (d2c13 eq '250') or (d2c13 ge 'E10' and d2c13 le 'E14') or
    (d3c13 eq '250') or (d3c13 ge 'E10' and d3c13 le 'E14') or
    (d4c13 eq '250') or (d4c13 ge 'E10' and d4c13 le 'E14') or
    (d5c13 eq '250') or (d5c13 ge 'E10' and d5c13 le 'E14') or
    (d6c13 eq '250') or (d6c13 ge 'E10' and d6c13 le 'E14')) diabetes = 1.

* Create a marker for Coronary Heart Disease (CHD) ICD codes: 410-414; I20-I25.
compute chd = 0.
if ((d1c13 ge '410' and d1c13 le '414') or (d1c13 ge 'I20' and d1c13 le 'I25') or 
    (d2c13 ge '410' and d2c13 le '414') or (d2c13 ge 'I20' and d2c13 le 'I25') or 
    (d3c13 ge '410' and d3c13 le '414') or (d3c13 ge 'I20' and d3c13 le 'I25') or 
    (d4c13 ge '410' and d4c13 le '414') or (d4c13 ge 'I20' and d4c13 le 'I25') or 
    (d5c13 ge '410' and d5c13 le '414') or (d5c13 ge 'I20' and d5c13 le 'I25') or 
    (d6c13 ge '410' and d6c13 le '414') or (d6c13 ge 'I20' and d6c13 le 'I25')) chd = 1.

* Create a marker for Heart Failure ICD codes: 428; I50.0, I50.1 and I50.9.
* Note that there are no codes I50.2-I50.8 so a range of codes can be used in the selection (checked ICD10 manual).

compute hefailure = 0.
if ((d1c13 eq '428') or (d1c14 ge 'I500' and d1c14 le 'I509') or
    (d2c13 eq '428') or (d2c14 ge 'I500' and d2c14 le 'I509') or
    (d3c13 eq '428') or (d3c14 ge 'I500' and d3c14 le 'I509') or
    (d4c13 eq '428') or (d4c14 ge 'I500' and d4c14 le 'I509') or
    (d5c13 eq '428') or (d5c14 ge 'I500' and d5c14 le 'I509') or
    (d6c13 eq '428') or (d6c14 ge 'I500' and d6c14 le 'I509'))hefailure = 1.

* Create a marker for Renal Failure ICD codes: 582, 585, 403.9, 404.9; N03, N18, N19, I12, I13.
compute refailure = 0.
if ((any(d1c13,'582','585','N03','N18','N19','I12','I13')) or (any(d1c14,'4039','4049')) or
    (any(d1c13,'582','585','N03','N18','N19','I12','I13')) or (any(d1c14,'4039','4049')) or
    (any(d1c13,'582','585','N03','N18','N19','I12','I13')) or (any(d1c14,'4039','4049')) or
    (any(d1c13,'582','585','N03','N18','N19','I12','I13')) or (any(d1c14,'4039','4049')) or
    (any(d1c13,'582','585','N03','N18','N19','I12','I13')) or (any(d1c14,'4039','4049')) or
    (any(d1c13,'582','585','N03','N18','N19','I12','I13')) or (any(d1c14,'4039','4049'))) refailure = 1.
execute.

* Create a marker for epilepsy ICD codes: 345; G40, G41.
compute epilepsy = 0.
if (any(d1c13,'345','G40','G41') or
    any(d2c13,'345','G40','G41') or
    any(d3c13,'345','G40','G41') or
    any(d4c13,'345','G40','G41') or
    any(d5c13,'345','G40','G41') or
    any(d6c13,'345','G40','G41')) epilepsy = 1.

* Create a marker for asthma ICD codes: 493; J45, J46.
compute asthma = 0.
if (any(d1c13,'493','J45','J46') or
    any(d2c13,'493','J45','J46') or
    any(d3c13,'493','J45','J46') or
    any(d4c13,'493','J45','J46') or
    any(d5c13,'493','J45','J46') or
    any(d6c13,'493','J45','J46')) asthma = 1.

* Create a marker for atrial fibrillation ICD codes: 427.3; I48 .
compute atrialfib = 0.
if ((d1c14 eq '4273') or (d1c13 eq 'I48') or
    (d2c14 eq '4273') or (d2c13 eq 'I48') or
    (d3c14 eq '4273') or (d3c13 eq 'I48') or
    (d4c14 eq '4273') or (d4c13 eq 'I48') or 
    (d5c14 eq '4273') or (d5c13 eq 'I48') or
    (d6c14 eq '4273') or (d6c13 eq 'I48')) atrialfib = 1.

* Create a marker for alzheimers ICD codes: 331.0; G30 .
compute alzheimers = 0.
if ((d1c14 eq '3310') or (d1c13 eq 'G30') or
    (d2c14 eq '3310') or (d2c13 eq 'G30') or 
    (d3c14 eq '3310') or (d3c13 eq 'G30') or
    (d4c14 eq '3310') or (d4c13 eq 'G30') or 
    (d5c14 eq '3310') or (d5c13 eq 'G30') or
    (d6c14 eq '3310') or (d6c13 eq 'G30')) alzheimers = 1.

* Create a marker for multiple sclerosis ICD codes: 340; G35 .
compute ms = 0.
if (any(d1c13,'340','G35') or
    any(d2c13,'340','G35') or
    any(d3c13,'340','G35') or
    any(d4c13,'340','G35') or
    any(d5c13,'340','G35') or
    any(d6c13,'340','G35')) ms = 1.

* Create a marker for cancer ICD codes: ICD9 to be added; ICD10 .
compute cancer = 0.
if ((d1c13 ge '140' and d1c13 le '208') or (d1c13 ge 'C00' and d1c13 le'C97') or
    (d2c13 ge '140' and d2c13 le '208') or (d2c13 ge 'C00' and d2c13 le'C97') or
    (d3c13 ge '140' and d3c13 le '208') or (d3c13 ge 'C00' and d3c13 le'C97') or
    (d4c13 ge '140' and d4c13 le '208') or (d4c13 ge 'C00' and d4c13 le'C97') or
    (d5c13 ge '140' and d5c13 le '208') or (d5c13 ge 'C00' and d5c13 le'C97') or 
    (d6c13 ge '140' and d6c13 le '208') or (d6c13 ge 'C00' and d6c13 le'C97')) cancer = 1.

* Create a marker for arthritis/artherosis ICD codes: ICD9 to be added; M05-M19, M45, M47, M46.0/.1/.2/.4/.8/.9 .
compute arth = 0.
if (any(d1c13,'714','274','715','716','720','721','984') or (any(d1c14,'7128','7129','7192','7193')) or
       (d1c13 ge 'M05' and d1c13 le 'M19') or (d1c13 eq 'M45') or (d1c13 eq 'M47') or
       (any(d1c14,'M460','M461','M462','M464','M468','M469')) or
    any(d2c13,'714','274','715','716','720','721','984') or (any(d2c14,'7128','7129','7192','7193')) or
       (d2c13 ge 'M05' and d2c13 le 'M19') or (d2c13 eq 'M45') or (d2c13 eq 'M47') or
       (any(d2c14,'M460','M461','M462','M464','M468','M469')) or
    any(d3c13,'714','274','715','716','720','721','984') or (any(d3c14,'7128','7129','7192','7193')) or
       (d3c13 ge 'M05' and d3c13 le 'M19') or (d3c13 eq 'M45') or (d3c13 eq 'M47') or
       (any(d3c14,'M460','M461','M462','M464','M468','M469')) or
    any(d4c13,'714','274','715','716','720','721','984') or (any(d4c14,'7128','7129','7192','7193')) or
       (d4c13 ge 'M05' and d4c13 le 'M19') or (d4c13 eq 'M45') or (d4c13 eq 'M47') or
       (any(d4c14,'M460','M461','M462','M464','M468','M469')) or
    any(d5c13,'714','274','715','716','720','721','984') or (any(d5c14,'7128','7129','7192','7193')) or
       (d5c13 ge 'M05' and d5c13 le 'M19') or (d5c13 eq 'M45') or (d5c13 eq 'M47') or
       (any(d5c14,'M460','M461','M462','M464','M468','M469')) or
    any(d6c13,'714','274','715','716','720','721','984') or (any(d6c14,'7128','7129','7192','7193')) or
       (d6c13 ge 'M05' and d6c13 le 'M19') or (d6c13 eq 'M45') or (d6c13 eq 'M47') or
       (any(d6c14,'M460','M461','M462','M464','M468','M469'))) arth = 1.

* Create a marker for Parkinsons ICD codes: 332, 333.0; G20-G22.
compute parkinsons = 0.
if ((d1c13 eq '332') or (d1c14 eq '3330') or (d1c13 ge 'G20' and d1c13 le 'G22') or
    (d2c13 eq '332') or (d2c14 eq '3330') or (d2c13 ge 'G20' and d2c13 le 'G22') or
    (d3c13 eq '332') or (d3c14 eq '3330') or (d3c13 ge 'G20' and d3c13 le 'G22') or
    (d4c13 eq '332') or (d4c14 eq '3330') or (d4c13 ge 'G20' and d4c13 le 'G22') or
    (d5c13 eq '332') or (d5c14 eq '3330') or (d5c13 ge 'G20' and d5c13 le 'G22') or
    (d6c13 eq '332') or (d6c14 eq '3330') or (d6c13 ge 'G20' and d6c13 le 'G22')) parkinsons = 1.


* Create a marker for Chronic Liver Disease ICD codes: ICD9 to be added; ICD10 .
compute liver = 0.
if (any(d1c13,'571','K70','K72','K73','K74','K76') or any(d1c14,'K711','K713','K714','K717','K754') or
    any(d2c13,'571','K70','K72','K73','K74','K76') or any(d2c14,'K711','K713','K714','K717','K754') or
    any(d3c13,'571','K70','K72','K73','K74','K76') or any(d3c14,'K711','K713','K714','K717','K754') or
    any(d4c13,'571','K70','K72','K73','K74','K76') or any(d4c14,'K711','K713','K714','K717','K754') or
    any(d5c13,'571','K70','K72','K73','K74','K76') or any(d5c14,'K711','K713','K714','K717','K754') or 
    any(d6c13,'571','K70','K72','K73','K74','K76') or any(d6c14,'K711','K713','K714','K717','K754')) liver = 1.
execute.


frequency variables = chd copd cvd dementia diabetes hefailure refailure.
frequency varaibles = epilepsy asthma atrialfib alzheimers ms cancer arth parkinsons liver.

* Create files for each LTC considered and select only those records where there is a upi present.

* Create CVD incidence cases file for all with a UPI.
temporary.
select if cvd = 1.
select if upi ne''.
aggregate outfile = !DataFiles + 'cvd_hosp.sav'
 /break upi
 /date_adm_cvd = first(date_adm).
execute.

* Create COPD incidence cases file for all with a UPI.
temporary.
select if copd = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'copd_hosp.sav'
 /break upi
 /date_adm_copd = first(date_adm).
execute.

* Create Dementia incidence cases file for all with a UPI.
temporary.
select if dementia = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'dementia_hosp.sav'
 /break upi
 /date_adm_dementia = first(date_adm).
execute.

* Create Diabetes incidence cases file for all with a UPI.
temporary.
select if diabetes = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'diabetes_hosp.sav'
 /break upi
 /date_adm_diabetes = first(date_adm).
execute.

* Create Heart Disease (CHD) incidence cases file for all with a UPI.
temporary.
select if chd = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'chd_hosp.sav'
 /break upi
 /date_adm_chd = first(date_adm).
execute.

* Create Heart failure incidence cases file for all with a UPI.
temporary.
select if hefailure = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'hefailure_hosp.sav'
 /break upi
 /date_adm_hefailure = first(date_adm).
execute.

* Create Renal failure incidence cases file for all with a UPI.
temporary.
select if refailure = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'refailure_hosp.sav'
 /break upi
 /date_adm_refailure = first(date_adm).
execute.

* Create Epilepsy incidence cases file for all with a UPI.
temporary.
select if epilepsy = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'epilepsy_hosp.sav'
 /break upi
 /date_adm_epilepsy = first(date_adm).
execute.

* Create Asthma incidence cases file for all with a UPI.
temporary.
select if asthma = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'asthma_hosp.sav'
 /break upi
 /date_adm_asthma = first(date_adm).
execute.

* Create Atrial fibrillation incidence cases file for all with a UPI.
temporary.
select if atrialfib = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'atrialfib_hosp.sav'
 /break upi
 /date_adm_atrialfib = first(date_adm).
execute.

* Create Alzheimers incidence cases file for all with a UPI.
temporary.
select if alzheimers = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'alzheimers_hosp.sav'
 /break upi
 /date_adm_alzheimers = first(date_adm).
execute.

* Create Multiple sclerosis incidence cases file for all with a UPI.
temporary.
select if ms = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'ms_hosp.sav'
 /break upi
 /date_adm_ms = first(date_adm).
execute.

* Create Cancer incidence cases file for all with a UPI.
temporary.
select if cancer = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'cancer_hosp.sav'
 /break upi
 /date_adm_cancer = first(date_adm).
execute.

* Create Arthritis/Artherosis incidence cases file for all with a UPI.
temporary.
select if arth = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'arth_hosp.sav'
 /break upi
 /date_adm_arth = first(date_adm).
execute.

* Create Parkinsons incidence cases file for all with a UPI.
temporary.
select if parkinsons = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'parkinsons_hosp.sav'
 /break upi
 /date_adm_parkinsons = first(date_adm).
execute.


* Create Chronic Liver Disease incidence cases file for all with a UPI.
temporary.
select if liver = 1.
select if upi ne ''.
aggregate outfile = !DataFiles + 'liver_hosp.sav'
 /break upi
 /date_adm_liver = first(date_adm).
execute.

***********************************************************************.

* Sort files in to financial year files. 
* CVD.
get file = !DataFiles + 'cvd_hosp.sav'.

if (date_adm_cvd le '20110331') year_1011 = 1.
if (date_adm_cvd le '20120331') year_1112 = 1.
if (date_adm_cvd le '20130331') year_1213 = 1.
if (date_adm_cvd le '20140331') year_1314 = 1.
if (date_adm_cvd le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'cvd1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'cvd1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'cvd1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'cvd1314_hosp.sav'.

* COPD.
get file = !DataFiles + 'copd_hosp.sav'.

if (date_adm_copd le '20110331') year_1011 = 1.
if (date_adm_copd le '20120331') year_1112 = 1.
if (date_adm_copd le '20130331') year_1213 = 1.
if (date_adm_copd le '20140331') year_1314 = 1.
if (date_adm_copd le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'copd1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'copd1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'copd1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'copd1314_hosp.sav'.

* Dementia.
get file = !DataFiles + 'dementia_hosp.sav'.

if (date_adm_dementia le '20110331') year_1011 = 1.
if (date_adm_dementia le '20120331') year_1112 = 1.
if (date_adm_dementia le '20130331') year_1213 = 1.
if (date_adm_dementia le '20140331') year_1314 = 1.
if (date_adm_dementia le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'dementia1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'dementia1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'dementia1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'dementia1314_hosp.sav'.

* Diabetes.
get file = !DataFiles + 'diabetes_hosp.sav'.

if (date_adm_diabetes le '20110331') year_1011 = 1.
if (date_adm_diabetes le '20120331') year_1112 = 1.
if (date_adm_diabetes le '20130331') year_1213 = 1.
if (date_adm_diabetes le '20140331') year_1314 = 1.
if (date_adm_diabetes le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'diabetes1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'diabetes1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'diabetes1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'diabetes1314_hosp.sav'.


* CHD.
get file = !DataFiles + 'chd_hosp.sav'.

if (date_adm_chd le '20110331') year_1011 = 1.
if (date_adm_chd le '20120331') year_1112 = 1.
if (date_adm_chd le '20130331') year_1213 = 1.
if (date_adm_chd le '20140331') year_1314 = 1.
if (date_adm_chd le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'chd1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'chd1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'chd1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'chd1314_hosp.sav'.

* Heart Failure.
get file = !DataFiles + 'hefailure_hosp.sav'.

if (date_adm_hefailure le '20110331') year_1011 = 1.
if (date_adm_hefailure le '20120331') year_1112 = 1.
if (date_adm_hefailure le '20130331') year_1213 = 1.
if (date_adm_hefailure le '20140331') year_1314 = 1.
if (date_adm_hefailure le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'hefailure1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'hefailure1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'hefailure1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'hefailure1314_hosp.sav'.


* Renal Failure.
get file = !DataFiles + 'refailure_hosp.sav'.

if (date_adm_refailure le '20110331') year_1011 = 1.
if (date_adm_refailure le '20120331') year_1112 = 1.
if (date_adm_refailure le '20130331') year_1213 = 1.
if (date_adm_refailure le '20140331') year_1314 = 1.
if (date_adm_refailure le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'refailure1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'refailure1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'refailure1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'refailure1314_hosp.sav'.


* Epilepsy. 
get file = !DataFiles + 'epilepsy_hosp.sav'.

if (date_adm_epilepsy le '20110331') year_1011 = 1.
if (date_adm_epilepsy le '20120331') year_1112 = 1.
if (date_adm_epilepsy le '20130331') year_1213 = 1.
if (date_adm_epilepsy le '20140331') year_1314 = 1.
if (date_adm_epilepsy le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'epilepsy1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'epilepsy1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'epilepsy1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'epilepsy1314_hosp.sav'.

* Asthma.
get file = !DataFiles + 'asthma_hosp.sav'.

if (date_adm_asthma le '20110331') year_1011 = 1.
if (date_adm_asthma le '20120331') year_1112 = 1.
if (date_adm_asthma le '20130331') year_1213 = 1.
if (date_adm_asthma le '20140331') year_1314 = 1.
if (date_adm_asthma le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'asthma1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'asthma1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'asthma1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'asthma1314_hosp.sav'.

* Atrial fibrillation.
get file = !DataFiles + 'atrialfib_hosp.sav'.

if (date_adm_atrialfib le '20110331') year_1011 = 1.
if (date_adm_atrialfib le '20120331') year_1112 = 1.
if (date_adm_atrialfib le '20130331') year_1213 = 1.
if (date_adm_atrialfib le '20140331') year_1314 = 1.
if (date_adm_atrialfib le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'atrialfib1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'atrialfib1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'atrialfib1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'atrialfib1314_hosp.sav'.

* Alzheimers.
get file = !DataFiles + 'alzheimers_hosp.sav'.

if (date_adm_alzheimers le '20110331') year_1011 = 1.
if (date_adm_alzheimers le '20120331') year_1112 = 1.
if (date_adm_alzheimers le '20130331') year_1213 = 1.
if (date_adm_alzheimers le '20140331') year_1314 = 1.
if (date_adm_alzheimers le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'alzheimers1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'alzheimers1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'alzheimers1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'alzheimers1314_hosp.sav'.

* Multiple sclerosis.
get file = !DataFiles + 'ms_hosp.sav'.

if (date_adm_ms le '20110331') year_1011 = 1.
if (date_adm_ms le '20120331') year_1112 = 1.
if (date_adm_ms le '20130331') year_1213 = 1.
if (date_adm_ms le '20140331') year_1314 = 1.
if (date_adm_ms le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'ms1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'ms1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'ms1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'ms1314_hosp.sav'.

* Cancer.
get file = !DataFiles + 'cancer_hosp.sav'.

if (date_adm_cancer le '20110331') year_1011 = 1.
if (date_adm_cancer le '20120331') year_1112 = 1.
if (date_adm_cancer le '20130331') year_1213 = 1.
if (date_adm_cancer le '20140331') year_1314 = 1.
if (date_adm_cancer le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'cancer1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'cancer1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'cancer1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'cancer1314_hosp.sav'.

* Arthritis/Artherosis.  
get file = !DataFiles + 'arth_hosp.sav'.

if (date_adm_arth le '20110331') year_1011 = 1.
if (date_adm_arth le '20120331') year_1112 = 1.
if (date_adm_arth le '20130331') year_1213 = 1.
if (date_adm_arth le '20140331') year_1314 = 1.
if (date_adm_arth le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'arth1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'arth1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'arth1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'arth1314_hosp.sav'.

* Parkinsons.
get file = !DataFiles + 'parkinsons_hosp.sav'.

if (date_adm_parkinsons le '20110331') year_1011 = 1.
if (date_adm_parkinsons le '20120331') year_1112 = 1.
if (date_adm_parkinsons le '20130331') year_1213 = 1.
if (date_adm_parkinsons le '20140331') year_1314 = 1.
if (date_adm_parkinsons le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'parkinsons1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'parkinsons1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'parkinsons1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'parkinsons1314_hosp.sav'.

* Chronic liver disease.
get file = !DataFiles + 'liver_hosp.sav'.

if (date_adm_liver le '20110331') year_1011 = 1.
if (date_adm_liver le '20120331') year_1112 = 1.
if (date_adm_liver le '20130331') year_1213 = 1.
if (date_adm_liver le '20140331') year_1314 = 1.
if (date_adm_liver le '20150331') year_1415 = 1.
frequency variables = year_1011 year_1112 year_1213 year_1314 year_1415.

recode year_1011 year_1112 year_1213 year_1314 year_1415 (sysmis = 0).
execute.

temporary.
select if (year_1011 eq 1).
save outfile = !DataFiles + 'liver1011_hosp.sav'.

temporary.
select if (year_1112 eq 1).
save outfile = !DataFiles + 'liver1112_hosp.sav'.

temporary.
select if (year_1213 eq 1).
save outfile = !DataFiles + 'liver1213_hosp.sav'.

temporary.
select if (year_1314 eq 1).
save outfile = !DataFiles + 'liver1314_hosp.sav'.