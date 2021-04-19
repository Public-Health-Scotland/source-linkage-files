* Encoding: UTF-8.
Define !sc_extracts()
    "/conf/social-care/05-Analysts/All Sandpit Extracts/"
!EndDefine.

* Get demographics extract.
* This will be changed to an SQL extract from the new platform in the future.
get file = !sc_extracts + "DEMOG/DEMOG_allyears.zsav"
    /Keep latest_record extract_date sending_location social_care_id
    submitted_chi_number upi
    submitted_postcode chi_postcode 
    submitted_date_of_birth chi_date_of_birth
    submitted_gender chi_gender_code.
* Cosmetic.
Variable width ALL (15).

* Fix string lengths and convert gender to numeric.
Alter type
    upi (A10)
    submitted_gender chi_gender_code (F2.0)
    sending_location (A3)
    submitted_date_of_birth chi_date_of_birth (date11)
    social_care_id (A10).

* Create new variables which will hold the 'final' data.
String postcode (A7).
Numeric
    gender (F1.0)
    dob (DATE11).

* Compare the values for submitted and CHI matched for gender dob and postcode.
* Clean up some gender codes.
if submitted_gender = 99 submitted_gender = 9.
* For gender prefer CHI match if we have it.
compute gender = chi_gender_code.
if sysmis(chi_gender_code) or any(chi_gender_code, 0, 9) gender = submitted_gender.

* For dob prefer CHI match if we have it.
compute dob = chi_date_of_birth.
if sysmis(chi_date_of_birth) dob = submitted_date_of_birth.

* Match to the Scottish Postcode Directory to determine if the submitted postcodes are valid.
Do repeat pc = submitted_postcode chi_postcode.
    * Correct Postcode formatting.
    * Remove any postcodes which are length less than 5 as these can not be valid (not a useful dummy either).
    If Length(pc) < 5 pc = "".

    * Remove spaces which deals with any 8-char postcodes.
    Compute Postcode = Replace(pc, " ", "").
    * If any postcodes are now 8 or longer, these are invalid.
    If Length(pc) >= 8 pc = "".

    * Add spaces to create a 7-char postcode.
    Loop if range(Length(pc), 5, 6).
        Compute #current_length = Length(pc).
        Compute pc = Concat(char.substr(pc, 1,  #current_length - 3), " ", char.substr(pc,  #current_length - 2, 3)).
    End Loop.

    * Remove dummy postcodes.
    If any(pc, "NF1 1AB", "NK1 0AA") pc = "".
End repeat.

alter type submitted_postcode chi_postcode (A7).

sort cases by submitted_postcode.

match files file = *
    /table = !PCDir
    /Rename pc7 = submitted_postcode
    /In = Valid_PC
    /Keep latest_record extract_date sending_location social_care_id upi gender dob postcode submitted_postcode chi_postcode
    /By submitted_postcode.

String postcode_type (A100).
* If the submitted postcode is valid keep it, otherwise use the postcode from CHI.
* Note that we might lose some valid non-Scottish postcodes here.
Do if Valid_PC = 1.
    Compute postcode_type = "submitted - valid".
    Compute postcode = submitted_postcode.
Else if chi_postcode NE "".
    Compute postcode_type = "CHI".
    Compute postcode = chi_postcode.
Else.
    Compute postcode_type = "submitted - invalid".
    Compute postcode = submitted_postcode.
End if.
If postcode = "" postcode_type = "missing".

* Sort so that the latest submissions are last.
sort cases by sending_location social_care_id latest_record extract_date.

* Set blank values for upi and postcode to be missing.
* This means they will be ignored on the aggregate.
* This is important as some people have successful linkage on one record but not on the latest one (e.g. postcode was missing etc.).
Missing values upi postcode ("").

* Aggregate to create one row per sending_location / ID - Note that a CHI could appear more than once if they appear in multiple LCA's data.
aggregate outfile = *
    /presorted
    /break sending_location social_care_id
    /chi = last(upi)
    /gender = last(gender)
    /dob = last(dob)
    /postcode = last(postcode).

 * Set postcode to A8 for correct matching with SLFs.
Alter type postcode (A8).

*  Save to be used in other Social Care processing.
save outfile = !Extracts_Alt + "Social Care Demographics lookup.zsav"
    /zcompressed.
get file =  !Extracts_Alt + "Social Care Demographics lookup.zsav".






