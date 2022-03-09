* Encoding: UTF-8.
********************************************************************************************************************************
* Match on the non-service-user CHIs.
********************************************************************************************************************************
* Needs to be matched on like this to ensure no CHIs are marked as NSU when we already have activity for them.
* Get a warning about duplicate key here but should be fine.
* Caused by the way we match on NSUs, if an 'NSU' is already in the file, and has more than one record, that's the duplicate.
* Gender not available in 1718 NSU extract - Add this back in when we get the new extract.
* gender = chi_gender.
match files
    /file = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav"
    /file = !NSU_dir + "All_CHIs_20" + !FY + ".zsav"
    /rename postcode = chi_postcode gpprac = chi_gpprac dob = chi_dob 
    /In = has_chi_data
    /By chi.

* Set up the variables for the NSU CHIs.
Do if recid = "".
    Compute year = !FY.
    Compute recid = "NSU".
    Compute SMRType = "Non-User".
    Compute postcode = chi_postcode. 
    Compute gpprac = chi_gpprac.
    Compute dob = chi_dob.
*    Compute gender = chi_gender.
* Fill in any other missing data from the CHI file.
Else if has_chi_data.
    If postcode = "" postcode = chi_postcode. 
    If sysmiss(gpprac) gpprac = chi_gpprac.
    If sysmiss(dob) dob = chi_dob.
 *   If sysmiss(gender) gender = chi_gender.
End if.

* save next temp file.
* add back into drop - chi_gender.
save outfile = !Year_dir + "temp-source-episode-file-4-" + !FY + ".zsav"
    /Drop has_chi_data chi_postcode chi_gpprac chi_dob 
    /zcompressed.
