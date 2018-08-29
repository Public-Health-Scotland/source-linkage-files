*Syntax which appends Andrew Mooney cohort variables to the source linkage files (episode and individual) - by CHI.

*Created 20/2/16 by GNW, with AM.
* Updated for 15/16 by DKG, October 2017.

*CD to directory with cohort files.
CD '/conf/sourcedev/'.

*DEFINE financial year.
define !FY()
'1617'
!enddefine.

*'/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' +!FY +'.sav'. 

*1. match demographic cohort variable onto the episode linked file.
match files file = 'source-episode-file-20'+!FY+'.zsav'
   /table = 'Patient_Demographic_Cohort_' +!FY +'.zsav'
   /table = 'GP_Practice_Service_Use_Cohorts_' +!FY+ '.zsav'
   /by CHI.

*Check results.

*Save file.
save outfile = '/conf/sourcedev/source-episode-file-20'+!FY+'.zsav'
   /zcompressed.
 * save outfile='/conf/irf/11-Development team/source-episode-file-20' +!FY +'.sav' /compressed.


*copy and paste file into hscdiip.

*************************************************************************************************************************.
*************************************************************************************************************************.


*2. Individual file.
match files file = 'source-individual-file-20'+!FY+'.sav'
   /table = 'Patient_Demographic_Cohort_' +!FY +'.sav'
   /table = 'GP_Practice_Service_Use_Cohorts_' +!FY+ '.sav'
   /by CHI.


*Save file.
 * save outfile='/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' +!FY +'.sav'.
 * save outfile='/conf/irf/11-Development team/source-individual-file-20' +!FY +'.sav'.

*copy and paste file into hscdiip.
save outfile = 'source-individual-file-20'+!FY+'.sav'.

 * save outfile='/conf/irf/11-Development team/source-individual-file-20' +!FY +'.sav' /compressed.











