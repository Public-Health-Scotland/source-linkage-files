* Encoding: UTF-8.
 * Run A01-Set up Macros first!.
 **************************************************************************************************
 * Build the Postcode lookup.

 * Start with the postcode directory and add all SIMD data.
match files
   /File = !PCDir
   /Table = !SIMDLookup
   /By PC7.

 * Sort by DataZone and then add on the localities.
sort cases by DataZone2011.
match files
   /File = * 
   /Table = !LocalitiesLookup
   /Rename (HSCPLocality = Locality)
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
save outfile = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
   /Rename (PC7 = postcode)
   /Keep Postcode HB2018 HSCP2018 CA2018 LCA Locality DataZone2011
      HB2019 CA2019 HSCP2019
      simd2020rank
      simd2020_sc_decile simd2020_sc_quintile
      simd2020_HB2019_decile simd2020_HB2019_quintile
      simd2020_HSCP2019_decile simd2020_HSCP2019_quintile
      UR8_2016 UR6_2016 UR3_2016 UR2_2016 
   /Zcompressed.

get file = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav".



