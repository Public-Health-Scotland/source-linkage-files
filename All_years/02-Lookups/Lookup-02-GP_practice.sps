* Encoding: UTF-8.
 * Run A01-Set up Macros first!.

 * Build the GPprac Lookup.
 * Using the R script '00_get_gp_cluster_data'.
 * This pulls from the open data platform.


 * Sort the national ref file by practice.
get file = !gpprac_Lookup
   /Keep praccode postcode end.

sort cases by praccode.

 * Match the cluster information onto the practice reference list.
 * This won't match all as cluster info is only added to currently active practices, we keep old practices as we can still add geography info to these.
match files
   /File = *
   /Rename (praccode = gpprac)
   /Table = !Lookup_dir_slf + "practice_details_" + !LatestUpdate + ".zsav"
   /by gpprac.

 * Fix the Locale -> Unicode issue.
alter type cluster (A50).
alter type postcode (A8).

 * Match on Geography info (the postcode from the ref file is PC8).
sort cases by Postcode.
match files
    /File = *
    /Rename Postcode = PC8
    /Table = !SPD_Lookup
    /Rename HB2018 = hbpraccode
    /By PC8.

 * Use CA2011 to produce the 2-char LCA codes.
String LCA (A2).

 * These macros are defined in A01, so this needs to be run before and in the same session as the following.
!CAtoLCA.

 * Set some known dummy practice codes to consistent Board codes.
Do if any(gpprac, 99942, 99957, 99961, 99976, 99981, 99999).
    Compute hbpraccode = "S08200003". /*Out-with Scotland / unknown*/.
Else if gpprac = 99995.
    Compute hbpraccode = "S08200001".  /*RUK*/.
End if.

 * Add dictionary info.
!AddLCADictionaryInfo LCA = LCA.
!AddHB2018DictionaryInfo HB = hbpraccode.

 * Sort by gpprac before saving.
Sort cases by gpprac.

 * Save out, rename HB2018 for source, keep LCA etc. for others (Andrew Mooney).
save outfile = !Lookup_dir_slf + "source_GPprac_lookup_" + !LatestUpdate + ".zsav"
   /Keep gpprac PC7 PC8 cluster hbpraccode HSCP2018 CA2018 LCA
   /zcompressed.

get file = !Lookup_dir_slf + "source_GPprac_lookup_" + !LatestUpdate + ".zsav".
