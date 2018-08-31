*episode file consistency work.

CD '/conf/linkage/output/gemma/'.

get file='/conf/hscdiip/01-Source-linkage-files/source-episode-file-201011.sav'.

*start with variable lengths - make all strings a=amin.
alter type datazone2011 datazone2001 (a=amin).

*delete unwanted variables.
delete variables CHP_2012 HSCP2016 HB2014 CA2011 pc7_2.

 * save outfile='/conf/hscdiip/01-Source-linkage-files/source-episode-file-201415.sav' /compressed.
save outfile='/conf/linkage/output/gemma/source-episode-file-201011.sav' /compressed.

