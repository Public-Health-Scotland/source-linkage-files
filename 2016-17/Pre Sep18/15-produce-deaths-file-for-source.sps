* Produce NRS deaths extract in suitable format for PLICS.
* Modified version of previous read in files used to create NRS data for PLICS. 

* Read in the deaths extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, July 2016.

* Create macros for file path.

******************************* **** UPDATE THIS BIT **** *************************************.
********************************************************************************************************.
* Create macros for file path.

define !file()
'/conf/hscdiip/DH-Extract/'
!enddefine. 

* Extract files - 'home'.
define !Extracts()
'/conf/hscdiip/DH-Extract/patient-reference-files'
!enddefine.

*define macro for FY.
define !FY()
'1617'
!enddefine.

********************************************************************************************************.
********************************************************************************************************.

GET DATA  /TYPE=TXT
  /FILE= !file + 'nrs death registrations all scotland episode level extract for source file production 20' + !FY + '.csv'
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  DateofDeath99 A19
  PatUPI A10
  PatGenderCode F1.0
  PatDateOfBirthC A19
  GPpracticecode99 A5
  GeoCouncilAreaCode A2
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
  SecCauseofDeath7Code4char A4
  SecCauseofDeath8Code4char A4
  SecCauseofDeath9Code4char A4
  PostMortemCode A1
  PlaceDeathOccurredCode A1
  NHSBoardofOccurrenceCodecurrent A9
  UniqueRecordIdentifier A8.
CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

save outfile = !file + 'deaths_extract_PLICS-20' +!FY +'.sav'
 /compressed.

get file = !file + 'deaths_extract_PLICS-20' + !FY +'.sav'.

string record_keydate1 record_keydate2 dob (a8).
compute record_keydate1 = concat(substr(dateofdeath99,1,4),substr(dateofdeath99,6,2),substr(dateofdeath99,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
compute record_keydate2 = record_keydate1.
execute.
alter type record_keydate1 record_keydate2 dob (f8.0).

string recid (a3) year (a4).
compute recid = 'NRS'.
compute year = !FY.
execute.

rename variables (gppracticecode99 = prac).

string hbpraccode (a9).
if (prac ge '80005' and prac le '83997') hbpraccode = 'S08000001'.
if (prac ge '16009' and prac le '17995') hbpraccode = 'S08000002'.
if (prac ge '18004' and prac le '19991') hbpraccode = 'S08000003'.
if (prac ge '20004' and prac le '24999') hbpraccode = 'S08000004'.
if (prac ge '25008' and prac le '29992') hbpraccode = 'S08000005'.
if (prac ge '30006' and prac le '37999') hbpraccode = 'S08000006'.
do if ((prac ge '40008' and prac le '54994') or (prac eq 	'84990') or (prac ge '86000' and prac le '86999') or (prac ge '87000' and prac le '87999')
         or ((prac ge '85000' and prac le '85999') and  ((prac ne '85009') and (prac ne '85117') and (prac ne '85141') and (prac ne '85155') and (prac ne	'85193')))).
compute hbpraccode = 'S08000007'.
else.
end if.
execute.

do if ((prac ge '55003' and prac le '59998') or (prac ge '84000' and prac le '84989') or (prac eq	'85009') or (prac eq '85117') or (prac eq	'85141') or (prac eq '85155') or (prac eq	'85193')).
compute hbpraccode = 'S08000008'.
else.
end if.
execute.
if (prac ge '60001' and prac le '65999') hbpraccode = 'S08000009'.
if (prac ge '70003' and prac le '79991') hbpraccode = 'S08000010'.
if (prac ge '38008' and prac le '38991') hbpraccode = 'S08000011'.
if (prac ge '39001' and prac le '39994') hbpraccode = 'S08000012'.
if (prac ge '10002' and prac le '15990') hbpraccode = 'S08000013'.
if (prac ge '90007' and prac le '90991') hbpraccode = 'S08000014'.
frequency variables = hbpraccode.
alter type prac (a5).

temporary.
select if hbpraccode = ''.
frequency variables = prac.

* Recode GP Practice codes that begin 999 as unknown health board.

if (substr(prac,1,3) eq '999') hbpraccode = 'S08200003'.
execute.

if (prac eq '') hbpraccode = 'S08200003'.
execute.

rename variables (PatUPI PatGenderCode GeoPostcodeC NHSBoardofResidenceCodeCurrent GeoCouncilAreaCode 
                  PrimCauseofDeathCode4char SecCauseofDeath0Code4char SecCauseofDeath1Code4char
                  SecCauseofDeath2Code4char SecCauseofDeath3Code4char SecCauseofDeath4Code4char
                  SecCauseofDeath5Code4char SecCauseofDeath6Code4char SecCauseofDeath7Code4char
                  SecCauseofDeath8Code4char SecCauseofDeath9Code4char
                  PostMortemCode PlaceDeathOccurredCode DeathLocationCode NHSBoardofOccurrenceCodeCurrent
                = chi gender pc7 hbrescode lca
                  deathdiag1 deathdiag2 deathdiag3 
                  deathdiag4 deathdiag5 deathdiag6 
                  deathdiag7 deathdiag8 deathdiag9
                  deathdiag10 deathdiag11
                  post_mortem place_death_occurred death_location_code death_board_occurrence).


save outfile = !file + 'deaths_for_source-20' +!FY +'.sav'.

get file = !file + 'deaths_for_source-20' +!FY +'.sav'.



**** House keeping.
erase file  !file + 'deaths_extract_PLICS-20' +!FY +'.sav'.




