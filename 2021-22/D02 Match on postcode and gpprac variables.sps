* Encoding: UTF-8.
get file = !Year_dir + "temp-source-individual-file-2-20" + !FY + ".zsav".

* Match on postcode stuff.
Sort Cases by postcode.

*Apply consistent geographies.
match files file = *
    /table = !Lookup_dir_slf + "source_postcode_lookup_" + !LatestUpdate + ".zsav"
    /Rename (HB2018 = hbrescode)
    /by postcode.

*****************************************************************************************.
********* Match in GP practice and cluster info. **********************************.
sort cases by gpprac.

match files file = *
    /table = !Lookup_dir_slf + "source_GPprac_lookup_" + !LatestUpdate + ".zsav"
    /Drop PC7 PC8
    /by gpprac.

 * Set some known dummy practice codes to consistent Board codes.
Do if any(gpprac, 99942, 99957, 99961, 99976, 99981, 99999).
    Compute hbpraccode = "S08200003". /*Out-with Scotland / unknown*/.
Else if gpprac = 99995.
    Compute hbpraccode = "S08200001".  /*RUK*/.
End if.

 * Add dummy codes etc.
!AddHB2018DictionaryInfo HB = hbrescode hbpraccode.
!AddHB2019DictionaryInfo HB = HB2019.

sort cases by chi.

save outfile = !Year_dir + "temp-source-individual-file-3-20" + !FY + ".zsav"
   /zcompressed.

get file = !Year_dir + "temp-source-individual-file-3-20" + !FY + ".zsav".
