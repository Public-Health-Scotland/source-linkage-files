*PLICS UPDATES.

*1. add age variable.
*2. order variables in same order.
*3. make all variables same type and length across files.

CD '/conf/irf/11-Development team/Dev00-PLICS-files/2016-17/'. 

******************************* 1415 and 1516**************************************.
define !FY()
'1617'
!enddefine.

define !FYage()
20160930
!enddefine.

get file='source-individual-file-20'+!FY+'.sav'.

*1. compute age variable.
alter type dob (f8.0).
compute age = trunc((!FYage - dob)/10000).
execute.

alter type dob (a8).
alter type age (f3.0).

****************************************match on SIMD2012***********************************.
sort cases by DataZone2001.

match files file=*
   /table '/conf/linkage/output/lookups/deprivation/DataZone2001_simd2012.sav'
   /by DataZone2001
   /drop HB2006 to CHP2007 CHP2012 simd2012_hb2006_quintile to simd2012_hb2014_decile 
   simd2012_chp2007_quintile to simd2012_chp2011sub_decile simd2012tp15 to total_pop_2010.
EXECUTE.

alter type DataZone2001 (a=amin).
*********************************************************************************************************.

****************************************match on urban/rural codes*********************************.
**** USE this lookup file.
 * get file='/conf/linkage/output/lookups/geography/Urban_Rural_Classification/postcode_urban_rural_2013_2014.sav'.

*make new variable for postcode to match the lookup files.
string pc8 (a7).
compute pc8=pc7.
alter type pc8 (a24).

add files file=*
   /keep year to pc7 pc8 ALL.
EXECUTE.

*add a space to 7 character postcodes.
if substr(pc8, 4, 1) ne ' ' pc8=concat(substr(pc8, 1, 4), ' ', substr(pc8,5, 3)).
EXECUTE.

*sort cases into same order as lookup file.
sort cases by pc8.

*match on using pc8.
match files file=*
   /table ='/conf/linkage/output/lookups/geography/Urban_Rural_Classification/postcode_urban_rural_2013_2014.sav'   
   /by pc8
   /drop Date_of_Introduction Date_of_Deletion.
EXECUTE.

*check pc8 - UR matches.
frequency variables pc8 UR8_2013_2014.

*delete pc8 variable.
delete variables pc8.

*resort cases by CHI.
sort cases by CHI.

*********************************************************************************************************.
*reorder variables into standard order across all CHI files.
add files file=*
   /keep year chi gender dob age deceased_flag date_death pc7 gpprac
   health_net_cost to pis_cost
   arth to digestive
   arth_date to digestive_date 
   hbres lca chp DataZone2001 DataZone2011 CHP2011 CHP2011subarea
   simd2012score simd2012rank simd2012_sc_quintile to simd2012_sc_decile simd2012_ca_quintile to simd2012_chp2012_decile hbsimd2012quintile hbsimd2012decile
   HRI_lca to HRI_scotP
   simd2016rank to simd2016_CA2011_quintile ALL.
EXECUTE.


*delete variables.
delete variables scsimd2012quintile scsimd2012decile SplitChar Split_Indicator datazone.
EXECUTE.

*save temp file.
save outfile='source-individual-file-20'+!FY+'.sav'.

get file='source-individual-file-20'+!FY+'.sav'.
   

*******************************************************************************************************************************.

*PART 2.

******************************* 1011 to 1314 **************************************.
*************************.
define !FY()
'1011'
!enddefine.

define !FYage()
20100930
!enddefine.
***************************.

get file='/conf/hscdiip/01-PLICS-analysis-files/CHImasterPLICS_Costed_20'+!FY+'.sav'.

*1. compute age variable.
alter type dob (f8.0).
compute age = trunc((!FYage - dob)/10000).
execute.

alter type dob (a8).
alter type age (f3.0).

****************************************match on SIMD2012***********************************.
*SIMD2012 file.
 * get file='/conf/linkage/output/lookups/deprivation/DataZone2001_simd2012.sav'.
sort cases by Datazone.
rename variables Datazone = DataZone2001.
alter type DataZone2001 (a27).

match files file=*
   /table '/conf/linkage/output/lookups/deprivation/DataZone2001_simd2012.sav'
   /by DataZone2001
   /drop HB2006 to CHP2007 CHP2012 simd2012_hb2006_quintile to simd2012_hb2014_decile 
   simd2012_chp2007_quintile to simd2012_chp2011sub_decile simd2012tp15 to total_pop_2010.
EXECUTE.

alter type DataZone2001 (a=amin).
*********************************************************************************************************.

****************************************match on urban/rural codes*********************************.
**** USE this lookup file.
 * get file='/conf/linkage/output/lookups/geography/Urban_Rural_Classification/postcode_urban_rural_2013_2014.sav'.

*make new variable for postcode to match the lookup files.
string pc8 (a7).
compute pc8=health_postcode.
alter type pc8 (a24).

add files file=*
   /keep year to health_postcode pc8 ALL.
EXECUTE.

*add a space to 7 character postcodes.
if substr(pc8, 4, 1) ne ' ' pc8=concat(substr(pc8, 1, 4), ' ', substr(pc8,5, 3)).
EXECUTE.

*sort cases into same order as lookup file.
sort cases by pc8.

*match on using pc8.
match files file=*
   /table ='/conf/linkage/output/lookups/geography/Urban_Rural_Classification/postcode_urban_rural_2013_2014.sav'   
   /by pc8
   /drop Date_of_Introduction Date_of_Deletion.
EXECUTE.

*check % of matches.
frequency variables UR8_2013_2014.

*delete pc8 variable.
delete variables pc8.

*resort cases by CHI.
sort cases by CHI.

*********************************************************************************************************.
*reorder variables into standard order across all CHI files.
add files file=*
   /keep year chi gender dob age deceased_flag date_death health_postcode gpprac
   health_net_cost to pis_cost
   arth to hefailure ms parkinsons to digestive
   arth_date to digestive_date 
   hbres lca chp DataZone2001 DataZone2011 CHP2011 CHP2011subarea
   simd2012score simd2012rank simd2012_sc_quintile to simd2012_sc_decile simd2012_ca_quintile simd2012_ca_decile
   simd2012_hscp_quintile simd2012_hscp_decile simd2012_chp2012_quintile simd2012_chp2012_decile hbsimd2012quintile hbsimd2012decile
   HRI_lca to HRI_scotP
   simd2016rank to simd2016_CA2011_quintile ALL.
EXECUTE.

**********************************************************.
*delete variables.
delete variables WARD urbrur_8 ukparl_con sparl_con easting northing deceased derived_datedeath scsimd2012quintile scsimd2012decile.
EXECUTE.
**********************************************************.

*rename variables.
rename variables CHI = chi CHP = chp.

*change lca to string.
alter type lca (a2).

*alter type for other variables.
alter type deceased_flag ms (f1.0).
alter type HRI_lcaP to HRI_scotP (f8.2).
alter type health_net_cost health_net_costincDNAs (f8.2).

*check variables are consistent with other files.

*save temp file.
save outfile='CHImasterPLICS_Costed_20'+!FY+'.sav'.




*EXTRA WORK:
*save and run GP practice updates.






















