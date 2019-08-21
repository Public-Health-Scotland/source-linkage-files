* Encoding: UTF-8.
************************************************************************************************************
   NSS (ISD)
   ************************************************************************************************************
   ** AUTHOR:	James McMahon (j.mcmahon1@nhs.net)
   ** Date:    	09/05/2018
   ************************************************************************************************************
   ** Amended by:
   ** Date:
   ** Changes:
   ************************************************************************************************************.
********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in outcome data.
GET DATA  /TYPE=TXT
   /FILE= !Extracts + "GP-OoH-outcomes-extract-20" + !FY + ".csv"
   /ENCODING='UTF8'
   /DELCASE=LINE
   /DELIMITERS=","
   /QUALIFIER='"'
   /FIRSTCASE=2
   /VARIABLES=
      GUID A36
      Outcome A55.
CACHE.

* Get rid of any with a blank outcome.
Select if Not(Outcome = '').

* Recode the Outcome to a number which will save space.
 * Merge A&E and MIU referrals.
 * Give them a hierarchy.
Recode Outcome
   ("DEATH" = '00')
   ("999/AMBULANCE" = '01')
   ("EMERGENCY ADMISSION" = '02')
   ("ADVISED TO CONTACT OWN GP SURGERY/GP TO CONTACT PATIENT" = '03')
   ("TREATMENT COMPLETED AT OOH/DISCHARGED/NO FOLLOW-UP" = '98')
   ("REFERRED TO A&E" = '21')
   ("REFERRED TO CPN/DISTRICT NURSE/MIDWIFE" = '22')
   ("REFERRED TO MIU" = '21')
   ("REFERRED TO SOCIAL SERVICES" = '24')
   ("OTHER HC REFERRAL/ADVISED TO CONTACT OTHER HCP (NON-EME" = '29')
   ("OTHER" = '99').

* Change Outcome to a number.
alter type Outcome (F2.0).
Variable Width Outcome (5).

* Keep the Outcome text as a value label.
Value Labels Outcome
   00 "Death"
   01 "999 / Ambulance"
   02 "Emergency admission"
   03 "Advised to contact own GP surgery / GP to contact patient"
   21 "Referred to A&E or MIU (Minor Injuries Unit)"
   22 "Referred to CPN / District Nurse / Midwife"
   24 "Referred to Social Services"
   29 "Other HC referral / advised to contact other HCP (non-emergency)"
   98 "Treatment completed at OOH / discharged / no follow-up"
   99 "Other".

 * Sort the records to identify any duplicate info.
sort cases by GUID Outcome.

 * Get rid of any records which are duplicates.
If GUID = Lag(GUID) AND Outcome = lag(Outcome) Duplicate = 1.
Select if SYSMIS(Duplicate).

 * Restructure the data - Not sure we need to do this, maybe just keep one outcome (hierarchy).
casestovars
   /ID = GUID
   /Drop Duplicate.

 * Make sure we have at least 4 outcomes. 
Do Repeat Outcome = Outcome.1 to Outcome.4.
   Compute Outcome = Outcome.
End Repeat.

 * Save, it's now ready to be linked to the consultation data.
 * Only keeping Outcome.1 to Outcome.4.
Save outfile = !File + "GP-Outcomes-Data-" + !FY + ".zsav"
   /Keep GUID Outcome.1 to Outcome.4
   /zcompressed.
get file = !File + "GP-Outcomes-Data-" + !FY + ".zsav".

 * Zip up raw data.
Host Command = ["gzip '" + !Extracts + "GP-OoH-outcomes-extract-20" + !FY + ".csv'"].