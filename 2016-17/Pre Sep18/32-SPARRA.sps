**To add SPARRA score to Source Linkage File 1617.
**05/02/18 Anita George.

*Get SPARRA extract file.
get file='/conf/hscdiip/DH-Extract/SPARRA April 1st 2016 Encrypted.sav'.

*Change chi to 10 digits for any 9 digit UPI_NUMBER. 

sort cases by UPI_NUMBER.
execute.
save outfile='/conf/hscdiip/DH-Extract/SPARRA April 1st 2016 Encrypted.sav'.

Alter type UPI_Number (A10).
String Firstcharacter (A1).
compute Firstcharacter = char.substr(UPI_Number,1,1).
EXECUTE.

String Zero (A10).
compute Zero = '0'.
execute.

String tempCHI (A10).
do if Firstcharacter = ' '.
compute tempchi = char.substr(UPI_Number,2,9).
else.
compute tempchi = UPI_Number.
end if.
execute.


String chi (A10).
do if Firstcharacter = ' '.
compute chi = concat(Zero,tempchi).
else.
compute chi = tempchi.
end if.
execute.

DELETE VARIABLES Zero, FirstCharacter, tempCHI,UPI_Number.
EXECUTE.

*Sort cases by chi and save the SPARRA file.
sort cases by chi.
exe.

save outfile='/conf/hscdiip/DH-Extract/SPARRA April 1st 2016 Encrypted.sav'.

*Get source linkage episode file 1617.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-201617.sav'.

*Sort cases by chi.
sort cases by chi.
exe.

*Match source episode file with sparra risk score.
match files file=*
/table='/conf/hscdiip/DH-Extract/SPARRA April 1st 2016 Encrypted.sav'
/by chi.
exe.

* Check frequencies.
FREQUENCIES VARIABLES=SPARRA_RISK_SCORE 
  /ORDER=ANALYSIS.

*Save final output.

save outfile= '/conf/sourcedev/source-episode-file-201617.sav'.


*To add SPARRA score to source individual file-1617.

get file= '/conf/hscdiip/01-Source-linkage-files/source-individual-file-201617.sav'.

sort cases by chi.
execute.
match files file=*
/table='/conf/sourcedev/Anita_temp/SPARRA/SPARRA April 1st 2016 Encrypted.sav'
/by chi.
execute.

FREQUENCIES VARIABLES=SPARRA_RISK_SCORE 
  /ORDER=ANALYSIS.

save outfile= '/conf/hscdiip/01-Source-linkage-files/source-individual-file-201617.sav'.

