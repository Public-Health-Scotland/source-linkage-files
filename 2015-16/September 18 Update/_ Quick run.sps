* Encoding: UTF-8.
CD "/conf/irf/11-Development team/Dev00-PLICS-files/2015-16/September 18 Update".

* A.
Insert File = "A01 Set up Macros (1516).sps" Error = Stop.
Preserve.
Insert File = "A02a Create Postcode Lookup.sps" Error = Stop.
Restore.
Preserve.
Insert File = "A02b Create GP practice Lookup.sps" Error = Stop.
Restore.
Insert File = "A03 Create care home name lookup.sps" Error = Stop.
 * Insert File = "A04 Create Read Code lookup.sps" Error = Stop.

 * B.
Insert File = "B01 Process Acute (SMR01 and GLS) extract.sps" Error = Stop.
Insert File = "B02 Process Maternity (SMR02) extract.sps" Error = Stop.
 * Insert File = "B03 Process Outpatients (SMR00) extract.sps" Error = Stop.
Insert File = "B03X B03X Format Oupatient records from old file.sps" Error = Stop.
Insert File = "B04 Process Mental Health (SMR04) extract.sps" Error = Stop.
Insert File = "B05 Process A&E (AE2) extract.sps" Error = Stop.
Insert File = "B06a Process PIS measures extract.sps" Error = Stop.
Insert File = "B06b Process PIS patient demographics extract.sps" Error = Stop.
Insert File = "B06c Join and tidy PIS file.sps" Error = Stop.
Insert File = "B07 Process District Nursing extract.sps" Error = Stop.
Insert File = "B08a Process Care Homes extract.sps" Error = Stop.
Insert File = "B08b Calculate Care Home costs and beddays.sps" Error = Stop.
Insert File = "B08c Tidy Care Home file.sps" Error = Stop.
Insert File = "B09a Process GP Out of hours Diagnoses extract.sps" Error = Stop.
Insert File = "B09b Process GP Out of hours Outcomes extract.sps" Error = Stop.
Insert File = "B09c Process GP Out of hours Contacts extract and link to Outcomes and Diagnoses.sps" Error = Stop.
Insert File = "B11 Process Deaths (NRS) extract.sps" Error = Stop.
Insert File = "B12 Create CHI - LTC Lookup.sps" Error = Stop.
Insert File = "B13 Create CHI - Deceased Lookup.sps" Error = Stop.

 * C - build episode.
Insert File = "C01 Make Episode File.sps" Error = Stop.
Insert File = "C03 Link NSU cohort match on LTCs and deaths + death fixes.sps" Error = Stop.
Insert File = "C04 Calculate pathways cohorts.sps" Error = Stop.
Insert File = "C05 Match on CHI variables - Cohorts SPARRA and HHG.sps" Error = Stop.
Insert File = "C06 Match on postcode and gpprac variables.sps" Error = Stop.
Insert File = "C07 Final tidy for Episode file.sps" Error = Stop.

 * D - Build individual.
Insert File = "D01 Make Individual File.sps" Error = Stop.
Insert File = "D02 Match on postcode and gpprac variables.sps" Error = Stop.
Insert File = "D03 Calculate and match HRI variables.sps" Error = Stop.
Insert File = "D04 Calculate and match Keep population flag.sps" Error = Stop.
Insert File = "D05 Final tidy for Individual file.sps" Error = Stop.
