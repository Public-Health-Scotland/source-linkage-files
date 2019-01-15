* Encoding: UTF-8.
 *  Encoding: UTF-8.
 * Program 02-Calculating HRIs (high resource individuals: i.e.NHS patients whose total health costs account for more than 50% of their council, or health board of
   residence, or of Scotland's total health costs.
 * Originally created by Kara Sellar 18/10/13.
 * Amended and updated by ML March 2013
    * Edited and updated by Alison McClelland Apr 2015 for HRI 200,000 days.

 * Aim - To create two files which the first will have the total cost of all patients for each council, health board or all Scotland. The second will have selected out the HRIs
   and contain only those cases >50% of their (HRIs are the individuals whose health cost sum will contribute to 50% of the council/health board total health cost).
 * First define the file path. Then the following steps outlined below describe how the files will be created.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * 
 *  1. Get the CHImaster PLICs costed file for the year of interest.
 *  2. Compute the age of each person in the file (this age is defined as the person's age at 30/09, i.e. the midpoint of the financial year).
 *  3. Compute the flag = 0 to allow the calculate HRIs for the whole of Scotland.
 *  4. Sort Cases by health cost in descending order.
 *  5. Aggregate the file three times, but use add variables to add the council area total health cost, health board total health cost and whole of Scotland total health cost.
 *  6. To make the process easier, using the substr function, change the HB variable so it just contains the last 2 characters from each health board number.
 *  7. Save this file. This file now contains all the information for all patients in Scotland for that year. * * ENSURE FILENAMES REFLECT CURRENT YEAR. *  * 

 * * *  * Now the HRIs for each health board, council area and whole of Scotland can be identified.. Health Board and Council Area are computed in the same way.

 *  8. Using the the Do Repeat command, put the health net cost for each person under the correct health board/council area variable.
 *  9. Again using the Do Repeat command calculate the total health cost for each council area/health board.
 *  10. The costs need to be summed to create a running total and so any missing values in the variables created in step 8 and 9 need to be set to 0.
 *  11. Using the do repeat command calculate the running total for all council areas and health boards by taking the preceding running total value and adding that
   to the health net cost value for that row.

 *  12. Calculate the running percentage for each council/health board by using the do repeat function to divide the running total by the total health cost, then multiply by 100.
 *  13. Compute 'lcaP' and 'hbP'- the proportion of the area's (council or board) total cost accounted for by each patient. This is done.by
   adding the the rows of all the percentages for each council area and health board.. lcaP and hbP should have a value in every row.
 *  14. To compute the percentage cost for the whole of Scotland first calculate the running total by using the compute and leave commands.
 *  15. Then work out the percentage cost of the running total using the compute command.
 *  16. Compute flags for council area/health board/ whole of Scotland so that the flag = 1 if the percentage is less than 50%. to identify and select of HRIs.
 *  17. Select if the flag equal 1 to select our HRIs.
 *  18. Delete the extraneous variables used to create and select the HRIs
   * 19. Save this file. This file now contains the information for all the HRIs for all councils, boards and whole of Scotland.



    * 1.5.Need to exclude people who we know are definitely not Scottish as we do not want to
   these in the Scottish HRI's.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * .
 * First quickly create a lookup for Postcode district, use the lookup file which has all Scottish Postcodes in it.
get file = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
    /Keep postcode.
String PCArea (A3).
 * Workout the postcode area.
 * Take the first bit of the postcode which will be 1, 2 or 3 chars, to work this out find the first number and take everything before this. e.g. EH5 1HU -> EH. 
Compute PCArea = char.substr(postcode, 1, char.index(postcode, "0123456789", 1) - 1).

sort cases by PCArea.
Select if PCArea NE lag(PCArea).

save outfile = !File + "temp-PCArea-lookup-for-HRIs-20" + !FY + ".zsav"
    /keep PCArea
    /zcompressed.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * .
get file = !File + "temp-source-individual-file-3-20" + !FY + ".zsav"
   /Keep year chi postcode gpprac lca hbrescode Health_net_cost Health_net_costincincomplete ch_cost.

String PCArea (A3).
 * Workout the postcode area.
 * Take the first bit of the postcode which will be 1, 2 or 3 chars, to work this out find the first number and take everything before this. e.g. EH5 1HU -> EH. 
If postcode NE '' PCArea = char.substr(postcode, 1, char.index(postcode, "0123456789", 1) - 1).

sort cases by PCArea.

match files 
   /file =  * 
   /table = !File + "temp-PCArea-lookup-for-HRIs-20" + !FY + ".zsav"
   /In = ScotFlag
   /by PCArea.

 * This is to keep the SMR (and other) dummy postcodes.
 * BF is armed forces with no UK address, NF is no fixed abode, NK is not known.
 * The ZZ are old codes which indicate an unknown address in a particular Scottish Local Government authority.
Define !SMRDummyPC()
any(postcode, "BF010AA", "NF1 1AB", "NK010AA") OR Range(char.substr(postcode, 1, 4), "ZZ01", "ZZ61")
!EndDefine.

 * Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish.
if ((postcode = "") OR (!SMRDummyPC)) and sysmis(gpprac) ScotFlag = 2.

 * Finally, we exclude people who have a blank postcode and an English GPprac. And include people with a dummy SMR postcode but no English practice.
 * If a GP practice is English then it should have a dummy code, as below.
Do If Not(sysmis(gpprac)).
    Compute Eng_Prac = 0.
    If (any(gpprac, 99942, 99957, 99961, 99976, 99981, 99999) OR gpprac = 99995) Eng_Prac = 1.
End if.

Do if (Eng_Prac = 0).
   If (postcode = "") ScotFlag = 3.
   If (!SMRDummyPC) ScotFlag = 4.
End if.

 * Way of checking Non-Scottish postcodes / people you are about to exclude. ScotFlag = 0.
 * If they had a Scottish postcode area, ScotFlag will be 1 (from the matching).
 * If they don't have a practice and have a blank or dummy postcode ScotFlag will be 2.
 * If they have a blank postcode but a Scottish practice Scotflag will be 3.
 * If they have a dummy postcode but a Scottish practice Scotflag will be 4.
String NonScot (A7).
if Scotflag = 0 NonScot = PCArea.
frequencies NonScot ScotFlag Eng_Prac.

select if ScotFlag NE 0.
Execute.
Delete Variables NonScot ScotFlag Eng_Prac postcode PCArea gpprac.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *.
 *  3.Flag variable denotes all of Scotland and creates a break variable to aggregate all Scotland cost.
 *  4.Sort Cases by health cost in descending order.

 * Modification to exclude Care Home costs as we only cost over 65s.
Compute health_net_costincIncomplete = health_net_costincIncomplete - ch_cost.

 *  5. Aggregate the file three times, but use add variables to add the council area total health cost, health board total health cost and whole of Scotland total health cost.
 * Scotland total cost.
aggregate
   /Presorted
   /Break
   /Scot_TotCost = Sum(Health_net_cost).

 * Council area total cost.
 * Council area total cost, including incomplete datasets.
AGGREGATE
   /BREAK = lca
   /CA_TotCost = SUM(health_net_cost)
   /CA_TotCost_inc = SUM(health_net_costincIncomplete).

 * Health Board total cost.
AGGREGATE
   /BREAK = hbrescode
   /HB_TotCost = SUM(health_net_cost).


 *  6. Use Auto recode to give each health board a sequential number, this will let us loop over them later.
 * Use missing to make sure any blank hbrescode ends up at the bottom of the list.
Missing Values hbrescode ("        ").
Autorecode hbrescode /into HB.
Alter type lca (F2.0).

 * * *  * Now the HRIs for each health board, council area and whole of Scotland can be identified.. Health Board and Council Area are computed in the same way.
 *  8. Using the the Do Repeat command, put the health net cost for each person under the correct health board/council area variable.
do repeat x = lca1 to lca32
   /y = 1 to 32.
   if (y = lca) x = health_net_cost.
end repeat.

do repeat x = hb1 to hb14
   /y = 1 to 14.
   if (y = HB) x = health_net_cost.
end repeat.

do repeat x = lcaB1 to lcaB32
   /y = 1 to 32.
   if (y = lca) x = health_net_costincIncomplete.
end repeat.


 *  9. Again using the Do Repeat command calculate the total health cost for each council area/health board.  * Insert "T" into var name to indicate council total etc.
do repeat x = lcaT1 to lcaT32
   /y = 1 to 32.
   if (y = lca) x = CA_TotCost.
end repeat.

do repeat x = hbT1 to hbT14
   /y = 1 to 14.
   if (y = HB) x = HB_TotCost.
end repeat.

do repeat x = lcaBT1 to lcaBT32
   /y = 1 to 32.
   if (y = lca) x = CA_TotCost_inc.
end repeat.

 *  10. The costs need to be summed to create a running total and so any missing values in the variables created in step 8 and 9 need to be set to 0.
recode
   hb1 to hb14
   hbT1 to hbT14
   lca1 to lca32
   lcaT1 to lcaT32 
   lcaB1 to lcaB32
   lcaBT1 to lcaBT32 (sysmis = 0).

 *  11. Using the do repeat command calculate the running total for all council areas and health boards by taking the preceding running total value and adding that
   to the health net cost value for that row.
sort cases by health_net_cost (D).
do repeat x = lcaR1 to lcaR32
   /y = lca1 to lca32.
   compute x = x + y.
   leave x.
end repeat.

do repeat x = hbR1 to hbR14
   /y = hb1 to hb14.
   compute x = x + y.
   leave x.
end repeat.

 *  14. To compute the percentage cost for the whole of Scotland first calculate the running total by using the compute and leave commands.
compute ScotH = health_net_cost.

compute ScotR = ScotR + ScotH.
leave ScotR.

sort cases by health_net_costincIncomplete (D).
do repeat x = lcaBR1 to lcaBR32
   /y = lcaB1 to lcaB32.
   compute x = x + y.
   leave x.
end repeat.

 *  12. Calculate the running percentage for each council/health board by using the do repeat function to divide the running total by the total health cost, then multiply by 100.
do repeat x = lcaP1 to lcaP32
   /y = lcaR1 to lcaR32
   /z = lcaT1 to lcaT32.
   compute x = (y/z) * 100.
end repeat.

do repeat x = hbP1 to hbP14
   /y = hbR1 to hbR14
   /z = hbT1 to hbT14.
   compute x = (y/z) * 100.
end repeat.

do repeat x = lcaBP1 to lcaBP32
   /y = lcaBR1 to lcaBR32
   /z = lcaBT1 to lcaBT32.
   compute x = (y/z) * 100.
end repeat.

 *  13. Compute 'lcaP' and 'hbP'- the proportion of the area's (council or board) total cost accounted for by each patient. This is done.by adding the the rows of
   all the percentages for each council area and health board.. lcaP and hbP should have a value in every row.
compute lcaP = Sum(lcaP1 to LcaP32).
compute lcaBP = Sum(lcaBP1 to LcaBP32).
compute hbP = Sum(hbP1 to hbP14).

 *  15. Then work out the percentage cost of the running total using the compute command.
compute ScotP = ScotR/Scot_TotCost * 100.

 *  16. Compute flags for council area/health board/ whole of Scotland so that the flag = 1 if the percentage is less than 50%. to identify and select of HRIs.
if (lcaP le 50.00) LcaFlag50 = 1.
if (lcaBP le 50.00) LcaBFlag50 = 1.
if (hbP le 50.00) hbFlag50 = 1.
if (ScotP le 50.00) ScotFlag50 = 1.

if (lcaP le 65.00) LcaFlag65 = 1.
if (lcaBP le 65.00) LcaBFlag65 = 1.
if (hbP le 65.00) hbFlag65 = 1.
if (ScotP le 65.00) ScotFlag65 = 1.

if (lcaP le 80.00) LCaFlag80 = 1.
if (lcaBP le 80.00) LcaBFlag80 = 1.
if (hbP le 80.00) hbFlag80 = 1.
if (scotP le 80.00) ScotFlag80 = 1.

if (lcaP le 95.00) LCaFlag95 = 1.
if (lcaBP le 95.00) LcaBFlag95 = 1.
if (hbP le 95.00) hbFlag95 = 1.
if (ScotP le 95.00) ScotFlag95 = 1.

 * Rename variables for Source individual file.
Rename Variables 
(LCAFlag50 = HRI_lca) 
(LCABFlag50 = HRI_lca_incDN) 
(hbFlag50 = HRI_hb) 
(ScotFlag50 = HRI_scot).

Rename Variables
(LCAP = HRI_lcaP) 
(LCABP = HRI_lcaP_incDN) 
(hbP = HRI_hbP) 
(ScotP = HRI_scotP).

sort cases by CHI.

 * Recode to make it a 1/0 flag.
Recode HRI_lca to HRI_scot (sysmis = 0).
Alter type
    HRI_lca to HRI_scot (F1.0)
    HRI_lcaP to HRI_ScotP (F3.1).

 * Check all HBs and LCAs have flags, is usually around 2%.
crosstabs HRI_hb by hbrescode
    /Cells = COLUMN.
crosstabs HRI_lca by lca
    /Cells = COLUMN.
crosstabs HRI_lca_incDN by lca
    /Cells = COLUMN.

save outfile = !file + 'HRI_lookup_' + !FY + '.zsav'
   /keep chi
      HRI_lca to HRI_scot
      HRI_lcaP to HRI_ScotP
    /zcompressed.

get file = !file + 'HRI_lookup_' + !FY + '.zsav'.

Erase file = !File + "temp-PCArea-lookup-for-HRIs-20" + !FY + ".zsav".

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * .
 * Match to individual file.
match files
    /file = !File + "temp-source-individual-file-3-20" + !FY + ".zsav"
    /table = !file + 'HRI_lookup_' + !FY + '.zsav'
    /By chi.

save outfile = !File + "temp-source-individual-file-4-20" + !FY + ".zsav"
    /zcompressed.

get file = !File + "temp-source-individual-file-4-20" + !FY + ".zsav".
