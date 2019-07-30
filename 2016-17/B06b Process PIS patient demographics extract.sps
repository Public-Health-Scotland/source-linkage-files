* Encoding: UTF-8.
* Read in the PIS patient information file (produced by NSS IM&T).
* Program by Denise Hastie, October 2013.
* Updated by Denise Hastie, April 2015.

* Updated with a different file path (temporary storage) for 2014/15 data.
* Updated by Denise Hastie, June 2016.
* Updated by Denise Hastie, August 2016 - to include prescriber practice code.


* Whilst it is the prescriber practice code which is available, it is thought that most
   * patients will get prescription from a GP within the practice they usually attend.  So in a
   * similar way that postcode is determined, the GP Practice Code is determined in the same manner.
* DH August 2016.
*Last ran 16/05/18-AnitaGeorge.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
 * This should unzip the file in the DH-Extracts directory.
* Change this to the relevant number.
* Should be '_extract_NUMBER'.
Define !Extract_Number()
    "_extract_4"
!EndDefine.
Host Command = ["gunzip '" + !CSDExtractLoc + !Extract_Number + "_fy_" + !altFY + ".csv'" ].

GET DATA  /TYPE=TXT
   /FILE = !CSDExtractLoc + !Extract_Number + "_fy_" + !altFY + ".csv"
   /ENCODING="UTF8"
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      upi A10
      dob A10
      gender F1.0
      postcode A8
      gpprac A5.
CACHE.

Alter Type dob (Edate12).
Alter Type dob (Date12).

* Remove the row with null as the upi.
select if (upi ne "null").

sort cases  by upi.

save outfile = !File + "pis_" + !FY + "_patients.zsav"
   /zcompressed.

get file = !File + "pis_" + !FY + "_patients.zsav".

Host Command = ["gzip '" + !CSDExtractLoc + !Extract_Number + "_fy_" + !altFY + ".csv'" ].


