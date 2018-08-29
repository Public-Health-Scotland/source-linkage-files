*Program 02-Calculating HRIs (high resource individuals: i.e.NHS patients whose total health costs account for more than 50% of their council, or health board of
   residence, or of Scotland's total health costs.
*Originally created by Kara Sellar 18/10/13.
*Amended and updated by ML March 2013
   *Edited and updated by Alison McClelland Apr 2015 for HRI 200,000 days.

*Aim - To create two files which the first will have the total cost of all patients for each council, health board or all Scotland. The second will have selected out the HRIs
   and contain only those cases >50% of their (HRIs are the individuals whose health cost sum will contribute to 50% of the council/health board total health cost).
*First define the file path. Then the following steps outlined below describe how the files will be created.

* Modified slightly to ensure successful running - DKH, October 2017.

**UPDATE FOR CURRENT YEAR, check file paths and name have not changed.
define !file()
   '/conf/sourcedev/'
!Enddefine.

define !FY()
   '1617'
!enddefine.

**********************************************************************************************
* 1. Get the CHImaster PLICs costed file for the year of interest.
* 2. Compute the age of each person in the file (this age is defined as the person's age at 30/09, i.e. the midpoint of the financial year).
* 3. Compute the flag=0 to allow the calculate HRIs for the whole of Scotland.
* 4. Sort Cases by health cost in descending order.
* 5. Aggregate the file three times, but use add variables to add the council area total health cost, health board total health cost and whole of Scotland total health cost.
* 6. To make the process easier, using the substr function, change the hb variable so it just contains the last 2 characters from each health board number.
* 7. Save this file. This file now contains all the information for all patients in Scotland for that year. **ENSURE FILENAMES REFLECT CURRENT YEAR.**

****Now the HRIs for each health board, council area and whole of Scotland can be identified.. Health Board and Council Area are computed in the same way.

* 8. Using the the Do Repeat command, put the health net cost for each person under the correct health board/council area variable.
* 9. Again using the Do Repeat command calculate the total health cost for each council area/health board.
* 10. The costs need to be summed to create a running total and so any missing values in the variables created in step 8 and 9 need to be set to 0.
* 11. Using the do repeat command calculate the running total for all council areas and health boards by taking the preceding running total value and adding that
   to the health net cost value for that row.

* 12. Calculate the running percentage for each council/health board by using the do repeat function to divide the running total by the total health cost, then multiply by 100.
* 13. Compute 'lcaP' and 'hbP'- the proportion of the area's (council or board) total cost accounted for by each patient. This is done.by
   adding the the rows of all the percentages for each council area and health board.. lcaP and hbP should have a value in every row.
* 14. To compute the percentage cost for the whole of Scotland first calculate the running total by using the compute and leave commands.
* 15. Then work out the percentage cost of the running total using the compute command.
* 16. Compute flags for council area/health board/ whole of Scotland so that the flag=1 if the percentage is less than 50%. to identify and select of HRIs.
* 17. Select if the flag equal 1 to select our HRIs.
* 18. Delete the extraneous variables used to create and select the HRIs
   * 19. Save this file. This file now contains the information for all the HRIs for all councils, boards and whole of Scotland.
**********************************************************************************************
   **Create AllPatients file**.
************************************************UPDATE BY ALISON MCCLELLAND Apr 2015******************************************************************
   *1.5.Need to exclude people who we know are definitely not Scottish as we do not want to
   these in the Scottish HRI's.

get file= !file + "source-individual-file-20" + !FY + ".zsav"
   /Keep year chi health_postcode gpprac lca hbres Health_net_cost Health_net_costincincomplete.

************************************************************** UPDATE DATE!!!! ********************************.
String PCArea (A3).
If health_Postcode NE '' PCArea = char.substr(health_postcode, 1, index(health_postcode, "0123456789", 1) - 1).

sort cases by PCArea.

match files 
   /file = *
   /table = '/conf/linkage/output/jamiem09/ScotPCDistrict2018_1.sav'
   /In = ScotFlag
   /Keep year To PCArea
   /by PCArea.

 * This is to keep the SMR (and other) dummy postcodes.
 * BF is armed forces with no UK address, NF is no fixed abode, NK is not known.
 * The ZZ are old codes which indicate an unknown address in a particular Scottish Local Government authority.
Define !SMRDummyPC()
any(health_postcode, "BF010AA", "NF1 1AB", "NK010AA") OR Range(char.substr(health_postcode, 1, 4), "ZZ01", "ZZ61")
!EndDefine.

 * Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish.
if ((health_postcode = "") OR (!SMRDummyPC)) and gpprac= "" ScotFlag = 2.

 * Finally, we exclude people who have a blank postcode and an English GPprac. And include people with a dummy SMR postcode but no English practice.
 * If a GP practice is English then it will begin with a letter, 99995 is the dummy SMR English practice.
If gpprac NE '' Eng_Prac = 0.
if (SysMiss(Number(char.substr(gpprac, 1, 1), F1.0)) AND gpprac ne "") OR gpprac = "99995" Eng_Prac = 1.
Do if (Eng_Prac = 0).
   If (health_postcode = "") ScotFlag = 3.
   If (!SMRDummyPC) ScotFlag = 4.
End if.

*Way of checking Non-Scottish people you are about to exclude.
string NonScot (A7).
if Scotflag = 0 NonScot = health_Postcode.
frequencies NonScot ScotFlag Eng_Prac.

select if ScotFlag NE 0.
Execute.
Delete Variables NonScot ScotFlag Eng_Prac health_postcode PCArea gpprac.
********************************************************************************************************************************************************************
* 3.Flag variable denotes all of Scotland and creates a break variable to aggregate all Scotland cost.
* 4.Sort Cases by health cost in descending order.
compute Scotland=0.

* 5. Aggregate the file three times, but use add variables to add the council area total health cost, health board total health cost and whole of Scotland total health cost.
*Scotland total cost.
aggregate
   /Presorted
   /Break = Scotland
   /Scot_TotCost = Sum(Health_net_cost).

 * Council area total cost.
 * Council area total cost, including incomplete datasets.
AGGREGATE
   /BREAK = lca
   /CA_TotCost = SUM(health_net_cost)
   /CA_TotCost_inc = SUM(health_net_costincIncomplete)..

*Health Board total cost.
AGGREGATE
   /BREAK = hbres
   /HB_TotCost = SUM(health_net_cost).


* 6. To make the process easier, using the substr function, change the hb variable so it just contains the last 2 characters from each health board number.
compute HB = Number(char.substr(hbres, 8, 2), F2.0).
Alter type lca (F2.0).

****Now the HRIs for each health board, council area and whole of Scotland can be identified.. Health Board and Council Area are computed in the same way.
* 8. Using the the Do Repeat command, put the health net cost for each person under the correct health board/council area variable.
do repeat x = lca1 to lca32
   /y = 1 to 32.
   if (y=lca) x = health_net_cost.
end repeat.

do repeat x = hb1 to hb14
   /y = 15 to 28.
   if (y=hb) x = health_net_cost.
end repeat.

do repeat x = lcaB1 to lcaB32
   /y = 1 to 32.
   if (y=lca) x = health_net_costincIncomplete.
end repeat.


* 9. Again using the Do Repeat command calculate the total health cost for each council area/health board. *Insert "T" into var name to indicate council total etc.
do repeat x = lcaT1 to lcaT32
   /y = 1 to 32.
   if (y=lca) x = CA_TotCost.
end repeat.

do repeat x = hbT1 to hbT14
   /y= 15 to 28.
   if (y=hb) x=HB_TotCost.
end repeat.

do repeat x = lcaBT1 to lcaBT32
   /y = 1 to 32.
   if (y=lca) x = CA_TotCost_inc.
end repeat.

* 10. The costs need to be summed to create a running total and so any missing values in the variables created in step 8 and 9 need to be set to 0.
recode
   hb1 to hb14
   hbT1 to hbT14
   lca1 to lca32
   lcaT1 to lcaT32 
   lcaB1 to lcaB32
   lcaBT1 to lcaBT32(sysmis=0).

* 11. Using the do repeat command calculate the running total for all council areas and health boards by taking the preceding running total value and adding that
   to the health net cost value for that row.
sort cases by health_net_cost (D).
do repeat x=lcaR1 to lcaR32
   /y=lca1 to lca32.
   compute x=x+y.
   leave x.
end repeat.

do repeat x=hbR1 to hbR14
   /y=hb1 to hb14.
   compute x=x+y.
   leave x.
end repeat.

* 14. To compute the percentage cost for the whole of Scotland first calculate the running total by using the compute and leave commands.
compute ScotH = health_net_cost.

compute ScotR = ScotR + ScotH.
leave ScotR.

sort cases by health_net_costincIncomplete (D).
do repeat x=lcaBR1 to lcaBR32
   /y=lcaB1 to lcaB32.
   compute x=x+y.
   leave x.
end repeat.

* 12. Calculate the running percentage for each council/health board by using the do repeat function to divide the running total by the total health cost, then multiply by 100.
do repeat x=lcaP1 to lcaP32
   /y=lcaR1 to lcaR32
   /z=lcaT1 to lcaT32.
   compute x=(y/z)*100.
end repeat.

do repeat x=hbP1 to hbP14
   /y=hbR1 to hbR14
   /z=hbT1 to hbT14.
   compute x=(y/z)*100.
end repeat.

do repeat x=lcaBP1 to lcaBP32
   /y=lcaBR1 to lcaBR32
   /z=lcaBT1 to lcaBT32.
   compute x=(y/z)*100.
end repeat.

* 13. Compute 'lcaP' and 'hbP'- the proportion of the area's (council or board) total cost accounted for by each patient. This is done.by adding the the rows of
   all the percentages for each council area and health board.. lcaP and hbP should have a value in every row.
compute lcaP=Sum(lcaP1 to LcaP32).
compute lcaBP=Sum(lcaBP1 to LcaBP32).
compute hbP=Sum(hbP1 to hbP14).

* 15. Then work out the percentage cost of the running total using the compute command.
compute ScotP=ScotR/Scot_TotCost*100.

* 16. Compute flags for council area/health board/ whole of Scotland so that the flag=1 if the percentage is less than 50%. to identify and select of HRIs.
if (lcaP le 50.00) LcaFlag50=1.
if (lcaBP le 50.00) LcaBFlag50=1.
if (hbP le 50.00) hbFlag50=1.
if (ScotP le 50.00) ScotFlag50=1.

if (lcaP le 65.00) LcaFlag65=1.
if (lcaBP le 65.00) LcaBFlag65=1.
if (hbP le 65.00) hbFlag65 = 1.
if (ScotP le 65.00) ScotFlag65 = 1.

if (lcaP le 80.00) LCaFlag80 = 1.
if (lcaBP le 80.00) LcaBFlag80=1.
if (hbP le 80.00) hbFlag80 = 1.
if (scotP le 80.00) ScotFlag80 = 1.

if (lcaP le 95.00) LCaFlag95 = 1.
if (lcaBP le 95.00) LcaBFlag95=1.
if (hbP le 95.00) hbFlag95 = 1.
if (ScotP le 95.00) ScotFlag95 = 1.

* Make lookup file - like Jamie's.
rename variables 
(LCAFlag50 = LCAflag) 
(LCABFlag50 = LCAflag_All) 
(hbFlag50 = HBflag) 
(ScotFlag50 = Scotflag).

sort cases by CHI.

save outfile=!file + 'HRI_lookup_' + !FY +'.sav'
   /keep chi
      LCAflag to Scotflag
      lcaP to ScotP.

get file = !file + 'HRI_lookup_' + !FY +'.sav'.













