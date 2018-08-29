*Get source episode file 201617.
get file='/conf/sourcedev/source-episode-file-201617.zsav'.
*Select records with chi nos.
select if chi ne ''.
exe.
*Choose records which have activity after derived_datedeath is recorded. Records with difference in 7 days between activity and death date is rejected.
sort cases by chi.
exe.
alter type derived_datedeath(F8).
compute Flag=0.
if (derived_datedeath lt record_keydate2) Flag=1.
select if Flag=1.
exe.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK chi
/recid_1 =last (recid)
/derived_datedeath_1=last(derived_datedeath)
/record_keydate2_1=last(record_keydate2).
exe.

Delete variables Flag.
exe.
compute Flag_1=0.
exe.
if (recid eq '00B' ) and (attendance_status eq '8') and (record_keydate2_1=record_keydate2)  Flag_1=2.
exe.
if (recid eq 'OoH' ) and (attendance_status eq '8') and (record_keydate2_1=record_keydate2)  Flag_1=2.
exe.
*Check Flag_1.
Crosstabs recid by Flag_1.
exe.

if (Flag_1=2 and chi eq lag (chi) and (derived_datedeath lt lag(record_keydate2))) Flag=1.
exe.
if (Flag_1=2 and chi ne lag(chi) and derived_datedeath lt record_keydate2_1) Flag=1.
exe.
if ((recid eq '00B' ) and (attendance_status ne '8' )and (derived_datedeath lt record_keydate2_1))Flag=1.
exe.
if (recid eq 'PIS' and derived_datedeath lt 20160401) Flag=1.
exe.

if (recid ne 'PIS' and recid ne '00B' and derived_datedeath lt record_keydate2_1) Flag=1.
exe.
*check frequencies.
Select if Flag=1.
exe.

*aggregate to find last record of activity with costs.

aggregate outfile=*
/break chi
/derived_datedeath =last(derived_datedeath)
/year=last(year)
/recid=last(recid)
/record_keydate1=last(record_keydate1)
/record_keydate2=last (record_keydate2)
/keydate1_dateformat=last(keydate1_dateformat)
/keydate2_dateformat=last(keydate2_dateformat)
/deathdiag1=last (deathdiag1)
/deathdiag2=last(deathdiag2)
/deathdiag3=last(deathdiag3)
/deathdiag4=last(deathdiag4)
/deathdiag5=last(deathdiag5)
/deathdiag6=last(deathdiag6)
/deathdiag7	=last(deathdiag7)
/	deathdiag8=last(deathdiag8)
/deathdiag9=last(deathdiag9)
	/deathdiag10=last(deathdiag10)
/deathdiag11=last(deathdiag11)
/deceased=last(deceased)
/cost_total_net	=last(cost_total_net)
/Cost_Total_Net_incDNAs=last(Cost_Total_Net_incDNAs)
/dob	=last(dob).
EXECUTE.

*Remove records which have activity within 7 days of date of death.
compute Flag=0.
alter type derived_datedeath(A8).
exe.
string derived_datedeath_1(A10).
compute derived_datedeath_1=concat(substr( derived_datedeath,7,2),'.',substr(derived_datedeath,5,2),'.',substr(derived_datedeath,1,4)).
EXECUTE.

alter type derived_datedeath_1(edate10).
EXECUTE.
save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.

alter type record_keydate2(A8).
exe.
string record_keydate2_1(A10).
compute  record_keydate2_1=concat(substr(record_keydate2,7,2),'.',substr(record_keydate2,5,2),'.',substr(record_keydate2,1,4)).
EXECUTE.

alter type record_keydate2_1(edate10).
EXECUTE.


compute Day_diff =DATEDIFF(record_keydate2_1,derived_datedeath_1,"days").
exe.
if (Day_diff gt 7) Flag=1.
exe.
select if Flag=1.
exe.

*Check for duplicate records of death.Check Flagchi frequencies.
sort cases by chi.
EXECUTE.
if chi=lag(chi) Flagchi=1.
EXECUTE.


save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.
********************************************************************************************************************************
*Get BOXI extract for Registered Date of Death(DateofDeathRegistered99).


GET DATA  /TYPE=TXT
  /FILE="/conf/sourcedev/James/Temp/GRO death registrations all scotland episode level extract for source file production 1617.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=" ,"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  DateofDeath99 A19
  PatUPI F10.0
  PatGenderCode F1.0
  PatDateOfBirthC A19
  GPpracticecode99 F5.0
  GeoCouncilAreaCode F2.0
  DateDeathRegistered99 A19
  NHSBoardofResidenceCodecurrent A9
  GeoPostcodeC A7
  CHPCode A9
  GeoDataZone2011 A9
  DeathLocationCode A5
  PrimCauseofDeathCode4char A4
  SecCauseofDeath0Code4char A4
  SecCauseofDeath1Code4char A4
  SecCauseofDeath2Code4char A4
  SecCauseofDeath3Code4char A4
  SecCauseofDeath4Code4char A4
  SecCauseofDeath5Code4char A4
  SecCauseofDeath6Code4char A4
  SecCauseofDeath7Code4char A3
  SecCauseofDeath8Code4char A3
  SecCauseofDeath9Code4char F1.0
  PostMortemCode F1.0
  PlaceDeathOccurredCode F1.0
  NHSBoardofOccurrenceCodecurrent A9
  UniqueRecordIdentifier F8.0.
CACHE.
EXECUTE.
DATASET NAME DataSet8 WINDOW=FRONT.


*Alter chi and Registered date of death for analysis.
string Datedeath_GRO(A8).
COMPUTE Datedeath_GRO=concat(substr(DateDeathRegistered99,1,4),substr(DateDeathRegistered99,6,2),substr(DateDeathRegistered99,9,2)).
exe.

string dob(A8).
COMPUTE  dob=concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
exe.


Alter type PatUPI (A10).
String Firstcharacter (A1).
compute Firstcharacter = char.substr(PatUPI,1,1).
EXECUTE.

String Zero (A10).
compute Zero = '0'.
execute.

String tempCHI (A10).
do if Firstcharacter = ' '.
compute tempchi = char.substr(PatUPI,2,9).
else.
compute tempchi = PatUPI.
end if.
execute.


String chi (A10).
do if Firstcharacter = ' '.
compute chi = concat(Zero,tempchi).
else.
compute chi = tempchi.
end if.
execute.

DELETE VARIABLES Zero, FirstCharacter, tempCHI.
EXECUTE.

sort cases by chi.
exe.

save outfile='/conf/sourcedev/Anita_temp/Death_derived/DeathwithBOregisters.sav'
/keep dob chi Datedeath_GRO.
exe.

*******************************************************************************************************************************
* Get GRO registered deaths.
get file='/conf/sourcedev/Anita_temp/Death_derived/DeathwithBOregisters.sav'.

alter type dob (F8).
alter type Datedeath_GRO(F8).
exe.
sort cases by chi dob.
Exe.
*Select records with chi not equal to 0 and not repeated.
select if chi ne '0'.
exe.
sort cases by chi.
if chi=lag (chi) flag=1.
exe.
*Aggregrate records to last date of death in registered deaths.
aggregate outfile=*
/break chi
/ Datedeath_GRO=last( Datedeath_GRO)
/dob=last(dob).
exe.

sort cases by chi dob.
exe.
save outfile='/conf/sourcedev/Anita_temp/Death_derived/DeathwithBOregisters.sav'.
*Match registered deaths with derived date of death.
get file='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.
sort cases by chi.
exe.
match files file=*
/table='/conf/sourcedev/Anita_temp/Death_derived/DeathwithBOregisters.sav'
/by chi.
exe.

delete variables flag flagchi.
exe.

save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.
*Flag records with registered dates of death has latest records than the derived deaths.(Around 2457 records) .
Alter type derived_datedeath(F8).
exe.
if (Datedeath_GRO gt derived_datedeath) Flag=1.
exe.
*check frequencies of flag.
Delete variables  Flag.
exe.
*Replace derived_datedeath with the latest registered dates of death.

if ( derived_datedeath lt  Datedeath_GRO)derived_datedeath=Datedeath_GRO.
exe.


save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.
*Check death records for prescribing and incurring costs.
get file='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.
if (recid='PIS' and cost_total_net ne .00 and derived_datedeath lt 20170401) Flag_PIS=1.
exe.
alter type derived_datedeath (A8).
if( Flag_PIS=1)derived_datedeath =''.
exe.

delete variables Flag_PIS.
exe.
save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.

sort cases by recid.
exe.
*Some PIS records have no costs but death before 201718 FY.
alter type derived_datedeath (F8).
if (recid='PIS' and derived_datedeath lt 20160401) derived_datedeath  eq 0.
exe.
if (recid='PIS' and derived_datedeath ge 20170401) Flag_PIS=1.
exe.
* check if death activity is beyond 7 days again.
delete variables derived_datedeath_1.
exe.
alter type derived_datedeath(A8).
exe.
string derived_datedeath_1(A10).
compute derived_datedeath_1=concat(substr( derived_datedeath,7,2),'.',substr(derived_datedeath,5,2),'.',substr(derived_datedeath,1,4)).
EXECUTE.

alter type derived_datedeath_1(edate10).
EXECUTE.
save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.

compute Day_diff_1 =DATEDIFF(record_keydate2_1,derived_datedeath_1,"days").
exe.
if (Day_diff_1 gt 7) Flag=1.
exe.

alter type derived_datedeath(F8).
exe.
alter type record_keydate2(F8).
exe.
*For NRS records if deathdiag1 is present then compute record_keydate 1 as the derived_death date.Check Frequencies.

if(Flag eq 1  and recid='NRS' and deathdiag1 ne '' and derived_datedeath lt record_keydate2) derived_datedeath eq record_keydate2.
exe.

*For GLS records, nullify derived date of death.Check Frequencies.
alter type record_keydate2 (F8).
if recid ='GLS' Flag_GLS=1.
if (Flag eq 1  and Flag_GlS eq 1 and derived_datedeath lt record_keydate2)  derived_datedeath=0.
exe.

*For Accident and emergency records, nullify derived date of death.Check Frequencies.
if (Flag eq 1 and recid='AE2' and derived_datedeath lt record_keydate2)  derived_datedeath=0.
exe.

*For Mental Health, nullify date of death.Check Frequencies.
if (Flag eq 1 and recid='04B' and derived_datedeath lt record_keydate2) derived_datedeath=0.
exe.
*For Materinty, nullify date of death.Check Frequencies.
if (Flag eq 1 and recid='02B' and derived_datedeath lt record_keydate2) derived_datedeath=0.
exe.
*For acute, nullify date of death. Check Frequencies.
if (Flag eq 1 and recid='01B' and derived_datedeath lt record_keydate2) derived_datedeath=0.
exe.
*For outpatients, nullify date of death. Check Frequencies.
if (Flag eq 1 and recid='00B' and derived_datedeath lt record_keydate2) derived_datedeath=0.
exe.
*For GP out of hours, nullify date of death. Check Frequencies.
if (Flag eq 1 and recid='OoH' and derived_datedeath lt record_keydate2) derived_datedeath=0.
exe.
*For District Nursing, nullify date of death. Check Frequencies.
if (Flag eq 1 and recid='DN' and derived_datedeath lt record_keydate2) derived_datedeath=0.
exe.

*For Care Homes, nullify date of death. Check Frequencies.
if (Flag eq 1 and recid='CH' and derived_datedeath lt record_keydate2) derived_datedeath=0.
exe.

sort cases by chi dob.
exe.
save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'
/keep chi derived_datedeath.
exe.
get file='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.

alter type derived_datedeath (A8).
if derived_datedeath eq '       0' derived_datedeath eq '1'.
exe.

rename variables derived_datedeath =derived_datedeath_1.
exe.
if derived_datedeath_1 eq '' derived_datedeath_1 eq '1'.
exe.

save outfile='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.
get file='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'.

*Match death record with source files to see activity after death is registered is accurate now.

get file='/conf/sourcedev/source-episode-file-201617.zsav'.

sort cases by chi.
match files file=*
/table='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'
/by chi.
exe.

if derived_datedeath_1 ne '' derived_datedeath eq derived_datedeath_1.
exe.
if derived_datedeath eq '1' derived_datedeath eq ''.
exe.
delete variables derived_datedeath_1.
*To delete death dates after the financial year.
string Flag(A1).
if derived_datedeath gt '20170331' derived_datedeath eq ''.
exe.


*Change deceased flag.

compute deceased = 0.
if (derived_datedeath ne '') deceased = 1.
exe.
CROSSTABS deceased by derived_datedeath.


save outfile='/conf/sourcedev/James/source-episode-file-201617.sav'.
get file='/conf/sourcedev/James/source-episode-file-201617.sav'.
sort cases by chi.
exe.

save outfile='/conf/sourcedev/James/source-episode-file-201617.sav'.
*************************
To check if derived_datedeath are correctly matched and historic dates are removed.
get file='/conf/sourcedev/James/source-episode-file-201617.sav'.
compute Flag=0.
exe.
alter type derived_datedeath(F8).
exe.
if (derived_datedeath lt record_keydate2) Flag=1.
exe.
select if Flag=1.
exe.
AGGREGATE OUTFILE=* 
  /BREAK chi
/recid =last (recid)
/derived_datedeath=last(derived_datedeath)
/record_keydate2=last(record_keydate2).
exe.

if (derived_datedeath lt 20160401) Flag_1=1.
EXECUTE.
select if Flag_1=1.
exe.
*check frequencies of flag.





********************************************
*To check death data against source individual file.

get file='/conf/hscdiip/01-Source-linkage-files/source-individual-file-201718.sav'.

match files file=*
/table='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'
/by chi.
exe.


if derived_datedeath_1 ne '' date_death eq derived_datedeath_1.
exe.


if date_death eq '1' date_death eq ''.
exe.


delete variables derived_datedeath_1.


compute deceased_flag = 0.
if (date_death ne '') deceased_flag= 1.
exe.
CROSSTABS deceased_flag by date_death.

*To delete death dates after the financial year.

if date_death gt '20180331' date_death eq ''.
exe.
save outfile='/conf/sourcedev/Anita_temp/source-individual-file-201718.sav'.

get file='/conf/sourcedev/Anita_temp/source-individual-file-201718.sav'.

 select if  date_death gt '20180331'.
exe.

