*02 Home care.

*Filepath to working directory.
CD  '/conf/irf/11-Development team/Dev00-PLICS-files/2016-17/SC/'.

*define financial year.
define !FY()
'1617'
!enddefine.

* Open BOXI extract for home care - keep original variable names.
GET DATA  /TYPE=TXT
  /FILE="/conf/irf/11-Development team/Dev00-PLICS-files/2016-17/SC/home_care_for_source.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  FinancialYear A4
  FinancialQuarter A1
  SendingCouncilAreaCode A2
  PracticeNHSBoardCode A1
  PracticeCode A5
  UPINumberC A10
  AgeatMidpointofFinancialYear F3.0
  ClientDoBDateC A19
  ClientDoDDate A19
  GenderDescription A6
  NHSBoardofResidenceCode A1
  ClientCouncilAreaCode A2
  ClientDataZone A9
  ClientPostcodeC A7
  HomeCareFlagQuarter A1
  HomeCareServiceStartDate A19
  HomeCareServiceEndDate A19
  HomeCareService A1
  HomeCareServiceDesc A17
  HomeCareHoursReceivedQuarter F1.0
  HomeCareOvernightHoursQuarter F1.0
  HomeCareAdditionalStaffingHoursQuarter F1.0
  LengthofHomeCareService F4.0.
CACHE.
EXECUTE.
 * DATASET NAME DataSet6 WINDOW=FRONT.

*remove records without valid chi numbers - because these can't be matched to the other datasets.
select if UPINumberC ne ' '.
EXECUTE.

*save file here for formatting.
save outfile='data/home_care_for_source_temp1.sav'.


*0. Financial year.
rename variables FinancialYear = year.
if substr(year, 3, 2) eq substr(!FY, 1, 2) year=!FY.
frequency variables year.

*CHECK - run a frequency analysis to ensure all cases are same financial year.
variable labels year 'Year'.

*1. create variables for SMRType and recid.
string recid (a3).
string SMRType (a10).

*change the order of variables.
add files file=*
   /keep year SMRType recid ALL.
EXECUTE.

*Check results of frequency analysis - are all cases home care?.
if HomeCareFlagQuarter eq 'Y' recid eq 'HC'.
frequency variables recid.

*populate SMRType and remove the home care flag as it's not needed anymore.
compute SMRType eq 'Home-Care'.
EXECUTE.
delete variables HomeCareFlagQuarter.

*2. sending lca - format this - extra variable in the output - this is the Local authority that submitted the record - not necessarily the LA of residence.
rename variables SendingCouncilAreaCode = sc_send_lca.
variable labels sc_send_lca 'Social Care data sending LCA'.


*3. HB practice code - currently 1 character string with the HB cypher - match onto the 9-character codes e.g. S08000024, etc.
***** lookup file here:='/conf/hscdiip/Development-linkage/lookups/hb2014_lookup.sav' - created with create_HB_lookup.sps.
string HBCypher (a1).
compute HBCypher=PracticeNHSBoardCode.

sort cases by HBCypher.

match files file=*
   /table 'hb2014_lookup.sav'
   /by HBCypher 
   /drop description_A.
EXECUTE.

*rename HB_Area_2014 and sort variables, then delete HBCypher & PracticeNHSBoardCode.
rename variables HB_Area_2014 = hbpraccode.

variable labels hbpraccode 'NHS Board of GP Practice'.

add files file=*
   /keep year to sc_send_lca hbpraccode ALL
   /drop PracticeNHSBoardCode HBCypher hb.
EXECUTE.

*4. Practice code - ensure this is a 6-char string and rename.
rename variables PracticeCode = prac.
variables labels prac 'GP Practice code'.
alter type prac (a6).

*5. UPI / CHI number - rename and make sure this is a 10-char string. 
rename variables UPINumberC = chi.
variables labels chi 'Community Health Index number'.

*6. Age - rename variables, add label, and make numberic (F3.0).
rename variables AgeatMidpointofFinancialYear = age.
variable labels age 'Age of patient at midpoint of financial year'.

*7. DOB - get into numeric format.
rename variables ClientDoBDateC = dob.
alter type dob (a10).

string dob_date (a8).
add files file=*
   /keep year to dob dob_date ALL.
EXECUTE.

compute dob_date=concat(substr(dob,1,4),substr(dob,6,2),substr(dob,9,2)).
EXECUTE.

alter type dob_date (f8.0).

*delete old date of birth and rename dob_date.
delete variables dob.
rename variables dob_date = dob.
variable labels dob 'Date of Birth'.

*save.
save outfile='data/home_care_for_source_temp2.sav'.

*Get saved file and continue with formatting.
get file='data/home_care_for_source_temp2.sav'.

*delete the previous file.
erase file='data/home_care_for_source_temp1.sav'.

*Continue with formatting.

*8 delete dod - get death data from the death records - if the client died then there will at least be an NRS record in the episode-level dataset.
delete variables ClientDoDDate.

*9. Gender - change to number, male = 1, female = 2.
rename variables GenderDescription = gender.
if gender eq 'MALE' gender = '1'.
if gender eq 'FEMALE' gender = '2'.
alter type gender (a=amin).
alter type gender (F1.0).
variable labels gender 'Gender'.


*10 - HB residence - same as for hbpraccode.
string HBCypher (a1).
compute HBCypher=NHSBoardofResidenceCode.
EXECUTE.

sort cases by HBCypher.

match files file=*
   /table 'hb2014_lookup.sav'
   /by HBCypher 
   /drop description_A.
EXECUTE.

*rename HB_Area_2014 and sort variables, then delete HBCypher & PracticeNHSBoardCode.
rename variables HB_Area_2014 = hbrescode.

variable labels hbrescode 'NHS Board of Residence'.

add files file=*
   /keep year to gender hbrescode ALL
   /drop NHSBoardofResidenceCode HBCypher.
EXECUTE.

*save.
save outfile='data/home_care_for_source_temp3.sav'.

* get newly saved file.
get file='data/home_care_for_source_temp3.sav'.

*delete old file.
erase file='data/home_care_for_source_temp2.sav'.

*Contine with formatting.

*11. lca - this is LCA of the client (residence).
rename variables ClientCouncilAreaCode = lca.
variable labels lca 'Local Council Area'.

*12. client DZ - this is 2001 DZ.
rename variables ClientDataZone = DataZone2001.
variable labels DataZone2001 'Datazone 2001'.

*13. client postcode - check same format as pc7 in source.
*make sure that postcodes with 5 characters have a double space in the middle.
rename variables ClientPostcodeC = pc7.
variable labels pc7 '7 character postcode'.

*Modify dates.
*14. admission and discharge dates in numeric and date format.
alter type HomeCareServiceStartDate HomeCareServiceEndDate (a10).

string start_date end_date (a8).

compute start_date=concat(substr(HomeCareServiceStartDate,1,4),substr(HomeCareServiceStartDate,6,2),substr(HomeCareServiceStartDate,9,2)).
compute end_date=concat(substr(HomeCareServiceEndDate,1,4),substr(HomeCareServiceEndDate,6,2),substr(HomeCareServiceEndDate,9,2)).
EXECUTE.

alter type start_date end_date (f8.0).

insert file='a2_convert_date.sps'.
convert_date indates=HomeCareServiceStartDate HomeCareServiceEndDate.

*rename variables and re-order.
add files file=*
   /keep year to pc7 start_date end_date ALL.
EXECUTE.

rename variables start_date = record_keydate1 end_date = record_keydate2 HomeCareServiceStartDate = keydate1_dateformat HomeCareServiceEndDate = keydate2_dateformat.

*15. home care service description.
rename variables HomeCareService = hc_service.
value labels hc_service '1' = 'Non-personal care' '2' = 'Personal care' '3' = 'Housing support' '4' = 'Non-personal and personal care'.
variable labels hc_service 'Services provided as part of the clients care plan'.

delete variables HomeCareServiceDesc.

*save temp file 4.
save outfile='data/home_care_for_source_temp4.sav'.

* get newly saved file.
get file='data/home_care_for_source_temp4.sav'.

*delete old file.
erase file='data/home_care_for_source_temp3.sav'.

sort cases by chi FinancialQuarter record_keydate1.





****Temp*****

select if chi = '0101275196' or chi = '0103703349' or chi = '1012265161' or chi = '2207861430'.
execute.

aggregate outfile = * 
 /break chi sc_send_lca
 /hours = sum(HomeCareHoursReceivedQuarter)
 /nighthours = sum(HomeCareOvernightHoursQuarter)
 /additional = sum(HomeCareAdditionalStaffingHoursQuarter)
 /length = sum(LengthofHomeCareService).
execute.

aggregate outfile = * 
 /break sc_send_lca
 /hours = sum(hours)
 /nighthours = sum(nighthours)
 /additional = sum(additional)
 /length = sum(length)
 /clients = n.
execute.

compute hoursPP = hours/clients.
execute. 

compute TotalhoursPP = (hours+nighthours+additional)/clients.
execute. 


*16. Aggregate over FQs and sum hours to get total for the year and length of service.
aggregate outfile=*
   /break year SMRType recid chi sc_send_lca hbpraccode prac age dob gender hbrescode lca DataZone2001 pc7 record_keydate1 record_keydate2 keydate1_dateformat 
   keydate2_dateformat hc_service 
   /hc_day_hours=sum(HomeCareHoursReceivedQuarter)
   /hc_night_hours=sum(HomeCareOvernightHoursQuarter)
   /hc_extra_hours=sum(HomeCareAdditionalStaffingHoursQuarter)
   /length_of_service=sum(LengthofHomeCareService).
EXECUTE.

variable labels hc_day_hours 'Total number of home care service hours received, planned or actual' 
                        hc_night_hours 'Total number of overnight (11pm - 6am) home care service hours received, planned or actual'
                        hc_extra_hours 'Additional staffing hours per home care service provided through double up or mulitple staff visits, planned or actual'.

*save temp file5.
save outfile='data/home_care_for_source_temp5.sav'.

* get newly saved file.
get file='data/home_care_for_source_temp5.sav'.

*delete old file.
erase file='data/home_care_for_source_temp4.sav'.

*17. year stay = length of service in this FY.
rename variables length_of_service = stay.
alter type stay (F7.0).


*calculate year length of service based on FY dates and CH start/end dates.
*compute dummy dates for this FY.
string finyear (a4).
compute finyear=concat('20',substr(!FY, 1, 2)).
alter type finyear (F4.0).

compute date1=date.dmy(1,4,finyear).
alter type date1 (date10).
if keydate1_dateformat gt date1 date1=keydate1_dateformat.
frequency variables date1.

compute date2=date.dmy(31,3,finyear+1).
alter type date2 (date10).
if keydate2_dateformat lt date2 date2=keydate2_dateformat.
frequency variables date2.

*calculate yearsstay between date1 and date2.
compute yearstay=datediff(date2, date1, 'days')+1.
EXECUTE.

*There should be no year stays less than zero - if so then pull these records out - save in a separate file and email file to data management - Elaine McNish.
temporary.
select if yearstay lt 0.
save outfile='data/home_care_date_error.sav'.

select if yearstay ge 0.
EXECUTE.

*Check the result of this frequency analysis to ensure that all records have at least 1 valid day.
compute flagup=0.
if yearstay lt 0 flagup=1.
if yearstay = 0 flagup=2.
frequency variables flagup.

select if flagup ne 2.
EXECUTE.

*delete date1 and date2 and finyear.
delete variables date1 date2 finyear.

*sort by chi and dates.
sort cases by chi record_keydate1 record_keydate2.

save outfile='data/home_care_for_source.sav'.

*get newly saved file.
get file='data/home_care_for_source.sav'.

erase file='data/home_care_for_source_temp5.sav'.









