* Encoding: UTF-8.
 * Run 01-Set up Macros first!.

CD "/conf/linkage/output/lookups/Unicode". 

 * Build the GPprac Lookup.
 * Email NSS.isdGeneralPractice asking for an updated GP Clusters file (Practice Details.sav)
 * Save the Cluster file to \\stats\irf\05-lookups\04-geography\Practice Details.sav.

 * Check the file from Primary care team is sorted by practice.
get file = !Lookup + "Practice Details.sav".
sort cases by Practice.
save outfile = !Lookup + "Practice Details.sav".

 * Sort the national ref file by practice.
get file = "National Reference Files/gpprac.sav"
   /Keep praccode postcode end.

sort cases by praccode.

 * Match the cluster information onto the practice reference list.
 * This won't match all as cluster info is only added to currently active practices, we keep old practices as we can still add geography info to these.
match files
   /File = *
   /Rename (praccode = gpprac)
   /Table = !Lookup + "Practice Details.sav"
   /Rename (practice = gpprac)
   /by gpprac.
exe.
 * Fix the Locale -> Unicode issue.
alter type cluster (A50).

 * Match on Geography info (the postcode from the ref file is PC8).
sort cases by Postcode.
match files
   /File = * 
   /Rename (Postcode = PC8)
   /Table = !PCDir
   /By PC8.
exe.
 * Use CA2011 to produce the 2-char LCA codes.
String LCA (A2).
 * These macros are defined in A02a, so this needs to be run before and in the same session as the following.
!CA2011toLCA.
!AddLCADictionaryInfo LCA = LCA.

 * Sort by gpprac before saving.
Sort cases by gpprac.

 * Save out, rename HB2014 for source, keep LCA etc. for others (Andrew Mooney).
save outfile = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav"
   /Rename (HB2014 = hbpraccode)
   /Keep gpprac PC7 PC8 cluster hbpraccode HSCP2016 CA2011 LCA
   /zcompressed.

get file = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav".


