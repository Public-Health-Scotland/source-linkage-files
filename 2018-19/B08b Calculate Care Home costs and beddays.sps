* Encoding: UTF-8.
************************************************************************************************************
                                                   NSS (ISD)
************************************************************************************************************
** AUTHOR:	James McMahon (j.mcmahon1@nhs.net)
** Date:    	03/05/2018
************************************************************************************************************
** Amended by:         
** Date:
** Changes:               
************************************************************************************************************.
********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

get file = !File + "Care-Home-Temp-3.zsav".
String Year (A4).
Compute year = !FY.

sort cases by year nursingcareprovision.

match files
    /file = *
    /Table = !Costs_Lookup + "Cost_CH_Lookup.sav"
    /By year nursingcareprovision.

 *Create age groups.
String AgeGroup (A15).
Recode Age (Lo Thru 17 = "<18") (18 Thru 64 = "18-64" ) (65 Thru Hi = "65+") Into AgeGroup.

************************************************************************************************************.
 * Define a macro that will calculate the cost per month.
Define !CostPerMonth (Month = !Tokens(1) 
   /MonthNum = !Tokens(1) 
   /DaysInMonth = !Tokens(1) 
   /Year = !Tokens(1))

 * Store the start and end date of the given month.
Compute #StartOfMonth = Date.DMY(1, !MonthNum, !Year).
Compute #EndOfMonth = Date.DMY(!DaysInMonth, !MonthNum, !Year).

 * Create the names of the variables e.g. April_beddays and April_cost.
!Let !BedDays = !Concat(!Month, "_beddays").
!Let !Cost = !Concat(!Month, "_cost").

 * Create variables for the month.
Numeric !BedDays (F2.0).
Numeric !Cost (F4.2).

 * Go through all possibilities to decide how many days to be allocated.
Do if CareHomeAdmissionDate LE #StartOfMonth.
   Do if CareHomeDischargeDate GE #EndOfMonth.
      Compute !BedDays = !DaysInMonth.
   Else.
      Compute !BedDays = DateDiff(CareHomeDischargeDate, #StartOfMonth, "days").
   End If.
Else if CareHomeAdmissionDate LT #EndOfMonth.
   Do if CareHomeDischargeDate GE #EndOfMonth.
      Compute !BedDays = DateDiff(#EndOfMonth, CareHomeAdmissionDate, "days").
   Else.
      Compute !BedDays = DateDiff(CareHomeDischargeDate, CareHomeAdmissionDate, "days").
   End If.
Else.
   Compute !BedDays = 0.
End If.

 * Months after the discharge date will end up with negatives.
If !BedDays < 0 !BedDays = 0.
 ************************************************************************************************************.
 * Now the month variable contains the days spent in a care home for that episode.
 * Turn them into costs.

 * Using COSLA funding for all funding for older people.
 * Matched in above.

 * Depending on the above group, calculate the cost per day, per episode and per episode for that financial year.
 * We're only doing this for over 65s.
Do if AgeGroup = "65+".
   Compute !Cost = CostPerDay * !BedDays.
   Compute FinYearCostofEpisode = CostPerDay * yearStay.
Else.
   Compute !Cost = $SysMis.
   Compute FinYearCostofEpisode = $SysMis.
End If.
!EndDefine.

 * This python program will call the macro for each month with the right variables.
 * They will also be in FY order.
Begin Program.
from calendar import month_name, monthrange
from datetime import date
import spss

#Set the financial year, this line reads the first variable ('year')
fin_year = int(spss.Cursor().fetchone()[0])

#This line generates a 'dictionary' which will hold all the info we need for each month
#month_name is a list of all the month names and just needs the number of the month
#(m < 4) + 2015 - This will set the year to be 2015 for April onwards and 2016 other wise
#monthrange takes a year and a month number and returns 2 numbers, the first and last day of the month, we only need the second.
months = {m: [month_name[m], (m < 4) + fin_year, monthrange((m < 4) + fin_year, m)[1]]  for m in range(1,13)}
print(months) #Print to the output window so you can see how it works

#This will make the output look a bit nicer
print("\n\n***This is the syntax that will be run:***")

#This loops over the months above but first sorts them by year, meaning they are in correct FY order
for month in sorted(months.items(), key=lambda x: x[1][1]):
   syntax = "!CostPerMonth Month = " + month[1][0][:3]
   syntax += " MonthNum = " + str(month[0])
   syntax += " DaysInMonth = " + str(month[1][2])
   syntax += " Year = " + str(month[1][1]) + "."
   
   print(syntax)
   spss.Submit(syntax)
End Program.

save outfile= !File + "Care-Home-Temp-4.zsav"
   /zcompressed.
get file = !File + "Care-Home-Temp-4.zsav".
