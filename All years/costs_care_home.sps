* Encoding: UTF-8.
*2. LookUp for costs for Care Homes.

*Get COSLA Value tables.
*The values are obtained from 
http://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Care-Homes/Previous-Publications/index.asp - Table15
Check and add any new years to 'CH_Costs.xlsx'  

GET DATA
  /TYPE=XLSX
  /FILE= !Extracts_Alt + "Costs/CH_Costs.xlsx"
  /SHEET=name 'Sheet1'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.

 * We only want the funding totals.
select if any(SourceofFunding, 'All Funding With Nursing Care', 'All Funding Without Nursing Care').

VARSTOCASES
    /MAKE Cost_per_week FROM @2007 to @2017
    /Index= Calender_Year (Cost_per_week).


 * remove the @ sign.
Compute Calender_Year = char.Subst(Calender_Year, 2).
Alter type Calender_Year (F4.0).

 * Create Year as FY = YYYY from CCYY.
String Year (A4).
Compute year = Lpad(Ltrim(String(((Calender_Year - 2000) * 100) + Mod(Calender_Year, 100) + 1, F4.0)), 4, "0"). 

 * Create a flag for Nusring care provision from source of funding.
String NursingCareProvision (A1).
Recode SourceofFunding
    ('All Funding With Nursing Care' = "Y")
    ('All Funding Without Nursing Care' = "N")
    into NursingCareProvision.

 * Calculate the cost per day.
Compute cost_per_day = (Cost_per_week / 7).

 * Work out the unknown nursing care case as the mean of the others.
String UnknownSource (A100).
Compute UnknownSource = "Unknown Source of Funding".

varstocases /make SourceofFunding from SourceofFunding UnknownSource.

 * We want it to appear as NursingCareProvision = blank.
if SourceofFunding = "Unknown Source of Funding" NursingCareProvision = "".

aggregate outfile = *
    /Break year NursingCareProvision
    /cost_per_day = Mean(cost_per_day).

 * Add in years by copying the most recent year we have.
***This bit will need changing to accomodate new costs ***.
 * Most recent costs year availiable.
String TempYear1 TempYear2(A4).
Do if Year = "1718".
    * Make costs for other years.
    Compute TempYear1 = "1819".
End if.

Varstocases /make Year from Year TempYear1 TempYear2.

  *Sort and save.

 * For new CH data.
Numeric nursing_care_provision (F1.0).
Recode NursingCareProvision ("N" = 0) ("Y" = 1) into nursing_care_provision.

sort cases by Year NursingCareProvision.


save outfile=!Extracts_Alt + "Costs/Cost_CH_Lookup.sav"
    /Keep year NursingCareProvision cost_per_day.

get file = !Extracts_Alt + "Costs/Cost_CH_Lookup.sav".



