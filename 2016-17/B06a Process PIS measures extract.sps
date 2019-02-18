* Encoding: UTF-8.
* Read in the PIS measures file (produced by NSS IM&T).
* Program by Denise Hastie, October 2013.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Updated by Denise Hastie, June 2016.
* Updated by Denise Hastie, August 2016 - to add in a new variable (DI paid GIC excl BB).

* 2016/17 data.
*Last ran 16/05/18-Anita George.


********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
 * This should unzip the file in the DH-Extracts directory.
* Change this to the relevant number.
* Should be '_extract_NUMBER'.
Define !Extract_Number()
    "_extract_3"
!EndDefine.

Host Command = ["gunzip '" + !CSDExtractLoc + !Extract_Number + "_paid_data_fy_" + !altFY + ".csv'"].

GET DATA  /TYPE=TXT
   /FILE= !CSDExtractLoc + !Extract_Number + "_paid_data_fy_" + !altFY + ".csv"
   /ENCODING="UTF8"
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      upi A10
      no_dispensed_items F3.0
      paid_nic_excl_bb F7.2
      paid_gic_excl_bb F7.2.
CACHE.

* Note that the row without a UPI provides the number of dispensed items and the cost associated with these.
Recode upi ("null" = "").

sort cases  by upi.

save outfile = !File + "pis_" + !FY + "_measures.zsav"
   /zcompressed.

get file = !File + "pis_" + !FY + "_measures.zsav".

 * zip raw data back up.
Host Command = ["gzip '" + !CSDExtractLoc + !Extract_Number + "_paid_data_fy_" + !altFY + ".csv'"].

