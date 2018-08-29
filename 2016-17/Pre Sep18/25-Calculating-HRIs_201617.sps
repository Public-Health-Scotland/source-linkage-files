
*Program 02-Calculating HRIs (high resource individuals: i.e.NHS patients whose total health costs account for more than 50% of their council, or health board of 
residence, or of Scotland's total health costs.
*Orginally created by Kara Sellar 18/10/13.
 *Amended and updated by ML March 2013
*Edited and updated by Alison McClelland Apr 2015 for HRI 200,000 days. 

*Aim - To create two files which the first will have the total cost of all patients for each council, health board or all Scotland. The second will have selected out the HRIs 
and contain only those cases >50% of their (HRIs are the individuals whose health cost sum will contribute to 50% of the council/health board total health cost).
*First define the file path. Then the following steps outlined below describe how the files will be created. 


**UPDATE FOR CURRENT YEAR, check filepaths and name have not changed.
Define !source()
 '/conf/sourcedev/source-individual-file-201617.sav'.
!Enddefine.

Define !file()
 '/conf/sourcedev/'.
!Enddefine.

*Define !file()
'/conf/hscdiip/euanpa01/HRI_LTC_Working/'
!Enddefine.

Define !year()
'1617'
!Enddefine.

*Not enough room in IRF so have changed this file path to cl-out which has been defined in the first program. 
*Define !file()
   '/conf/irf/01-CPTeam/02-Functional-outputs/08-HRI-200,000-days/2012-13/Programs/Working-Files/'
!Enddefine.


**********************************************************************************************
* 1. Get the CHImaster PLICs costed file for the year of interest.
* 2. Compute the age of each person in the file (this age is defined as the person's age at 30/09, ie the midpoint of the financal year).
* 3. Compute the flag=0 to allow the calculate HRIs for the whole of Scotland.
* 4. Sort Cases by health cost in descending order.
* 5. Aggregate the file three times, but use add variables to add the council area total health cost, health board total health cost and whole of Scotland total health cost.
* 6. To make the process easier, using the substr function, change the hb variable so it just contains the last 2 charaters from each health board number.
* 7. Save this file. This file now contains all the information for all patitnes in Scotland for that year. **ENSURE FILENAMES REFLECT CURRENT YEAR.**

****Now the HRIs for each health board, council area and whole of Scotland can be identified.. Health Board and Council Area are computed in the same way. 

* 8. Using the the Do Repeat command, put the health net cost for each person under the correct health board/council area variable. 
* 9. Again using the Do Repeat command calcuale the total health cost for each council area/health board. 
* 10. The costs need to be summed to create a running total and so any missing values in the variables created in step 8 and 9 need to be set to 0.
* 11. Using the do repeat command calculate the running total for all council areas and health boards by taking the precedubg running total value and adding that 
to the health net cost value for that row.

* 12. Calulate the running percentage for each council/health board by using the do repeat function to divide the running total by the total health cost, then multiply by 100. 
* 13. Compute 'lcaP' and 'hbP'- the proportion of the area's (council or board) total cost accounted for by each patient. This is done.by
        adding the the rows of all the percentages for each council area and health board.. lcaP and hbP should have a value in every row.
* 14. To compute the percentage cost for the whole of scotland first calculate the running total by using the compute and leave commands. 
* 15. Then work out the percentage cost of the running total using the compute command.
* 16. Compute flags for council area/health board/ whole of scotland so that the flag=1 if the percentage is less than 50%. to identify and select of HRIs.
* 17. Select if the flag equal 1 to select our HRIs. 
* 18. Delete the extraneous variables used to create and selectselect the HRIs
* 19. Save this file. This file now contains the information for all the HRIs for all councils, boards and whole of scotland. 
**********************************************************************************************
**Create AllPatients file**.


*1.Get the CHImaster PLICs costed firle for the year of interest + 2.Compute the age of each person in the file (this age is defined as the person's age at 30/09, 
ie the midpoint of the financal year).***MAKE SURE TO ALTER THE AGE CALCULATION WHEN ALTERING THE FINANCIAL YEAR***. 
*Get file=!plics.
*Alter type dob (F8.0).
*Compute age= trunc((20120930-dob)/10000).
*Alter type age (F3.0).
*Execute.

************************************************UPDATE BY ALISON MCCLELLAND Apr 2015******************************************************************
*1.5.Need to exclude people who we know are definitely not Scottish as we do not want to 
 these in the Scottish HRI's. 
*get file =  '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'.

*save outfile =   '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'.

*aggregate outfile = *
         /break PC_District Scotflag
         /count = n.
*save outfile = '/conf/linkage/output/alisom18/01-HRI/New_Scot_Post_LKP1_District.sav'      
         /drop count.

*String PCDistrict (A18).
*Compute PCDistrict = substr(health_postcode,1,4).
*execute. 
*get file = '/conf/hscdiip/01-PLICS-analysis-files/masterPLICS_Costed_201112.sav'.

*aggregate outfile = *
/break chi ms
/number = n.

*save outfile = !file + 'MS_temp.sav'
/drop number.


Get file= !source.


*sort cases by CHI.
*match files file = *
/table = !file + 'MS_temp.sav'
/by chi.
*exe.

Alter type dob (F8.0).
************************************************************** UPDATE DATE!!!! ********************************.
Compute age= trunc((20160930-dob)/10000).
Alter type age (F3.0).
Alter type health_postcode (A21).
Rename variables health_postcode = pc7.
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
*Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 

*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = substr(PC7,1,4).
execute. 

sort cases by PCDistrict.
match files file = *
/table =  '/conf/linkage/output/jamiem09/ScotLookup.sav'
/by PCDistrict.
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If pc7 = "" and gpprac= "" ScotFlag = 1.
*execute. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English then it will begin with a letter. 
String GP (A1).
Compute GP = substr(gpprac,1,1).
*execute. 

String Eng_Flag (A1).
If any(GP, 'A','Z') Eng_Flag='1'.
If (PC7 = "" and Eng_Flag ne '1') scotflag=1.
If (PC7='null' and Eng_Flag ne '1') scotflag = 1.
*execute. 



*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = substr(Pc7,1,2).
execute.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

*sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = PCDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = pc7.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables  GP Glasgow_Flag Eng_Flag  count.
 

select if scotflag = 1.
execute. 
Delete variables Scotflag.

*FREQUENCIES VARIABLES=Scottish
  /ORDER=ANALYSIS.

*Check who has been excluded. 
*Select if Scottish ne '1'.
*execute. 
*FREQUENCIES VARIABLES=PCDistrict
  /ORDER=ANALYSIS.
*2012/13 3739 non-Scottish patients excluded. 

*2010/11 5095 non-Scottish Patients excluded. 
*2011/12
5039
********************************************************************************************************************************************************************************

*3.Flag variable denotes all of Scotland and creates a break variable to aggregate all Scotland cost.
*+
*4.Sort Cases by health cost in descending order.
Sort Cases by health_net_cost (d).
Compute Flag=0.
*execute.

* 5. Aggregate the file three times, but use add variables to add the council area total health cost, health board total health cost and whole of Scotland total health cost.
*Scotland total cost.
Aggregate 
  /Outfile=* Mode=AddVariables 
  /Break=Flag
  /Scot_TotCost=Sum(Health_net_cost).
*Execute.


*Council area total cost. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca 
  /CA_TotCost=SUM(health_net_cost).
*Execute.

*Health Board total cost. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=hbres
  /HB_TotCost=SUM(health_net_cost).
Execute.

* 6. To make the process easier, using the substr function, change the hb variable so it just contains the last 2 charaters from each health board number.
String hb (A2).
Compute hb=substr(hbres,8,2).
alter type hb (F2.0).
alter type lca (f2.0).
exe.


****if any gender codes are not 1 or 2 (some were found to be miscoded to 0 or 9, recode genders to proper code from CHI.
String CHI_gender (A1).
Compute CHI_gender = SUBSTR(chi,9,1).
Alter type CHI_gender (F1.0).

Do if gender = 0 or gender = 9.
   Do If any (CHI_gender, 1, 3, 5, 7, 9).
   Compute gender = 1.
   Else if any (CHI_gender, 0, 2, 4, 6, 8).
   Compute gender = 2.
End if.
End if.
Execute.



* 7. Save this file. This file now contains all the information for all patients in Scotland for that year. **ENSURE FILENAMES REFLECT CURRENT YEAR.**
*****.
*Save outfile= !file + '02-AllPatients' + !year + '.sav'
   /drop CHI_gender.
*get file = !file+ '02-AllPatients' + !year + '.sav'.

delete variables chi_gender. 
****Now the HRIs for each health board, council area and whole of Scotland can be identified.. Health Board and Council Area are computed in the same way. 
* 8. Using the the Do Repeat command, put the health net cost for each person under the correct health board/council area variable. 
do repeat x = lca1 to lca32
 /y = 1 to 32.
if (y=lca) x = health_net_cost.
end repeat.
execute.

do repeat x = hb1 to hb14
 /y = 15 to 28.
if (y=hb) x = health_net_cost.
end repeat.
execute.

* 9. Again using the Do Repeat command calcuale the total health cost for each council area/health board. *Insert "T" into var name to indicate council total etc.
Do repeat x = lcaT1 to lcaT32
 /y = 1 to 32.
If (y=lca) x = CA_TotCost.
End repeat.
Execute.

Do Repeat x = hbT1 to hbT14
/y= 15 to 28.
if (y=hb) x=HB_TotCost.
End Repeat.
Execute.

* 10. The costs need to be summed to create a running total and so any missing values in the variables created in step 8 and 9 need to be set to 0.
recode hb1 to hb14 (sysmis=0).
recode hbT1 to hbT14 (sysmis=0).
recode lca1 to lca32 (sysmis=0).
recode lcaT1 to lcaT32 (sysmis=0).

* 11. Using the do repeat command calculate the running total for all council areas and health boards by taking the preceding running total value and adding that 
to the health net cost value for that row.
Do repeat x=lcaR1 to lcaR32
/y=lca1 to lca32.
Compute x=x+y.
leave x.
end repeat.
execute.

Do repeat x=hbR1 to hbR14
/y=hb1 to hb14.
Compute x=x+y.
leave x.
end repeat.
execute.


* 12. Calulate the running percentage for each council/health board by using the do repeat function to divide the running total by the total health cost, then multiply by 100.
Do repeat x=lcaP1 to lcaP32
/y=lcaR1 to lcaR32
/z=lcaT1 to lcaT32.
Compute x=(y/z)*100.
end repeat.
Execute.

Do repeat x=hbP1 to hbP14
/y=hbR1 to hbR14
/z=hbT1 to hbT14.
Compute x=(y/z)*100.
end repeat.
Execute.

* 13. Compute 'lcaP' and 'hbP'- the proportion of the area's (council or board) total cost accounted for by each patient. This is done.by adding the the rows of 
        all the percentages for each council area and health board.. lcaP and hbP should have a value in every row.
Compute lcaP=Sum(lcaP1 to LcaP32).
Compute hbP=Sum(hbP1 to hbP14).
Execute.

* 14. To compute the percentage cost for the whole of scotland first calculate the running total by using the compute and leave commands. 
Compute ScotH=health_net_cost.

Compute ScotR=ScotR+ScotH.
Leave ScotR.
Execute.

* 15. Then work out the percentage cost of the running total using the compute command.
Compute ScotP=ScotR/Scot_TotCost*100.
Execute. 

* 16. Compute flags for council area/health board/ whole of scotland so that the flag=1 if the percentage is less than 50%. to identify and select of HRIs.
If (lcaP le 50.00) LcaFlag50=1.
If(hbP le 50.00) hbFlag50=1.
If(ScotP le 50.00) ScotFlag50=1.
if(lcaP le 65.00) LcaFlag65=1.
if(hbP le 65.00) hbFlag65 = 1.
if(ScotP le 65.00) ScotFlag65 = 1.
if(lcaP le 80.00) LCaFlag80 = 1.
if(hbP le 80.00) hbFlag80 = 1.
if(scotP le 80.00) ScotFlag80 = 1.
if(lcaP le 95.00) LCaFlag95 = 1.
if(hbP le 95.00) hbFlag95 = 1.
if(ScotP le 95.00) ScotFlag95 = 1.
Execute.


* 18. Delete the extraneous variables used to create and selectselect the HRIs.
Delete Variables lca1 to lca32, lcaT1 to lcaT32, lcaR1 to lcaR32, lcaP1 to lcaP32, hb1 to hb14, hbT1 to hbT14, hbR1 to hbR14, hbP1 to hbP14, ScotH, ScotR.



************************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************
*Edit Alison McClelland - save this as the all patients file as this will include everyone but will also have an HRI flag.
*This will be of use for turnover. 
*Edit the HRI Flags to include the year. 
*CHANGE THIS PART ACCORDING TO THE YEAR.
************************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************.

Alter type lca (a2).
String hb2 (a2).
If (hb=1) hb2='A'.
If (hb=2) hb2='B'.
If (hb=3) hb2='Y' .
If (hb=4) hb2='F'.
If (hb=5) hb2='V'.
If (hb=6) hb2='N'.
If (hb=7) hb2='G'.
If (hb=8) hb2='H'.
If (hb=9) hb2='L'.
If (hb=10) hb2='S'.
If (hb=11) hb2='R'.
If (hb=12) hb2='Z'.
If (hb=13) hb2='T' .
If (hb=14) hb2='W'.
***Change in Apr2015 - Now to have 5 year agebands. Alison McClelland***.
String AgeBand (A8).
If (Age le 4) AgeBand = '0-4'.
If (Age ge 5 and Age le 9) AgeBand = '5-9'.
If (Age ge 10 and Age le 14) AgeBand = '10-14'.
If (Age ge 15 and Age le 19) AgeBand = '15-19'.
If (Age ge 20 and Age le 24) AgeBand = '20-24'.
If (Age ge 25 and Age le 29) AgeBand = '25-29'.
If (Age ge 30 and Age le 34) AgeBand = '30-34'.
If (Age ge 35 and Age le 39) AgeBand = '35-39'.
If (Age ge 40 and Age le 44) AgeBand = '40-44'.
If (Age ge 45 and Age le 49) AgeBand = '45-49'.
If (Age ge 50 and Age le 54) AgeBand = '50-54'.
If (Age ge 55 and Age le 59) AgeBand = '55-59'.
If (Age ge 60 and Age le 64) AgeBand = '60-64'.
If (Age ge 65 and Age le 69) AgeBand = '65-69'.
If (Age ge 70 and Age le 74) AgeBand = '70-74'.
If (Age ge 75 and Age le 79) AgeBand = '75-79'.
If (Age ge 80 and Age le 84) AgeBand = '80-84'.
If (Age ge 85 and Age le 89) AgeBand = '85-89'.
If (Age ge 90) AgeBand = '90+'.
Execute. 

recode LcaFlag50 hbFlag50 ScotFlag50 LcaFlag65 hbFlag65 LCaFlag80 hbFlag80 ScotFlag80 LCaFlag95 hbFlag95 ScotFlag95 (sysmis = 0).
exe.


*Save over the all patients file. 
Save outfile= !file + '02-AllPatients' + !year + '.sav'.
get file = !file+ '02-AllPatients' + !year + '.sav'.

* Make lookup file - like Jamie's.
rename variables (LCAFlag50=LCAflag) (hbFlag50=HBflag) (ScotFlag50=Scotflag).

sort cases by CHI.

save outfile=!file + 'HRI_lookup_1617.sav' /keep chi LCAflag to Scotflag lcaP to ScotP year.

erase file=!file + '02-AllPatients' + !year + '.sav'.

get file = !file + 'HRI_lookup_1617.sav'.

*