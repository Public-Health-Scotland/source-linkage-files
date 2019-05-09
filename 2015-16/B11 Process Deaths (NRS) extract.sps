* Encoding: UTF-8.
* Produce NRS deaths extract in suitable format for PLICS.
* Modified version of previous read in files used to create NRS data for PLICS.

* Read in the deaths extract.  Rename/reformat/recode columns as appropriate.

* Program by Denise Hastie, July 2016.


********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA  /TYPE=TXT
    /FILE= !Extracts + 'NRS-death-registrations-extract-20' + !FY + '.csv'
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    PatUPI A10
    DateofDeath99 A10
    DateDeathRegistered99 A10
    PatGenderCode F1.0
    PatDateOfBirthC A10
    GPpracticecode99 A5
    GeoCouncilAreaCode A2
    NHSBoardofResidenceCode A9
    GeoPostcodeC A7
    HSCPCode A9
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
    PlaceDeathOccurredCode F1.0
    NHSBoardofOccurrenceCode A9
    UniqueRecordIdentifier A8.
CACHE.

Rename Variables
    PatDateofBirthC = dob
    DateDeathRegistered99 = Datedeath_GRO.

alter type dob Datedeath_GRO (SDate10).
alter type dob Datedeath_GRO (Date12).

Numeric record_keydate1 record_keydate2 (F8.0).
compute record_keydate1 = Number(concat(char.substr(dateofdeath99, 1, 4), char.substr(dateofdeath99, 6, 2), char.substr(dateofdeath99, 9, 2)), F8.0).
compute record_keydate2 = record_keydate1.

string recid (a3) year (a4).
compute recid = 'NRS'.
compute year = !FY.

rename variables
    PatUPI = chi
    PatGenderCode = gender
    GeoPostcodeC = postcode
    NHSBoardofResidenceCode = hbrescode
    GeoCouncilAreaCode = lca
    HSCPCode = HSCP
    GeoDataZone2011 = DataZone
    PrimCauseofDeathCode4char = deathdiag1
    SecCauseofDeath0Code4char = deathdiag2
    SecCauseofDeath1Code4char = deathdiag3
    SecCauseofDeath2Code4char = deathdiag4
    SecCauseofDeath3Code4char = deathdiag5
    SecCauseofDeath4Code4char = deathdiag6
    SecCauseofDeath5Code4char = deathdiag7
    SecCauseofDeath6Code4char = deathdiag8
    SecCauseofDeath7Code4char = deathdiag9
    SecCauseofDeath8Code4char = deathdiag10
    SecCauseofDeath9Code4char = deathdiag11
    PostMortemCode = post_mortem
    PlaceDeathOccurredCode = place_death_occurred
    DeathLocationCode = death_location_code
    NHSBoardofOccurrenceCode = death_board_occurrence
    gppracticecode99 = gpprac
    UniqueRecordIdentifier = uri.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

sort cases by chi.

 * Save the main file out for source.
save outfile = !file + 'deaths_for_source-20' + !FY + '.zsav'
    /Drop Datedeath_GRO
    /zcompressed.

********************************************.
 * Save out the extra file to fix dates if needed.
 * Only keep dates in this FY.
Select if Datedeath_GRO GE Date.DMY(1, 4, Number(!altFY, F4.0)).

aggregate outfile = *
   /Break chi
   /Datedeath_GRO = Max(Datedeath_GRO).

Select if CHI ne "".

save outfile = !File + "Death_Date_Registered-20" + !FY + ".zsav"
   /zcompressed.

get file = !File + "Death_Date_Registered-20" + !FY + ".zsav".
*******************************************

get file = !file + 'deaths_for_source-20' + !FY + '.zsav'.

 * zip up the raw data.
Host Command = ["gzip '" + !Extracts + "NRS-death-registrations-extract-20" + !FY + ".csv'"].
