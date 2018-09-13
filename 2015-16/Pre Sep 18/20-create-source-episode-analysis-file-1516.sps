* Create the master PLICS file for 2015/16.

* Program created and modified by Denise Hastie, June/July 2016.

* Minor updates made by Denise Greig (nee Hastie), October 2017.  
* Changing plics to source is the main change that has been made.  


************************************ IMPORTANT NOTE FOR 2015/16 ************************************.
* Following the completion of the costing process and other linkage projects in October 2015, the 
* process for the costed files has changed and so has the process for creating the Master and CHI
* Master PLICs analysis files.  

* One of the most significant changes is the CIJ marker.  This will appear 'odd' for this year.  Once
* a file is created from 2010/11 onwards, the CIJ marker will not look odd.  Infact, it will enhance 
* the data across the years and will make multiple year analysis using this field much more 
* practical.  

* A second signficant change is with the mental health records.  2013/14 saw a change in that we 
* removed a lot of duplicates during the costing process.  The same methodology as SPARRA has been used
* for removing duplicates.  This change is more noticeable in the CHI master PLICS file, in that there
* aren't any patients with over 365(366 when appropriate) in the mental health bed days column.

* The data used for creating the files is extracted from Business Objects as CSV files.  Other data 
* files, CSV format as well have been supplied by IT (following large data extract requests).  See
* the full standard operating procedure for details on the full process.  

* Denise Hastie, June 2016.

* Program updated by Denise Hastie, September 2016.
* September 2016 updates - added in new code that populates newpattype_cis based on the admission type for records without a
                           upi number (chi).  Note that transfers will be coded as Other. 
*                        - moved the section for creating the SMRType variable to the acute program 10c (for acute only)
                           other record types will be updated here (but need to be moved to individual programs.
*Modified by GNW on 20/9/16.

****************************************************************************************************.

* Lots of extra saves in this program - just to try and reduce updating time if temp space/network
* space (lack of) cause issues).  

* Define macro.
define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine.

* LTC flags files - 'home'.
define !LTCFile()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

* Death flag files - 'home'.
define !DeathsFile()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

* Master Source Linkage Episode File - temp 'home'.
define !mplics()
'/conf/hscdiip/DH-Extract/'
!enddefine.

*Define Financial year for filenames of output files.
define !FY()
'201516'
!enddefine.

*****************************************************END of setup*******************************************************.

* Bring all the data sets together. 
add files file = !file + 'acute_file_for_source-201516.sav'
 /file = !file + 'maternity_file_for_source-201516.sav'
 /file = !file + 'mental_health_file_for_source-201516.sav'
 /file = !file + 'op_file_for_source-201516.sav'
 /file = !file + 'aande_file_for_source-201516.sav'
 /file = !file + 'prescribing_file_for_source-201516.sav'
 /file = !file + 'deaths_extract_for_source-201516.sav'.
execute.

temporary.
select if chi eq ' '.
frequency variables newpattype_cis.

temporary.
select if recid eq '02B'.
frequency variables tadm.

* Set the type of admission for Maternity records to 42. 
do if (recid eq '02B').
compute tadm = '42'.
end if.
execute.

temporary.
select if recid eq '02B' AND chi ne ' '.
frequency variables newcis_admtype.

* Sort by CHI to bring all records belonging to an individual together.
sort cases by chi.

save outfile = !file + 'temp-source-episode-file-'+ !FY + '.sav'
 /compressed.

******************************************************************************************************************************.
********************Match on LTC flags and dates of LTC incidence (based on hospital incidence only)*****. 
get file = !file + 'temp-source-episode-file-'+ !FY + '.sav'.

match files file = *
 /table = !LTCfile + 'LTCs_patient_reference_file.sav'
 /by chi.
execute.

* recode included - but this is really only applicable to records without a CHI number. 
recode arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd 
       hefailure ms parkinsons refailure congen bloodbfo endomet digestive (sysmis = 0).
execute.

*Match on deceased flags and date. 
match files file = *
 /table = !Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.

if sysmis(deceased) deceased = 0.
execute.

* Populate SMRType for non-acute records (note GLS is included in the acute program).
if (recid eq '02B' and any(mpat,'1','3','5','7','A')) SMRType = 'Matern-IP'.
if (recid eq '02B' and any(mpat,'2','4','6')) SMRType = 'Matern-DC'.
if (recid eq '04B') SMRType = 'Psych-IP'.
if (recid eq '00B') SMRType = 'Outpatient'.
if (recid eq 'AE2') SMRType = 'A & E'.
if (recid eq 'PIS') SMRType = 'PIS'.
if (recid eq 'NRS') SMRType = 'NRS Deaths'.
frequency variables = SMRType.

*CHECK RESULTS FROM FREQUENCY SMRTYPE.

save outfile = !file + 'temp-source-episode-file-'+ !FY + '.sav'
 /compressed.

******************************************************************************************************************************.
********************Create cost incl. DNAs, & modify cost not incl. DNAs using cattend *****. 
get file = !file + 'temp-source-episode-file-'+ !FY + '.sav'.

* Modify cost_total_net so that it zeros cost for in the cost_total_net column. 
* The full cost will be held in the cost_total_net_incDNA column. 
numeric Cost_Total_Net_incDNAs (F8.2).
compute Cost_Total_Net_incDNAs = Cost_Total_Net.
execute.

* In the Cost_Total_Net column set the cost for those with attendance status (column CATTEND) 5 or 8 (CNWs and DNAs).
alter type attendance_status (a1). 
do if (any(attendance_status,'5','8')).
compute Cost_Total_Net = 0.
else.
end if.
execute.

save outfile = !file + 'temp-source-episode-file-'+ !FY + '.sav'
 /compressed.

******************************************************************************************************************************.
************** Correct the postcodes that have 6 characters instead of 7. 
get file = !file + 'temp-source-episode-file-'+ !FY + '.sav'.

*D.
string pc7_2 (a7).

*D.
do if ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')).
compute pc7_2 = concat(substr(pc7,1,2),"  ",substr(pc7,4,3)).
end if. 
execute.
do if ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')).
compute pc7 = pc7_2.
end if. 
execute.

sort cases by pc7.
*Apply consistent geographies e.g. not all data marts have datazone 2011 (or clearly labelled).
match files file = *
 /table =  '/conf/irf/05-lookups/04-geography/geographies-for-PLICS-updated2016.sav'
 /by pc7.
execute.

* Change length to a21 for matching on deprivation as the lookup file has been saved in locale mode.
* Note that the trailing spaces are not visible in the unicode setting - they are automatically truncated
* but to match the file on the variable type must match.

* Change the length to a21 for the next match, then back to a7 once the match has been carried out. 
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
*DataZone2001 CHP2011 CHP2011subarea CHP2012.

* All columns being retained from the deprivation file are all numeric, so their length is not an issue with the 
* difference in unicode settings.
alter type pc7 (a7).

* another save as issues exist with temp space, July 2016.  
save outfile = !file + 'temp-source-episode-file-'+ !FY + '.sav'
 /compressed.


********************************************************************************************************************.
get file = !file + 'temp-source-episode-file-'+ !FY + '.sav'.

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
prac 'GP Practice code'
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
refsource 'Referral Source'
attendance_status 'Attendance Status'
clinic_type 'Clinic Type'
ae_arrivaltime 'Arrival Time'
ae_arrivalmode 'Arrival Mode'
ae_refsource 'Referral Source'
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

delete variables costsfy unique_id DateofDeath99 PatDateofBirthC CHPCode GeoDatazone2011
                 DateofDeath99  PatDateOfBirthC CHPCode GeoDataZone2011.

* some final changes.  
if (recid eq 'NRS') uri = UniqueRecordIdentifier.
if (newpattype_cis eq 'Non-elective') newpattype_cis = 'Non-Elective'.
execute.

alter type prac (a6) oldtadm (f1.0) smr01_cis (a5) discondition (a1) stadm  (f1.0)
           reftype (a1) clinic_type (a1) place_death_occurred (f1.0) uri (f8.0).


* Update for age.  
do if (recid eq 'PIS').
compute age = trunc((20150930 - dob)/10000).
end if.
execute.

if sysmis(dob)age = 999.
execute.

save outfile = !file + 'source-episode-file-'+ !FY + '.sav'
 /keep year recid record_keydate1 record_keydate2 SMRType chi gender dob prac hbpraccode
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
 /compressed.


********************************************************************************************************************************.
********************************************************EXTRA CODE TO ADD DATES*****************************.
 * get file = !file + 'masterPLICS_Costed_'+ !FY + '.sav'.

get file = !file + 'source-episode-file-'+ !FY + '.sav'.

*Add extra variables for dates. 
compute keydate1_dateformat=record_keydate1.
compute keydate2_dateformat=record_keydate2.
execute.

*rearrange variables for dates are together at the beginning of the dataset.
add files file=*
 /keep year to record_keydate2 keydate1_dateformat keydate2_dateformat ALL.
execute.

*convert variables to strings.
alter type keydate1_dateformat keydate2_dateformat (a8).
*compile date convert program.
insert file='/conf/irf/11-Development team/Dev00-PLICS-files/2015-16/convert_date.sps'.
*run date convert program.
convert_date indates = keydate1_dateformat keydate2_dateformat.

save outfile= !file + 'source-episode-file-'+ !FY + '.sav'
/compressed.

********************************************************END OF EXTRA CODE TO ADD DATES*****************************.
********************************************************************************************************************************.


********************************************Additional code to correct inpatient - el/non-el split - GNW *************************************.
*add in correction for newpattype_cis using types of admission codes.
get file = !file + 'source-episode-file-' + !FY + '.sav'.


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
execute.

 * temporary.
 * select if CHI eq ' '.
 * frequency variables newpattype_cis cis_marker newcis_admtype.

 * temporary.
 * select if not(recid eq 'NRS' OR recid eq 'PIS' OR recid eq '00B' OR recid eq 'AE2') AND (CHI ne ' ').
 * frequency variables newpattype_cis cis_marker newcis_admtype.
sort cases by CHI record_keydate1 record_keydate2.

temporary.
select if not(recid eq '01B' OR recid eq '04B' OR recid eq 'GLS' OR recid eq '02B').
save outfile = !file + 'source-episode-file-' +!FY +'_NRS_PIS_AE_OP.sav'.

select if recid eq '01B' OR recid eq '04B' OR recid eq 'GLS' OR recid eq '02B'.
execute.

*RECODE BLANK CIS_MARKER - for records starting before 2009.
 * temporary.
 * select if CHI ne ' '.
 * frequency variables cis_marker.

*fill in the blanks.
sort cases by CHI record_keydate1 record_keydate2.
do if (chi ne lag(chi)) AND cis_marker eq ' ' AND chi ne ' '.
compute cis_marker='1'.
end if.
execute.

 * temporary.
 * select if CHI ne ' '.
 * frequency variables cis_marker.

 * temporary.
 * select if recid eq '02B'.
 * frequency variables ipdc.

 * frequency variables ipdc.


*RECODE CIS_IPDC.
*populate ipdc for maternity records.
if SMRType eq 'Matern-IP' ipdc eq 'I'.
if SMRType eq 'Matern-DC' ipdc eq 'D'.
execute.

 * temporary.
 * select if chi ne ' '.
 * frequency variables newcis_ipdc.


***************Start of Temporary code***********************.
*get file = '/conf/linkage/output/gemma/masterPLICS1516/masterPLICS_Costed_201516.sav'.

*get file='/conf/irf/10-PLICS-analysis-files/masterPLICS_Costed_201415.sav'.

*check ipdc and newcis_ipdc.
 * dataset name PLICS.
 * temporary.
*select if chi ne ' ' AND ipdc eq 'I' AND newcis_ipdc eq 'D'.
*EXECUTE.
 * save outfile='/conf/linkage/output/gemma/masterPLICS1516/wrong_newcisipdc_uri.sav' /keep SMRType uri CHI.
 * get file='/conf/linkage/output/gemma/masterPLICS1516/wrong_newcisipdc_uri.sav'.
 * save translate outfile='/conf/linkage/output/gemma/masterPLICS1516/wrong_newcisipdc_uri.xls' /type xls
   /replace
   /map
   /cells=values
   /fieldnames.

*frequency variables SMRType.




***************End of Temporary code***********************.




aggregate outfile=* MODE=ADDVARIABLES OVERWRITE=YES
   /break CHI cis_marker
   /newcis_ipdc = max(newcis_ipdc).
execute.

if newcis_ipdc eq ' ' AND chi ne ' ' AND ipdc eq 'I' newcis_ipdc = 'I'.
if (recid eq '01B' AND newcis_ipdc eq ' ' AND chi ne ' ' AND ipdc eq 'D') newcis_ipdc eq 'D'.
execute.

temporary.
select if chi ne ' '.
frequencies newcis_ipdc newpattype_cis cis_marker.

save outfile = !file + 'source-episode-file-' + !FY + '.sav'
 /compressed.

get file = !file + 'source-episode-file-' + !FY + '.sav'.
*add back in the other records.
add files file=*
   /file = !file + 'source-episode-file-' +!FY +'_NRS_PIS_AE_OP.sav'
   /by CHI.
execute.

sort cases by CHI record_keydate1 record_keydate2.

add files file=*
   /keep year to cis_marker newcis_ipdc ALL.
execute.

*save outfile = !file + 'source-episode-file-' + !FY + '.sav'
 /compressed.
frequencies recid.
save outfile = '/conf/acnd_testing/source-episode-file-' + !FY + '.sav'
 /compressed.

*********************************************************************match on SIMD 2016***********************************************************.
*get file = !file + 'source-episode-file-' + !FY + '.sav'.
get file = '/conf/acnd_testing/source-episode-file-' + !FY + '.sav'.

*sort on postcode.
rename variables pc7 = health_postcode.
sort cases by health_postcode.

match files file=*
   /table '/conf/linkage/output/gemma/CHImaster_w_HRI_SIMD16/postcode_simd2016.sav'
   /by health_postcode.
execute.

rename variables health_postcode = pc7.

sort cases by CHI record_keydate1 record_keydate2.


*save outfile = !file + 'source-episode-file-' + !FY + '.sav'.
save outfile = '/conf/acnd_testing/source-episode-file-' + !FY + '.sav'
 /compressed.

************************************************************************************************************************************************************.
*get file = !file + 'source-episode-file-' + !FY + '.sav'.
get file = '/conf/acnd_testing/source-episode-file-' + !FY + '.sav'.

*RUN CHECKS.




* Housekeeping.
* NEED TO CHECK FILE NAMES.  ALREADY DELETED FOR NETWORK SPACE ISSUES BEFORE THIS SECTION IN THE PROGRAM WAS REACHED. 
erase file = !file + 'acute_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'maternity_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'mental_health_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'op_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'aande_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'prescribing_file_for_source-'+ !FY + '.sav'.
erase file = !file + 'deaths_extract_for_source-'+ !FY + '.sav'.
