* Encoding: UTF-8.
************************************************************************************************************
                                                   NSS (ISD)
************************************************************************************************************
** Filename:				Create care home lookup
** Description of syntax purpose:	Create a sav file from the XLSX lookup which can be used for checking data.
** Name of customer/output:		Source
** Directory where outputs saved:	Set by CD
** Length of time to run program:	10 secs.
** AUTHOR:				James McMahon (j.mcmahon1@nhs.net)
** Date:    				15/05/2018
************************************************************************************************************
** Amended by:         
** Date:
** Changes:               
************************************************************************************************************.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
 * Ask Social Care Team for the care home names lookup, which originally comes from the Care Inspectorate.
*Last ran :23/11/2018-AG.
* Read in care home lookup file (all care homes).
GET DATA /TYPE=XLSX
   /FILE= !Extracts_Alt + 'Care_home_lookup.xlsx'
   /SHEET=name 'ALL'
   /CELLRANGE=full
   /READNAMES=on
   /ASSUMEDSTRWIDTH=32767.

* Only keep ones which were open on or after the start of the FY.
select if Sysmis(DateCanx) OR DateCanx > Date.DMY(01, 04, Number(!altFY, F4.0)).
exe.
* If the postcode has a space in it & it's more than 7 long, remove a space, repeat if needed.
Loop If (char.Index(CareHomePostcode, " ") > 0) & (char.Length(CareHomePostcode) > 7).
   Compute CareHomePostcode = Replace(CareHomePostcode, " ", "").
End Loop.

 * Assign Council Codes.
Do If CareHomeCouncil = 'Aberdeen City'.
   Compute CareHomeCouncilAreaCode = 1.
Else If CareHomeCouncil = 'Aberdeenshire'.
   Compute CareHomeCouncilAreaCode = 2.
Else If CareHomeCouncil = 'Angus'.
   Compute CareHomeCouncilAreaCode = 3.
Else If CareHomeCouncil = 'Argyll & Bute'.
   Compute CareHomeCouncilAreaCode = 4.
Else If CareHomeCouncil = 'Scottish Borders'.
   Compute CareHomeCouncilAreaCode = 5.
Else If CareHomeCouncil = 'Clackmannanshire'.
   Compute CareHomeCouncilAreaCode = 6.
Else If CareHomeCouncil = 'West Dunbartonshire'.
   Compute CareHomeCouncilAreaCode = 7.
Else If CareHomeCouncil = 'Dumfries & Galloway'.
   Compute CareHomeCouncilAreaCode = 8.
Else If CareHomeCouncil = 'Dundee City'.
   Compute CareHomeCouncilAreaCode = 9.
Else If CareHomeCouncil = 'East Ayrshire'.
   Compute CareHomeCouncilAreaCode = 10.
Else If CareHomeCouncil = 'East Dunbartonshire'.
   Compute CareHomeCouncilAreaCode = 11.
Else If CareHomeCouncil = 'East Lothian'.
   Compute CareHomeCouncilAreaCode = 12.
Else If CareHomeCouncil = 'East Renfrewshire'.
   Compute CareHomeCouncilAreaCode = 13.
Else If CareHomeCouncil = 'Edinburgh, City of'.
   Compute CareHomeCouncilAreaCode = 14.
Else If CareHomeCouncil = 'Falkirk'.
   Compute CareHomeCouncilAreaCode = 15.
Else If CareHomeCouncil = 'Fife'.
   Compute CareHomeCouncilAreaCode = 16.
Else If CareHomeCouncil = 'Glasgow City'.
   Compute CareHomeCouncilAreaCode = 17.
Else If CareHomeCouncil = 'Highland'.
   Compute CareHomeCouncilAreaCode = 18.
Else If CareHomeCouncil = 'Inverclyde'.
   Compute CareHomeCouncilAreaCode = 19.
Else If CareHomeCouncil = 'Midlothian'.
   Compute CareHomeCouncilAreaCode = 20.
Else If CareHomeCouncil = 'Moray'.
   Compute CareHomeCouncilAreaCode = 21.
Else If CareHomeCouncil = 'North Ayrshire'.
   Compute CareHomeCouncilAreaCode = 22.
Else If CareHomeCouncil = 'North Lanarkshire'.
   Compute CareHomeCouncilAreaCode = 23.
Else If CareHomeCouncil = 'Orkney Islands'.
   Compute CareHomeCouncilAreaCode = 24.
Else If CareHomeCouncil = 'Perth & Kinross'.
   Compute CareHomeCouncilAreaCode = 25.
Else If CareHomeCouncil = 'Renfrewshire'.
   Compute CareHomeCouncilAreaCode = 26.
Else If CareHomeCouncil = 'Shetland Islands'.
   Compute CareHomeCouncilAreaCode = 27.
Else If CareHomeCouncil = 'South Ayrshire'.
   Compute CareHomeCouncilAreaCode = 28.
Else If CareHomeCouncil = 'South Lanarkshire'.
   Compute CareHomeCouncilAreaCode = 29.
Else If CareHomeCouncil = 'Stirling'.
   Compute CareHomeCouncilAreaCode = 30.
Else If CareHomeCouncil = 'West Lothian'.
   Compute CareHomeCouncilAreaCode = 31.
Else If CareHomeCouncil = 'Na h-Eilean Siar'.
   Compute CareHomeCouncilAreaCode = 32.
End If.

 * Set to the correct types for matching.
Alter type CareHomeCouncilAreaCode (A2) CareHomePostcode (A7).

 * Aggregate to remove any duplicates (shouldn't be any) and to sort correctly for matching. Keep some interesting variables.
Aggregate
   /outfile = !Extracts + 'Care_home_lookup-20' + !FY + '.sav'
   /Break CareHomeCouncilAreaCode CareHomePostcode CareHomeName
   /CareHomeCouncilName MainClientGroup Sector = First(CareHomeCouncil MainClientGroup Sector)
   /DateReg DateCanx = Max(DateReg DateCanx).
exe.

