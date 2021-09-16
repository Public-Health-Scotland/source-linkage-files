* Encoding: UTF-8.
* Create Lookup for District Nursing Costs.

** 10/08/18-Anita George

 * 1.  Download latest costs file from Cost Book website
http://www.isdscotland.org/Health-Topics/Finance/Costs/Detailed-Tables/index.asp (R500)

 * 2. Check and add costs to the Excel file 'DN_Costs.xlsx'.

 * 3. Extract numbers of contacts from the CHAD - District Nursing Datamart using the query: DN-Contacts-Numbers-for-Costs
This should be run/scheduled and downloaded as a csv
Check the numbers in this file as some data completeness issues may mean the numbers can't be used to create costs.

 * Make a copy of the existing file, incase something wierd has happened to the data!.
 * Get an error because of the -p flag: This keeps the ammend date but fails on permissions - command works fine though.
 * If this doesn't work manually make a copy.
Host Command = ["cp '" + !Costs_dir + "Cost_DN_Lookup.sav' '" +  !Costs_dir + "Cost_DN_Lookup_OLD.sav'"].

 * Read Costs Excel workbook.
GET DATA
  /TYPE=XLSX
  /FILE= !Costs_dir + "DN_Costs.xlsx"
  /SHEET=name 'DN'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=80.0
  /HIDDEN IGNORE=YES.
EXECUTE.

 * Add extra years in here as needed.
Varstocases 
    /Make Cost from @1516_Cost @1617_Cost @1718_Cost @1819_Cost @1920_Cost
    /Index Year(Cost).

Compute Year = char.substr(Year, 2, 4).
Alter type year (A4).

sort cases by year HB2019.

save outfile = !Costs_dir + "raw_dn_costs.sav".

*Get District Nursing file extracted from BOXI .

GET DATA  /TYPE=TXT
  /FILE= !Costs_dir + "DN-Contacts-Numbers-for-Costs.csv"
  /DELIMITERS=" ,"
  /QUALIFIER='"'
  /FIRSTCASE=2
  /VARIABLES=
  ContactFinancialYear F4.0
  TreatmentNHSBoardCode A9
  TreatmentNHSBoardName A27
  NumberofContacts F6.0.
CACHE.

 * Create Year as FY = YYYY from CCYY.
String Year (A4).
Compute Year = String(((ContactFinancialYear - 2000) * 100) + Mod(ContactFinancialYear, 100) + 1, F4.0). 

sort cases by year TreatmentNHSBoardCode.

match files file= *
    /rename TreatmentNHSBoardCode = HB2019
    /table =  !Costs_dir + "raw_dn_costs.sav"
    /by year HB2019.

save outfile =  !Costs_dir + "raw_dn_costs_with_contacts.sav".

************************************************************************
*Calculate population cost for NHS Highland with HSCP population ratio. Of the two HSCPs, Argyll and Bute provides the District Nursing data which is 27% of the population.
get file = !HSCP_5year_Pop_Lookup.

 * Select only the HSCPs for NHS Highland.
select if any(HSCP2019, "S37000004", "S37000016") and Year >= 2015.

 * Create Year as FY = YYYY from CCYY.
Compute Year = ((Year - 2000) * 100) + Mod(Year, 100) + 1. 
alter type Year (A4).

aggregate outfile = *
    /break year HSCP2019
    /Pop = Sum(Pop).

 * Give the HSCP a name for easy viewing.
String HSCPName (A100).
Compute HSCPName = ValueLabel(HSCP2019).

 * Add the HB.
String HB2019 (A9).
Compute HB2019 = "S08000022".

aggregate
    /Break year HB2019
    /TotalPop = Sum(Pop).

Compute PopProportion = Pop / TotalPop.
Compute PopPct = PopProportion * 100.

*Argyll and Bute is the only HSCP in NHS Highland that submits data.
select if HSCPName EQ "Argyll and Bute".

match files File = !Costs_dir + "raw_dn_costs_with_contacts.sav"
    /Table = * 
    /by year HB2019.

Recode PopProportion (sysmiss = 1).

 * Cost is curently measured in £1000s. Make it in £.
 * Then make it per contact (weighted by the propoprtion). 
Compute cost_total_net = ((Cost * 1000) / (NumberofContacts / PopProportion)).

sort cases by HB2019.
 * Only keep records we have a cost for. 
select if Not(Sysmis(cost_total_net)). 


*****************************************************************.
 * This section should be reviewed periodically to check if these fixes are still needed.
 * Check the latest highlight report!.
*****************************************************************.
 * Fix for NHS Highland 2017/18.
 * Highland have not sumbitted Q4 17/18 data so the costs would be inflated if we used their contact numbers.
 * As a temp fix we will use 16/17 for Highland but use 17/18 costs for other boards.

 * Tayside also have a partial submission for 17/18 and 18/19.

String TempYear1 TempYear2 (A4).
Do if Board_Name = "NHS Highland".
    If Year = "1718" Year = "".
    If Year = "1617" TempYear1 = "1718".
Else if Board_Name = "NHS Tayside".
    If Year = "1718" Year = "".
    If Year = "1617" TempYear1 = "1718".
    If Year = "1819" Year = "".
    If Year = "1617" TempYear2 = "1819".
End if.

varstocases /make year from year tempyear1 tempyear2.
*****************************************************************.

 * Add in years by copying the most recent year we have.
***This bit will need changing to accomodate new costs ***.
 * Most recent costs year availiable.
String TempYear1 TempYear2 (A4).
Do if Year = "1819".
    * Make costs for other years.
    Compute TempYear1 = "1920".
    Compute TempYear2 = "2021".
End if.

Varstocases /make Year from Year TempYear1 TempYear2.

add files file = *
    /Rename  HB2019 = hbtreatcode
    TreatmentNHSBoardName = hbtreatname
    /Keep Year hbtreatcode hbtreatname cost_total_net.

 * Check here to make sure costs haven't changed radically.
match files file = *
    /table !Costs_dir + "Cost_DN_Lookup_OLD.sav"
    /Rename cost_total_net = cost_old
    /By hbtreatcode Year.

Compute Difference = cost_total_net - cost_old.
crosstabs  Difference by year by hbtreatcode.

save outfile = !Costs_dir + "Cost_DN_Lookup.sav"
    /Drop cost_old Difference.

get file =  !Costs_dir + "Cost_DN_Lookup.sav".


**Tidyup.
Erase file = !Costs_dir + "raw_dn_costs.sav".
Erase file = !Costs_dir + "raw_dn_costs_with_contacts.sav".
