*Fix Glasgow A&E datazone issue where it is needed.
* Only applicable to episode level files.

*Test code on this file first.
 * get file='/conf/hscdiip/DH-Extract/201415/source-episode-file-201415.sav'.

get file='/conf/hscdiip/01-Source-linkage-files/source-episode-file-201011.sav'.

*check existing datazone to ascertain if the problem exisits with this file.
temporary.
select if recid eq 'AE2' AND datazone eq 'S01010022'.
frequency variables pc7.


********************************************* Taken from program 20 in 201617 folder - PART FOUR ********************************************************.
* Correct the postcodes that have 6 characters instead of 7. 

*D.
string pc7_2 (a7).
EXECUTE.

*D.
do if ((substr(pc7,3,1) eq ' ') and (substr(pc7,4,1) ne ' ')).
compute pc7_2 = concat(substr(pc7,1,2),"  ",substr(pc7,4,3)).
compute pc7 = pc7_2.
end if. 
EXECUTE.

sort cases by pc7.

delete variables datazone2011.

*Apply consistent geographies e.g. not all data marts have datazone 2011 (or clearly labelled).
match files file = *
 /table =  '/conf/irf/05-lookups/04-geography/geographies-for-PLICS-updated2016.sav'
 /by pc7
   /drop SplitChar Split_Indicator.
execute.

compute datazone=datazone2011.
EXECUTE.

temporary.
select if recid eq 'AE2' AND datazone eq 'S01010022'.
frequency variables pc7.

sort cases by CHI record_keydate1 record_keydate2.

* another save as issues exist with temp space, July 2016.  
 * save outfile='/conf/hscdiip/01-Source-linkage-files/source-episode-file-201112.sav' /compressed.

save outfile='/conf/linkage/output/gemma/source-episode-file-201011.sav' /compressed.

get file='/conf/linkage/output/gemma/source-episode-file-201011.sav'.

