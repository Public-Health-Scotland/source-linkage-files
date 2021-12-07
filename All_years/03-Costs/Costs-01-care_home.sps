* Encoding: UTF-8.
*2. LookUp for costs for Care Homes.

*Get COSLA Value tables.
*The values are obtained from.
* https://publichealthscotland.scot/publications/care-home-census-for-adults-in-scotland/ - Estimated Average Gross Weekly Charge for Long Stay Residents in Care Homes for Older People in Scotland.
* Check and add any new years to 'CH_Costs.xlsx'.

 * Make a copy of the existing file, incase something wierd has happened to the data!.
 * Get an error because of the -p flag: This keeps the ammend date but fails on permissions - command works fine though.
 * If this doesn't work manually make a copy.
Host Command = ["cp '" + !Costs_dir + "Cost_CH_Lookup.sav' '" +  !Costs_dir + "Cost_CH_Lookup_OLD.sav'"].

GET DATA
    /TYPE=XLSX
    /FILE= !Costs_dir + "CH_Costs.xlsx"
    /CELLRANGE=FULL
    /READNAMES=ON
    /DATATYPEMIN PERCENTAGE=95.0
    /HIDDEN IGNORE=YES.
EXECUTE.

* We only want the funding totals.
select if any(SourceofFunding, 'All Funding With Nursing Care', 'All Funding Without Nursing Care').

VARSTOCASES
    /MAKE Cost_per_week FROM @2017 to @2019
    /Index= Calender_Year (Cost_per_week).

* remove the @ sign.
Compute Calender_Year = char.Subst(Calender_Year, 2).
Alter type Calender_Year (F4.0).

* Create Year as FY = YYYY from CCYY.
String Year (A4).
Compute year = char.Lpad(Ltrim(String(((Calender_Year - 2000) * 100) + Mod(Calender_Year, 100) + 1, F4.0)), 4, "0").

* Create a flag for Nursing care provision from source of funding.
Numeric nursing_care_provision (F1.0).
Recode SourceofFunding
    ('All Funding With Nursing Care' = 1)
    ('All Funding Without Nursing Care' = 0)
    into nursing_care_provision.

* Calculate the cost per day.
Compute cost_per_day = (Cost_per_week / 7).

* Work out the unknown nursing care case as the mean of the others.
String unknown_nursing (A100).
Compute unknown_nursing = "Unknown Source of Funding".

varstocases /make SourceofFunding from SourceofFunding unknown_nursing.

* We want it to appear as NursingCareProvision = blank.
if SourceofFunding = "Unknown Source of Funding" nursing_care_provision = $sysmis.

aggregate outfile = *
    /Break year nursing_care_provision
    /cost_per_day = Mean(cost_per_day).

***This bit will need changing to accomodate new costs ***.
* Add in years by copying the most recent year we have.
* Most recent costs year availiable.
String TempYear1 TempYear2 (A4).
Do if Year = "1920".
    * Make costs for other years.
    Compute TempYear1 = "2021".
    Compute TempYear2 = "2122".
End if.

Varstocases /make Year from Year TempYear1 TempYear2.

* Uplift costs for Years after the latest year.
* increase by 1% for every year after the latest.
* Add/delete lines as appropriate.
if year > "1920" cost_per_day = cost_per_day * 1.01.
if year > "2021" cost_per_day = cost_per_day * 1.01.
if year > "2122" cost_per_day = cost_per_day * 1.01.
if year > "2223" cost_per_day = cost_per_day * 1.01.

sort cases by Year nursing_care_provision.

* Check here to make sure costs haven't changed radically.
match files file = *
    /table !Costs_dir + "Cost_CH_Lookup_OLD.sav"
    /Rename cost_per_day = cost_old
    /By year nursing_care_provision.

Compute pct_diff = (cost_per_day - cost_old) / cost_old * 100.
crosstabs  pct_diff by year by nursing_care_provision.

save outfile=!Costs_dir + "Cost_CH_Lookup.sav"
    /Keep year nursing_care_provision cost_per_day.

get file = !Costs_dir + "Cost_CH_Lookup.sav".
