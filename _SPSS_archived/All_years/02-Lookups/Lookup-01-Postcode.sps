﻿* Encoding: UTF-8.
 * Run A01a - Set up Universal Macros and A01b Set up (year) Macros first!.
 **************************************************************************************************
 * Build the Postcode lookup.

 * Start with the postcode directory and add all SIMD data.
match files
   /File = !SPD_Lookup
   /Table = !SIMD_Lookup
   /By PC7.

 * Sort by DataZone and then add on the localities.
sort cases by DataZone2011.
match files
   /File = * 
   /Table = !Localities_Lookup
   /Rename (hscp_locality = Locality)
   /Drop ca2019name hscp2019name hb2019name
   /By Datazone2011.

Recode Locality ("" = "No Locality Information").

 * Use Council Area variable to produce the 2-char LCA codes.
String LCA (A2).
!CAtoLCA.
!AddLCADictionaryInfo LCA = LCA.

 * Add Variable labels.
Variable Labels
    LCA "Local Council Authority"
    Locality "HSCP Locality. Based on postcode and are correct at time of update".

 * Sort back to PC7 so it can be matched later.
sort cases by PC7.

 * Save out, only keep the variables we need and rename PC7.
save outfile = !Lookup_dir_slf + "source_postcode_lookup_" + !LatestUpdate + ".zsav"
   /Rename (PC7 = postcode)
   /Keep Postcode HB2018 HSCP2018 CA2018 LCA Locality DataZone2011
      HB2019 CA2019 HSCP2019
      simd2020v2_rank
      simd2020v2_sc_decile simd2020v2_sc_quintile
      simd2020v2_hb2019_decile simd2020v2_hb2019_quintile
      simd2020v2_hscp2019_decile simd2020v2_hscp2019_quintile
      UR8_2020 UR6_2020 UR3_2020 UR2_2020 
   /Zcompressed.

get file = !Lookup_dir_slf + "source_postcode_lookup_" + !LatestUpdate + ".zsav".
