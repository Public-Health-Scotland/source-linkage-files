define !file()
 '/conf/sourcedev/'
!enddefine.

Define !SPARRA()
   "/conf/sourcedev/James/SPARRA_2016_04_(April).zsav"
!EndDefine.

define !FY()
   '1516'
!enddefine.

************************************************************************************.
 * Fix Chi numbers * .
get file = !SPARRA.
String chi (A10).

Compute chi = LTRIM(String(UPI_number, F10.0)).

If len(chi) = 9 chi = Concat("0", chi).

Save outfile = !SPARRA
   /Drop UPI_Number
   /zcompressed.

************************************************************************************.
 * Episode file *.
match files 
   /file = !file + 'source-episode-file-20' + !FY + '.zsav'
   /table = !SPARRA
   /by CHI.

save outfile = !file + 'source-episode-file-20' + !FY + '.zsav'
   /zcompressed.

************************************************************************************.
 * Individual file *.
match files 
   /file = !file + 'source-individual-file-20' + !FY + '.zsav'
   /table = !SPARRA
   /by CHI.

save outfile = !file + 'source-individual-file-20' + !FY + '.zsav'
   /zcompressed.

