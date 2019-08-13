* Encoding: UTF-8.
 * Run A01-Set up Macros first!.
************************************************************************************************************************************.
************************************************************************************************************************************.
************************************************************************************************************************************.
 * We don't currently have an NSU cohort for 2018/19.
 * Use this code for new years where we don't have an NSU cohort, otherwise run main code below.
get file = !File + "temp-source-individual-file-4-20" + !FY + ".zsav".
Numeric Keep_Population (F1.0).
Compute Keep_Population = 1.
save outfile = !File + "temp-source-individual-file-5-20" + !FY + ".zsav"
    /zcompressed.
************************************************************************************************************************************.
************************************************************************************************************************************.
************************************************************************************************************************************.
 
************************************************************************************************************************************.
* 1. Obtain the population estimates for Locality AgeGroup and Gender.
get file = !DataZone_Pops
    /Keep Year DataZone2011 sex age0 to age90plus.

 * Select out the estimates for the year of interest.
 * This may need to be changed if we don't have estimates yet.

 * Code if we don't have estimates for this year (and so have to use previous year).
select if year = Number(!altFY, F4.0) - 1.
execute.
compute year = year + 1.

 * Code in usual case where estimates are available.
* select if year = Number(!altFY, F4.0).

 * Recode to make it match source.
Recode sex ("M" = 1) ("F" = 2) into gender.

 * Flip the population estimates, Indexed by age.
varstocases /make Population_Estimate from age0 to age90plus
    /index = Age_plus_one.

* Break into 10-year age groups.
* Note that the ages start at 0 but vars to cases numbers from 1.
String AgeGroup (A5).
Recode Age_plus_one
    (1 Thru 5 = "0-4")
    (6 Thru 15 = "5-14")
    (16 Thru 25 = "15-24")
    (26 Thru 35 = "25-34")
    (36 Thru 45 = "35-44")
    (46 Thru 55 = "45-54")
    (56 Thru 65 = "55-64")
    (66 Thru 75 = "65-74")
    (76 Thru 85 = "75-84")
    (86 Thru Hi = "85+")
    Into AgeGroup.

sort cases by DataZone2011.

 * Match on Localities.
match files
   /File = * 
   /Table = !LocalitiesLookup
   /Rename (HSCPLocality = Locality)
   /By Datazone2011.

 * Aggregate to get populations for Locality/Age Group/Gender.
aggregate outfile = *
    /Break Locality AgeGroup gender
    /Population_Estimate = Sum(Population_Estimate).

save outfile = !File + "Population-estimates-20" + !FY + ".zsav"
    /zcompressed.

************************************************************************************************************************************.
* 2. Work out the current population sizes in the SLF for Locality AgeGroup and Gender.
get file = !File + "temp-source-individual-file-4-20" + !FY + ".zsav"
    /Keep chi Locality age gender NSU death_date.

 * If they don't have a locality, they're no good as we won't have an estimate to match them against.
 * Same for age and gender.
select if Locality ne ''.
select if Not(sysmis(age)).

 * Remove people who died before the mid-point of the calender year.
 * This will make our numbers line up better with the methodology used for the mid-year population estimates.
compute Dead_at_midyear = 0.
 * Set some dates.
compute #mid_year = date.dmy(30, 06, Number(!altFY, F4.0)).
 * Nasty hack to make SPSS recognise missing death dates!!!.
 * anyone who died 5 years before the file shouldn't be in it anyway...
compute #previous_date = date.dmy(30, 06, Number(!altFY, F4.0) - 5).

 * Flag non-NSUs who were dead at the mid year date. This will also tag sysmis dates because SPSS sucks.
If NSU = 0 and death_date <= #mid_year Dead_at_midyear = 1.
 * This is the cleanup.
If death_date < #previous_date Dead_at_midyear = 0.

Frequencies Dead_at_midyear.
Select if Dead_at_midyear = 0.

 * Assign the same 10-year age-groups.
String AgeGroup (A5).
Recode Age
    (0 Thru 4 = "0-4")
    (5 Thru 14 = "5-14")
    (15 Thru 24 = "15-24")
    (25 Thru 34 = "25-34")
    (35 Thru 44 = "35-44")
    (45 Thru 54 = "45-54")
    (55 Thru 64 = "55-64")
    (65 Thru 74 = "65-74")
    (75 Thru 84 = "75-84")
    (85 Thru Hi = "85+")
    Into AgeGroup.

 * Sort now to make the aggregate quicker and because it needs to be like this to match later.
sort cases by Locality AgeGroup Gender.

 * Calculate the populations of the whole SLF and of the NSU.
aggregate
    /Presorted
    /break Locality AgeGroup Gender
    /NSU_Population = Sum(NSU)
    /Total_Source_Population = n.

 * Now we've got the counts for the service-users, we only need NSUs.
select if NSU = 1.

 * Match on the population estimates.
match files file = *
    /table = !File + "Population-estimates-20" + !FY + ".zsav"
    /by Locality AgeGroup Gender.

 * Calculate difference between Source Population and Estimated Population.
compute Difference = Total_Source_Population - Population_Estimate.

 * Create a scaling factor which will decide what proportion of NSU's should be kept.
compute New_NSU_Figure = NSU_Population - Difference.
compute Scaling_Factor = New_NSU_Figure / NSU_Population.

 * Run Bernoulli Random Sampling. 
 * Recode any scaling factors that fall outside (0, 1), as these will result in sysmiss if given to rv.Bernoulli.
 * A scaling factor < 0 implies that we have more service-users than population estimate; hence we should get rid of more NSUs than we actually have.
 * A scaling factor > 1 implies that we NSU + service-users is less than the population estimate; hence we need to add NSUs ...
Recode Scaling_Factor (Lo Thru 0 = 0) (1 Thru Hi = 1).
Frequencies Scaling_Factor.

 * Seed is set to make sure same number of individuals is picked each time syntax is ran.
Numeric Keep_NSU (F1.0).
set seed 100.
compute Keep_NSU = RV.BERNOULLI(Scaling_Factor).
Frequencies Keep_NSU.

 * Save out the flag as a lookup by CHI, only need to keep the NSUs with the flag. 
Select if Keep_NSU = 1.

Sort cases by CHI.

save outfile = !File + "NSU-Keep-Lookup-20" + !FY + ".zsav"
    /Keep chi Keep_NSU
    /zcompressed.

************************************************************************************************************************************.
* 3. Match the flag back on to the SLF.
match files 
    /file = !File + "temp-source-individual-file-4-20" + !FY + ".zsav"
    /table = !File + "NSU-Keep-Lookup-20" + !FY + ".zsav"
    /Rename Keep_NSU = Keep_Population
    /By Chi.

 * Flag all non-NSUs as Keep.
If NSU = 0 Keep_Population = 1.

 * If the flag is missing they must be a non-keep NSU so set to 0.
Recode Keep_Population (sysmis = 0).
Crosstabs NSU by Keep_Population.

save outfile = !File + "temp-source-individual-file-5-20" + !FY + ".zsav"
    /zcompressed.

get file = !File + "temp-source-individual-file-5-20" + !FY + ".zsav".

