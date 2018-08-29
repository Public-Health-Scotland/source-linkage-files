* Program to match the measures file and the patient details file together to create the file to use in the master
* PLICS file as well as the aggregated CHI/UPI PLICs.
*
* Program by Denise Hastie, October 2013.
* Updated by Denise Hastie, April 2015.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Added in erase file commands for the two files that make up the final output file. 
* Updated by Denise Hastie, June 2016.

* Updated to add in geographies, Denise Hastie July 2016.

define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 

* Extract files - 'home'.
define !Extracts()
'/conf/hscdiip/DH-Extract/patient-reference-files/'
!enddefine.

*define macro for FY.
define !FY()
'1617'
!enddefine.

***************************************************************************************************.

match files file = !file + 'pis_'+!FY+'_patients.sav'
 /file = !file + 'pis_'+!FY+'_measures.sav'
 /by upi.
execute.

save outfile = !file + 'prescribing_20' +!FY+'.sav'.

erase file =!file + 'pis_'+!FY+'_patients.sav'.
erase file = !file + 'pis_'+!FY+'_measures.sav'. 


* make changes as required for the when the files are all brought together.
get file = !file + 'prescribing_20' +!FY+'.sav'.

numeric record_keydate1 record_keydate2 (F8.0).
compute record_keydate1 = 20170331.
compute record_keydate2 = record_keydate1.
execute.

string recid (a3) year (a4).
compute recid = 'PIS'.
compute year = '1617'.
execute.

alter type gender (F1.0).

string dob (a8).
compute dob = concat(substr(date_of_birth,7,4),substr(date_of_birth,4,2),substr(date_of_birth,1,2)).
execute.
alter type dob (F8.0).

rename variables (patient_postcode = pc7).
sort cases by pc7.

match files file = *
 /table = '/conf/irf/05-lookups/04-geography/geographies-for-PLICS-updated2016.sav'
 /by pc7.
execute.

sort cases by ca2011.
rename variables (ca2011 = CouncilArea2011Code).
match files file = *
 /table = '/conf/irf/05-lookups/04-geography/lca_two_to_nine_digit_lookup.sav'
 /by CouncilArea2011Code.
execute.

sort cases by upi.

rename variables (HB2014 CHP_2012 DataZone2011 = hbrescode chp datazone). 
delete variables SplitChar Split_Indicator CouncilArea2011Code HSCP2016 CouncilArea2011Name NRSCouncilAreaName.

rename variables (upi paid_nic_excl_bb = chi cost_total_net).
delete variables date_of_birth.

alter type prac (a5).

select if chi ne ' '.
EXECUTE.

save outfile = !file + 'prescribing_file_for_source-20' +!FY +'.sav'.

get file = !file + 'prescribing_file_for_source-20' +!FY +'.sav'.

* Housekeeping.
erase file = !file + 'prescribing_201617.sav'.


