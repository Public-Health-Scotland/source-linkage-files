*Last ran 18/5/18-AnitaGeorge.
define !file()
'/conf/sourcedev/Anita_temp/'
!enddefine.

define !episode()
'source-episode-file-20'
!enddefine.

define !individual()
'source-individual-file-20'
!enddefine.

define !FY()
'1718'
!enddefine.

get file = !file + !episode + !FY + '.sav'.

*rename variables health_postcode = pc7.

rename variables prac = gpprac.
alter type gpprac (A5).

sort cases by gpprac.

match files file = * 
 /table =  '/conf/irf/11-Development team/Dev08-Pathways/Tableau Matrix/3. Data/Lookup/PracticeDetailsUpdated.sav'
 /by gpprac.
execute.

*rename variables gpprac = prac.
alter type gpprac (A6).

if cluster = '' flag = 1.
execute.

if flag = 1 cluster = 'Unknown'.
execute.

sort cases by datazone.

match files file = *
 /table = '/conf/irf/05-lookups/04-geography/01-locality/Locality_lookup_source.sav'
 /by datazone.
execute.

if locality = '' locality = 'No Locality Information'.
execute.

sort cases by CHI record_keydate1 record_keydate2.

save outfile = !file + !episode + !FY + '.sav'
 /drop partnership flag HB. 

get file = !file + !episode + !FY + '.sav'.
*****************************************************************
*Same for individual file. 


get file = !file + !individual + !FY + '.sav'.

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

sort cases by datazone.

match files file = *
 /table = '/conf/irf/05-lookups/04-geography/01-locality/Locality_lookup_source.sav'
 /by datazone.
execute.

if locality = '' locality = 'No Locality Information'.
execute.

sort cases by CHI.

save outfile = '/conf/sourcedev/Anita_temp/source-individual-file-201718.sav'
 /drop partnership datazone flag HB.



