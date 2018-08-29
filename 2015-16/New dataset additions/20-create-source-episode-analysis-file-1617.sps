* Modified version for adding DN, GP OOHs and Care Homes data.

****************************************************************************************************.
************************************* SETUP - EDIT THIS ****************************************.
*Define Financial year for filenames of output files.
define !FY()
   '1516'
!enddefine.

define !FYage()
   20150930
!enddefine.

*define path to save output.
define !file()
   '/conf/sourcedev/James/Temp/'
!enddefine.

* define path to LTC file'.
define !LTCFile()
   '/conf/sourcedev/James/Temp/' + 'LTCs_patient_reference_file.zsav'
!enddefine.

* Death flag files - 'home'.
define !DeathsFile()
   '/conf/sourcedev/James/Temp/' + 'Deceased_patient_reference_file.zsav'.
!enddefine.

* define path to source linkage files on hscdiip.
define !source()
   '/conf/hscdiip/01-Source-linkage-files/'
!enddefine.

*******************************************END of setup******************************************************.
******************************************* PART ONE ****************************************************.
* Get current source linkage file.
get file = !source + "source-episode-file-20" + !FY + ".sav"
   /Drop deceased derived_datedeath arth to digestive_date simd2012score to CHP2011subarea DataZone2011 to Service_Use_Cohort.

 * We're changing Location to 7 chars now.
alter type location (A7).

 * We're calling the GP practice gpprac instead of gpprac.
Rename Variables prac = gpprac.

add files file = *
   /file = "/conf/sourcedev/James/Care Homes/Care_Home_For_Source-" + !FY + ".zsav"
   /file = "/conf/sourcedev/James/GP OOH/GP-OOH-for-Source-" + !FY + ".zsav"
   /file = "/conf/hscdiip/DH-Extract/DN_for_source-20" + !FY + ".sav".

* Sort by CHI to bring all records belonging to an individual together.
sort cases by chi.

*Save the combined file.
save outfile = !file + 'temp_source-episode-file_'+ !FY + '.zsav'
   /zcompressed.

******************************************* PART TWO ******************************************************************.
get file = !file + 'temp_source-episode-file_'+ !FY + '.zsav'.
*get file = '/conf/linkage/output/deniseh/' + 'temp_source-episode-file_'+ !FY + '.sav'.

* Populate SMRType for non-acute records (note GLS is included in the acute program).
if (recid eq '02B' and any(mpat,'1','3','5','7','A')) SMRType = 'Matern-IP'.
if (recid eq '02B' and any(mpat,'2','4','6')) SMRType = 'Matern-DC'.
if (recid eq '04B') SMRType = 'Psych-IP'.
if (recid eq '00B') SMRType = 'Outpatient'.
if (recid eq 'AE2') SMRType = 'A & E'.
if (recid eq 'PIS') SMRType = 'PIS'.
if (recid eq 'NRS') SMRType = 'NRS Deaths'.
crosstabs SMRType by recid.
*CHECK RESULTS FROM FREQUENCY SMRTYPE.

* Match with LTC flags and dates of incidence (based on hospital incidence).
match files file = *
   /table = !LTCfile
   /by chi.

* Recode system missing values to 0's.
recode arth to digestive (sysmis = 0).

 * Update date for new year.
Do Repeat LTC = arth to digestive
   /LTC_Date = arth_date to digestive_date.
   Do if (LTC_date > '20160331').
      Compute LTC = 0.
      Compute LTC_Date = ''.
   End if.
End repeat.

*Match with deceased flag and date.
match files file = *
   /table = !Deathsfile
   /by chi.

*recode sysmis values to 0's.
if sysmis(deceased) deceased = 0.

*******************************************************************************************************************************************.
********************** insert code here to update deceased flag and death date using the NRS records ***********************.

*Note that the deaths file is out-of-date, therefore there are some cases where NRS record exisits with date of death, but deceased flag is 0, because this person wasn't in the deceased file.
* temporary.
* select if recid eq 'NRS'.
* frequency variables deceased.

alter type record_keydate1 (a8).
do if (recid eq 'NRS' and deceased eq 0 and CHI ne ' ').
   compute deceased = 1.
   compute derived_datedeath = record_keydate1.
end if.
alter type record_keydate1 (f8.0).

aggregate outfile=* mode addvariables overwrite=yes
   /break CHI
   /deceased=max(deceased)
   /derived_datedeath=max(derived_datedeath).

*re-order the variables so that deceased flag and derived_datedeath are in original order.
add files file=*
   /keep year to deathdiag11 deceased derived_datedeath ALL.

*update flag and date for blank CHIs.
alter type record_keydate1 (a8).
do if (chi eq ' ' and recid eq 'NRS').
   compute deceased=1.
   compute derived_datedeath = record_keydate1.
end if.

alter type record_keydate1 (f8.0).

 * Clean up any deaths which are now outside of the FY.
 * Only needed when updating older files using newer death extracts.
Do if derived_datedeath > '20170331'.
   Compute derived_datedeath = ''.
   Compute deceased = 0.
End if.   


*SAVE FILE!!!.
save outfile = !file + 'temp_source-episode-file_'+ !FY + '.zsav'
   /zcompressed.
get file = !file + 'temp_source-episode-file_'+ !FY + '.zsav'.

****************************************************************************************.
* make a deceased lookup file to match to the individual file.
add files file=*
   /by CHI
   /first=F.

select if (F eq 1) AND (CHI ne ' ').

save outfile= !file + 'deceased_update_lookup.zsav'
   /keep CHI deceased derived_datedeath
   /zcompressed.

get file = !file + 'deceased_update_lookup.zsav'.
****************************************************************************************.

************************************************ PART THREE ****************************************************************************.
* Create cost incl. DNAs, & modify cost not incl. DNAs using cattend.
get file = !file + 'temp_source-episode-file_'+ !FY + '.zsav'.


* Modify cost_total_net so that it zeros cost for in the cost_total_net column.
* The full cost will be held in the cost_total_net_incDNA column.
compute Cost_Total_Net_incDNAs = Cost_Total_Net.

* In the Cost_Total_Net column set the cost for those with attendance status (column CATTEND) 5 or 8 (CNWs and DNAs).
if (any(attendance_status, '5', '8')) Cost_Total_Net = 0.

*This version of the file has Cost_total_net updated to take account of do-not-attends (DNA), and could-not-waits (CNW).
save outfile = !file + 'temp_source-episode-file_'+ !FY + '.zsav'
   /zcompressed.

********************************************* PART FOUR ***********************************************************************************.
* Correct the postcodes that have 6 characters instead of 7.
get file = !file + 'temp_source-episode-file_'+ !FY + '.zsav'.

*D.
string pc7_2 (a7).

*D.
do if ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')).
   compute pc7_2 = concat(substr(pc7,1,2),"  ",substr(pc7,4,3)).
end if.

do if ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')).
   compute pc7 = pc7_2.
end if.


sort cases by pc7.
*Apply consistent geographies e.g. not all data marts have datazone 2011 (or clearly labelled).
match files file = *
   /table =  '/conf/irf/05-lookups/04-geography/geographies-for-PLICS-updated2016.sav'
   /by pc7.

* Match on SIMD2012.
match files file = *
   /table = '/conf/linkage/output/lookups/Unicode/Deprivation/postcode_2016_1_simd2012.sav'
   /drop OA2001 HB2006 HB2014 CA2011 HSCP2016 CHP2007
      simd2012rank simd2012_hb2006_quintile simd2012_hb2006_decile simd2012_chp2007_quintile
      simd2012_chp2007_decile simd2012_chp2011_quintile simd2012_chp2011_decile simd2012_chp2011sub_quintile
      simd2012_chp2011sub_decile simd2012tp15 simd2012bt15
      simd2012_inc_rate simd2012_inc_dep_N simd2012_inc_rank simd2012_emp_rate simd2012_emp_dep_N simd2012_emp_rank
      simd2012_hlth_score simd2012_hlth_rank simd2012_educ_score simd2012_educ_rank simd2012_house_score simd2012_house_rank
      simd2012_access_score simd2012_access_rank simd2012_crime_score simd2012_crime_rank
   /by pc7.

*  KEEP THESE.
* DataZone2001 CHP2011 CHP2011subarea CHP2012.

* another save as issues exist with temp space, July 2016.
save outfile = '/conf/sourcedev/temp_source-episode-file_'+ !FY + '.zsav'
   /Drop pc7_2
   /zcompressed.

******************************************* PART FIVE *************************************************************************.
get file = '/conf/sourcedev/temp_source-episode-file_'+ !FY + '.zsav'.

rename variables (simd2012_sc_quintile simd2012_sc_decile simd2012_hb2014_quintile simd2012_hb2014_decile
   = scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile).

delete variables chp datazone.
rename variables (CHP_2012 DataZone2011 = chp datazone).

variable labels
   year 'Year'
   recid 'Record Identifier'
   record_keydate1 'Record Keydate 1'
   record_keydate2 'Record Keydate 2'
   SMRType 'Record type'
   chi 'Community Health Index number'
   gender 'Gender'
   dob 'Date of Birth'
   gpprac 'GP Practice code'
   hbpraccode 'NHS Board of GP Practice'
   pc7 '7 character postcode'
   hbrescode 'NHS Board of Residence'
   lca 'Local Council Area'
   chp 'Community Health Partnership 2012'
   datazone 'Datazone 2011'
   hbtreatcode 'NHS Board of Treatment'
   location 'Location code'
   yearstay 'Stay within year '
   stay 'Length of Stay'
   ipdc 'Inpatient/Day case marker'
   spec 'Specialty '
   sigfac 'Significant Facility'
   conc 'Consultant Code'
   mpat 'Management of Patient'
   cat 'Patient Category'
   tadm 'Type of Admission'
   adtf 'Admitted/Transferred from'
   admloc 'Admitted/Transferred from location'
   oldtadm 'Old Type of Admission'
   disch 'Discharge Type'
   dischto 'Discharged To'
   dischloc 'Discharged To Location'
   diag1 'Main condition'
   diag2 'Co-morbidity/other condition 1'
   diag3 'Co-morbidity/other condition 2'
   diag4 'Co-morbidity/other condition 3'
   diag5 'Co-morbidity/other condition 4'
   diag6 'Co-morbidity/other condition 5'
   op1a 'Main operation code (A part)'
   op1b 'Main operation code (B part)'
   dateop1 'Date of Main Operation'
   op2a 'Other operation 1 (A Part)'
   op2b 'Other operation 1 (B Part)'
   dateop2 'Date of Other operation 1'
   op3a 'Other operation 2 (A Part)'
   op3b 'Other operation 2 (B Part)'
   dateop3 'Date of Other operation 2'
   op4a 'Other operation 3 (A Part)'
   op4b 'Other operation 3 (B Part)'
   dateop4 'Date of Other operation 3'
   smr01_cis 'CIS marker from SMR01 record'
   discondition 'Condition on Discharge'
   stadm 'Status on Admission'
   adcon1 'Admission Condition 1'
   adcon2 'Admission Condition 2'
   adcon3 'Admission Condition 3'
   adcon4 'Admission Condition 4'
   reftype 'Referral Type'
   refsource 'Referral Source (00B)'
   attendance_status 'Attendance Status'
   clinic_type 'Clinic Type'
   ae_arrivaltime 'Arrival Time'
   ae_arrivalmode 'Arrival Mode'
   ae_refsource 'Referral Source (AE2)'
   ae_attendcat 'Attendance Category'
   ae_disdest 'Discharge Destination'
   ae_patflow 'Patient Flow'
   ae_placeinc 'Place Incident Occurred'
   ae_reasonwait 'Reason for Wait'
   ae_bodyloc 'Bodily Location'
   ae_alcohol 'Alcohol Involved'
   no_dispensed_items 'Number of dispensed items'
   death_location_code 'Death location'
   death_board_occurrence 'NHS Board of Occurrence of death'
   place_death_occurred 'Place death occurred'
   deathdiag1 'Main cause of death'
   deathdiag2 'Secondary Cause 0'
   deathdiag3 'Secondary Cause 1'
   deathdiag4 'Secondary Cause 2'
   deathdiag5 'Secondary Cause 3'
   deathdiag6 'Secondary Cause 4'
   deathdiag7 'Secondary Cause 5'
   deathdiag8 'Secondary Cause 6'
   deathdiag9 'Secondary Cause 7'
   deathdiag10 'Secondary Cause 8'
   deathdiag11 'Secondary Cause 9'
   age 'Age of patient at midpoint of financial year'
   cost_total_net 'Total Net Cost excluding Outpatient DNA costs'
   Cost_Total_Net_incDNAs 'Total Net Cost including Outpatient DNAs costs'
   nhshosp 'NHS Hospital flag'
   cvd 'CVD LTC marker'
   copd 'COPD LTC marker'
   dementia 'Dementia LTC marker'
   diabetes 'Diabetes LTC marker'
   chd 'CHD LTC marker'
   hefailure 'Heart Failure LTC marker'
   refailure 'Renal Failure LTC marker'
   epilepsy 'Epilepsy LTC marker'
   asthma 'Asthma LTC marker'
   atrialfib 'Atrial Fibrilliation LTC marker'
   cancer 'Cancer LTC marker'
   arth 'Arthritis Artherosis LTC marker'
   parkinsons 'Parkinsons LTC marker'
   liver 'Chronic Liver Disease LTC marker'
   ms 'Multiple Sclerosis LTC marker'
   congen 'Congenital Problems LTC marker'
   bloodbfo 'Diseases of Blood and Blood Forming Organs LTC marker'
   endomet 'Other Endocrine Metabolic Diseases LTC marker'
   digestive 'Other Diseases of Digestive System LTC marker'
   arth_date 'Arthritis Artherosis LTC incidence date'
   asthma_date 'Asthma LTC incidence date'
   atrialfib_date 'Atrial Fibrilliation LTC incidence date'
   cancer_date 'Cancer LTC incidence date'
   cvd_date 'CVD LTC incidence date'
   liver_date 'Chronic Liver Disease LTC incidence date'
   copd_date 'COPD LTC incidence date'
   dementia_date 'Dementia LTC incidence date'
   diabetes_date 'Diabetes LTC incidence date'
   epilepsy_date 'Epilepsy LTC incidence date'
   chd_date 'CHD LTC incidence date'
   hefailure_date 'Heart failure LTC incidence date'
   ms_date 'Multiple Sclerosis LTC incidence date'
   parkinsons_date 'Parkinsons LTC incidence date'
   refailure_date 'Renal failure LTC incidence date'
   congen_date 'Congenital Problems LTC incidence date'
   bloodbfo_date 'Diseases of Blood and Blood Forming Organs LTC incidence date'
   endomet_date 'Other Endocrine Metabolic Diseases LTC incidence date'
   digestive_date 'Other Diseases of Digestive System LTC incidence date'
   april_beddays 'Number of Bed days from episode in April'
   may_beddays 'Number of Bed days from episode in May'
   june_beddays 'Number of Bed days from episode in June'
   july_beddays 'Number of Bed days from episode in July'
   august_beddays 'Number of Bed days from episode in August'
   sept_beddays 'Number of Bed days from episode in September'
   oct_beddays 'Number of Bed days from episode in October'
   nov_beddays 'Number of Bed days from episode in November'
   dec_beddays 'Number of Bed days from episode in December'
   jan_beddays 'Number of Bed days from episode in January'
   feb_beddays 'Number of Bed days from episode in February'
   mar_beddays 'Number of Bed days from episode in March'
   april_cost 'Cost from episode in April'
   may_cost 'Cost from episode in May'
   june_cost 'Cost from episode in June'
   july_cost 'Cost from episode in July'
   august_cost 'Cost from episode in August'
   sept_cost 'Cost from episode in September'
   oct_cost 'Cost from episode in October'
   nov_cost 'Cost from episode in November'
   dec_cost 'Cost from episode in December'
   jan_cost 'Cost from episode in January'
   feb_cost 'Cost from episode in February'
   mar_cost 'Cost from episode in March'
   uri 'Unique record identifer'
   cis_marker 'CIJ marker'
   newcis_admtype 'CIJ admission type'
   newcis_ipdc 'CIJ inpatient day case identifier'
   newpattype_ciscode 'CIJ patient type code'
   newpattype_cis 'CIJ patient type'
   CIJadm_spec 'Specialty on first record in CIJ'
   CIJdis_spec 'Specialty on last record in CIJ'
   alcohol_adm 'Indicates alcohol related admission or attendance'
   submis_adm 'Indicates substance misuse related admission or attendance'
   falls_adm 'Indicates fall related admission or attendance'
   selfharm_adm 'Indicates fall related admission or attendance'
   commhosp 'Community Hospital flag'
   post_mortem 'Post Mortem Indicator'
   deceased 'Deceased flag'
   derived_datedeath 'Derived Date of Death'
   simd2012score 'SIMD 2012 score'
   scsimd2012quintile 'Scottish SIMD 2012 quintile'
   scsimd2012decile 'Scottish SIMD 2012 decile'
   hbsimd2012quintile 'NHS Board SIMD 2012 quintile'
   hbsimd2012decile 'NHS Board SIMD 2012 decile'
   simd2012_ca_quintile  'Local Council Area SIMD 2012 quintile'
   simd2012_ca_decile 'Local Council Area SIMD 2012 decile'
   simd2012_hscp_quintile 'HSCP SIMD 2012 quintile'
   simd2012_hscp_decile 'HSCP SIMD 2012 decile'
   simd2012_chp2012_quintile 'CHP SIMD 2012 quintile'
   simd2012_chp2012_decile  'CHP SIMD 2012 decile'
   SplitChar 'Split character for postcode added by NRS'
   Split_Indicator 'Postcode split indicator'.

* some final changes.
 * if (recid eq 'NRS') uri = UniqueRecordIdentifier. /* Not needed this time (should this be done in the NRS file processing?).
if (newpattype_cis eq 'Non-elective') newpattype_cis = 'Non-Elective'.

alter type gpprac (a6) oldtadm (f1.0) smr01_cis (a5) discondition (a1) stadm  (f1.0)
   reftype (a1) clinic_type (a1) place_death_occurred (f1.0) uri (f8.0).

* PIS records don't have age yet - create this for these records - MODIFY FY DATE BELOW!.
do if (recid eq 'PIS').
   compute age = trunc((!FYage - dob)/10000).
end if.

if sysmis(dob) age = 999.

*compute age from midpoint of FY if missing.
*1. compute age variable.
do if sysmis(age) and dob gt 1.
   compute age = trunc((!FYage - dob)/10000).
end if.


********************** newly added code here!!! *******************************.
****if any gender codes are missing or 0 recode to CHI gender
string CHI_gender (F1.0).
If chi NE '' CHI_gender = Number(char.SUBSTR(chi, 9, 1), F1.0).


do if sysmis(gender) OR gender = 0.
   do if any (CHI_gender, 1, 3, 5, 7, 9).
      compute gender = 1.
   else if any (CHI_gender, 0, 2, 4, 6, 8).
      compute gender = 2.
   end if.
end if.
execute.

delete variables CHI_gender.


 * Reorder and keep vars.
 * New vars;
 * GPOOH - KIS_accessed ConsultationStartTime ConsultationEndTime ooh_outcome.1 ooh_outcome.2 ooh_outcome.3 ooh_outcome.4 ooh_CC 
 * Care Homes - sc_send_lca ch_name ch_lca ch_admreas
 * DN - CCM TotalnoDNcontacts TotalDurationofContacts


save outfile = '/conf/sourcedev/source-episode-file_20'+ !FY + '.zsav'
   /keep year recid record_keydate1 record_keydate2 SMRType chi gender dob gpprac hbpraccode
      pc7 hbrescode lca chp datazone hbtreatcode location
      yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc
      diag1 diag2 diag3 diag4 diag5 diag6 op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4
      smr01_cis
      discondition
      stadm adcon1 adcon2 adcon3 adcon4
      reftype refsource attendance_status clinic_type
      ae_arrivaltime ae_arrivalmode ae_refsource ae_attendcat ae_disdest ae_patflow ae_placeinc ae_reasonwait
      ae_bodyloc ae_alcohol
      no_dispensed_items
      death_location_code death_board_occurrence place_death_occurred post_mortem
      deathdiag1 deathdiag2 deathdiag3 deathdiag4 deathdiag5 deathdiag6 deathdiag7 deathdiag8
      deathdiag9 deathdiag10 deathdiag11
      deceased derived_datedeath
      age
      KIS_accessed ConsultationStartTime ConsultationEndTime ooh_outcome.1 ooh_outcome.2 ooh_outcome.3 ooh_outcome.4 ooh_CC
      CCM TotalnoDNcontacts TotalDurationofContacts
      sc_send_lca ch_name ch_lca ch_admreas
      Cost_Total_Net Cost_Total_Net_incDNAs nhshosp commhosp
      cis_marker newcis_admtype newcis_ipdc newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec
      arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd
      hefailure ms parkinsons refailure congen bloodbfo endomet digestive
      arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date
      diabetes_date epilepsy_date chd_date hefailure_date ms_date parkinsons_date refailure_date
      congen_date bloodbfo_date endomet_date digestive_date
      alcohol_adm submis_adm falls_adm selfharm_adm
      april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays
      oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
      april_cost may_cost june_cost july_cost august_cost sept_cost
      oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
      simd2012score scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile
      simd2012_ca_quintile simd2012_ca_decile simd2012_hscp_quintile simd2012_hscp_decile
      simd2012_chp2012_quintile simd2012_chp2012_decile SplitChar Split_Indicator
      dataZone2001 chp2011 chp2011subarea
      uri
   /zcompressed.


*********************************************************** End of original code**************************************************************.

************************************************************************************************************************************************.

********************************************************** Start of Updates ******************************************************************.


********************************************EXTRA CODE TO ADD DATES************************************************.
*get file = !file + 'source-episode-file-20'+ !FY + '.sav'.

get file = '/conf/sourcedev/source-episode-file_20'+ !FY + '.zsav'.

*Add extra variables for dates.
compute keydate1_dateformat = record_keydate1.
compute keydate2_dateformat = record_keydate2.

*rearrange variables for dates are together at the beginning of the dataset.
add files file=*
   /keep year to record_keydate2 keydate1_dateformat keydate2_dateformat ALL.

*convert variables to strings.
alter type keydate1_dateformat keydate2_dateformat (a8).
*compile date convert program.
insert file = '/conf/irf/11-Development team/Dev00-PLICS-files/2016-17/convert_date.sps'.
*run date convert program.
convert_date indates = keydate1_dateformat keydate2_dateformat.


********************************************************END OF EXTRA CODE TO ADD DATES*****************************.


********************************************Additional code to correct inpatient - el/non-el split - GNW ********************.
*add in correction for newpattype_cis using types of admission codes.

*apply newpattype_CIS logic to all records with a valid CHI number.
do if chi ne ' '.
   do if (recid eq '01B' OR recid eq '04B' OR recid eq 'GLS' OR recid eq '02B').
      do if newcis_admtype ge '10' AND newcis_admtype le '19' AND newcis_admtype ne '18'.
         compute newpattype_cis eq 'Elective'.
      else if (newcis_admtype ge '20' AND newcis_admtype le '22') OR (newcis_admtype ge '30' AND newcis_admtype le '39') OR
         newcis_admtype eq '18'.
         compute newpattype_cis eq 'Non-Elective'.
      else if newcis_admtype eq '42'.
         compute newpattype_cis eq 'Maternity'.
      else if (newcis_admtype eq '40' OR newcis_admtype eq '48' OR newcis_admtype eq 'Un' OR newcis_admtype eq '99').
         compute newpattype_cis eq 'Other'.
      end if.
   end if.
end if.

*RECODE CIS_IPDC.
*populate ipdc for maternity records.
if SMRType eq 'Matern-IP' ipdc eq 'I'.
if SMRType eq 'Matern-DC' ipdc eq 'D'.

temporary.
select if recid eq '01B' OR recid eq '04B' OR recid eq 'GLS' OR recid eq '02B'.
aggregate outfile=* mode=addvariables
   /break CHI cis_marker
   /new_newcis_ipdc = max(newcis_ipdc).


If new_newcis_ipdc > newcis_ipdc newcis_ipdc = new_newcis_ipdc.
exe.

delete variables new_newcis_ipdc.

sort cases by CHI record_keydate1 record_keydate2.

add files file=*
   /keep year to cis_marker newcis_ipdc ALL.


*********************************************************************match on SIMD 2016***********************************************************.
*sort on postcode.
sort cases by pc7.

match files file=*
   /table '/conf/linkage/output/gemma/CHImaster_w_HRI_SIMD16/postcode_simd2016.sav'
   /rename (health_postcode = pc7)
   /by pc7.

sort cases by CHI record_keydate1 record_keydate2.

save outfile = '/conf/sourcedev/source-episode-file-20'+ !FY + '.zsav'
   /zcompressed.

get file = '/conf/sourcedev/source-episode-file-20'+ !FY + '.zsav'.


* Housekeeping.
erase file = !file + 'acute_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'maternity_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'mental_health_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'op_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'aande_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'prescribing_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'deaths_extract_for_source-'+ !FY + '.sav'.
