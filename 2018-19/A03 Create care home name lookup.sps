* Encoding: UTF-8.
************************************************************************************************************
                                                   NSS (ISD)
************************************************************************************************************
** Filename:				Create care home lookup
** Description of syntax purpose:	Create a sav file from the XLSX lookup which can be used for checking data.
** Name of customer/output:		Source
** Directory where outputs saved:	Set by CD
** Length of time to run program:	10 secs.
** AUTHOR:				James McMahon (james.mcmahon@phs.scot)
** Date:    				15/05/2018
************************************************************************************************************
** Amended by:         
** Date:
** Changes:               
************************************************************************************************************.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
 * To get an updated Care Home Lookup file email the Care Inspectorate.
 * Contact is Al Scrougal - Al.Scougal@careinspectorate.gov.scot 
 * Attach the existing lookup and ask for an updated version - it is updated monthly.

* Read in care home lookup file (all care homes).
GET DATA /TYPE=XLSX
   /FILE= !Lookup + 'CareHome Lookup All.xlsx'
   /CELLRANGE=full
   /READNAMES=on
   /ASSUMEDSTRWIDTH=32767.

Rename Varaibles
    AccomPostCodeNo = CareHomePostcode.

* Only keep ones which were open on or after the start of the FY.
select if Sysmis(DateCanx) OR DateCanx > Date.DMY(01, 04, Number(!altFY, F4.0)).

* If the postcode has a space in it & it's more than 7 long, remove a space, repeat if needed.
Loop If (char.Index(CareHomePostcode, " ") > 0) & (char.Length(CareHomePostcode) > 7).
   Compute CareHomePostcode = Replace(CareHomePostcode, " ", "").
End Loop.

 * Assign Council Codes.
Do If Council_Area_Name = 'Aberdeen City'.
   Compute CareHomeCouncilAreaCode = 1.
Else If Council_Area_Name = 'Aberdeenshire'.
   Compute CareHomeCouncilAreaCode = 2.
Else If Council_Area_Name = 'Angus'.
   Compute CareHomeCouncilAreaCode = 3.
Else If Council_Area_Name = 'Argyll & Bute'.
   Compute CareHomeCouncilAreaCode = 4.
Else If Council_Area_Name = 'Scottish Borders'.
   Compute CareHomeCouncilAreaCode = 5.
Else If Council_Area_Name = 'Clackmannanshire'.
   Compute CareHomeCouncilAreaCode = 6.
Else If Council_Area_Name = 'West Dunbartonshire'.
   Compute CareHomeCouncilAreaCode = 7.
Else If Council_Area_Name = 'Dumfries & Galloway'.
   Compute CareHomeCouncilAreaCode = 8.
Else If Council_Area_Name = 'Dundee City'.
   Compute CareHomeCouncilAreaCode = 9.
Else If Council_Area_Name = 'East Ayrshire'.
   Compute CareHomeCouncilAreaCode = 10.
Else If Council_Area_Name = 'East Dunbartonshire'.
   Compute CareHomeCouncilAreaCode = 11.
Else If Council_Area_Name = 'East Lothian'.
   Compute CareHomeCouncilAreaCode = 12.
Else If Council_Area_Name = 'East Renfrewshire'.
   Compute CareHomeCouncilAreaCode = 13.
Else If any(Council_Area_Name, 'Edinburgh, City of', "City of Edinburgh").
   Compute CareHomeCouncilAreaCode = 14.
Else If Council_Area_Name = 'Falkirk'.
   Compute CareHomeCouncilAreaCode = 15.
Else If Council_Area_Name = 'Fife'.
   Compute CareHomeCouncilAreaCode = 16.
Else If Council_Area_Name = 'Glasgow City'.
   Compute CareHomeCouncilAreaCode = 17.
Else If Council_Area_Name = 'Highland'.
   Compute CareHomeCouncilAreaCode = 18.
Else If Council_Area_Name = 'Inverclyde'.
   Compute CareHomeCouncilAreaCode = 19.
Else If Council_Area_Name = 'Midlothian'.
   Compute CareHomeCouncilAreaCode = 20.
Else If Council_Area_Name = 'Moray'.
   Compute CareHomeCouncilAreaCode = 21.
Else If Council_Area_Name = 'North Ayrshire'.
   Compute CareHomeCouncilAreaCode = 22.
Else If Council_Area_Name = 'North Lanarkshire'.
   Compute CareHomeCouncilAreaCode = 23.
Else If Council_Area_Name = 'Orkney Islands'.
   Compute CareHomeCouncilAreaCode = 24.
Else If Council_Area_Name = 'Perth & Kinross'.
   Compute CareHomeCouncilAreaCode = 25.
Else If Council_Area_Name = 'Renfrewshire'.
   Compute CareHomeCouncilAreaCode = 26.
Else If Council_Area_Name = 'Shetland Islands'.
   Compute CareHomeCouncilAreaCode = 27.
Else If Council_Area_Name = 'South Ayrshire'.
   Compute CareHomeCouncilAreaCode = 28.
Else If Council_Area_Name = 'South Lanarkshire'.
   Compute CareHomeCouncilAreaCode = 29.
Else If Council_Area_Name = 'Stirling'.
   Compute CareHomeCouncilAreaCode = 30.
Else If Council_Area_Name = 'West Lothian'.
   Compute CareHomeCouncilAreaCode = 31.
Else If Council_Area_Name = 'Na h-Eilean Siar'.
   Compute CareHomeCouncilAreaCode = 32.
End If.

 * Set to the correct types for matching.
Alter type CareHomeCouncilAreaCode (A2) CareHomePostcode (A7).
 * Pad council area code with zero if needed.
Compute CareHomeCouncilAreaCode = Replace(CareHomeCouncilAreaCode, " ", "0").

 * Run the Python function 'capwords' on CareHomeName.
 * This will capitalise each word for uniformity and will improve matching.
 * https://docs.python.org/2/library/string.html#string-functions

SPSSINC TRANS RESULT = CareHomeName Type = 73
   /FORMULA "string.capwords(ServiceName)".

 * Aggregate to remove any duplicates (shouldn't be any) and to sort correctly for matching. Keep some interesting variables.
Aggregate
   /outfile = !Extracts + 'Care_home_name_lookup-20' + !FY + '.sav'
   /Break CareHomePostcode CareHomeName CareHomeCouncilAreaCode 
   /CareHomeCouncilName MainClientGroup Sector = First(Council_Area_Name MainClientGroup Sector)
   /DateReg DateCanx = Max(DateReg DateCanx).


