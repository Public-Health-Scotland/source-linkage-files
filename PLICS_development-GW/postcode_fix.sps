*POSTCODE_FIX.

*fix 6-digit postcodes in 1516 episode file - using 7 digit PCs in the individual file as a first attempt.

*1. create lookup postcode files using 1516 individual.
get file='/conf/hscdiip/01-Source-linkage-files/source-individual-file-201516.sav'.
dataset name individual1516.

save outfile='/conf/linkage/output/gemma/pc_lookup1516.sav'    
   /keep CHI health_postcode
   /compressed.

get file='/conf/linkage/output/gemma/pc_lookup1516.sav'.    
dataset name lookup1516.

*****************************************************************************************************************.

get file='/conf/hscdiip/01-Source-linkage-files/source-episode-file-201516.sav'.

save outfile='/conf/linkage/output/gemma/test_episode1516.sav'    
   /keep recid record_keydate1 record_keydate2 chi pc7
   /compressed.

get file='/conf/linkage/output/gemma/test_episode1516.sav'.
dataset name episode1516.

****************************************************************************************************************.

CD '/conf/linkage/output/gemma/'.

****************************************************************************************************************.

do if pc7 ne ' '.



end if.
EXECUTE.





















