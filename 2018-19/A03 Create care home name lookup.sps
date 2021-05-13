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
* Contact is Al Scrougal - Al.Scougal@careinspectorate.gov.scot.
* Attach the existing lookup and ask for an updated version - it is updated monthly.

* Read in care home lookup file (all care homes).
GET DATA /TYPE=XLSX
    /FILE= !Lookup + 'CareHome Lookup All.xlsx'
    /CELLRANGE=full
    /READNAMES=on
    /ASSUMEDSTRWIDTH=32767.

* Correct Postcode formatting.
Rename variables AccomPostCodeNo = CareHomePostcode.
* Remove any postcodes which are length 3 or 4 as these can not be valid (not a useful dummy either).
If range(Length(CareHomePostcode), 3, 4) CareHomePostcode = "".

* Remove spaces which deals with any 8-char postcodes.
* Shouldn't get these but we read all in as 8-char just in case.
* Also make it upper-case.
Compute CareHomePostcode = Replace(Upcase(CareHomePostcode), " ", "").

* Add spaces to create a 7-char postcode.
Loop if range(Length(CareHomePostcode), 5, 6).
    Compute #current_length = Length(CareHomePostcode).
    Compute CareHomePostcode = Concat(char.substr(CareHomePostcode, 1,  #current_length - 3), " ", char.substr(CareHomePostcode,  #current_length - 2, 3)).
End Loop.

alter type CareHomePostcode (A7).

* Only interested in name changes.
aggregate outfile = *
    /Break ServiceName CareHomePostcode Council_Area_Name
    /DateReg = Min(DateReg)
    /DateCanx = Max(DateCanx).

* Remove any old Care Homes which aren't of interest.
Select if DateReg >= date.dmy(01, 04, 2015) or DateCanx >= date.dmy(01, 04, 2015).

sort cases by CareHomePostcode Council_Area_Name DateReg.

 * When a Care Home changes name mid-year change to the start of the FY.
Do if CareHomePostcode = lag(CareHomePostcode) and Council_Area_Name = lag(Council_Area_Name) and DateReg NE lag(DateReg) and DateReg = lag(DateCanx).
    Compute #year_opened = xdate.year(DateReg).
    If xdate.month(DateReg) < 4 #year_opened = xdate.year(DateReg) - 1.
    Compute DateReg = Date.dmy(01, 04, #year_opened).
    Compute changed_reg = 1.
End if.

sort cases by CareHomePostcode Council_Area_Name(A) DateReg(D).

Do if CareHomePostcode = lag(CareHomePostcode) and Council_Area_Name = lag(Council_Area_Name) and lag(changed_reg).
    Compute DateCanx = date.dmy(31, 03, xdate.year(lag(DateReg))).
    Compute changed_Canx = 1.
End if.
    
sort cases by CareHomePostcode Council_Area_Name DateReg.

Do Repeat open = Open_2015 to Open_2030
    /year = 2015 to 2030.
    Compute #yearStart = date.dmy(01, 04, year).
    Compute #yearEnd = date.dmy(31, 03, year + 1).
    Compute Open = DateReg <=  #yearEnd and (sysmis(DateCanx) or DateCanx >= #yearStart).
End Repeat.

 * Assign Council Codes.
String CareHomeCouncilAreaCode (A2).
Recode Council_Area_Name
    ('Aberdeen City' = '01')
    ('Aberdeenshire' = '02')
    ('Angus' = '03')
    ('Argyll & Bute' = '04')
    ('Scottish Borders' = '05')
    ('Clackmannanshire' = '06')
    ('West Dunbartonshire' = '07')
    ('Dumfries & Galloway' = '08')
    ('Dundee City' = '09')
    ('East Ayrshire' = '10')
    ('East Dunbartonshire' = '11')
    ('East Lothian' = '12')
    ('East Renfrewshire' = '13')
    ('City of Edinburgh' = '14')
    ('Falkirk' = '15')
    ('Fife' = '16')
    ('Glasgow City' = '17')
    ('Highland' = '18')
    ('Inverclyde' = '19')
    ('Midlothian' = '20')
    ('Moray' = '21')
    ('North Ayrshire' = '22')
    ('North Lanarkshire' = '23')
    ('Orkney Islands' = '24')
    ('Perth & Kinross' = '25')
    ('Renfrewshire' = '26')
    ('Shetland Islands' = '27')
    ('South Ayrshire' = '28')
    ('South Lanarkshire' = '29')
    ('Stirling' = '30')
    ('West Lothian' = '31')
    ('Na h-Eileanan Siar' = '32')
    Into CareHomeCouncilAreaCode.

!AddLCADictionaryInfo LCA = CareHomeCouncilAreaCode.

*******************************************************************************************************.
* Tidy up care home names.
* Use custom Python as it's twice as quick as built in SPSS.
Begin Program.
import spss

# Open the dataset with write access
# Read in the CareHomeNames, which must be the first variable "spss.Cursor([0]..."
cur = spss.Cursor([0], accessType = 'w')

# Create a new variable, string length 73
cur.AllocNewVarsBuffer(80)
cur.SetOneVarNameAndType('CareHomeName', 73)
cur.CommitDictionary()

# Loop through every case and write the tidied care home name
for i in range(cur.GetCaseCount()):
    # Read a case and save the care home name
    # We need to strip trailing spaces
    care_home_name = cur.fetchone()[0].rstrip()
    
    # Write the tidied name to the SPSS dataset
    cur.SetValueChar('CareHomeName', str(care_home_name).title())
    cur.CommitCase()
    
# Close the connection to the dataset
cur.close()
End Program.

* Fix some obvious typos.
* Double (or more spaces).
Compute fixed_space = char.Index(CareHomeName, "  ") > 0.
Loop If char.Index(CareHomeName, "  ") > 0.
    compute CareHomeName = replace(CareHomeName, "  ", " ").
End Loop.

* No space before brackets.
Compute fixed_bracket = 0.
Do if char.Index(CareHomeName, "(") > 0.
    Do if char.substr(CareHomeName, char.Index(CareHomeName, "(") - 1, 1) NE " ".
        Compute CareHomeName = replace(CareHomeName, "(", " (").
        Compute fixed_bracket = 1.
    End if.
End if.

frequencies fixed_space fixed_bracket.

* If there is a duplicate keep the one relevant to the FY, otherwise keep all.
Compute open_in_fy = Sysmis(DateCanx) OR DateCanx > Date.DMY(01, 04, Number(!altFY, F4.0)).
sort cases by CareHomePostcode open_in_fy DateReg.

 * Aggregate to remove the duplicates, keeping the one which was open in the FY, or if there are multiple, the latest opened.
 * Count so that we can use this info when looking up. 
aggregate outfile = *
    /Presorted
    /Break CareHomePostcode
    /CareHomeName CareHomeCouncilAreaCode = last(CareHomeName CareHomeCouncilAreaCode)
    /n_in_fy = sum(open_in_fy)
    /n_at_postcode = n.

Alter type n_in_fy n_at_postcode (F2.0).

sort cases by CareHomePostcode CareHomeName CareHomeCouncilAreaCode.

save outfile =  !Extracts + "Care_home_name_lookup-20" + !FY + ".sav".

get file =  !Extracts + "Care_home_name_lookup-20" + !FY + ".sav".

