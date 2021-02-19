* Encoding: UTF-8.
Define !sc_extracts()
    "/conf/social-care/05-Analysts/All Sandpit Extracts/"
!EndDefine.

* Get demographics extract.
* This will be changed to an SQL extract from the new platform in the future.
get file = !sc_extracts + "DEMOG/DEMOG_allyears.zsav"
    /Keep latest_record extract_date sending_location social_care_id submitted_chi_number
    submitted_postcode submitted_date_of_birth submitted_gender submitted_chi_number
    upi chi_date_of_birth chi_gender_code chi_postcode.
cache.
* Cosmetic.
Variable width ALL (15).

* Fix string lengths and convert gender to numeric.
Alter type
    upi (A10)
    submitted_postcode (A7)
    submitted_gender chi_gender_code (F1.0).

* Create new variables which will hold the 'final' data.
String postcode (A7).
Numeric
    gender (F1.0)
    dob (DATE11).

* Compare the values for submitted and CHI matched for gender dob and postcode.

* For gender prefer CHI match if we have it.
Do if sysmis(chi_gender_code).
    compute gender = submitted_gender.
Else.
    compute gender = chi_gender_code.
End if.

* For dob prefer CHI match if we have it.
Do if sysmis(chi_date_of_birth).
    compute dob = submitted_date_of_birth.
Else.
    compute dob = chi_date_of_birth.
End if.

* Match to the Scottish Postcode Directory to determine if the submitted postcodes are valid.
sort cases by submitted_postcode.

match files file = *
    /table = !PCDir
    /Rename pc7 = submitted_postcode
    /In = Valid_PC
    /Keep latest_record extract_date sending_location social_care_id upi gender dob postcode submitted_postcode chi_postcode
    /By submitted_postcode.

* If the submitted postcode is valid keep it, otherwise use the postcode from CHI.
* Note that we might lose some valid non-Scottish postcodes here.
Do if Valid_PC = 1.
    Compute postcode = submitted_postcode.
Else.
    Compute postcode = chi_postcode.
End if.

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

*  Save to be used in other Social Care processing.
save outfile = !Extracts_Alt + "Social Care Demographics lookup.zsav"
    /zcompressed.






