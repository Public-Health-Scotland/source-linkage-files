
**To add SPARRA score to source linkage files.
*09/02/18-Anita George.

*To add SPARRA score to source episode 1718 file.

get file = '/conf/sourcedev/Anita_temp/SPARRA/SPARRA_2018_04_(Apr).zsav'
   /password='hello'.

sort cases by UPI_NUMBER.
execute.

rename variables UPI_NUMBER=chi.
exe.
save outfile= '/conf/sourcedev/Anita_temp/SPARRA/SPARRA_201718.zsav'.

get file = '/conf/sourcedev/Anita_temp/source-episode-file-201718.sav'.
sort cases by chi.
execute.

match files file=*
/table= '/conf/sourcedev/Anita_temp/SPARRA/SPARRA_201718.zsav'
/by chi.
execute.

rename variables SPARRA_RISK_SCORE =SPARRA_Risk_Score.
exe.

FREQUENCIES VARIABLES=SPARRA_Risk_Score
  /ORDER=ANALYSIS.

save outfile= '/conf/sourcedev/Anita_temp/source-episode-file-201718.sav'.



*To add SPARRA score to source individual 1718 file.

get file= '/conf/sourcedev/Anita_temp/source-individual-file-201718.sav'.

sort cases by chi.
execute.
match files file=*
/table= '/conf/sourcedev/Anita_temp/SPARRA/SPARRA_2018_04_(Apr).zsav'
/by chi.
execute.


rename variables SPARRA_RISK_SCORE =SPARRA_Risk_Score.
exe.

FREQUENCIES VARIABLES=SPARRA_Risk_Score
  /ORDER=ANALYSIS.


save outfile= '/conf/sourcedev/Anita_temp/source-individual-file-201718.sav'.

