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

sort cases by year NursingCareProvision.

 * Match on the costs lookup.
match files
    /file = *
    /Table = !Extracts_Alt + "Costs/Cost_CH_Lookup.sav"
    /By year NursingCareProvision.

 * Beddays.
 * This Python program will call the 'BedDaysPerMonth' macro (Defined in A01) for each month in FY order.
Begin Program.
from calendar import month_name
import spss

#Loop through the months by number in FY order
for month in (4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3):
   #To show what is happening print some stuff to the screen
   print(month, month_name[month])
   
   #Set up the syntax
   syntax = "!BedDaysPerMonth Month_abbr = " + month_name[month][:3]
   
   #Use the correct admission and discharge variables
   syntax += " AdmissionVar = Admission DischargeVar = Discharge."
   
   #print the syntax to the screen
   print(syntax)
   
   #run the syntax
   spss.Submit(syntax)
End Program.

* Costs.
* Declare Variables.
Numeric apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost (F8.2).
* Calculate Cost per month from beddays and daily cost.
* We're only doing this for over 65s.
Do Repeat Beddays = Apr_beddays to Mar_beddays
    /Cost = Apr_cost to Mar_cost.
    Do if Age >= 65.
        Compute Cost = Beddays * Cost_Per_Day.
    End if.
End Repeat.

Compute cost_total_net = Sum(apr_cost to mar_cost).

save outfile= !File + "Care-Home-Temp-4.zsav"
   /zcompressed.
get file = !File + "Care-Home-Temp-4.zsav".
