* Encoding: UTF-8.
get file = !File + "temp-source-episode-file-5-" + !FY + ".zsav".

* Match on postcode stuff.
Sort Cases by postcode.

 * Keep existing values in case we can't match the postcode.
Rename Variables
    LCA = LCA_old
    HSCP = HSCP_old
    Datazone = Datazone_old
    hbrescode = hbrescode_old.

*Apply consistent geographies.
match files file = *
    /table = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
    /Rename (HB2018 = hbrescode)
    /In = PostcodeMatch
    /by postcode.

 * If the postcode matched use the new values, if it didn't use the existing ones.
Do if PostcodeMatch = 0.
    Compute LCA = LCA_old.
    Compute HSCP2018 = HSCP_old.
    Compute Datazone2011 = Datazone_old.
    Compute hbrescode = hbrescode_old.
End if.

 * If we can, 'cascade' the geographies upwards i.e. if they have an LCA use this to fill in HSCP2018 and so on for hbrescode.
 * Codes are correct as at August 2018.

* First LCA -> HSCP2018.
Do if HSCP2018 = "".
    Do if (LCA = "01").
        Compute HSCP2018 = "S37000001".
    Else if (LCA = "02").
        Compute HSCP2018 = "S37000002".
    Else if (LCA = "03").
        Compute HSCP2018 = "S37000003".
    Else if (LCA = "04").
        Compute HSCP2018 = "S37000004".
    Else if (LCA = "05").
        Compute HSCP2018 = "S37000025".
    Else if (LCA = "06").
        Compute HSCP2018 = "S37000005".
    Else if (LCA = "07").
        Compute HSCP2018 = "S37000029".
    Else if (LCA = "08").
        Compute HSCP2018 = "S37000006".
    Else if (LCA = "09").
        Compute HSCP2018 = "S37000007".
    Else if (LCA = "10").
        Compute HSCP2018 = "S37000008".
    Else if (LCA = "11").
        Compute HSCP2018 = "S37000009".
    Else if (LCA = "12").
        Compute HSCP2018 = "S37000010".
    Else if (LCA = "13").
        Compute HSCP2018 = "S37000011".
    Else if (LCA = "14").
        Compute HSCP2018 = "S37000012".
    Else if (LCA = "15").
        Compute HSCP2018 = "S37000013".
    Else if (LCA = "16").
        Compute HSCP2018 = "S37000032".
    Else if (LCA = "17").
        Compute HSCP2018 = "S37000015".
    Else if (LCA = "18").
        Compute HSCP2018 = "S37000016".
    Else if (LCA = "19").
        Compute HSCP2018 = "S37000017".
    Else if (LCA = "20").
        Compute HSCP2018 = "S37000018".
    Else if (LCA = "21").
        Compute HSCP2018 = "S37000019".
    Else if (LCA = "22").
        Compute HSCP2018 = "S37000020".
    Else if (LCA = "23").
        Compute HSCP2018 = "S37000021".
    Else if (LCA = "24").
        Compute HSCP2018 = "S37000022".
    Else if (LCA = "25").
        Compute HSCP2018 = "S37000033".
    Else if (LCA = "26").
        Compute HSCP2018 = "S37000024".
    Else if (LCA = "27").
        Compute HSCP2018 = "S37000026".
    Else if (LCA = "28").
        Compute HSCP2018 = "S37000027".
    Else if (LCA = "29").
        Compute HSCP2018 = "S37000028".
    Else if (LCA = "30").
        Compute HSCP2018 = "S37000005".
    Else if (LCA = "31").
        Compute HSCP2018 = "S37000030".
    Else if (LCA = "32").
        Compute HSCP2018 = "S37000031".
    End if.
End if.

* Now HSCP2018 -> hbrescode.
Do if hbrescode = "".
    Do if (HSCP2018 = "S37000001").
        Compute hbrescode = "S08000020".
    Else if (HSCP2018 = "S37000002").
        Compute hbrescode = "S08000020".
    Else if (HSCP2018 = "S37000003").
        Compute hbrescode = "S08000030".
    Else if (HSCP2018 = "S37000004").
        Compute hbrescode = "S08000022".
    Else if (HSCP2018 = "S37000005").
        Compute hbrescode = "S08000019".
    Else if (HSCP2018 = "S37000006").
        Compute hbrescode = "S08000017".
    Else if (HSCP2018 = "S37000007").
        Compute hbrescode = "S08000030".
    Else if (HSCP2018 = "S37000008").
        Compute hbrescode = "S08000015".
    Else if (HSCP2018 = "S37000009").
        Compute hbrescode = "S08000021".
    Else if (HSCP2018 = "S37000010").
        Compute hbrescode = "S08000024".
    Else if (HSCP2018 = "S37000011").
        Compute hbrescode = "S08000021".
    Else if (HSCP2018 = "S37000012").
        Compute hbrescode = "S08000024".
    Else if (HSCP2018 = "S37000013").
        Compute hbrescode = "S08000019".
    Else if (HSCP2018 = "S37000015").
        Compute hbrescode = "S08000021".
    Else if (HSCP2018 = "S37000016").
        Compute hbrescode = "S08000022".
    Else if (HSCP2018 = "S37000017").
        Compute hbrescode = "S08000021".
    Else if (HSCP2018 = "S37000018").
        Compute hbrescode = "S08000024".
    Else if (HSCP2018 = "S37000019").
        Compute hbrescode = "S08000020".
    Else if (HSCP2018 = "S37000020").
        Compute hbrescode = "S08000015".
    Else if (HSCP2018 = "S37000021").
        Compute hbrescode = "S08000023".
    Else if (HSCP2018 = "S37000022").
        Compute hbrescode = "S08000025".
    Else if (HSCP2018 = "S37000024").
        Compute hbrescode = "S08000021".
    Else if (HSCP2018 = "S37000025").
        Compute hbrescode = "S08000016".
    Else if (HSCP2018 = "S37000026").
        Compute hbrescode = "S08000026".
    Else if (HSCP2018 = "S37000027").
        Compute hbrescode = "S08000015".
    Else if (HSCP2018 = "S37000028").
        Compute hbrescode = "S08000023".
    Else if (HSCP2018 = "S37000029").
        Compute hbrescode = "S08000021".
    Else if (HSCP2018 = "S37000030").
        Compute hbrescode = "S08000024".
    Else if (HSCP2018 = "S37000031").
        Compute hbrescode = "S08000028".
    Else if (HSCP2018 = "S37000032").
        Compute hbrescode = "S08000029".
    Else if (HSCP2018 = "S37000033").
        Compute hbrescode = "S08000030".
    End If.
End if.

*****************************************************************************************.
********* Match in GP practice and cluster info. **********************************.
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


!AddHBDictionaryInfo HB = hbrescode hbtreatcode hbpraccode death_board_occurrence.
!AddLCADictionaryInfo LCA = LCA sc_send_lca ch_lca.


 * If the practice code didn't match the lookups and also doesn't have a board code (usually all of them), remove it as it's probably a bad code.
if GPPracMatch = 0 and hbpraccode = "" gpprac = $sysmis.

 * Recode according to boundary changes 08/05/2018.
 * All of the codes should be correct (have labels) except for the few which we will recode below.
Frequencies hbrescode hbpraccode hbtreatcode HSCP2018 CA2018 LCA.
Recode hbrescode hbpraccode hbtreatcode ("S08000018" = "S08000029") ("S08000027" = "S08000030").
Recode HSCP2018 ("S37000014" = "S37000032") ("S37000023" = "S37000033").
Recode CA2018 ("S12000015" = "S12000047") ("S12000024" = "S12000048").

save outfile = !File + "temp-source-episode-file-6-" + !FY + ".zsav"
    /Drop LCA_old HSCP_old Datazone_old hbrescode_old hbpraccode_old PostcodeMatch GPPracMatch
    /zcompressed.
