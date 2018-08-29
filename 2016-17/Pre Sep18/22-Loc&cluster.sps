get file = '/conf/sourcedev/source-episode-file-201617.sav'.

*rename variables health_postcode = pc7.

rename variables prac = gpprac.
alter type gpprac (A5).
exe.

sort cases by gpprac.

match files file = * 
 /table =  '/conf/irf/11-Development team/Dev08-Pathways/Tableau Matrix/3. Data/Lookup/PracticeDetailsUpdated.sav'
 /by gpprac.
EXECUTE.

rename variables gpprac = prac.
alter type prac (A6).


if cluster = '' flag = 1.
execute.
if flag = 1 cluster = 'Unknown'.
execute.

String datazonetemp (A9).
compute datazonetemp = datazone.
execute.

do if lca = '32'.
 compute datazonetemp = DATAZONE2001.
end if.
EXECUTE.

if lca = '18' datazonetemp = 'NULL'.
EXECUTE.

rename variables datazone = datazonekeep.
rename variables datazonetemp = datazone.
sort cases by datazone.

match files file = *
 /table = '/conf/irf/05-lookups/04-geography/01-locality/locality_lookup_update.sav'
 /by datazone.
EXECUTE.

if locality = '' locality = 'No Locality Information'.
execute.

rename variables datazone = datazonedrop.
rename variables datazonekeep = datazone.

sort cases by CHI record_keydate1 record_keydate2.

save outfile = '/conf/sourcedev/source-episode-file-201617.sav'
 /drop partnership datazonedrop flag. 


*****************************************************************
*Same for individual file. 


get file = '/conf/irf/11-Development team/Dev00-PLICS-files/2016-17/source-individual-file-201617.sav'.

*rename variables health_postcode = pc7.

sort cases by gpprac.

match files file = * 
 /table =  '/conf/irf/11-Development team/Dev08-Pathways/Tableau Matrix/3. Data/Lookup/PracticeDetailsUpdated.sav'
 /by gpprac.
EXECUTE.

if cluster = '' flag = 1.
exe. 

if flag = 1 cluster = 'Unknown'.
exe.

String datazone (A9).
compute datazone = datazone2011.
exe.

do if lca = '32'.
 compute datazone = DATAZONE2001.
end if.
EXECUTE.

if lca = '18' datazone = 'NULL'.
EXECUTE.

sort cases by datazone.

match files file = *
 /table = '/conf/irf/05-lookups/04-geography/01-locality/locality_lookup_update.sav'
 /by datazone.
EXECUTE.

if locality = '' locality = 'No Locality Information'.
execute.

sort cases by CHI.

save outfile = '/conf/irf/11-Development team/Dev00-PLICS-files/2016-17/source-individual-file-201617.sav'
 /drop partnership datazone flag. 
