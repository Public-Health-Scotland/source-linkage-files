* 2016/17 data.
* Creating an individual source linkage file with one row per client.
* The aggregated file will contain the following data sets:
* SMR00 - Outpatients
* SMR01 - Acute inpatients/day cases
* SMR02 - Maternity
* SMR04 - Mental Health
* SMR01_1E - Geriatric Long Stay
* Accident & Emergency 
* Prescribing

* Program created by Denise Hastie, October 2013. 
* Program updated by Denise Hastie, May 2015 to reflect changes made in Julie's costed files. 
* Program updated by Denise Hastie, August 2016 to make the addition of LTCs be in line with the master PLICS file for 14/15. 
*   Deceased flag will also be updated. The geogpraphy and deprivation section has also been changed to be the same as the
*   updated version of the 14/15 master plics SPSS program. 

*Modified by GNW to add HRI and SIMD2016.


*************************************************************************************************************************************************.
**************************************************************************** SETUP ********************************************************.
*define FY.
define !FY()
'1617'
!enddefine.

* input/output directory filepath.
define !file()
'/conf/hscdiip/DH-Extract/201617/'
!enddefine.

* LTC flags files - 'home'.
define !LTCFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

* Death flag files - 'home'.
define !DeathsFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/data-extracts/02-NRS-deaths/'
!enddefine.

*************************************************************** END OF SETUP ********************************************************.
*************************************************************************************************************************************************.
* For SMR01/02/04/01_1E: sum activity and costs per patient with an Elective/Non-Elective split.

* Acute (SMR01) section.
* Get episode level file.
get file = !file + 'source-episode-file-20'+!FY+'.sav'.
*frequency variables = recid smrtype.
select if (smrtype eq 'Acute-DC' or smrtype eq 'Acute-IP').
 * frequency variables = smrtype.
select if  (newpattype_cis ne 'Maternity').
frequency variables = smrtype.

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
if (substr(chi,1,2) ge '01' and substr(chi,1,2) le '31' AND chi ne ' ') valid = 1.
select if (valid eq 1).
execute.

* For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
  append this to the end of each record for each patient.
rename variables (gender = gender2).

aggregate outfile = * mode=addvariables 
 /break CHI
 /acute_dob gender acute_postcode acute_prac = last(dob gender2 pc7 prac).
execute.

*check ipdc and newpattype_cis frequency.
frequency variables ipdc newpattype_cis.

* Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
* Activity (count the episodes).
compute acute_episodes = 1.
compute acute_daycase_episodes = 0.
compute acute_inpatient_episodes = 0.
compute acute_el_inpatient_episodes = 0.
compute acute_non_el_inpatient_episodes = 0.
execute.

if (IPDC='D') acute_daycase_episodes=1.
if (IPDC='I') acute_inpatient_episodes=1.
if (newpattype_CIS ='Non-Elective' and IPDC='I') acute_non_el_inpatient_episodes=1.
if (newpattype_CIS ='Elective' and IPDC='I') acute_el_inpatient_episodes=1.
execute.

* Cost (use the Cost_Total_Net).
compute acute_cost = Cost_Total_Net.
compute acute_daycase_cost = 0.
compute acute_inpatient_cost = 0.
compute acute_el_inpatient_cost = 0.
compute acute_non_el_inpatient_cost = 0.
execute.

if (IPDC='D') acute_daycase_cost = Cost_Total_Net.
if (IPDC='I') acute_inpatient_cost = Cost_Total_Net.
if (newpattype_CIS ='Elective' and IPDC='I') acute_el_inpatient_cost = Cost_Total_Net.
if (newpattype_CIS ='Non-Elective' and IPDC='I') acute_non_el_inpatient_cost = Cost_Total_Net.
execute.


*Beddays for inpatients (use the yearstay).
compute acute_inpatient_beddays = 0.
compute acute_el_inpatient_beddays = 0.
compute acute_non_el_inpatient_beddays = 0.
EXECUTE.

if (IPDC='I') acute_inpatient_beddays = yearstay.
if (newpattype_CIS ='Elective' and IPDC='I') acute_el_inpatient_beddays = yearstay.
if (newpattype_CIS ='Non-Elective' and IPDC='I') acute_non_el_inpatient_beddays = yearstay.
execute.

aggregate outfile =*
 /break chi gender acute_postcode 
 /acute_dob = last(acute_dob)
 /acute_prac = last(acute_prac)
 /acute_episodes acute_daycase_episodes acute_inpatient_episodes  
  acute_el_inpatient_episodes acute_non_el_inpatient_episodes
  acute_cost acute_daycase_cost acute_inpatient_cost  
  acute_el_inpatient_cost acute_non_el_inpatient_cost 
  acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays  = 
  sum(acute_episodes acute_daycase_episodes acute_inpatient_episodes  
  acute_el_inpatient_episodes acute_non_el_inpatient_episodes
  acute_cost acute_daycase_cost acute_inpatient_cost  
  acute_el_inpatient_cost acute_non_el_inpatient_cost 
  acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays).
execute.

save outfile  = !file + 'temp_acute_agg.sav'.

get file = !file + 'temp_acute_agg.sav'.

*************************************************************************************************************************************************.
* Maternity (SMR02) section.
* Get episode level file.
get file = !file + 'source-episode-file-20'+!FY+'.sav'.
select if (newpattype_cis eq 'Maternity').
EXECUTE.

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
if (substr(chi,1,2) ge '01' and substr(chi,1,2) le '31' AND chi ne ' ') valid = 1.
select if (valid eq 1).
execute.

* For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
  append this to the end of each record for each patient.
rename variables (gender = gender2).

aggregate outfile = * mode=addvariables 
 /break CHI
 /mat_dob gender mat_postcode mat_prac = last(dob gender2 pc7 prac).
execute.

*check for system missing values.
frequency variables ipdc newcis_ipdc.

*populate ipdc for maternity records.
if (recid eq '02B' and any(mpat,'1','3','5','7','A')) ipdc = 'I'.
if (recid eq '02B' and any(mpat,'2','4','6')) ipdc = 'D'.
EXECUTE.

*check for system missing values.
frequency variables ipdc.

* Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
* Activity (count the episodes).
compute mat_episodes = 1.
compute mat_daycase_episodes = 0.
compute mat_inpatient_episodes = 0.
execute.

if (IPDC='I') mat_inpatient_episodes=1.
if (IPDC='D') mat_daycase_episodes=1.
execute.

* Cost (use the Cost_Total_Net).
compute mat_cost = Cost_Total_Net.
compute mat_daycase_cost = 0.
compute mat_inpatient_cost = 0.
execute.

if (IPDC='D') mat_daycase_cost = Cost_Total_Net.
if (IPDC='I') mat_inpatient_cost = Cost_Total_Net.
execute.

*Beddays for inpatients (use the yearstay).
compute mat_inpatient_beddays = 0.

if (IPDC='I') mat_inpatient_beddays = yearstay.
execute.

aggregate outfile =*
 /break chi gender mat_postcode 
 /mat_dob = last(mat_dob)
 /mat_prac = last(mat_prac)
 /mat_episodes mat_daycase_episodes mat_inpatient_episodes
  mat_cost mat_daycase_cost mat_inpatient_cost  
  mat_inpatient_beddays = 
  sum(mat_episodes mat_daycase_episodes mat_inpatient_episodes
  mat_cost mat_daycase_cost mat_inpatient_cost  
  mat_inpatient_beddays).
execute.

save outfile  = !file + 'temp_mat_agg.sav'.

get file = !file + 'temp_mat_agg.sav'.

*************************************************************************************************************************************************.
* Mental Health (SMR04) section.
* Get episode level file.
get file = !file + 'source-episode-file-20'+!FY+'.sav'.
select if (recid eq '04B').
select if  (newpattype_cis ne 'Maternity').
EXECUTE.

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
if (substr(chi,1,2) ge '01' and substr(chi,1,2) le '31' AND chi ne ' ') valid = 1.
select if (valid eq 1).
execute.

* For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
  append this to the end of each record for each patient.
rename variables (gender = gender2).

aggregate outfile = * mode=addvariables 
 /break CHI
 /mentalh_dob gender mentalh_postcode mentalh_prac = last(dob gender2 pc7 prac).
execute.

*check for system missing values.
frequency variables ipdc newpattype_cis.

* Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
* Activity (count the episodes).
compute mentalh_episodes = 1.
compute mentalh_daycase_episodes = 0.
compute mentalh_inpatient_episodes = 0.
compute mentalh_el_inpatient_episodes = 0.
compute mentalh_non_el_inpatient_episodes = 0.
execute.

if (IPDC='D') mentalh_daycase_episodes=1.
if (IPDC='I') mentalh_inpatient_episodes=1.
if (newpattype_CIS ='Elective' and IPDC='I') mentalh_el_inpatient_episodes=1.
if (newpattype_CIS ='Non-Elective' and IPDC='I') mentalh_non_el_inpatient_episodes=1.
execute.

* Cost (use the Cost_Total_Net).
compute mentalh_cost = Cost_Total_Net.
compute mentalh_inpatient_cost = 0.
compute mentalh_daycase_cost = 0.
compute mentalh_el_inpatient_cost = 0.
compute mentalh_non_el_inpatient_cost = 0.
execute.

if (IPDC='D') mentalh_daycase_cost = Cost_Total_Net.
if (IPDC='I') mentalh_inpatient_cost = Cost_Total_Net.
if (newpattype_CIS ='Elective' and IPDC='I') mentalh_el_inpatient_cost = Cost_Total_Net.
if (newpattype_CIS ='Non-Elective' and IPDC='I') mentalh_non_el_inpatient_cost = Cost_Total_Net.
execute.


*Beddays for inpatients (use the yearstay).
compute mentalh_inpatient_beddays = 0.
compute mentalh_el_inpatient_beddays = 0.
compute mentalh_non_el_inpatient_beddays = 0.

if (IPDC='I') mentalh_inpatient_beddays = yearstay.
if (newpattype_CIS ='Elective' and IPDC='I') mentalh_el_inpatient_beddays = yearstay.
if (newpattype_CIS ='Non-Elective' and IPDC='I') mentalh_non_el_inpatient_beddays = yearstay.
execute.

aggregate outfile =*
 /break chi gender mentalh_postcode 
 /mentalh_dob = last(mentalh_dob)
 /mentalh_prac = last(mentalh_prac)
 /mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes  
  mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
  mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost  
  mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost 
  mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays  = 
  sum(mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes  
  mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
  mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost  
  mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost 
  mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays).
execute.

save outfile  = !file + 'temp_mentalh_agg.sav'.

get file = !file + 'temp_mentalh_agg.sav'.

*************************************************************************************************************************************************.
* Geriatric Long Stay (SMR01_1E) section.
get file = !file + 'source-episode-file-20'+!FY+'.sav'.
*frequency variables = smrtype.
select if (smrtype eq 'GLS-IP').
EXECUTE.

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
if (substr(chi,1,2) ge '01' and substr(chi,1,2) le '31' AND chi ne ' ') valid = 1.
select if (valid eq 1).
execute.

* For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
  append this to the end of each record for each patient.
rename variables (gender = gender2).

aggregate outfile = * mode=addvariables 
 /break CHI
 /gls_dob gender gls_postcode gls_prac = last(dob gender2 pc7 prac).
execute.

*check for system missing values.
frequency variables ipdc newpattype_cis.

* Create IP/DC activity, cost and bed day counts for acute el/nel inpatients and day cases.
* Activity (count the episodes).
compute gls_episodes = 1.
compute gls_daycase_episodes = 0.
compute gls_inpatient_episodes = 0.
compute gls_el_inpatient_episodes = 0.
compute gls_non_el_inpatient_episodes = 0.
execute.

if (IPDC='D') gls_daycase_episodes=1.
if (IPDC='I') gls_inpatient_episodes=1.
if (newpattype_CIS ='Non-Elective' and IPDC='I') gls_non_el_inpatient_episodes=1.
if (newpattype_CIS ='Elective' and IPDC='I') gls_el_inpatient_episodes=1.
execute.

* Cost (use the Cost_Total_Net).
compute gls_cost = Cost_Total_Net.
compute gls_daycase_cost = 0.
compute gls_inpatient_cost = 0.
compute gls_el_inpatient_cost = 0.
compute gls_non_el_inpatient_cost = 0.
execute.

if (IPDC='D') gls_daycase_cost = Cost_Total_Net.
if (IPDC='I') gls_inpatient_cost = Cost_Total_Net.
if (newpattype_CIS ='Elective' and IPDC='I') gls_el_inpatient_cost = Cost_Total_Net.
if (newpattype_CIS ='Non-Elective' and IPDC='I') gls_non_el_inpatient_cost = Cost_Total_Net.
execute.

*Beddays for inpatients (use the yearstay).
compute gls_inpatient_beddays = 0.
compute gls_el_inpatient_beddays = 0.
compute gls_non_el_inpatient_beddays = 0.

if (IPDC='I') gls_inpatient_beddays = yearstay.
if (newpattype_CIS ='Elective' and IPDC='I') gls_el_inpatient_beddays = yearstay.
if (newpattype_CIS ='Non-Elective' and IPDC='I') gls_non_el_inpatient_beddays = yearstay.
execute.

aggregate outfile =*
 /break chi gender gls_postcode 
 /gls_dob = last(gls_dob)
 /gls_prac = last(gls_prac)
 /gls_episodes gls_daycase_episodes gls_inpatient_episodes  
  gls_el_inpatient_episodes gls_non_el_inpatient_episodes
  gls_cost gls_daycase_cost gls_inpatient_cost  
  gls_el_inpatient_cost gls_non_el_inpatient_cost 
  gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays  = 
  sum(gls_episodes gls_daycase_episodes gls_inpatient_episodes  
  gls_el_inpatient_episodes gls_non_el_inpatient_episodes
  gls_cost gls_daycase_cost gls_inpatient_cost  
  gls_el_inpatient_cost gls_non_el_inpatient_cost 
  gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays).
execute.

save outfile  = !file + 'temp_gls_agg.sav'.

get file = !file + 'temp_gls_agg.sav'.

*************************************************************************************************************************************************.
* Outpatients (SMR00) section.
get file = !file + 'source-episode-file-20'+!FY+'.sav'.
select if (recid eq '00B').

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
if (substr(chi,1,2) ge '01' and substr(chi,1,2) le '31' AND chi ne ' ') valid = 1.
select if (valid eq 1).
execute.

* For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
  append this to the end of each record for each patient.
rename variables (gender = gender2).

aggregate outfile = * mode=addvariables 
 /break CHI
 /op_dob gender op_postcode op_prac = last(dob gender2 pc7 prac).
execute.

* Activity (count the attendances).
compute op_newcons_attendances = 0.
compute op_newcons_dnas = 0.

if (attendance_status eq '1') op_newcons_attendances = 1.
if (attendance_status ne '1') op_newcons_dnas = 1.
execute.

* Cost (for DNAs).
compute op_cost_dnas = 0.
if (attendance_status gt '1') op_cost_dnas = Cost_Total_Net_incDNAs.
execute.

aggregate outfile =*
 /break chi gender op_postcode 
 /op_dob = last(op_dob)
 /op_prac = last(op_prac)
 /op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas = sum(op_newcons_attendances op_newcons_dnas Cost_Total_Net Cost_Total_Net_incDNAs).
execute.

save outfile  = !file + 'temp_op_agg.sav'.

get file = !file + 'temp_op_agg.sav'.


*************************************************************************************************************************************************.
* Accident and Emergency (AE2) section (sum the number of of attendances and costs associated).
get file = !file + 'source-episode-file-20'+!FY+'.sav'.
select if (recid eq 'AE2').

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
if (substr(chi,1,2) ge '01' and substr(chi,1,2) le '31' AND chi ne ' ') valid = 1.
select if (valid eq 1).
execute.

* For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
  append this to the end of each record for each patient.
rename variables (gender = gender2).

aggregate outfile = * mode=addvariables 
 /break CHI
 /ae_dob gender ae_postcode ae_prac = last(dob gender2 pc7 prac).
execute.

* Activity (count the attendances).
compute ae_attendances = 1.
execute.

aggregate outfile =*
 /break chi gender ae_postcode 
 /ae_dob = last(ae_dob)
 /ae_prac = last(ae_prac)
 /ae_attendances ae_cost = sum(ae_attendances Cost_Total_Net).
execute.

save outfile  = !file + 'temp_ae_agg.sav'.

get file = !file + 'temp_ae_agg.sav'.

*************************************************************************************************************************************************.
* Prescribing (PIS) section.
* For Prescribing: sum the information by patient
* only one row per person exists in the master PLICs file with minimal data.

get file = !file + 'source-episode-file-20'+!FY+'.sav'.
select if (recid eq 'PIS').

* Exclude people with blank chi or an invalid chi (based on the day of the chi being incorrect).
* The valid variable will also exclude the dummy CHIs as well.
if (substr(chi,1,2) ge '01' and substr(chi,1,2) le '31' AND chi ne ' ') valid = 1.
select if (valid eq 1).
execute.

* For the fields that there will be a hierarchy taken, aggregate and take the last of each column and
  append this to the end of each record for each patient.
rename variables (gender = gender2).

aggregate outfile = * mode=addvariables 
 /break chi
 /pis_dob gender pis_postcode pis_prac = last(dob gender2 pc7 prac).
execute.

aggregate outfile =*
 /break chi gender pis_postcode 
 /pis_dob = last(pis_dob)
 /pis_prac = last(pis_prac)
 /pis_dispensed_items pis_cost = sum(no_dispensed_items Cost_Total_Net).
execute.

save outfile  = !file + 'temp_pis_agg.sav'.
get file = !file + 'temp_pis_agg.sav'.

*************************************************************************************************************************************************.
* Match all the temporary data files together. 

match files file = !file + 'temp_acute_agg.sav'
 /file = !file + 'temp_mat_agg.sav'
 /file = !file + 'temp_mentalh_agg.sav'
 /file = !file + 'temp_gls_agg.sav'
 /file = !file + 'temp_op_agg.sav'
 /file = !file + 'temp_ae_agg.sav'
 /file = !file + 'temp_pis_agg.sav'
 /by chi.
execute.


********************** newly added code here!!! *******************************.
****if any gender codes are not 1 or 2 (some were found to be miscoded to 0 or 9, recode genders to proper code from CHI.
String CHI_gender (A1).
Compute CHI_gender = SUBSTR(chi,9,1).
Alter type CHI_gender (F1.0).

Do if sysmis(gender).
   Do If any (CHI_gender, 1, 3, 5, 7, 9).
   Compute gender = 1.
   Else if any (CHI_gender, 0, 2, 4, 6, 8).
   Compute gender = 2.
End if.
End if.
Execute.

delete variables CHI_gender.
EXECUTE.



* From all the diifferent data sources that we have in the file, a hierarchy will be created for how
* Postcode, GP Practice and Date of Birth will be assigned.
* Note that due to the minimum data extract that for PIS data, GP Practice is not available.  This was 
* not included in the request for the extract so that multiple rows for patients would be avoided and 
* also because the GP Practice that is held in PIS is the GP Practice of the PRESCRIBER not the patient.  
* In most cases this will be the GP Practice of the patient but this is not always the case.

*The hierarchy has been decided based on what health service would most likely be used by patients.
* 1 - Prescribing (except for GP Practice - added in for GP Practice August 2016)
* 2 - Accident and Emergency
* 3 - Outpatients
* 4 - Acute
* 5 - Maternity
* 6 - Mental health
* 7 - Geriatric long stay.


* Date of birth hierarchy.
numeric dob (f8.0).
alter type pis_dob ae_dob acute_dob mat_dob mentalh_dob gls_dob op_dob dob (a8).
if (dob eq '') dob = pis_dob.
if (dob eq '' and ae_dob ne '') dob = ae_dob.
if (dob eq '' and op_dob ne '') dob = op_dob.
if (dob eq '' and acute_dob ne '') dob = acute_dob.
if (dob eq '' and mat_dob ne '') dob = mat_dob.
if (dob eq '' and mentalh_dob ne '') dob = mentalh_dob.
if (dob eq '' and gls_dob ne '') dob = gls_dob.
execute.


* Postcode hierarchy.
* Have updated the syntax for the recording of postcode as null had been recorded for an unknown postcode
* in the PIS extract.  These null postcodes will be set as blank and then the rest of the hierarchy will 
* be applied. DH 25 March 2014.
string postcode (a7).
do if (postcode eq '' and pis_postcode ne 'null') .
compute postcode = pis_postcode.
else if (postcode eq '' and pis_postcode eq 'null').
compute postcode = ''.
end if.
execute.
if (postcode eq '' and ae_postcode ne '') postcode = ae_postcode.
if (postcode eq '' and op_postcode ne '') postcode = op_postcode.
if (postcode eq '' and acute_postcode ne '') postcode = acute_postcode.
if (postcode eq '' and mat_postcode ne '') postcode = mat_postcode.
if (postcode eq '' and mentalh_postcode ne '') postcode = mentalh_postcode.
if (postcode eq '' and gls_postcode ne '') postcode = gls_postcode.
execute.

* GP Practice hierarchy.
* Prescribing will need to be added once updated extracts are available. DH August 2016. 
* Prescriber GP Practice now added to this heirarchy as first in the list.  DH, August 2016.
string gpprac (a5).
if (gpprac eq '' and pis_prac ne '') gpprac = pis_prac.
if (gpprac eq '' and ae_prac ne '') gpprac = ae_prac.
if (gpprac eq '' and op_prac ne '') gpprac = op_prac.
if (gpprac eq '' and acute_prac ne '') gpprac = acute_prac.
if (gpprac eq '' and mat_prac ne '') gpprac = mat_prac.
if (gpprac eq '' and mentalh_prac ne '') gpprac = mentalh_prac.
if (gpprac eq '' and gls_prac ne '') gpprac = gls_prac.
execute.

* Do a temporary save.
save outfile = !file + 'source_individual_file_20' + !FY +'.sav'. 
get file  = !file + 'source_individual_file_20' + !FY +'.sav'. 

*from here.......

* version of GP PRACTICE created (for all other CHI PLICS files without the use of GP Practice from PIS.
* Creating this to compare with the updated heirarchy above which includes PIS GP Practice of presecriber.
* DH, August 2016.
string gpprac_orig (a5).
if (gpprac_orig eq '' and ae_prac ne '') gpprac_orig = ae_prac.
if (gpprac_orig eq '' and op_prac ne '') gpprac_orig = op_prac.
if (gpprac_orig eq '' and acute_prac ne '') gpprac_orig = acute_prac.
if (gpprac_orig eq '' and mat_prac ne '') gpprac_orig = mat_prac.
if (gpprac_orig eq '' and mentalh_prac ne '') gpprac_orig = mentalh_prac.
if (gpprac_orig eq '' and gls_prac ne '') gpprac_orig = gls_prac.
execute.

* save a file with minimal variables for checking the GP practice codes.
 * temporary.
 * save outfile = !file + 'check_gppractice_methodology.sav'
 /keep chi gpprac gpprac_orig.

* Delete the record specific dob gpprac and postcode.
delete variables acute_postcode acute_dob acute_prac mat_postcode mat_dob mat_prac
                 mentalh_postcode mentalh_dob mentalh_prac gls_postcode gls_dob gls_prac
                 op_postcode op_dob op_prac ae_postcode ae_dob ae_prac pis_postcode pis_dob pis_prac.

* Recode all the system missing values to zero so that calculations will work.

recode acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
       acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost
       acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays 
       mat_episodes mat_daycase_episodes mat_inpatient_episodes 
       mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays
       mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
       mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost
       mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays
       gls_episodes gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes gls_non_el_inpatient_episodes
       gls_cost gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost
       gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays 
       op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas
       ae_attendances ae_cost
       pis_dispensed_items pis_cost (sysmis = 0).
execute.

* Create a total health cost.
compute health_net_cost = acute_cost + mat_cost + mentalh_cost + gls_cost + op_cost_attend + ae_cost + pis_cost.
compute health_net_costincDNAs = acute_cost + mat_cost + mentalh_cost + gls_cost + op_cost_dnas + ae_cost + pis_cost.
execute.


* Do a temporary save.
save outfile = !file + 'source_individual_file_20' + !FY +'.sav'. 
get file  = !file + 'source_individual_file_20' + !FY +'.sav'. 

* Geography and deprivation columns need to be matched on by postcode (to be in line with 
* the master PLICs file).

rename variables (postcode = pc7).
sort cases by pc7.

* Change length to a21 for matching on deprivation as the lookup file has been saved in locale mode.
* Note that the trailing spaces are not visible in the unicode setting - they are automatically truncated
* but to match the file on the variable type must match.

* Change the length back to a7 once the match has been carried out. 
alter type pc7 (a21).

match files file = *
 /table = '/conf/linkage/output/lookups/deprivation/postcode_2016_1_simd2012.sav'
 /drop OA2001 HB2006 HB2014 CA2011 HSCP2016 CHP2007
       simd2012rank simd2012_hb2006_quintile simd2012_hb2006_decile simd2012_chp2007_quintile
       simd2012_chp2007_decile simd2012_chp2011_quintile simd2012_chp2011_decile simd2012_chp2011sub_quintile
       simd2012_chp2011sub_decile simd2012tp15 simd2012bt15
       simd2012_inc_rate simd2012_inc_dep_N simd2012_inc_rank simd2012_emp_rate simd2012_emp_dep_N simd2012_emp_rank
       simd2012_hlth_score simd2012_hlth_rank simd2012_educ_score simd2012_educ_rank simd2012_house_score simd2012_house_rank
       simd2012_access_score simd2012_access_rank simd2012_crime_score simd2012_crime_rank 
 /by pc7.
execute.


*  KEEP THESE.
*DataZone2001 CHP2011 CHP2011subarea.

* All columns being retained from the deprivation file are all numeric, so their length is not an issue with the 
* difference in unicode settings.
alter type pc7 (a7).

match files file = *
 /table =  '/conf/irf/05-lookups/04-geography/geographies-for-PLICS-updated2016.sav'
 /by pc7.
execute.

string lca (a2).
if (CA2011 eq 'S12000005') lca = '06'.
if (CA2011 eq 'S12000006') lca = '08'.
if (CA2011 eq 'S12000008') lca = '10'.
if (CA2011 eq 'S12000010') lca = '12'.
if (CA2011 eq 'S12000011') lca = '13'.
if (CA2011 eq 'S12000013') lca = '32'.
if (CA2011 eq 'S12000014') lca = '15'.
if (CA2011 eq 'S12000015') lca = '16'.
if (CA2011 eq 'S12000017') lca = '18'.
if (CA2011 eq 'S12000018') lca = '19'.
if (CA2011 eq 'S12000019') lca = '20'.
if (CA2011 eq 'S12000020') lca = '21'.
if (CA2011 eq 'S12000021') lca = '22'.
if (CA2011 eq 'S12000023') lca = '24'.
if (CA2011 eq 'S12000024') lca = '25'.
if (CA2011 eq 'S12000026') lca = '05'.
if (CA2011 eq 'S12000027') lca = '27'.
if (CA2011 eq 'S12000028') lca = '28'.
if (CA2011 eq 'S12000029') lca = '29'.
if (CA2011 eq 'S12000030') lca = '30'.
if (CA2011 eq 'S12000033') lca = '01'.
if (CA2011 eq 'S12000034') lca = '02'.
if (CA2011 eq 'S12000035') lca = '04'.
if (CA2011 eq 'S12000036') lca = '14'.
if (CA2011 eq 'S12000038') lca = '26'.
if (CA2011 eq 'S12000039') lca = '07'.
if (CA2011 eq 'S12000040') lca = '31'.
if (CA2011 eq 'S12000041') lca = '03'.
if (CA2011 eq 'S12000042') lca = '09'.
if (CA2011 eq 'S12000044') lca = '23'.
if (CA2011 eq 'S12000045') lca = '11'.
if (CA2011 eq 'S12000046') lca = '17'.
execute.

rename variables (CHP_2012 DataZone2011 HB2014 pc7 = chp datazone hbres health_postcode).

* Create a year variable, similar to the master PLICs file - incase analysts require to add 
* together the CHI master PLICS files.

string year (a4).
compute year = !FY.
execute.

*************************************************************************************************************************************************.
* Add on a death marker and the date of death (where applicable).
* Note that date of death has been extracted by UPI for calendar year 2010 onwards.
sort cases by chi.

match files file = *
 /table = !Deathsfile + 'Deceased_patient_reference_file-modified.sav'
 /by chi.
execute.

if sysmis(deceased) deceased = 0.
execute.

rename variables (deceased = deceased_flag).

*************************************************************************************************************************************************.
* Add in LTC markers. 
*************************************************************************************************************************************************.
*sort cases by chi.

* Match on the LTC flags and the date of LTC incidence (note this is based on hospital incidence only). 

match files file = *
 /table = !LTCfile + 'LTCs_patient_reference_file.sav'
 /by chi.
execute.

* recode included - but this is really only applicable to records without a CHI number. 
recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
       hefailure ms parkinsons refailure congen bloodbfo endomet digestive (sysmis = 0).
execute.

* rename this variable to be consistent with out years files. 
rename variables (derived_datedeath = date_death).

rename variables (simd2012_sc_quintile simd2012_sc_decile simd2012_hb2014_quintile simd2012_hb2014_decile
                = scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile).


save outfile =  !file + 'source-individual-file-20' + !FY +'.sav'
 /keep year CHI gender dob health_postcode gpprac
       health_net_cost health_net_costincDNAs
       acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
       acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost
       acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays
       mat_episodes mat_daycase_episodes mat_inpatient_episodes 
       mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays 
       mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
       mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost
       mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays
       gls_episodes gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes gls_non_el_inpatient_episodes
       gls_cost gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost
       gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays
       op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas
       ae_attendances ae_cost pis_dispensed_items pis_cost
       deceased_flag date_death
       arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
       hefailure ms parkinsons refailure congen bloodbfo endomet digestive
       arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date 
       diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date 
       congen_date bloodbfo_date endomet_date digestive_date
       hbres lca datazone chp
       simd2012score scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile 
       simd2012_ca_quintile simd2012_ca_decile simd2012_hscp_quintile simd2012_hscp_decile
       simd2012_chp2012_quintile simd2012_chp2012_decile SplitChar Split_Indicator
       DataZone2001 CHP2011 CHP2011subarea
 /compressed.

get file = !file + 'source-individual-file-20' + !FY +'.sav'.




*****Run HRI program. ******************************.








save outfile = !file + 'source-individual-file-20' + !FY +'.sav'.
get file = !file + 'source-individual-file-20' + !FY +'.sav'.


*************************************************************************************************************************************************.
* Erase temporary files created throughout the program.
erase file =  !CostedFiles + 'temp_acute_agg.sav'.
erase file =  !CostedFiles + 'temp_mat_agg.sav'.
erase file =  !CostedFiles + 'temp_mentalh_agg.sav'.
erase file =  !CostedFiles + 'temp_gls_agg.sav'.
erase file =  !CostedFiles + 'temp_op_agg.sav'.
erase file =  !CostedFiles + 'temp_ae_agg.sav'.
erase file =  !CostedFiles + 'temp_pis_agg.sav'.


