************************************************************************************************************
                                                   NSS (ISD)
************************************************************************************************************
** AUTHOR:	James McMahon (j.mcmahon1@nhs.net)
** Date:    	17/04/2018
************************************************************************************************************
** Amended by:         
** Date:
** Changes:               
************************************************************************************************************.

Begin Program.
# This program splits the given string into words and then capitalises each word
# It then joins them together putting the spaces back in.
def titleCase(string):
    return " ".join([word[0].upper() + word[1:].lower() for word in string.split()])
End Program.

 * Run the above python program on CareHomeName.
SPSSINC TRANS RESULT=CareHomeName Type=73
   /FORMULA "titleCase(CareHomeName)".

 * First get a count of how often individual names are used.
Aggregate
   /break SendingCouncilAreaCode CareHomeCouncilAreaCode CareHomePostcode CareHomeName
   /RecordsPerName = n.

 * Find out many authorities are using particular versions of names.
Aggregate Outfile = * Mode = AddVariables Overwrite = Yes
   /break CareHomeCouncilAreaCode CareHomePostcode CareHomeName
   /RecordsPerName = Sum(RecordsPerName)
   /DiffSendingAuthorities = n.

 * Created a weighted count, which means multiple authorities using the same name is more powerful, if they have a blank postcode or CA code give them zero weight.
Compute weighted_count = RecordsPerName * DiffSendingAuthorities * not(any('', CareHomePostcode, CareHomeCouncilAreaCode)).

*******************************************************************************************************.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /In = AccurateData1
   /By CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
Frequencies AccurateData1.
* 16.7% Match the lookup.
********************************************************************************************************.

 * Fill in any blank CouncilAreaCodes which we can be reasonably sure about.
Sort cases by SendingCouncilAreaCode (A) CareHomeName (A) AccurateData1 (D) weighted_count (D).
Aggregate Outfile = * Mode = AddVariables Overwrite = Yes
   /Presorted
   /break = SendingCouncilAreaCode CareHomeName
   /CareHomeCouncilAreaCode = First(CareHomeCouncilAreaCode).
 * Filled in about 2000 blanks

*******************************FIX NAMES*************************************************************************.
 * Guess some possible names for ones which don't match the lookup.
String TestName1 TestName2(A73).
Do if AccurateData1 = 0.
    * Try adding 'Care Home' or 'Nursing Home' on the end.
   Compute TestName1 = Concat(Rtrim(CareHomeName), " Care Home").
   Compute TestName2 = Concat(Rtrim(CareHomeName), " Nursing Home").
    * If they have the above alread try removing / replacing it.
   Do if char.index(CareHomeName, "Care Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Care Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Care Home", "Nursing Home").
   Else if char.index(CareHomeName, "Nursing Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing Home", "Care Home").
   Else if char.index(CareHomeName, "Nursing") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing", "Care Home").
   * If ends in brackets replace it.
   Else if char.index(CareHomeName, "(") > 1.
      Compute TestName1 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Care Home").
      Compute TestName2 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Nursing Home").
   End if.
End if.
*******************************************************************************************************.
 * Check if TestName1 makes the record match the lookup.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode TestName1.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /Rename (CareHomeName = TestName1)
   /In = TestName1Correct
   /By CareHomeCouncilAreaCode CareHomePostcode TestName1.

*******************************************************************************************************.
 * Check if TestName2 makes the record match the lookup.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode TestName2.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /Rename (CareHomeName = TestName2)
   /In = TestName2Correct
   /By CareHomeCouncilAreaCode CareHomePostcode TestName2.

 * If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 AND TestName2Correct = 0.
   Compute CareHomeName = TestName1.
Else If TestName2Correct = 1 AND TestName1Correct = 0.
   Compute CareHomeName = TestName2.
End If.
Execute.
Delete Variables TestName1 TestName2 TestName1Correct TestName2Correct.

*******************************************************************************************************.
 * See which match now.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /In = AccurateData2
   /By CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
Frequencies AccurateData2.
* 16.7% Match the lookup.

******************************FIX POSTCODES**************************************************************************.
 * Recalculate the wieghted count.
Compute weighted_count = RecordsPerName * DiffSendingAuthorities * not(any('', CareHomePostcode, CareHomeCouncilAreaCode)).

 * Sort so the most likely postcode is at the top for each LA / Care home name combo.
 * We prefer a match from the lookup first if none then use the most submitted.
Sort cases by CareHomeCouncilAreaCode (A) CareHomeName (A) AccurateData2 (D) weighted_count (D).

 * Use the most likely postcode. Overwriting different ones. (On first try this 'removed' about 100).
Aggregate Outfile = * Mode = AddVariables Overwrite = Yes
   /Presorted
   /break = CareHomeCouncilAreaCode CareHomeName
   /CareHomePostcode = First(CareHomePostcode).

*******************************************************************************************************.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /In = AccurateData3
   /By CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
Frequencies AccurateData3.
* Now 17.9% Match the lookup.
********************************************************************************************************.

*******************************FIX NAMES*************************************************************************.
 * Guess some possible names for ones which don't match the lookup.
String TestName1 TestName2(A73).
Do if AccurateData3 = 0.
    * Try adding 'Care Home' or 'Nursing Home' on the end.
   Compute TestName1 = Concat(Rtrim(CareHomeName), " Care Home").
   Compute TestName2 = Concat(Rtrim(CareHomeName), " Nursing Home").
    * If they have the above alread try removing / replacing it.
   Do if char.index(CareHomeName, "Care Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Care Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Care Home", "Nursing Home").
   Else if char.index(CareHomeName, "Nursing Home") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing Home") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing Home", "Care Home").
   Else if char.index(CareHomeName, "Nursing") > 1.
      Compute TestName1 = Strunc(CareHomeName, char.index(CareHomeName, "Nursing") - 1).
      Compute TestName2 = Replace(CareHomeName, "Nursing", "Care Home").
   * If ends in brackets replace it.
   Else if char.index(CareHomeName, "(") > 1.
      Compute TestName1 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Care Home").
      Compute TestName2 = Concat(Rtrim(Strunc(CareHomeName, char.index(CareHomeName, "(") - 1)), " Nursing Home").
   End if.
End if.
*******************************************************************************************************.
 * Check if TestName1 makes the record match the lookup.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode TestName1.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /Rename (CareHomeName = TestName1)
   /In = TestName1Correct
   /By CareHomeCouncilAreaCode CareHomePostcode TestName1.

*******************************************************************************************************.
 * Check if TestName2 makes the record match the lookup.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode TestName2.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /Rename (CareHomeName = TestName2)
   /In = TestName2Correct
   /By CareHomeCouncilAreaCode CareHomePostcode TestName2.

*******************************************************************************************************.
 * If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 AND TestName2Correct = 0.
   Compute CareHomeName = TestName1.
Else If TestName2Correct = 1 AND TestName1Correct = 0.
   Compute CareHomeName = TestName2.
End If.
Execute.
Delete Variables TestName1 TestName2 TestName1Correct TestName2Correct.

*******************************************************************************************************.
 * See which match now.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /In = AccurateData4
   /By CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
Frequencies AccurateData4.
* 16.7% Match the lookup.

******************************FIX POSTCODES**************************************************************************.
 * Recheck Postcodes as we may have some matches now that we weren't using before.
 * Recalculate the wieghted count.
Compute weighted_count = RecordsPerName * DiffSendingAuthorities * not(any('', CareHomePostcode, CareHomeCouncilAreaCode)).

 * Sort so the most likely postcode is at the top for each LA / Care home name combo.
 * We prefer a match from the lookup first if none then use the most submitted.
Sort cases by CareHomeCouncilAreaCode (A) CareHomeName (A) AccurateData4 (D) weighted_count (D).

 * Use the most likely postcode. Overwriting different ones. (On first try this 'removed' about 100).
Aggregate Outfile = * Mode = AddVariables Overwrite = Yes
   /Presorted
   /break = CareHomeCouncilAreaCode CareHomeName
   /CareHomePostcode = First(CareHomePostcode).

*******************************************************************************************************.
Sort Cases by CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
match files
   /file = *
   /Table = "Care_home_lookup.sav"
   /In = AccurateData5
   /By CareHomeCouncilAreaCode CareHomePostcode CareHomeName.
* Now 30.6% Match the lookup.
********************************************************************************************************.
Frequencies AccurateData1 AccurateData2 AccurateData3 AccurateData4 AccurateData5.

Delete Variables RecordsPerName DiffSendingAuthorities weighted_count AccurateData1 AccurateData2 AccurateData3 AccurateData4.
Rename Variables AccurateData5 = LookupMatch.
