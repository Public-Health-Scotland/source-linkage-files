* Encoding: UTF-8.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.
*This should unzip the PIS extract in the IT extract directory.
*The Macro !Extract_Number can be found in A01b 'Year' Macro and the number should be specific to FY. 
*!Extract_Number should be changed to the relevant number.
Host Command = ["gunzip '" + !PIS_extract_file + "'"].

GET DATA  /TYPE=TXT
    /FILE=!PIS_extract_file
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=3
    /VARIABLES=
    PatUPI A10
    PatDoB EDATE10
    PatGender F1.0
    PatPostcode A8
    PracticeCode A6
    NumberofDispensedItems F2.0
    DIPaidNICexcl.BB F6.2
    DIPaidGICexcl.BB F6.2
    /MAP.
CACHE.
EXECUTE.

rename variables
    PatUPI = chi
    PatDoB = dob
    PatGender = gender
    PatPostcode = postcode
    PracticeCode = gpprac
    NumberofDispensedItems = no_dispensed_items
    DIPaidNICexcl.BB = cost_total_net.

select if chi ne "".

* Recode GP Practice into a 5 digit number.
* We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
    Compute gpprac = "99995".
End if.
Alter Type GPprac (F5.0).

* Set date to the end of the FY.
numeric record_keydate1 record_keydate2 (F8.0).
compute record_keydate1 = ((Number(!altFY, F4.0) + 1) * 10000) + 0331.
compute record_keydate2 = record_keydate1.

string recid (A3) year (A4).
compute recid = "PIS".
compute year = !FY.

sort cases by chi.

save outfile = !Year_dir + "prescribing_file_for_source-20" + !FY + ".zsav"
    /Drop DIPaidGICexcl.BB
    /zcompressed.

get file = !Year_dir + "prescribing_file_for_source-20" + !FY + ".zsav".

* zip raw data back up.
Host Command = ["gzip '" + !PIS_extract_file + "'"].

