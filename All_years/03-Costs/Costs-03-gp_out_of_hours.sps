* Encoding: UTF-8.
* Make GP Out of  Hours Cost Lookup.

* 1. Attendances taken from 2018 Primary Care Out of Hours Report
    http://www.isdscotland.org/Health-Topics/Emergency-Care/GP-Out-of-Hours-Services/Primary-Care-Statistics/

* 2. Costs taken from R520 (Costbook) report for 2015/16
    http://www.isdscotland.org/Health-Topics/Finance/Costs/Detailed-Tables/index.asp (R520)

* 3. The above should be checked / added to the Excel file 'OOH_Costs.xlsx' before running this syntax.

 * Make a copy of the existing file, in case something weird has happened to the data!.
 * Get an error because of the -p flag: This keeps the amend date but fails on permissions - command works fine though.
 * If this doesn't work manually make a copy.
Host Command = ["cp " + !Costs_dir + "Cost_GPOoH_Lookup.sav " +  !Costs_dir + "Cost_GPOoH_Lookup_pre" + !LatestUpdate + ".sav"].

* Now read in from the spreadsheet.
GET DATA
    /TYPE=XLSX
    /FILE= !Costs_dir + "OOH_Costs.xlsx"
    /SHEET=name 'Sheet1'
    /CELLRANGE=FULL
    /READNAMES=ON
    /DATATYPEMIN PERCENTAGE=95.0
    /HIDDEN IGNORE=YES.
EXECUTE.

varstocases
    /Make Consultations from @1415_Consultations to @1819_Consultations
    /Make Cost from @1415_Cost to @1819_Cost
    /Index Year(Cost).

Compute Year = char.substr(Year, 2, 4).
Alter type year (A4).

Compute Cost_per_consultation = Cost * 1000 / Consultations.

* Add in years by copying the most recent year we have.
***This bit will need changing to accommodate new costs ***.
* Most recent costs year available.
String TempYear1 TempYear2 (A4).
Do if Year = "1819".
    * Make costs for other years.
    Compute TempYear1 = "1920".
    Compute TempYear2 = "2021".
End if.

Varstocases /make Year from Year TempYear1 TempYear2.

sort cases by HB2019 year.

 * Check here to make sure costs haven't changed radically.
match files file = *
    /table  !Costs_dir + "Cost_GPOoH_Lookup_OLD.sav"
    /Rename Cost_per_consultation = cost_old
    /Rename TreatmentNHSBoardCode = HB2019
    /By HB2019 Year.

Compute Difference = Cost_per_consultation - cost_old.
crosstabs  Difference by year by HB2019.

* Save.
save outfile =  !Costs_dir + "Cost_GPOoH_Lookup.sav"
    /Rename
    HB2019 = TreatmentNHSBoardCode
    /Keep Year TreatmentNHSBoardCode Cost_per_consultation.

get file =  !Costs_dir + "Cost_GPOoH_Lookup.sav".
