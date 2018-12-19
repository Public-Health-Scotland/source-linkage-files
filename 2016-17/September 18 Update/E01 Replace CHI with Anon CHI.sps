* Encoding: UTF-8.
*****************************************************************************************.
* Run A01 Set-up Macros first!.
*****************************************************************************************.

*****************************************************************************************.
 * Episode file
*****************************************************************************************.
 * Match on the Anon_CHI from the lookup.
match files
    /file = !file + "source-episode-file-20" + !FY + ".zsav"
    /table = !CHItoAnonlookup
    /By CHI.

sort cases by Anon_CHI.

 * Save out, put Anon_CHI where CHI was and drop CHI.
save outfile = !file + "source-episode-file-20" + !FY + ".zsav"
    /Keep Year to SMRType Anon_CHI All
    /Drop Chi
    /zcompressed.


*****************************************************************************************.
 * Individual file
*****************************************************************************************.
 * Match on the Anon_CHI from the lookup.
match files
    /file = !file + "source-individual-file-20" + !FY + ".zsav"
    /table = !CHItoAnonlookup
    /By CHI.

sort cases by Anon_CHI.

 * Save out, put Anon_CHI where CHI was and drop CHI.
save outfile = !file + "source-individual-file-20" + !FY + ".zsav"
    /Keep Year to  Anon_CHI All
    /Drop Chi
    /zcompressed.
