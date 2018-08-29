Define !Year()
   "1617"
!EndDefine.

get file = !file + 'source-episode-file-20'+ !FY + '.zsav'.

Compute gpprac = ltrim(gpprac).
alter type gpprac (a5).

sort cases by gpprac.

match files file = *
   /table =  '/conf/irf/11-Development team/Dev08-Pathways/Tableau Matrix/3. Data/Lookup/PracticeDetailsUpdated.sav'
   /by gpprac.


if cluster = '' cluster = 'Unknown'.

String datazonetemp (A9).

Do if lca = '32'.
   Compute datazonetemp = DATAZONE2001.
Else if lca = '18'.
   Compute datazonetemp = 'NULL'.
Else.
   Compute datazonetemp = DataZone2011.
End If.

sort cases by datazonetemp.

match files file = *
   /table = '/conf/irf/05-lookups/04-geography/01-locality/Locality_lookup_source.sav'
   /Rename(datazone = datazonetemp)
   /by datazonetemp.

if locality = '' locality = 'No Locality Information'.

sort cases by CHI record_keydate1 record_keydate2.

save outfile = !file + 'source-episode-file-20'+ !FY + '.zsav'
   /drop partnership datazonetemp
   /zcompressed.


*****************************************************************
   *Same for individual file.
get file = !file + 'source-individual-file-20' + !FY + '.zsav'.

sort cases by gpprac.

match files file = *
   /table =  '/conf/irf/11-Development team/Dev08-Pathways/Tableau Matrix/3. Data/Lookup/PracticeDetailsUpdated.sav'
   /by gpprac.

if cluster = '' cluster = 'Unknown'.

String datazonetemp (A9).

Do if lca = '32'.
   Compute datazonetemp = DATAZONE2001.
Else if lca = '18'.
   Compute datazonetemp = 'NULL'.
Else.
   Compute datazonetemp = DataZone2011.
End If.

sort cases by datazonetemp.

match files file = *
   /table = '/conf/irf/05-lookups/04-geography/01-locality/Locality_lookup_source.sav'
   /Rename(datazone = datazonetemp)
   /by datazonetemp.

if locality = '' locality = 'No Locality Information'.

sort cases by CHI.

save outfile = !file + 'source-individual-file-20' + !FY + '.zsav'
   /drop partnership datazonetemp
   /zcompressed.
