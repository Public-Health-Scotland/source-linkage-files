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
get file= "CareHomeTemp.zsav".

 *Create age gorups.
String AgeGroup (A15).
Recode AgeatMidpointofFinancialYear (Lo Thru 17 = "<18") (18 Thru 64 = "18-64" ) (65 Thru Hi = "65+") Into AgeGroup.

************************************************************************************************************.
 * Define a macro that will calculate the cost per month.
Define !CostPerMonth (Month = !Tokens(1) 
   /MonthNum = !Tokens(1) 
   /DaysInMonth = !Tokens(1) 
   /Year = !Tokens(1))

 * Store the start and end date of the given month.
Compute #StartOfMonth = Date.DMY(1, !MonthNum, !Year).
Compute #EndOfMonth = Date.DMY(!DaysInMonth, !MonthNum, !Year).

!Let !BedDays = !Concat(!Month, "_beddays").
!Let !Cost = !Concat(!Month, "_cost").

 * Create variables for the month.
Numeric !BedDays (F2.0).
Numeric !Cost (F4.2).

 * Go through all possibilities to decide how many days to be allocated.
 * We're only doing this for over 65s.
Do if AgeGroup = "65+".
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

* Set the costs for the 3 groups.
Compute #CostPerDayWithNursing = (694 / 7).
Compute #CostPerDayWithoutNursing = (614 / 7).
Compute #CostPerDayUnknownNursing = ((694 + 614 / 2) / 7).

 * Depending on the above group, calculate the cost per day, per episode and per episode for that financial year.
	Do If NursingCareProvision = "Y".
	  Compute !Cost = #CostPerDayWithNursing * !BedDays.
   Compute CostofEpisode = #CostPerDayWithNursing * stay.
   Compute FinYearCostofEpisode = #CostPerDayWithNursing * yearStay.
	Else If NursingCareProvision = "N".
	  Compute !Cost =  #CostPerDayWithoutNursing * !BedDays.
   Compute CostofEpisode = #CostPerDayWithoutNursing * stay.
   Compute FinYearCostofEpisode = #CostPerDayWithoutNursing * yearStay.
	Else. 
	  Compute !Cost =  #CostPerDayUnknownNursing * !BedDays.
   Compute CostofEpisode = #CostPerDayUnknownNursing * stay.
   Compute FinYearCostofEpisode = #CostPerDayUnknownNursing * yearStay.
	End If.
End If.
!EndDefine.

 * This python program will call the macro for each month with the right variables.
 * They will also be in FY order.
Begin Program.
from calendar import month_name, monthrange
from datetime import date
import spss

#This line generates a 'dictionary' which will hold all the info we need for each month

#month_name is a list of all the month names and just needs the number of the month
#(m < 4) + 2015 - This will set the year to be 2015 for April onwards and 2016 other wise
#monthrange takes a year and a month number and returns 2 numbers, the first and last day of the month, we only need the second.
months = {m: [month_name[m], (m < 4) + 2015, monthrange((m < 4) + 2015, m)[1]]  for m in range(1,13)}
print(months) #Print to the output window so you can see how it works

#This loops over the months above but first sorts them by year, meaning they are in correct FY order
for month in sorted(months.items(), key=lambda x: x[1][1]):
   syntax = "!CostPerMonth Month = " + month[1][0]
   syntax += " MonthNum = " + str(month[0])
   syntax += " DaysInMonth = " + str(month[1][2])
   syntax += " Year = " + str(month[1][1]) + "."
   
   print(syntax)
   spss.Submit(syntax)
End Program.

save outfile= "CareHomeTemp.zsav"
   /zcompressed. 