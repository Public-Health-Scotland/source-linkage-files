* Produce NRS deaths extract in suitable format for PLICS.
* Modified version of previous read in files used to create NRS data for PLICS. 

* Read in the deaths extract.  Rename/reformat/recode columns as appropriate. 

* Progam by Denise Hastie, July 2016.

* Create macros for file path.

******************************* **** UPDATE THIS BIT **** *************************************.
********************************************************************************************************.
* Create macros for file path.

define !file()
   '/conf/sourcedev/Anita_temp/'
!enddefine.

* Extract files - 'home'.
define !Extracts()
   '/conf/hscdiip/DH-Extract/patient-reference-files'
!enddefine.

*define macro for FY.
define !FY()
   '1718'
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


save outfile = !file + 'deaths_extract_PLICS-20' +!FY +'.zsav'
   /zcompressed.

get file = !file + 'deaths_extract_PLICS-20' + !FY +'.zsav'.

string record_keydate1 record_keydate2 dob (a8).
compute record_keydate1 = concat(substr(dateofdeath99,1,4),substr(dateofdeath99,6,2),substr(dateofdeath99,9,2)).
compute dob = concat(substr(PatDateOfBirthC,1,4),substr(PatDateOfBirthC,6,2),substr(PatDateOfBirthC,9,2)).
compute record_keydate2 = record_keydate1.

alter type record_keydate1 record_keydate2 dob (f8.0).

string recid (a3) year (a4).
compute recid = 'NRS'.
compute year = !FY.

rename variables (gppracticecode99 = prac).

* These are correct as of May 2018 JMc.
string hbpraccode (a9).
Do If (prac GE '80005' AND prac LE '83997').
   Compute hbpraccode = 'S08000015'.
Else If (prac GE '16009' AND prac LE '17995').
   Compute hbpraccode = 'S08000016'.
Else If (prac GE '18004' AND prac LE '19991').
   Compute hbpraccode = 'S08000017'.
Else If (prac GE '20004' AND prac LE '24999').
   Compute hbpraccode = 'S08000029'.
Else If (prac GE '25008' AND prac LE '29992').
   Compute hbpraccode = 'S08000019'.
Else If (prac GE '30006' AND prac LE '37999').
   Compute hbpraccode = 'S08000020'.
Else if ((prac GE '40008' AND prac LE '54994') OR (prac EQ 	'84990') OR (prac GE '86000' AND prac LE '86999') OR (prac GE '87000' AND prac LE '87999')
   OR ((prac GE '85000' AND prac LE '85999') AND  ((prac NE '85009') AND (prac NE '85117') AND (prac NE '85141') AND (prac NE '85155') AND (prac NE '85193')))).
   Compute hbpraccode = 'S08000021'.
Else if ((prac GE '55003' AND prac LE '59998') OR (prac GE '84000' AND prac LE '84989') OR (prac EQ '85009') OR (prac EQ '85117') OR (prac EQ '85141') OR (prac EQ '85155') OR (prac EQ '85193')).
   Compute hbpraccode = 'S08000022'.
Else If (prac GE '60001' AND prac LE '65999').
   Compute hbpraccode = 'S08000023'.
Else If (prac GE '70003' AND prac LE '79991').
   Compute hbpraccode = 'S08000024'.
Else If (prac GE '38008' AND prac LE '38991').
   Compute hbpraccode = 'S08000025'.
Else If (prac GE '39001' AND prac LE '39994').
   Compute hbpraccode = 'S08000026'.
Else If (prac GE '10002' AND prac LE '15990').
   Compute hbpraccode = 'S08000030'.
Else If (prac GE '90007' AND prac LE '90991').
   Compute hbpraccode = 'S08000028'.
End If.

alter type prac (a6).

* Set hbpraccode for GP Practice codes that begin 999 as unknown health board.
if (substr(prac,1,3) eq '999') hbpraccode = 'S08200003'.

* Set hbpraccode for GP Practice codes that are blank as unknown health board.
if (prac eq '') hbpraccode = 'S08200003'.


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


save outfile = !file + 'deaths_for_source-20' +!FY +'.zsav'
   /zcompressed.

get file = !file + 'deaths_for_source-20' +!FY +'.zsav'.


**** House keeping.
erase file  !file + 'deaths_extract_PLICS-20' +!FY +'.zsav'.

