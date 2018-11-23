* Encoding: UTF-8.
 * Run 01-Set up Macros first!.

CD "/conf/linkage/output/lookups/Unicode".

 * Most up to date Postcode directory.
Define !PCDir()
   "Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2018_2.sav"
!EndDefine.

 * Most up to date SIMD / Postcode lookup.
Define !SIMDLookup()
   "Deprivation/postcode_2018_2_simd2016.sav"
!EndDefine.

 * Most up to date Urban-Rural / Postcode lookup.
Define !URLookup()
   "Geography/Urban Rural Classification/postcode_urban_rural_2016.sav"
!EndDefine.

Define !CA2011toLCA()
Do if ValueLabel(CA2011) = "Aberdeen City".
   Compute LCA = "01".
Else if ValueLabel(CA2011) = "Aberdeenshire".
   Compute LCA = "02".
Else if ValueLabel(CA2011) = "Angus".
   Compute LCA = "03".
Else if ValueLabel(CA2011) = "Argyll and Bute".
   Compute LCA = "04".
Else if ValueLabel(CA2011) = "Scottish Borders".
   Compute LCA = "05".
Else if ValueLabel(CA2011) = "Clackmannanshire".
   Compute LCA = "06".
Else if ValueLabel(CA2011) = "West Dunbartonshire".
   Compute LCA = "07".
Else if ValueLabel(CA2011) = "Dumfries and Galloway".
   Compute LCA = "08".
Else if ValueLabel(CA2011) = "Dundee City".
   Compute LCA = "09".
Else if ValueLabel(CA2011) = "East Ayrshire".
   Compute LCA = "10".
Else if ValueLabel(CA2011) = "East Dunbartonshire".
   Compute LCA = "11".
Else if ValueLabel(CA2011) = "East Lothian".
   Compute LCA = "12".
Else if ValueLabel(CA2011) = "East Renfrewshire".
   Compute LCA = "13".
Else if ValueLabel(CA2011) = "City of Edinburgh".
   Compute LCA = "14".
Else if ValueLabel(CA2011) = "Falkirk".
   Compute LCA = "15".
Else if ValueLabel(CA2011) = "Fife".
   Compute LCA = "16".
Else if ValueLabel(CA2011) = "Glasgow City".
   Compute LCA = "17".
Else if ValueLabel(CA2011) = "Highland".
   Compute LCA = "18".
Else if ValueLabel(CA2011) = "Inverclyde".
   Compute LCA = "19".
Else if ValueLabel(CA2011) = "Midlothian".
   Compute LCA = "20".
Else if ValueLabel(CA2011) = "Moray".
   Compute LCA = "21".
Else if ValueLabel(CA2011) = "North Ayrshire".
   Compute LCA = "22".
Else if ValueLabel(CA2011) = "North Lanarkshire".
   Compute LCA = "23".
Else if ValueLabel(CA2011) = "Orkney Islands".
   Compute LCA = "24".
Else if ValueLabel(CA2011) = "Perth and Kinross".
   Compute LCA = "25".
Else if ValueLabel(CA2011) = "Renfrewshire".
   Compute LCA = "26".
Else if ValueLabel(CA2011) = "Shetland Islands".
   Compute LCA = "27".
Else if ValueLabel(CA2011) = "South Ayrshire".
   Compute LCA = "28".
Else if ValueLabel(CA2011) = "South Lanarkshire".
   Compute LCA = "29".
Else if ValueLabel(CA2011) = "Stirling".
   Compute LCA = "30".
Else if ValueLabel(CA2011) = "West Lothian".
   Compute LCA = "31".
Else if ValueLabel(CA2011) = "Na h-Eileanan Siar".
   Compute LCA = "32".
End If.
!EndDefine.

Define !AddLCADictionaryInfo (LCA = !CMDEND)
   Value Labels !LCA
      '01' "Aberdeen City"
      '02' "Aberdeenshire"
      '03' "Angus"
      '04' "Argyll and Bute"
      '05' "Scottish Borders"
      '06' "Clackmannanshire"
      '07' "West Dunbartonshire"
      '08' "Dumfries and Galloway"
      '09' "Dundee City"
      '10' "East Ayrshire"
      '11' "East Dunbartonshire"
      '12' "East Lothian"
      '13' "East Renfrewshire"
      '14' "City of Edinburgh"
      '15' "Falkirk"
      '16' "Fife"
      '17' "Glasgow City"
      '18' "Highland"
      '19' "Inverclyde"
      '20' "Midlothian"
      '21' "Moray"
      '22' "North Ayrshire"
      '23' "North Lanarkshire"
      '24' "Orkney Islands"
      '25' "Perth and Kinross"
      '26' "Renfrewshire"
      '27' "Shetland Islands"
      '28' "South Ayrshire"
      '29' "South Lanarkshire"
      '30' "Stirling"
      '31' "West Lothian"
      '32' "Na h-Eileanan Siar"
!EndDefine.
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
   /Table = !Lookup + "01-locality/Locality_lookup_source.sav"
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



