﻿* Encoding: UTF-8.
* Calculating HRIs (high resource individuals) which are patients whose total health costs account for more than 50% of their council, health board of
    residence, or Scotland's total health costs.
* Originally created by Kara Sellar 18/10/13.
* Amended and updated by ML March 2013.
* Edited and updated by Alison McClelland Apr 2015 for HRI 200,000 days.
* Re-written to simplify reading by James McMahon Aug 2019.

* Step 1 - Remove non-Scottish residents
    * Step 2 - Work out total cost for Scotland, HBs and LCAs.
* Step 3 - Create a cumulative percentage using the percentage of resource used by each CHI.
* Step 4 - Identify those CHIs which are jointly using 50% of the resources for an area, these are the HRIs.
* Step 5 - Save out and link back to the SLF.


* First quickly create a lookup for Postcode district, use the lookup file which has all Scottish Postcodes in it.
get file = !Lookup_dir_slf + "source_postcode_lookup_" + !LatestUpdate + ".zsav"
    /Keep postcode.
String PCArea (A3).
* Workout the postcode area.
* Take the first bit of the postcode which will be 1, 2 or 3 chars, to work this out find the first number and take everything before this. e.g. EH5 1HU -> EH.
Compute PCArea = char.substr(postcode, 1, char.index(postcode, "0123456789", 1) - 1).

sort cases by PCArea.
Select if PCArea NE lag(PCArea).

save outfile = !Year_dir + "temp-PCArea-lookup-for-HRIs-20" + !FY + ".zsav"
    /keep PCArea
    /zcompressed.


get file = !Year_dir + "temp-source-individual-file-3-20" + !FY + ".zsav"
    /Keep year chi postcode gpprac lca hbrescode Health_net_cost
    Acute_episodes Mat_episodes MH_episodes GLS_episodes OP_newcons_attendances OP_newcons_dnas AE_attendances PIS_paid_items OoH_cases.

* Exclude people who didn't have health activity.
compute health_activity = Acute_episodes + Mat_episodes + MH_episodes + GLS_episodes + OP_newcons_attendances + OP_newcons_dnas + AE_attendances + PIS_paid_items + OoH_cases.

select if health_activity >= 1.

String PCArea (A3).
* Workout the postcode area.
* Take the first bit of the postcode which will be 1, 2 or 3 chars, to work this out find the first number and take everything before this. e.g. EH5 1HU -> EH.
If postcode NE "" PCArea = char.substr(postcode, 1, char.index(postcode, "0123456789", 1) - 1).

sort cases by PCArea.

match files
    /file = *
    /table = !Year_dir + "temp-PCArea-lookup-for-HRIs-20" + !FY + ".zsav"
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

select if ScotFlag NE 0.

sort cases by chi.
Delete Variables NonScot ScotFlag Eng_Prac postcode PCArea gpprac.

* Get the total costs for the different Geographies.
* Scotland total cost.
aggregate
    /Break
    /scotland_cost = Sum(health_net_cost).

* Health Board total cost.
aggregate
    /Break hbrescode
    /hb_cost = Sum(health_net_cost).

* Council area total cost.
* Council area total cost, including incomplete datasets.
aggregate
    /Break lca
    /lca_cost = Sum(health_net_cost).

* Work out what percentage of the total cost each CHI used for the different geographies.
Compute scotland_pct = health_net_cost / scotland_cost * 100.
Compute hb_pct = health_net_cost / hb_cost * 100.
Compute lca_pct = health_net_cost / lca_cost * 100.

* Work out the cumulative percentages for each geography.
* Scotland.
Sort cases by health_net_cost (D).

Do if $casenum = 1.
    * The first case will just be its own percentage.
    Compute HRI_scotP = scotland_pct.
Else.
    * Subsequent cases are the cumulative sum of percentages.
    Compute HRI_scotP = lag(HRI_scotP) + scotland_pct.
End if.

* HBs.
Sort cases by hbrescode (A) health_net_cost (D).
* As above but we also start again when the Health Board changes.
Do if $casenum = 1 or hbrescode NE lag(hbrescode).
    Compute HRI_hbP = hb_pct.
Else.
    Compute HRI_hbP = lag(HRI_hbP) + hb_pct.
End if.

* LCAs.
Sort cases by lca (A) health_net_cost (D).
Do if $casenum = 1 or lca NE lag(lca).
    Compute HRI_lcaP = lca_pct.
Else.
    Compute HRI_lcaP = lag(HRI_lcaP) + lca_pct.
End if.

* Flag the CHIs who together are using the 'first' 50% of resource
    * These are the HRIs and are usually around 2% of the total population.
if (HRI_scotP <= 50) HRI_scot = 1.
if (HRI_hbP <= 50) HRI_hb = 1.
if (HRI_lcaP <= 50) HRI_lca = 1.

* Recode to make it a 1/0 flag.
Recode HRI_scot to HRI_lca (sysmis = 0).
Alter type
    HRI_scot to HRI_lca (F1.0)
    HRI_scotP to HRI_lcaP (F3.1).

* Remove values for chis with no HB or LCA.
Do if hbrescode = "".
    Compute HRI_hb = 0.
    Compute HRI_hbP = $sysmis.
End if.

Do if LCA = "".
    Compute HRI_LCA = 0.
    Compute HRI_LCAP = $sysmis.
End if.

* Sort back by CHI ready for matching.
sort cases by CHI.

save outfile = !Year_dir + "HRI_lookup_" + !FY + ".zsav"
    /keep chi
    HRI_scot to HRI_lca
    HRI_scotP to HRI_lcaP
    /zcompressed.


* Match to individual file.
match files
    /file = !Year_dir + "temp-source-individual-file-3-20" + !FY + ".zsav"
    /table = !Year_dir + "HRI_lookup_" + !FY + ".zsav"
    /By chi.

save outfile = !Year_dir + "temp-source-individual-file-4-20" + !FY + ".zsav"
    /zcompressed.

get file = !Year_dir + "temp-source-individual-file-4-20" + !FY + ".zsav".

* Housekeeping.
Erase file = !Year_dir + "temp-PCArea-lookup-for-HRIs-20" + !FY + ".zsav".
