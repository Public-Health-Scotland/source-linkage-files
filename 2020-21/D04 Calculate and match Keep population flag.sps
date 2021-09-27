* Encoding: UTF-8.
 * Run A01-Set up Macros first!.
************************************************************************************************************************************.
*NSU Dummy file
************************************************************************************************************************************. 
* We don't currently have an NSU cohort for 2014/15 or latest years.
 * Use this code for new years where we don't have an NSU cohort, otherwise run main code.
get file = !Year_dir + "temp-source-individual-file-4-20" + !FY + ".zsav".
Numeric Keep_Population (F1.0).
Compute Keep_Population = 1.
save outfile = !Year_dir + "temp-source-individual-file-5-20" + !FY + ".zsav"
    /zcompressed.
