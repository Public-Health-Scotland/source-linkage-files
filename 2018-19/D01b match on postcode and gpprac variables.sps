* Encoding: UTF-8.
get file = !File + "temp-source-individual-file-2-" + !FY + ".zsav".

* Match on postcode stuff.
Sort Cases by postcode.

 * Keep existing values in case we can't match the postcode.
Rename Variables
    LCA = LCA_old
    HSCP2016 = HSCP2016_old
    Datazone2011 = Datazone2011_old.

*Apply consistent geographies.
match files file = *
    /table = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
    /In = PostcodeMatch
    /by postcode.

 * If the postcode matched use the new values, if it didn't use the existing ones.
Do if PostcodeMatch = 0.
    Compute LCA = LCA_old.
    Compute HSCP2016 = HSCP2016_old.
    Compute Datazone2011 = Datazone2011_old.
Else.
    Compute hbrescode = HB2014.
End if.

 * If we can, 'cascade' the geographies upwards i.e. if they have an LCA use this to fill in HSCP2016 and so on for hbrescode.
 * Codes are correct as at August 2018.

* First LCA -> HSCP2016.
Do if HSCP2016 = "".
    Do if (LCA = "01").
        Compute HSCP2016 = "S37000001".
    Else if (LCA = "02").
        Compute HSCP2016 = "S37000002".
    Else if (LCA = "03").
        Compute HSCP2016 = "S37000003".
    Else if (LCA = "04").
        Compute HSCP2016 = "S37000004".
    Else if (LCA = "05").
        Compute HSCP2016 = "S37000025".
    Else if (LCA = "06").
        Compute HSCP2016 = "S37000005".
    Else if (LCA = "07").
        Compute HSCP2016 = "S37000029".
    Else if (LCA = "08").
        Compute HSCP2016 = "S37000006".
    Else if (LCA = "09").
        Compute HSCP2016 = "S37000007".
    Else if (LCA = "10").
        Compute HSCP2016 = "S37000008".
    Else if (LCA = "11").
        Compute HSCP2016 = "S37000009".
    Else if (LCA = "12").
        Compute HSCP2016 = "S37000010".
    Else if (LCA = "13").
        Compute HSCP2016 = "S37000011".
    Else if (LCA = "14").
        Compute HSCP2016 = "S37000012".
    Else if (LCA = "15").
        Compute HSCP2016 = "S37000013".
    Else if (LCA = "16").
        Compute HSCP2016 = "S37000032".
    Else if (LCA = "17").
        Compute HSCP2016 = "S37000015".
    Else if (LCA = "18").
        Compute HSCP2016 = "S37000016".
    Else if (LCA = "19").
        Compute HSCP2016 = "S37000017".
    Else if (LCA = "20").
        Compute HSCP2016 = "S37000018".
    Else if (LCA = "21").
        Compute HSCP2016 = "S37000019".
    Else if (LCA = "22").
        Compute HSCP2016 = "S37000020".
    Else if (LCA = "23").
        Compute HSCP2016 = "S37000021".
    Else if (LCA = "24").
        Compute HSCP2016 = "S37000022".
    Else if (LCA = "25").
        Compute HSCP2016 = "S37000033".
    Else if (LCA = "26").
        Compute HSCP2016 = "S37000024".
    Else if (LCA = "27").
        Compute HSCP2016 = "S37000026".
    Else if (LCA = "28").
        Compute HSCP2016 = "S37000027".
    Else if (LCA = "29").
        Compute HSCP2016 = "S37000028".
    Else if (LCA = "30").
        Compute HSCP2016 = "S37000005".
    Else if (LCA = "31").
        Compute HSCP2016 = "S37000030".
    Else if (LCA = "32").
        Compute HSCP2016 = "S37000031".
    End if.
End if.

* Now HSCP2016 -> hbrescode.
Do if hbrescode = "".
    Do if (HSCP2016 = "S37000001").
        Compute hbrescode = "S08000020".
    Else if (HSCP2016 = "S37000002").
        Compute hbrescode = "S08000020".
    Else if (HSCP2016 = "S37000003").
        Compute hbrescode = "S08000030".
    Else if (HSCP2016 = "S37000004").
        Compute hbrescode = "S08000022".
    Else if (HSCP2016 = "S37000005").
        Compute hbrescode = "S08000019".
    Else if (HSCP2016 = "S37000006").
        Compute hbrescode = "S08000017".
    Else if (HSCP2016 = "S37000007").
        Compute hbrescode = "S08000030".
    Else if (HSCP2016 = "S37000008").
        Compute hbrescode = "S08000015".
    Else if (HSCP2016 = "S37000009").
        Compute hbrescode = "S08000021".
    Else if (HSCP2016 = "S37000010").
        Compute hbrescode = "S08000024".
    Else if (HSCP2016 = "S37000011").
        Compute hbrescode = "S08000021".
    Else if (HSCP2016 = "S37000012").
        Compute hbrescode = "S08000024".
    Else if (HSCP2016 = "S37000013").
        Compute hbrescode = "S08000019".
    Else if (HSCP2016 = "S37000015").
        Compute hbrescode = "S08000021".
    Else if (HSCP2016 = "S37000016").
        Compute hbrescode = "S08000022".
    Else if (HSCP2016 = "S37000017").
        Compute hbrescode = "S08000021".
    Else if (HSCP2016 = "S37000018").
        Compute hbrescode = "S08000024".
    Else if (HSCP2016 = "S37000019").
        Compute hbrescode = "S08000020".
    Else if (HSCP2016 = "S37000020").
        Compute hbrescode = "S08000015".
    Else if (HSCP2016 = "S37000021").
        Compute hbrescode = "S08000023".
    Else if (HSCP2016 = "S37000022").
        Compute hbrescode = "S08000025".
    Else if (HSCP2016 = "S37000024").
        Compute hbrescode = "S08000021".
    Else if (HSCP2016 = "S37000025").
        Compute hbrescode = "S08000016".
    Else if (HSCP2016 = "S37000026").
        Compute hbrescode = "S08000026".
    Else if (HSCP2016 = "S37000027").
        Compute hbrescode = "S08000015".
    Else if (HSCP2016 = "S37000028").
        Compute hbrescode = "S08000023".
    Else if (HSCP2016 = "S37000029").
        Compute hbrescode = "S08000021".
    Else if (HSCP2016 = "S37000030").
        Compute hbrescode = "S08000024".
    Else if (HSCP2016 = "S37000031").
        Compute hbrescode = "S08000028".
    Else if (HSCP2016 = "S37000032").
        Compute hbrescode = "S08000029".
    Else if (HSCP2016 = "S37000033").
        Compute hbrescode = "S08000030".
    End If.
End if.


*****************************************************************************************.
********* Mathch in GP practice and cluster info. **********************************.
sort cases by gpprac.

 * Keep existing values in case we can't match the gpprac code.
Rename Variables
    hbpraccode = hbpraccode_old.

match files file = *
    /table = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav"
    /In = GPPracMatch
    /Drop PC7 PC8
    /by gpprac.

 * If the gpprac code didn't match use the existing values.
Do if GPPracMatch = 0.
    Compute hbpraccode = hbpraccode_old.
End if.

 * Set some known dummy practice codes to consistent Board codes.
Do if any(gpprac, 99942, 99957, 99961, 99976, 99981, 99999).
    Compute hbpraccode = "S08200003". /*Outwith Scotland / unknown*/.
Else if gpprac = 99995.
    Compute hbpraccode = "S08200001".  /*RUK*/.
End if.

 * Add labels for the dummy boards.
Add Value Labels hbpraccode
    "S08200003" "Outwith Scotland / Unknown"
    "S08200001" "Rest of UK".

 * If the practice code didn't match the lookups and still doesn't have a board code, remove it as it's probably a bad code.
if GPPracMatch = 0 and hbpraccode = "" gpprac = $sysmis.


save outfile = !File + "temp-source-individual-file-3-" + !FY + ".zsav"
   /zcompressed.

get file = !File + "temp-source-individual-file-3-" + !FY + ".zsav".
