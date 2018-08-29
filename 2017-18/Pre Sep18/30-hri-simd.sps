*PLICS development.
*Add HRI flags and SIMD 2016 to CHI master PLICS files.

*input FY.
define !FY()
'1718'
!enddefine.

 * define !outdir()
'/conf/hscdiip/DH-Extract/CHImaster_w_HRI_SIMD16/'
!enddefine.

define !outdir()
'/conf/sourcedev/Anita_temp/'
!enddefine.

 * CD '/conf/hscdiip/DH-Extract/CHImaster_w_HRI_SIMD16/'.

CD '/conf/sourcedev/Anita_temp/'.

******************************************************start here*******************************************.

get file='source-individual-file-20' + !FY + '.sav'.

*check one record per CHI.
add files file=*
   /by CHI
   /first=F.
EXECUTE.

frequency variables F.

delete variables F.

*Checks run.
********************************************************************.

*cases should be sorted by CHI, if not then sort cases by CHI.
sort cases by CHI.

dataset name source.

*match onto HRI file.
match files file=*
   /table 'HRI_lookup_' + !FY + '.sav'
   /by CHI.
EXECUTE.

*save file.
save outfile=!outdir + 'source-individual-file-20' + !FY + '.sav' /compressed.

***************************************************************************************************************.
get file=!outdir + 'source-individual-file-20' + !FY + '.sav'.

frequency variables LCAflag HBflag Scotflag.

frequency variables lcaP.

*extra code for 13/14 backwards because there are no flags=0 to indicate NOT an HRI, only 1 or sysmis. Recode this to match 14/15.
if lcaP ge 50 AND sysmis(LCAflag) LCAflag=0.
if hbP ge 50 and sysmis(HBflag) HBflag=0.
if ScotP ge 50 AND sysmis(Scotflag) Scotflag=0.
EXECUTE.

rename variables (LCAflag = HRI_lca) (HBflag = HRI_hb) (Scotflag = HRI_scot) (lcaP = HRI_lcaP) (hbP = HRI_hbP) (ScotP = HRI_scotP).

*approx. 5000 CHIs without HRI info (0, or 1) make these 9's.
alter type HRI_lca HRI_hb HRI_scot (f1.0).
recode HRI_lca HRI_hb HRI_scot (SYSMIS=9).
EXECUTE.

*check for sysmis.
*run frequencies.
frequency variables HRI_lca HRI_hb HRI_scot.

variable labels 
HRI_lca 'HRIs in LCA'
HRI_hb 'HRIs in HB' 
HRI_scot 'HRIs in Scotland'
HRI_lcaP 'Cumulative percent in LCA (low pcent = high cost and vice versa)'
HRI_hbP 'Cumulative percent in HB (low pcent = high cost and vice versa)'
HRI_scotP 'Cumulative percent in Scotland (low pcent = high cost and vice versa)'.

value labels 
HRI_lca HRI_hb HRI_scot
0 'not HRI'
1 'HRI'
9 'eg non-Scottish resident, no datazone'.
EXECUTE.

*ONLY FOR 1516 BECAUSE SIMD16 WAS ADDED BEFORE HRI FLAGS.
*Rearrange the variables.
 * add files file=*
   /keep year to CHP2011subarea HRI_lca to HRI_scotP Datazone2011 simd2016rank to simd2016_CA2011_quintile  ALL.
 * EXECUTE.

*save file.
save outfile=!outdir + 'source-individual-file-20' + !FY + '.sav' /compressed.

get file=!outdir + 'source-individual-file-20' + !FY + '.sav'.

*************************************************************************************.
***** Use to make datazone2011_simd2016 file.

 * get file= '/conf/linkage/output/lookups/deprivation/postcode_2016_1_simd2016.sav'.

* UPdated file following the release of the 2016_2 scottish postcode directory.
 * get file= '/conf/linkage/output/lookups/deprivation/postcode_2016_1_simd2016.sav'.

 * delete variables pc7 IntZone2011 to CA2011 simd2016tp15 to simd2016_crime_rank.

 * sort cases by DataZone2011.

 * add files file=*
   /by DataZone2011
   /first=F.
 * EXECUTE.

 * select if F=1.
 * EXECUTE.

 * rename variables DataZone2011 = datazone.
 * alter type datazone (a9).

* delete variables F.

 * save outfile='datazone2011_simd2016.sav'.

 * get file='datazone2011_simd2016.sav'.

 * delete variables F.

******************************************************************************************.
***** Use to make postcode_simd2016 file.

 * get file= '/conf/linkage/output/lookups/deprivation/postcode_2016_1_simd2016.sav'.

 * delete variables IntZone2011 to CA2011 simd2016tp15 to simd2016_crime_rank.

 * alter type pc7 (a7).

 * rename variables pc7 = health_postcode.

 * save outfile=!outdir+'postcode_simd2016.sav'.

******************************************************************************************.

*match on SIMD 2016.
get file=!outdir + 'source-individual-file-20' + !FY + '.sav'.

*sort on postcode.
sort cases by health_postcode.
alter type datazone2011 (A27).

match files file=*
   /table '/conf/hscdiip/DH-Extract/postcode_simd2016.sav'
   /by health_postcode.
EXECUTE.

sort cases by CHI.

dataset name source.


*save file with SIMD2016 and HRI flags.
 * save outfile='CHImasterPLICS_Costed_20'+!FY+'.sav' /compressed.

save outfile=!outdir + 'source-individual-file-20' + !FY + '.sav' /compressed.

get file=!outdir + 'source-individual-file-20' + !FY + '.sav'.


