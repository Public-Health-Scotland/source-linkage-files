define !FY()
   '1516'
!enddefine.

define !temp()
   '/conf/sourcedev/James/Temp/'
!enddefine.

define !file()
   '/conf/sourcedev/'
!enddefine.

*Get source episode file.
get file= !file + "source-episode-file-20" + !FY + ".zsav".

*Select records with chi nos.
select if chi ne ''.

*Choose records which have activity after derived_datedeath is recorded. Records with difference in 7 days between activity and death date is rejected.
alter type derived_datedeath(F8).
compute Flag=0.
if (derived_datedeath lt record_keydate2) Flag=1.
select if Flag=1.

AGGREGATE
   /BREAK chi
   /recid_1 =last (recid)
   /derived_datedeath_1=last(derived_datedeath)
   /record_keydate2_1=last(record_keydate2).
execute.

Delete variables Flag.

if( (recid  eq '00B') and (attendance_status eq '8' ) and (record_keydate2_1=record_keydate2) ) Flag_1=2.

if (Flag_1=2 and chi eq lag (chi) and (derived_datedeath lt lag(record_keydate2))) Flag=1.

if (Flag_1=2 and chi ne lag(chi) and derived_datedeath lt record_keydate2_1) Flag=1.

if ((recid eq '00B' ) and (attendance_status ne '8' )and (derived_datedeath lt record_keydate2_1))Flag=1.

if (recid eq 'PIS' and derived_datedeath lt 20150401) Flag=1.

if (recid ne 'PIS' and recid ne '00B' and derived_datedeath lt record_keydate2_1) Flag=1.

*check frequencies.
Frequencies Flag Flag_1.
Select if Flag=1.


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
   /deathdiag8=last(deathdiag8)
   /deathdiag9=last(deathdiag9)
   /deathdiag10=last(deathdiag10)
   /deathdiag11=last(deathdiag11)
   /deceased=last(deceased)
   /cost_total_net	=last(cost_total_net)
   /Cost_Total_Net_incDNAs=last(Cost_Total_Net_incDNAs)
   /dob	=last(dob).

*Remove records which have activity within 7 days of date of death.
compute Flag=0.
alter type derived_datedeath record_keydate2(A8).

string derived_datedeath_1(A10).
compute derived_datedeath_1=concat(substr( derived_datedeath,7,2),'.',substr(derived_datedeath,5,2),'.',substr(derived_datedeath,1,4)).

string record_keydate2_1(A10).
compute  record_keydate2_1=concat(substr(record_keydate2,7,2),'.',substr(record_keydate2,5,2),'.',substr(record_keydate2,1,4)).

alter type derived_datedeath_1 record_keydate2_1(edate10).

compute Day_diff = DATEDIFF(record_keydate2_1, derived_datedeath_1, "days").

if (Day_diff gt 7) Flag=1.
Frequencies Flag.

select if Flag=1.

save outfile= !temp + "Death_Flag" + !FY + ".sav".
********************************************************************************************************************************
   *Get BOXI extract for Registered Date of Death(DateofDeathRegistered99).
GET DATA  /TYPE=TXT
   /FILE= !temp + "GRO death registrations all scotland episode "+
      "level extract for source file production " + !fy + ".csv"
   /ENCODING='UTF8'
   /DELCASE=LINE
   /DELIMITERS=" ,"
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /IMPORTCASE=ALL
   /VARIABLES=
      DateofDeath99 A10
      PatUPI A10
      PatGenderCode F1.0
      PatDateOfBirthC A10
      GPpracticecode99 F5.0
      GeoCouncilAreaCode F2.0
      DateDeathRegistered99 A10
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

*Alter chi and Registered date of death for analysis.
string Datedeath_GRO(A8).
COMPUTE Datedeath_GRO=concat(substr(DateDeathRegistered99,1,4),substr(DateDeathRegistered99,6,2),substr(DateDeathRegistered99,9,2)).

string dob(A8).
COMPUTE  dob=concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).

Rename Variables PatUPI = chi.

alter type dob Datedeath_GRO(F8).

*Select records with chi not equal to 0 and not repeated.
select if chi ne ''.

sort cases by chi dob.

save outfile= !temp + "DeathwithBOregisters.sav"
   /keep dob chi Datedeath_GRO.

*******************************************************************************************************************************
* Get GRO registered deaths.
get file= !temp + "DeathwithBOregisters.sav".

*Aggregrate records to last date of death in registered deaths.
aggregate outfile=*
   /break chi
   /Datedeath_GRO=last(Datedeath_GRO)
   /dob=last(dob).

sort cases by chi dob.

save outfile= !temp + "DeathwithBOregisters.sav".

*Match registered deaths with derived date of death.

match files file = !temp + "Death_Flag" + !FY + ".sav"
   /table = !temp + "DeathwithBOregisters.sav"
   /In = NewDeathDate
   /by chi.
exe.

DELETE VARIABLES   flag.

*Flag records with registered dates of death has latest records than the derived deaths.(Around 857 records) .
Alter type derived_datedeath(F8).
if (Datedeath_GRO gt derived_datedeath) NewDeathDate = 2.
Frequencies NewDeathDate.

Delete variables NewDeathDate.

*Replace derived_datedeath with the latest registered dates of death.
if (derived_datedeath lt Datedeath_GRO) derived_datedeath=Datedeath_GRO.


save outfile= !temp + "Death_Flag" + !FY + ".sav".

*Check death records for prescribing and incurring costs.
get file= !temp + "Death_Flag" + !FY + ".sav".
if (recid='PIS' and cost_total_net ne .00 and derived_datedeath lt 20150401) Flag_PIS=1.

alter type derived_datedeath (A8).
if( Flag_PIS=1) derived_datedeath =''.
exe.

delete variables Flag_PIS.


*Some PIS records have no costs but death before 201718 FY.
alter type derived_datedeath (F8).
if (recid='PIS' and derived_datedeath lt 20150401) derived_datedeath  eq 0.

if (recid='PIS' and derived_datedeath ge 20150401) Flag_PIS=1.
exe.

* check if death activity is beyond 7 days again.
delete variables derived_datedeath_1.

alter type derived_datedeath(A8).

string derived_datedeath_1(A10).
compute derived_datedeath_1=concat(substr( derived_datedeath,7,2),'.',substr(derived_datedeath,5,2),'.',substr(derived_datedeath,1,4)).

alter type derived_datedeath_1(edate10).

compute Day_diff_1 =DATEDIFF(record_keydate2_1,derived_datedeath_1,"days").

if (Day_diff_1 gt 7) Flag=1.

alter type derived_datedeath record_keydate2(F8).

*For NRS records if deathdiag1 is present then compute record_keydate 1 as the derived_death date.Check Frequencies.
if(Flag eq 1 and recid='NRS' and deathdiag1 ne '' and derived_datedeath lt record_keydate2) derived_datedeath eq record_keydate2.

*For other records, nullify derived date of death.Check Frequencies.
if (Flag eq 1 and any(recid, 'GLS', 'AE2', '04B', '02B', '01B', '00B', 'DN', 'OoH', 'CH') and derived_datedeath lt record_keydate2) derived_datedeath=0.

sort cases by chi.
save outfile= !temp + "Death_Flag" + !FY + ".sav"
   /keep chi derived_datedeath.

get file =  !temp + "Death_Flag" + !FY + ".sav".

alter type derived_datedeath (A8).
if derived_datedeath eq '       0' derived_datedeath eq '1'.

rename variables derived_datedeath =derived_datedeath_1.

if derived_datedeath_1 eq '' derived_datedeath_1 eq '1'.

save outfile = !temp + "Death_Flag" + !FY + ".sav".


*Match death record with source files to see activity after death is registered is accurate now.
match files file=!file + "source-episode-file-20" + !FY + ".zsav"
   /table='/conf/sourcedev/Anita_temp/Death_derived/Death_Flag.sav'
   /by chi.
exe.

if derived_datedeath_1 ne '' derived_datedeath eq derived_datedeath_1.

if derived_datedeath eq '1' derived_datedeath eq ''.
execute.

delete variables derived_datedeath_1.

 * Recalculate Deceased flag.
compute deceased = 0.
if (derived_datedeath ne '') deceased = 1.
frequencies deceased.


save outfile= !file + "source-episode-file-20" + !FY + ".zsav"
   /zcompressed.

Erase file save outfile= !file + "temp_source-episode-file-20" + !FY + ".zsav".



