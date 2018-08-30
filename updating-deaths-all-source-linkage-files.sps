* Updating deaths on Source-episode linkage files with extract received on 28 February 2017.
* Denise Greig, March 2017.


* Death flag files - 'home'.
define !DeathsFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/data-extracts/02-NRS-deaths/'
!enddefine.

* Source linkage files home.
define !episode()
'/conf/hscdiip/01-Source-linkage-files/source-episode-file-'
!enddefine.

define !individual()
'/conf/hscdiip/01-Source-linkage-files/source-individual-file-'
!enddefine.


*get file = !Deathsfile + 'Deceased_patient_reference_file.sav'.
* Episode files.
get file = !episode + '201011.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !episode + '201011.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !episode + '201112.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !episode + '201112.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !episode + '201213.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !episode + '201213.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !episode + '201314.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !episode + '201314.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !episode + '201415.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !episode + '201415.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !episode + '201516.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !episode + '201516.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !episode + '201617.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !episode + '201617.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

* Individual files.

get file = !individual + '201011.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !individual + '201011.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !individual + '201112.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !individual + '201112.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !individual + '201213.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !individual + '201213.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !individual + '201314.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !individual + '201314.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !individual + '201415.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !individual + '201415.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !individual + '201516.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !individual + '201516.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

get file = !individual + '201617.sav'.
delete variables ADD IN VARIABLES TO BE DELETED .
sort cases by chi.
match files file = *
 /table = !!Deathsfile + 'Deceased_patient_reference_file.sav'
 /by chi.
execute.
save outfile = !individual + '201617.sav' 
 /keep GET ORDERED LIST OF VARIABLES.

