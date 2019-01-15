* Encoding: UTF-8.
***************************************************************************.
 * Syntax to add new CHIs to the file after an update.
 * This could be ran every time but it makes more sense to run it once all new / updated files are available.
***************************************************************************.
 * Run A01 Set-up macros first!.

 * Add updated individual files together.
 * Only need to do individual files as they have all the CHIs.

* Add the file paths e.g.
* "/conf/sourcedev/Source Linkage File Updates/YEAR/source-individual-file-20YEAR.zsav".
add files
    /File =
    /File =
    /Keep CHI Year
    /By CHI.

 * Get unique CHIs.
add files
    /File = *
    /First = Keep
    /By CHI.

Select if Keep = 1.

 * Match to the existing lookup so we can tell which ones are new.
 * If running this for the first time i.e. there is no lookup, skip this bit and run an execute. then continue from Begin Program instead.
match files
    /File = * 
    /Table = !CHItoAnonlookup
    /In = Seen_Before
    /By CHI
    /Keep = CHI Year.

Select if Seen_Before = 0.
 * This will show how many new CHIs came from each file.
 * Don't skip this bit as it also executes which is required for the below.
Frequencies Year.

 * This Python program reads in the CHI numbers, encodes them and then creates a new variable in SPSS and writes the values to it.
Begin Program.
from base64 import standard_b64encode
import spss

 # Open the dataset with write access
 # Read in the CHIs, which must be the first variable "spss.Cursor([0]..."
cur = spss.Cursor([0], accessType='w')

# Create a new variable, string length 16
cur.SetVarNameAndType(['Anon_CHI'], [16])

# Give the Variable a label
cur.SetVarLabel('Anon_CHI', 'Community Health Index number (CHI) - Anonymised format')
cur.CommitDictionary()

 # Loop through every case and write in the encoded CHI
for i in range(cur.GetCaseCount ()):
    # Read a case and save the CHI number
    # We need to strip trailing spaces
    CHI = cur.fetchone()[0].rstrip()
    
    # Use the function defined above to encode the CHI
    encoded_CHI = standard_b64encode(CHI)

    # Write the encoded CHI to the SPSS dataset
    cur.SetValueChar('Anon_CHI', encoded_CHI)
    cur.CommitCase()

 # Close the connection to the dataset
cur.close() 
End Program.

 * Add to the existing lookup.
 * Or skip if running for the first time / no lookup available.
add files
    /File = *
    /File = !CHItoAnonlookup
    /By CHI.

 * Save out, we will use this one to swap out CHIs in SLFs.
save outfile = !CHItoAnonlookup
    /Keep CHI Anon_CHI
    /zcompressed.

 * Put into Anon_CHI order so we can match by it.
sort cases by Anon_CHI.

 * Save out, this one will be provided for users to match CHIs back when needed.
save outfile = !AnontoCHIlookup
    /Keep Anon_CHI CHI
    /zcompressed.