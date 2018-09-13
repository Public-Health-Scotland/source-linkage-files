* Encoding: UTF-8.
CD "/conf/irf/11-Development team/Dev00-PLICS-files/2015-16/September 18 Update".

* A.
Insert File = "A01 Set up Macros (1516).sps" Error = Stop.
Insert File = "A02a Create Postcode Lookup.sps" Error = Stop.
Insert File = "A02b Create GP practice Lookup.sps" Error = Stop.
Insert File = "A03 Create care home name lookup.sps" Error = Stop.
 * Insert File = "A04 Create Read Code lookup.sps" Error = Stop.

 * B.
Insert File = "B01a read in acute uri linenumber source.sps" Error = Stop.
Insert File = "B01b produce acute file for source.sps" Error = Stop.
Insert File = "B02 produce maternity file for source.sps" Error = Stop.
Insert File = "B03 produce outpatients file for source.sps" Error = Stop.
Insert File = "B04a read in mh los by uri create reference table for source.sps" Error = Stop.
Insert File = "B04b produce mental health file for source.sps" Error = Stop.
Insert File = "B05 produce a&e file for source.sps" Error = Stop.
Insert File = "B06a read in pis measures file.sps" Error = Stop.
Insert File = "B06b read in pis patient file.sps" Error = Stop.
Insert File = "B06c create pis data file.sps" Error = Stop.
Insert File = "B07 produce District Nursing file for source.sps" Error = Stop.
Insert File = "B08a produce care home file for source.sps" Error = Stop.
Insert File = "B08b care home costs.sps" Error = Stop.
Insert File = "B08c care home variables and labels.sps" Error = Stop.
Insert File = "B09a read in GP Out of hours diagnosis data.sps" Error = Stop.
Insert File = "B09b read in GP Out of hours outcome data.sps" Error = Stop.
Insert File = "B09c produce GP Out of hours file for source.sps" Error = Stop.
Insert File = "B10 produce Delayed Discharge records.sps" Error = Stop.
Insert File = "B11 produce deaths file for source.sps" Error = Stop.
Insert File = "B12 create LTC patient ref table.sps" Error = Stop.
Insert File = "B13 create Deceased patient ref table.sps" Error = Stop.

 * C - build episode.
Insert File = "C01a create source episode analysis file.sps" Error = Stop.
Insert File = "C01b Link Delayed Discharge to episode file.sps" Error = Stop.
Insert File = "C01c match on LTC and deaths + death fixes.sps" Error = Stop.
Insert File = "C02 Calculate pathways cohorts.sps" Error = Stop.
Insert File = "C03 Match on CHI variables - Cohorts SPARRA and HHG.sps" Error = Stop.
Insert File = "C04 Match on postcode and gpprac variables.sps" Error = Stop.
Insert File = "C05 Labels and final tidy for episode file.sps" Error = Stop.

 * D - Build individual.
Insert File = "D01a create source linkage individual analysis file.sps" Error = Stop.
Insert File = "D01b match on postcode and gpprac variables.sps" Error = Stop.
Insert File = "D02 Calculate HRI variables.sps" Error = Stop.
Insert File = "D03 Labels and final tidy for individual file.sps" Error = Stop.
