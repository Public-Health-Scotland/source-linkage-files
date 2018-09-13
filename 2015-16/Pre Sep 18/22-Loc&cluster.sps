get file = '/conf/acnd_testing/source-episode-file-201516.sav'.

*rename variables health_postcode = pc7.

rename variables prac = gpprac.
alter type gpprac (A5).

sort cases by gpprac.

match files file = * 
 /table =  '/conf/irf/11-Development team/Dev08-Pathways/Tableau Matrix/3. Data/Lookup/PracticeDetailsUpdated.sav'
 /by gpprac.
execute.

rename variables gpprac = prac.
alter type prac (A6).

if cluster = '' flag = 1.
execute.

if flag = 1 cluster = 'Unknown'.
execute.

string datazonetemp (A9).
compute datazonetemp = datazone.
execute.

if lca = '32' datazonetemp = DATAZONE2001.
if lca = '18' datazonetemp = 'NULL'.
execute.

rename variables datazone = datazonekeep.
rename variables datazonetemp = datazone.
sort cases by datazone.

match files file = *
 /table = '/conf/irf/05-lookups/04-geography/01-locality/locality_lookup_update.sav'
 /by datazone.
execute.

if locality = '' locality = 'No Locality Information'.
execute.

rename variables datazone = datazonedrop.
rename variables datazonekeep = datazone.

sort cases by CHI record_keydate1 record_keydate2.

save outfile = '/conf/acnd_testing/source-episode-file-201516.sav'
 /drop partnership datazonedrop flag. 

get file = '/conf/acnd_testing/source-episode-file-201516.sav'.
*****************************************************************
*Same for individual file. 


get file = '/conf/irf/11-Development team/Dev00-PLICS-files/2016-17/source-individual-file-201617.sav'.

*rename variables health_postcode = pc7.

rename variables (datazone = datazone2011).

sort cases by gpprac.

match files file = * 
 /table =  '/conf/irf/11-Development team/Dev08-Pathways/Tableau Matrix/3. Data/Lookup/PracticeDetailsUpdated.sav'
 /by gpprac.
execute.

if cluster = '' flag = 1.
execute.

if flag = 1 cluster = 'Unknown'.
execute.

String datazone (A9).
compute datazone = datazone2011.
execute.

do if lca = '32'.
compute datazone = DATAZONE2001.
end if.
execute.

if lca = '18' datazone = 'NULL'.
execute.

sort cases by datazone.

match files file = *
 /table = '/conf/irf/05-lookups/04-geography/01-locality/locality_lookup_update.sav'
 /by datazone.
execute.

if locality = '' locality = 'No Locality Information'.
execute.

sort cases by CHI.

save outfile = '/conf/sourcedev/source-individual-file-201516.sav'
 /drop partnership datazone flag. 


