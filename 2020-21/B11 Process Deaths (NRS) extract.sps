* Encoding: UTF-8.
* Read in the deaths extract.  Rename/reformat/recode columns as appropriate.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA  /TYPE=TXT
    /FILE= !Year_Extracts_dir + 'NRS-death-registrations-extract-20' + !FY + '.csv'
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    PatUPI A10
    DateofDeath99 A10
    PatGenderCode F1.0
    PatDateOfBirthC A10
    GPpracticecode99 A5
    GeoCouncilAreaCode A2
    NHSBoardofResidenceCode A9
    GeoPostcodeC A8
    HSCPCode A9
    GeoDataZone2011 A9
    DeathLocationCode A5
    PrimCauseofDeathCode6char A6
    SecCauseofDeath0Code6char A6
    SecCauseofDeath1Code6char A6
    SecCauseofDeath2Code6char A6
    SecCauseofDeath3Code6char A6
    SecCauseofDeath4Code6char A6
    SecCauseofDeath5Code6char A6
    SecCauseofDeath6Code6char A6
    SecCauseofDeath7Code6char A6
    SecCauseofDeath8Code6char A6
    SecCauseofDeath9Code6char A6
    PostMortemCode A1
    PlaceDeathOccurredCode F1.0
    NHSBoardofOccurrenceCode A9
    UniqueRecordIdentifier A11.
CACHE.
Execute.

Rename Variables
    DeathLocationCode = death_location_code
    GeoCouncilAreaCode = lca
    GeoDataZone2011 = DataZone
    GeoPostcodeC = postcode
    HSCPCode = HSCP
    NHSBoardofOccurrenceCode = death_board_occurrence
    NHSBoardofResidenceCode = hbrescode
    PatDateofBirthC = dob
    PatGenderCode = gender
    PatUPI = chi
    PlaceDeathOccurredCode = place_death_occurred
    PostMortemCode = post_mortem
    PrimCauseofDeathCode6char = deathdiag1
    SecCauseofDeath0Code6char = deathdiag2
    SecCauseofDeath1Code6char = deathdiag3
    SecCauseofDeath2Code6char = deathdiag4
    SecCauseofDeath3Code6char = deathdiag5
    SecCauseofDeath4Code6char = deathdiag6
    SecCauseofDeath5Code6char = deathdiag7
    SecCauseofDeath6Code6char = deathdiag8
    SecCauseofDeath7Code6char = deathdiag9
    SecCauseofDeath8Code6char = deathdiag10
    SecCauseofDeath9Code6char = deathdiag11
    UniqueRecordIdentifier = uri
    gppracticecode99 = gpprac.

alter type dob dateofdeath99 (SDate10).
alter type dob (Date12).

Rename Variables dateofdeath99 = record_keydate1.
Numeric record_keydate2 (F8.0).
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = record_keydate1.
Alter type record_keydate1 (F8.0).

string recid (a3) year (a4).
compute recid = 'NRS'.
compute year = !FY.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

sort cases by chi.

Value Labels place_death_occurred
    '0' "Home"
    '1' "Farm"
    '2' "Mine/Quarry"
    '3' "Place of Industry"
    '4' "Sport/Recreation Area"
    '5' "Street/Highway"
    '6' "Public Building"
    '7' "Residential Institution"
    '8' "Other Specified Place"
    '9' "Unspecified".

Value Labels post_mortem
    '1' "Post mortem has been performed"
    '2' "Post mortem may be performed"
    '3' "Post mortem not proposed"
    '4' "Post mortem proposed and performed later"
    '5' "Post mortem proposed but no further information received"
    '6' "Post mortem not proposed but performed later".

 * Save the main file out for source.
save outfile = !Year_dir + 'deaths_for_source-20' + !FY + '.zsav'
    /zcompressed.

get file = !Year_dir + 'deaths_for_source-20' + !FY + '.zsav'.

 * zip up the raw data.
Host Command = ["gzip '" + !Year_Extracts_dir + "NRS-death-registrations-extract-20" + !FY + ".csv'"].
