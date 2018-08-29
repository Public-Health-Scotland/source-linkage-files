define !file()
 '/conf/sourcedev/'
!enddefine.

Define !SPARRA()
   "/conf/sourcedev/James/SPARRA_2017_04_(April).zsav"
!EndDefine.

define !FY()
   '1617'
!enddefine.

************************************************************************************.
get file = !SPARRA.
sort cases by UPI_Number.
save outfile = !SPARRA
   /zcompressed.

save outfile = !file + 'source-episode-file-20' + !FY + '.zsav'
   /zcompressed
   /map.

************************************************************************************.
 * Individual file *.
match files 
   /file = !file + 'source-individual-file-20' + !FY + '.zsav'
   /table = !SPARRA
   /rename UPI_Number = chi
   /by CHI.

save outfile = !file + 'source-individual-file-20' + !FY + '.zsav'
   /zcompressed
   /map.
