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
    return " ".join([char[0].upper() + char[1:].lower() for char in string.split()])
End Program.

 * Run the above python program on CareHomeName.
SPSSINC TRANS RESULT=CareHomeName Type=39
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

* 20% Match the lookup.
********************************************************************************************************.

 * Fill in any blank CouncilAreaCodes which we can be reasonably sure about.
Sort cases by SendingCouncilAreaCode (A) CareHomeName (A) AccurateData1 (D) weighted_count (D).
Aggregate Outfile = * Mode = AddVariables Overwrite = Yes
   /Presorted
   /break = SendingCouncilAreaCode CareHomeName
   /CareHomeCouncilAreaCode = First(CareHomeCouncilAreaCode).

 * Recalculate the wieghted count.
Compute weighted_count = RecordsPerName * DiffSendingAuthorities * not(any('', CareHomePostcode, CareHomeCouncilAreaCode)).

 * Sort so the most likely postcode is at the top for each LA / Care home name combo.
 * We prefer a match from the lookup first if none then use the most submitted.
Sort cases by CareHomeCouncilAreaCode (A) CareHomeName (A) AccurateData1 (D) weighted_count (D).

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
   /In = AccurateData2
   /By CareHomeCouncilAreaCode CareHomePostcode CareHomeName.

* Now 23% Match the lookup.
********************************************************************************************************.
Execute.
Delete Variables AccurateData1 AccurateData2 Weighted_Count RecordsPerName DiffSendingAuthorities.

