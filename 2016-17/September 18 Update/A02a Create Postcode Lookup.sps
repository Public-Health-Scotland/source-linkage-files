* Encoding: UTF-8.
 * Run A01-Set up Macros first!.

 **************************************************************************************************
 * Build the Postcode lookup.

 * Start with the postcode directory and add all SIMD data.
match files
   /File = !PCDir
   /Table = !SIMDLookup
   /By PC7.

 * Add on Urban Rural Classifications.
match files
   /File = *
   /Table = !URLookup
   /By PC8.

 * Sort by DataZone and then add on the localities.
sort cases by DataZone2011.
match files
   /File = * 
   /Table = !LocalitiesLookup
   /Rename (DataZone = DataZone2011)
   /By Datazone2011.

if locality = "" locality = "No Locality Information".

 * Use CA2011 to produce the 2-char LCA codes.
String LCA (A2).
!CA2011toLCA.
!AddLCADictionaryInfo LCA = LCA.

 * Sort back to PC7 so it can be matched later.
sort cases by PC7.

 * Save out, only keep the variables we need and rename PC7.
save outfile = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
   /Rename (PC7 = postcode)
   /Keep Postcode HB2014 HSCP2016 CA2011 LCA Locality DataZone2011
      SIMD2016rank
      simd2016_sc_decile simd2016_sc_quintile
      simd2016_HB2014_decile simd2016_HB2014_quintile
      simd2016_HSCP2016_decile simd2016_HSCP2016_quintile
      UR8_2016 UR6_2016 UR3_2016 UR2_2016 
   /Zcompressed.

get file = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav".



