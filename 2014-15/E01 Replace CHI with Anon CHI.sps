* Encoding: UTF-8.
*****************************************************************************************.
* Run A01 Set-up Macros first!.
*****************************************************************************************.

*****************************************************************************************.
 * Episode file
*****************************************************************************************.
*Create a copy of source episode file so this doesnt get overwritten if there is an error.
Host Command = ["cp '" + !Year_dir + "source-episode-file-20" + !FY + ".zsav' '" + !Year_dir + "source-episode-file-20" + !FY + "_CHI.zsav'"]. 

* Match on the Anon_CHI from the lookup.
match files
    /file = !Year_dir + "source-episode-file-20" + !FY + ".zsav"
    /table = !CHItoAnonlookup
    /By CHI.

sort cases by Anon_CHI.

 * Pause and check here - it's difficult to go back after the save!.
If CHI NE "" and Anon_CHI = "" Error = 1.
Frequencies Error.

 * Save out, put Anon_CHI where CHI was and drop CHI.
save outfile = !Year_dir + "source-episode-file-20" + !FY + ".zsav"
    /Keep Year to SMRType Anon_CHI All
    /Drop Chi Error
    /zcompressed.


*****************************************************************************************.
 * Individual file
*****************************************************************************************.
*Create a copy of source episode file so this doesnt get overwritten if there is an error.
Host Command = ["cp '" + !Year_dir + "source-individual-file-20" + !FY + ".zsav' '" + !Year_dir + "source-individual-file-20" + !FY + "_CHI.zsav'"]. 

* Match on the Anon_CHI from the lookup.
match files
    /file = !Year_dir + "source-individual-file-20" + !FY + ".zsav"
    /table = !CHItoAnonlookup
    /By CHI.

sort cases by Anon_CHI.

 * Pause and check here - it's difficult to go back after the save!.
If CHI NE "" and Anon_CHI = "" Error = 1.
Frequencies Error.

 * Save out, put Anon_CHI where CHI was and drop CHI.
save outfile = !Year_dir + "source-individual-file-20" + !FY + ".zsav"
    /Keep Year Anon_CHI All
    /Drop Chi Error
    /zcompressed.
