* Encoding: UTF-8.

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

************************************************************************************************************.
* Read in Diagnosis extract.
GET DATA  /TYPE=TXT
   /FILE= !Extracts + "GP-OoH-diagnosis-extract-20" + !FY + ".csv"
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      GUID A36
      ReadCode A5
      Description A70.
CACHE.

* Sort and save.
Sort cases by ReadCode.
save outfile = !File + "GP-Diagnosis-Data-Temp.zsav"
   /zcompressed.
************************************************************************************************************.
* This section attempts to identify and fix any bad read codes 
************************************************************************************************************.
* See which ones match.
match files
   /File = !File + "GP-Diagnosis-Data-Temp.zsav"
   /Table = !Lookup + "../ReadCodeLookup.zsav"
   /In = FullMatch1
   /By ReadCode Description.

* If the codes still don't match it could just be because the descriptions are different.
match files
   /File = *
   /Table = !Lookup + "../ReadCodeLookup.zsav"
   /Rename (Description = TrueDescription)
   /By ReadCode.

* If we had a description in the lookup that matched a Read code, use that one now.
If FullMatch1 = 0 AND TrueDescription NE "" Description = TrueDescription.

* Any that are still not matching at this point must be bad Read codes.
Sort cases by ReadCode Description.
match files
   /File = *
   /Table = !Lookup + "../ReadCodeLookup.zsav"
   /In = FullMatch2
   /By ReadCode Description.

Frequencies FullMatch1 FullMatch2.

Temporary.
select if FullMatch2 = 0.
 * The following are probably bad Read codes for some reason.
Frequencies ReadCode Description.

******************************************.
* PAUSE HERE *
* Check the output for any dodgy Read codes and try and fix by adding exceptions / code to the do if below. 
******************************************.

* If we can let's use the description to pick a Read code from the lookup file.
* Couldn't think of a way to generalise this as descriptions are not necessarily unique.
String Old_ReadCode (A5).
Do if FullMatch2 = 0.
    Compute Old_ReadCode = ReadCode.
    If ReadCode = "Xa1m." ReadCode = "S349". /*Someone used ReadCode v3.
    If ReadCode = "Xa1mz" ReadCode = "S349." /*Someone used ReadCode v3.
    If ReadCode = "HO6.." ReadCode = "H06.." /*Letter 'O' was used instead of zero.
    Compute ReadCode = Replace(ReadCode, "?", ".").  /*Someone used '?' instead of '.'.
    Compute ReadCode = char.Rpad(ReadCode, 5, "."). /*Some readcodes were not padded out with '.'s.
End if.

 * See which were changed.
 * Shouldn't be many!.
Temporary.
Select if FullMatch2 = 0 and Old_ReadCode NE ReadCode.
Crosstabs Old_ReadCode by ReadCode.

 * Do a final check.
Sort cases by ReadCode Description.
match files
   /File = *
   /Table = !Lookup + "../ReadCodeLookup.zsav"
   /In = FinalCheck
   /By ReadCode.

 * If the final corrections worked then this command should result in a warning.
Temporary.
select if FinalCheck = 0.
Frequencies ReadCode Description.

************************************************************************************************************.
* Sort and restructure the data so it's ready to link to case IDs.
Sort cases by GUID ReadCode.
 * Remove any duplicates.
Select if Not(GUID = lag(GUID) AND ReadCode = lag(ReadCode)).

 * Sort the Read codes to keep the more specific ones if available. 
Do if char.index(Readcode, ".") > 0.
   Compute ReadCodeLevel = char.index(Readcode, ".").
Else.
   Compute ReadCodeLevel = 5.
End If.

Sort cases GUID (A) ReadCodeLevel (D) ReadCode (A).

CasesToVars
   /ID=GUID
   /Drop Description TrueDescription FullMatch1 FullMatch2 ReadCodeLevel.

 * Make sure we have at least 6 ReadCodes.
String diag1 diag2 diag3 diag4 diag5 diag6 (A6).

Do Repeat diag = diag1 to diag6
   /ReadCode = ReadCode.1 to ReadCode.6.
   Compute diag = ReadCode.
End Repeat.

* Save, it's now ready to be linked to the consultation data.
Save outfile = !File + "GP-Diagnosis-Data-" + !FY + ".zsav"
   /Keep GUID diag1 to diag6
   /zcompressed.

get file = !File + "GP-Diagnosis-Data-" + !FY + ".zsav".

* Clean up / save space.
Erase File = !File + "GP-Diagnosis-Data-Temp.zsav".

 * Zip up raw data.
Host Command = ["gzip '" + !Extracts + "GP-OoH-diagnosis-extract-20" + !FY + ".csv'"].
