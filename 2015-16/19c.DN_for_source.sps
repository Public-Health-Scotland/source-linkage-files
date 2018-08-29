
*District Nursing Database.
*Anita George 15/11/2017 .
*calculate recid frequencies for cost book and to average out costs in the excel spreadsheet.
*Last ran 30/5/18.-AnitaGeorge.

* Define macro for file.

define !file()
'/conf/sourcedev/Anita_temp/DN/'
!enddefine. 

*define macro for FY.
define !FY()
'1516'
!enddefine.

GET DATA  /TYPE=TXT
  /FILE="/conf/sourcedev/Anita_temp/DN/DN_source_extract_201516.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=" ,"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  TreatmentNHSBoardCode A1
  TreatmentNHSBoardName A27
  ServiceTeam A28
  AgeatContactDate F2.0
  EpisodeContactNumber F4.0
  PatientDoDDate A19
  ContactStartTime A5
  ContactEndTime A5
  ContactDate A19
  OtherInterventionCategory1 F2.0
  PatientContactCategory F1.0
  OtherInterventionSubcategory1 F1.0
  OtherInterventionCategory2 F2.0
  OtherInterventionSubcategory2 F1.0
  NumberofContacts F1.0
  OtherInterventionCategory3 F2.0
  OtherInterventionSubcategory3 F1.0
  OtherInterventionCategory4 F2.0
  OtherInterventionSubcategory4 F1.0
  PrimaryInterventionSubcategory F1.0
  PrimaryInterventionCategory F2.0
  TreatmentNHSBoardCode9 A9
  VisitStatus F1.0
  UPINumberC F10.0
  PatientDoBDateC A19
  PlannedUnplanned F1.0
  PatientSIMDScoreContact F6.3
  PatientSIMDScotlandQuintileContact F1.0
  PatientSIMDScotlandDecileContact F2.0
  PatientSIMDHealthBoardQuintileContact F1.0
  PatientSIMDHealthBoardDecileContact F2.0
  PatientPostcodeCContact A7
  PatientUrbanRural6FoldGroupingContact A18
  PatientUrbanRural2FoldGroupingContact A5
  PatientUrbanRuralContact F1.0
  PatientDataZoneContact A9
  DurationofContactmeasure F3.0
  Gender F1.0
  ContactFinancialYear F4.0
  LocationofContact F1.0
  PracticeNHSBoardCodeContact A1
  ContactID A36
  PracticeNHSBoardCode9Contact A9
  PatientCouncilAreaCodeContact F2.0
  PracticeCodeContact F5.0
  NHSBoardofResidenceCodeContact A1.
CACHE.
EXECUTE.
DATASET NAME DataSet6 WINDOW=FRONT.


save outfile=!File +'Temp_1'+'.sav'.
get file=!File +'Temp_1'+'.sav'.

*Check frequencies for Healthboards and calculate costs.

*Create UniqueId with Treatment NHS Code and ContactId.Convert numeric to string.

string UniqueID(A63).
Compute UniqueID= concat(TreatmentNHSBoardCode9,ContactID).
Execute.
sort cases by UniqueID.

*Check Frequencies for NumberofContacts (should be 1).
FREQUENCIES VARIABLES=NumberofContacts
  /ORDER=ANALYSIS.

*Prefix 0 to the UPINumber missing 1 character from the string variable.

Alter type UPINumberC (A10).
String Firstcharacter (A1).
compute Firstcharacter = char.substr(UPINumberC,1,1).
EXECUTE.

String Zero (A10).
compute Zero = '0'.
execute.

String tempCHI (A10).
do if Firstcharacter = ' '.
compute tempchi = char.substr(UPINumberC,2,9).
else.
compute tempchi = UPINumberC.
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

save outfile=!File +'Temp_1'+'.sav'.
get file=!File +'Temp_1'+'.sav'.

*Alter or create variables to match file to source file.
rename variables ContactFinancialYear=year.
rename variables TreatmentNHSBoardName=hbtreatname.
rename variables TreatmentNHSBoardCode=hbtreatcode.
rename variables Gender=gender.
rename variables PatientPostcodeCContact=pc7.
rename variables PracticeNHSBoardCodeContact=hbpraccode.
rename variables NHSBoardofResidenceCodeContact=hbrescode.
rename variables Ageatcontactdate=age.
Rename variables PracticeCodeContact =gpprac.
rename variables PatientCouncilAreaCodeContact=lca.
execute.



*Create recid variable .
string recid(A3).
compute recid='DN'.
execute.
*Create variable SMRtype with value DN(District Nursing).

string SMRType (A10).
compute SMRType='DN'.
execute.

*Create variables recordkeydate1 =Contact Date and record keydate2 =recordkeydate1. Create keydates in date format.
string record_keydate1(A8).
COMPUTE record_keydate1=concat(substr(ContactDate,1,4),substr(ContactDate,6,2),substr(ContactDate,9,2)).
exe.
string record_keydate2 (a8).
compute record_keydate2= record_keydate1.
execute.

string keydate1_dateformat(A10).
string keydate2_dateformat(A10).
compute keydate1_dateformat=concat(substr( record_keydate1,7,2),'.',substr( record_keydate1,5,2),'.',substr( record_keydate1,1,4)).
exe.
alter type keydate1_dateformat(edate10).
exe.
alter type keydate2_dateformat (edate10).
compute keydate2_dateformat =  keydate1_dateformat.
exe.



*Compute date of death  .
string dod(a8).
 
compute dod=concat(substr( PatientDoDDate,1,4),substr(PatientDoDDate,6,2),substr(PatientDoDDate,9,2)).
exe.
Delete variables PatientDoDDate.
exe.

*Compute date of birth.
string dob (a8).
compute dob=concat(substr(  PatientDoBDateC,1,4),substr( PatientDoBDateC,6,2),substr( PatientDoBDateC,9,2)).
exe.
delete variables  PatientDoBDateC.
alter type dob(F8).
exe.


* hbrescode variable matching up.

alter type hbrescode(a9).

if hbrescode='A' hbrescode='S08000015'.
if hbrescode='B' hbrescode='S08000016'.
if hbrescode='E' hbrescode='S08200001'.
if hbrescode='F' hbrescode='S08000018'.
if hbrescode='G' hbrescode='S08000021'.
if hbrescode='H' hbrescode='S08000022'.
if hbrescode='L' hbrescode='S08000023'.
if hbrescode='N' hbrescode='S08000020'.
if hbrescode='R' hbrescode='S08000025'.
if hbrescode='S' hbrescode='S08000024'.
if hbrescode='T' hbrescode='S08000027'.
if hbrescode='U' hbrescode='S08200003'.
if hbrescode='V' hbrescode='S08000019'.
if hbrescode='W' hbrescode='S08000028'.
if hbrescode='Y' hbrescode='S08000017'.
if hbrescode='Z' hbrescode='S08000026'.
exe.


alter type hbtreatcode(a9).
if hbtreatcode='B' hbtreatcode='S08000016'.
if hbtreatcode='G' hbtreatcode='S08000021'.
if hbtreatcode='H' hbtreatcode='S08000022'.
if hbtreatcode='L' hbtreatcode='S08000023'.
if hbtreatcode='S' hbtreatcode='S08000024'.
if hbtreatcode='T' hbtreatcode='S08000027'.
if hbtreatcode='V' hbtreatcode='S08000019'.
exe.



alter type hbpraccode (a9).

if hbpraccode='A' hbpraccode='S08000015'.
if hbpraccode='B' hbpraccode='S08000016'.
if hbpraccode='E' hbpraccode='S08200001'.
if hbpraccode='F' hbpraccode='S08000018'.
if hbpraccode='G' hbpraccode='S08000021'.
if hbpraccode='H' hbpraccode='S08000022'.
if hbpraccode='L' hbpraccode='S08000023'.
if hbpraccode='N' hbpraccode='S08000020'.
if hbpraccode='R' hbpraccode='S08000025'.
if hbpraccode='S' hbpraccode='S08000024'.
if hbpraccode='T' hbpraccode='S08000027'.
if hbpraccode='U' hbpraccode='S08200003'.
if hbpraccode='V' hbpraccode='S08000019'.
if hbpraccode='W' hbpraccode='S08000028'.
if hbpraccode='Y' hbpraccode='S08000017'.
if hbpraccode='Z' hbpraccode='S08000026'.
exe.

* Create costs for the DN from costsbook. (Work from here).

if hbtreatname='NHS FORTH VALLEY' cost_total_net =40.
if hbtreatname='NHS GREATER GLASGOW & CLYDE' cost_total_net =34.
if hbtreatname='NHS HIGHLAND' cost_total_net =221.
if hbtreatname='NHS LANARKSHIRE' cost_total_net =44.
if hbtreatname='NHS LOTHIAN' cost_total_net =54.
if hbtreatname='NHS TAYSIDE' cost_total_net =58.
exe.
*Tidying up.

Alter type gpprac (a6).
Alter type age (F3).
Alter type dob(F8).
Alter type cost_total_net (F8).
alter type record_keydate1 (F8).
alter type record_keydate2 (F8).
alter type cost_total_net (F8).
alter type lca (a2).
alter type hbpraccode (a9).
exe.

*Add values to variables-Run Macros.
!Macrovalues1.
!Macrovalues2.
!Macrovalues3.
!Macrovalues4.
!Macrovalues5.
!Macrovalues6.
!Macrovalues7.
!Macrovalues8.
!Macrovalues9.
execute.

*Run Macros to create values for variables.

!Macrovalues10.
!Macrovalues11.
!Macrovalues12.
execute.


save outfile=!File +'DN_temp'+'.sav'.

get file=!File +'DN_temp'+'.sav'.

*Select records with chi nos.
if chi eq '0' chi eq ''.
exe.
Select if chi ne ''.
exe.
sort cases by chi.
exe.
*Remove NHS Borders records temporarily.
select if hbtreatcode ne 'S08000016'.
exe.

*Create variable with contact date to do further calculations.

sort cases by chi record_keydate1 record_keydate2.
exe.
alter type record_keydate1(A8).
alter type record_keydate2(A8).
exe.
string CIS_Marker_date_1(A10).
compute CIS_Marker_date_1=concat(substr( record_keydate1,7,2),'.',substr(record_keydate1,5,2),'.',substr(record_keydate1,1,4)).
EXECUTE.

alter type CIS_Marker_date_1 (edate10).
EXECUTE.
alter type record_keydate1(F8).
alter type record_keydate2(F8).
exe.

*tidy up chi.
if chi eq '0' chi eq ''.
exe.

*Finding the difference between dates of contacts and creating new variable DATEDIFF.

sort cases by chi dob CIS_Marker_date_1.
if (chi=lag(chi) and dob eq lag(dob)) Day_diff eq DATEDIFF(Cis_Marker_date_1,lag(Cis_Marker_date_1),"days").
 exe.
*Creating CCM Continous Care Marker. Records with less than or equal to 7 days are maintained as same CCM and greater than 7 days is CCM+1.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK chi
/record_keydate1_1=first(record_keydate1)
/Day_diff_1=first(day_diff).
EXECUTE.
Compute CCM_1=1.
exe.


if (chi=lag(chi) and lag(record_keydate1) eq record_keydate1_1 and Day_diff le 7) CCM=CCM_1.
exe.
if (chi=lag(chi) and lag(record_keydate1) eq record_keydate1_1 and  Day_diff gt 7) CCM=CCM_1+1.
exe.
if (chi=lag(chi) and  lag (record_keydate1) ne record_keydate1_1 and Day_diff le 7) Flag=1.
if (chi=lag(chi) and lag(record_keydate1) ne record_keydate1_1 and Day_diff gt 7) Flag=2.
exe.

Do if  Flag=1.
Compute CCM=lag(CCM).
else if Flag=2.
Compute CCM=(lag(CCM)+1).
END IF.
exe.

alter type CCM(A8).
exe.

if CCM eq '' CCM='1'.
exe.

alter type CCM(F8).
exe.


save outfile='/conf/sourcedev/Anita_temp/DN/DN_temp.sav'.

get file='/conf/sourcedev/Anita_temp/DN/DN_temp.sav'.

*calculate costs per month and total costs.
string cost_monthnum(A2).
alter type record_keydate2(A8).
compute cost_monthnum=char.substr(record_keydate2,5,2).
exe.

if cost_monthnum eq '01' jan_beddays=1.
if cost_monthnum eq '02' feb_beddays=1.
if cost_monthnum eq '03' mar_beddays=1.
if cost_monthnum eq '04' apr_beddays=1.
if cost_monthnum eq '05' may_beddays=1.
if cost_monthnum eq '06' jun_beddays=1.
if cost_monthnum eq '07' jul_beddays=1.
if cost_monthnum eq '08' aug_beddays=1.
if cost_monthnum eq '09' sept_beddays=1.
if cost_monthnum eq '10' oct_beddays=1.
if cost_monthnum eq '11' nov_beddays=1.
if cost_monthnum eq '12' dec_beddays=1.
exe.

alter type cost_total_net(F8.2).
if jan_beddays =1 jan_cost=cost_total_net.
if feb_beddays =1 feb_cost=cost_total_net.
if mar_beddays =1 mar_cost=cost_total_net.
if apr_beddays =1 apr_cost=cost_total_net.
if may_beddays =1 may_cost=cost_total_net.
if jun_beddays =1 jun_cost=cost_total_net.
if jul_beddays =1 jul_cost=cost_total_net.
if aug_beddays =1 aug_cost=cost_total_net.
if sept_beddays =1 sept_cost=cost_total_net.
if oct_beddays =1 oct_cost=cost_total_net.
if nov_beddays =1 nov_cost=cost_total_net.
if dec_beddays =1 dec_cost=cost_total_net.
exe.
rename variables cost_total_net=costcontact.
exe.

*calculate no. of contacts for ones with chi no.

*TotalnoDNcontacts=sum(NumberofContacts)
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK chi
/record_keydate1_1=first(record_keydate1)
/Day_diff_1=first(day_diff)
EXECUTE


compute cost_total_net= sum(jan_cost,feb_cost,mar_cost,apr_cost,may_cost,jun_cost,jul_cost,aug_cost,sept_cost,oct_cost,nov_cost,dec_cost).
exe.
delete variables cost_monthnum costcontact.
exe.

*Aggregate out records for final DN to source linkage files.
sort cases by chi dob record_keydate1 record_keydate2.
exe.

aggregate outfile=*
/break chi CCM  
/record_keydate1 = first(record_keydate1)
/record_keydate2= last(record_keydate2)
/keydate1_dateformat=first(keydate1_dateformat)
/keydate2_dateformat=last(keydate2_dateformat)
/SMRType=first(SMRType)
/recid=first(recid)
/dod=first(dod)
/dob=first(dob)
/hbtreatcode=last(hbtreatcode)
/hbrescode=last(hbrescode)
/age=last(age)
/diag1=first(PrimaryInterventionCategory)
/diag2=first (OtherInterventionCategory1)
/diag3=first(OtherInterventionCategory2)
/diag4=last(PrimaryInterventionCategory)
/diag5=last(OtherInterventionCategory1)
/diag6=last(OtherInterventionCategory2)
/pc7=last(pc7)
/gender=first(gender)
/hbpraccode=first(hbpraccode)
/gpprac=first(gpprac)
/cost_total_net=sum(cost_total_net)
/location=first (LocationofContact)
/year=first(year)
/TotalnoDNcontacts=sum(NumberofContacts)
/TotalDurationofContacts=sum(DurationofContactmeasure)
 /jan_cost=sum(jan_cost)
/feb_cost=sum(feb_cost)
/mar_cost=sum(mar_cost)
/april_cost=sum(apr_cost)
/may_cost=sum(may_cost)
/june_cost=sum(jun_cost)
/july_cost=sum(jul_cost)
/august_cost=sum(aug_cost)
/sept_cost=sum(sept_cost)
/oct_cost=sum(oct_cost)
/nov_cost=sum(nov_cost)
/dec_cost=sum(dec_cost).
exe.

*Tidy up for source linkage episode file.
alter type year(A4).
compute year='1516'.
exe.
alter type record_keydate2(F8).
alter type location(A5).
Alter type diag1(A6).
Alter type diag2 (A6).
Alter type diag3 (A6).
Alter type diag4(A6).
Alter type diag5(A6).
Alter type diag6(A6).
alter type location(A7).
exe.
!Macrovalues13.
exe.
alter type location (A5).
sort cases by chi.
exe.


save outfile='/conf/sourcedev/Anita_temp/DN/DN_for_source-201516.sav'
/keep 
year
recid
record_keydate1
record_keydate2
keydate1_dateformat
keydate2_dateformat
SMRType
chi
gender
dob
dod
CCM
gpprac
hbpraccode
pc7
hbrescode
hbtreatcode
location
diag1
diag2
diag3
diag4
diag5
diag6
age
cost_total_net
jan_cost
feb_cost
mar_cost
april_cost
may_cost
june_cost
july_cost
august_cost
sept_cost
oct_cost
nov_cost
dec_cost
TotalnoDNcontacts
TotalDurationofContacts.

get file='/conf/sourcedev/Anita_temp/DN/DN_for_source-201516.sav'.



*******************************************

*check if variables match with source linkage episode file1617.

get file='/conf/hscdiip/01-Source-linkage-files/source-episode-file-201617.sav'.

match files file=*
/file='/conf/sourcedev/Anita_temp/DN/DN_for_source-201617.sav'
/by chi.
exe.
******************************************************
*Delete temp files.
Erase file= '/conf/sourcedev/Anita_temp/DN/DN_temp.sav'.
Erase file= '/conf/sourcedev/Anita_temp/DN/Temp_1.sav'.

