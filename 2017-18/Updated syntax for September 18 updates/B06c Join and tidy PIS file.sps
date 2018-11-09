* Encoding: UTF-8.
* Program to match the measures file and the patient details file together to create the file to use in the master
   * PLICS file as well as the aggregated CHI/UPI PLICs.
*
   * Program by Denise Hastie, October 2013.
* Updated by Denise Hastie, April 2015.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Added in erase file commands for the two files that make up the final output file.
* Updated by Denise Hastie, June 2016.

* Updated to add in geographies, Denise Hastie July 2016.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

match files file = !file + "pis_" + !FY + "_patients.zsav"
   /file = !file + "pis_"+ !FY + "_measures.zsav"
   /by upi.

rename variables
    upi =chi
    paid_nic_excl_bb = cost_total_net.

select if chi ne "".

 * Set date to the end of the FY.
numeric record_keydate1 record_keydate2 (F8.0).
compute record_keydate1 = ((Number(!altFY, F4.0) + 1) * 10000) + 0331.
compute record_keydate2 = record_keydate1.

string recid (A3) year (A4).
compute recid = "PIS".
compute year = !FY.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

save outfile = !file + "prescribing_file_for_source-20" + !FY + ".zsav"
   /zcompressed.

get file = !file + "prescribing_file_for_source-20" + !FY + ".zsav".

* Housekeeping.
erase file = !file + "pis_" + !FY + "_patients.zsav".
erase file = !file + "pis_" + !FY + "_measures.zsav".




