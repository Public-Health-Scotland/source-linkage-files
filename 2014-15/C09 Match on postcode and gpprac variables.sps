* Encoding: UTF-8.
get file = !File + "temp-source-episode-file-7-" + !FY + ".zsav".

* Correct Postcode formatting.
* Remove any postcodes which are length 3 or 4 as these can not be valid (not a useful dummy either).
If range(Length(Postcode), 3, 4) Postcode = "".

* Remove spaces which deals with any 8-char postcodes.
* These should only come from A&E but we read all in as 8-char just in case.
Compute Postcode = Replace(Postcode, " ", "").

* Add spaces to create a 7-char postcode.
Loop if range(Length(Postcode), 5, 6).
    Compute #current_length = Length(Postcode).
    Compute Postcode = Concat(char.substr(Postcode, 1,  #current_length - 3), " ", char.substr(Postcode,  #current_length - 2, 3)).
End Loop.

alter type postcode (A7).

* Match on postcode stuff.
Sort Cases by postcode.

* Keep existing values in case we can't match the postcode.
Rename Variables
    LCA = LCA_old
    HSCP = HSCP_old
    Datazone = Datazone_old
    hbrescode = hbrescode_old.

 * Use the postcode lookup file to identify valid postcodes.
 * We don't want any of the geographies at this point.
match files file = *
    /table = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
    /In = PostcodeMatch
    /Drop HB2018 to UR2_2016
    /by postcode.

* Where there are blank postcodes try to fill in from other episodes.
* Work out which CHIs we can do something with (where they have at least one correct postcode and at least one incorrect one).
aggregate
    /Break chi
    /all_match = mean(PostcodeMatch).

* Identify CHIs which are 'potentially fixable'.
Compute potentially_fixable = 0.
if chi NE "" and (all_match NE 0 and all_match NE 1) potentially_fixable = 1.

* Save out main file for now.
Temporary.
Select if potentially_fixable = 0.
save outfile = !File + "temp-no-postcode-changes-" + !FY + ".zsav"
    /zcompressed.

* Work on 'potentially fixable' records for now.
Select if potentially_fixable = 1.

* Keep track of changed postcodes.
Compute changed_postcode = 0.

sort cases by chi keydate1_dateformat keytime1 keydate2_dateformat keytime2.

* NK010AA is a dummy postcode for 'Unknown' so we're good to replace this.
Do if chi = lag(chi) and any(postcode, "", "NK010AA").
    Do if (lag(PostcodeMatch) = 1 or lag(changed_postcode) = 1).
        Compute postcode = lag(postcode).
        Compute changed_postcode = 1.
    Else if chi = lag(chi, 2) and (lag(PostcodeMatch, 2) = 1 or lag(changed_postcode, 2) = 1).
        Compute postcode = lag(postcode, 2).
        Compute changed_postcode = 1.
    End if.
End if.

sort cases by chi (A) keydate2_dateformat keytime2 keydate1_dateformat keytime1 (D).

Do if chi = lag(chi) and any(postcode, "", "NK010AA").
    Do if (lag(PostcodeMatch) = 1 or lag(changed_postcode) = 1).
        Compute postcode = lag(postcode).
        Compute changed_postcode = 1.
    Else if chi = lag(chi, 2) and (lag(PostcodeMatch, 2) = 1 or lag(changed_postcode, 2) = 1).
        Compute postcode = lag(postcode, 2).
        Compute changed_postcode = 1.
    End if.
End if.

sort cases by Postcode.

add files file = *
    /file = !File + "temp-no-postcode-changes-" + !FY + ".zsav"
    /Drop PostcodeMatch all_match potentially_fixable changed_postcode
    /By Postcode.

* Apply consistent geographies.
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

 * Remove some strange dummy codes which seem to come from A&E.
If any(HSCP2018, "S37999998", "S37999999") HSCP2018 = "".

* If we can, 'cascade' the geographies upwards i.e. if they have an LCA use this to fill in HSCP2018 and so on for hbrescode.
* Codes are correct as at August 2018.

* First HSCP -> LCA.
* Best one to do first as we can't do anything about C & S.
Do if LCA = "".
    Do if (HSCP2018 = "S37000001").
        Compute LCA = "01".
    Else if (HSCP2018 = "S37000002").
        Compute LCA = "02".
    Else if (HSCP2018 = "S37000003").
        Compute LCA = "03".
    Else if (HSCP2018 = "S37000004").
        Compute LCA = "04".
    Else if (HSCP2018 = "S37000025").
        Compute LCA = "05".
    Else if (HSCP2018 = "S37000029").
        Compute LCA = "07".
    Else if (HSCP2018 = "S37000006").
        Compute LCA = "08".
    Else if (HSCP2018 = "S37000007").
        Compute LCA = "09".
    Else if (HSCP2018 = "S37000008").
        Compute LCA = "10".
    Else if (HSCP2018 = "S37000009").
        Compute LCA = "11".
    Else if (HSCP2018 = "S37000010").
        Compute LCA = "12".
    Else if (HSCP2018 = "S37000011").
        Compute LCA = "13".
    Else if (HSCP2018 = "S37000012").
        Compute LCA = "14".
    Else if (HSCP2018 = "S37000013").
        Compute LCA = "15".
    Else if (HSCP2018 = "S37000032").
        Compute LCA = "16".
    Else if (HSCP2018 = "S37000015").
        Compute LCA = "17".
    Else if (HSCP2018 = "S37000016").
        Compute LCA = "18".
    Else if (HSCP2018 = "S37000017").
        Compute LCA = "19".
    Else if (HSCP2018 = "S37000018").
        Compute LCA = "20".
    Else if (HSCP2018 = "S37000019").
        Compute LCA = "21".
    Else if (HSCP2018 = "S37000020").
        Compute LCA = "22".
    Else if (HSCP2018 = "S37000021").
        Compute LCA = "23".
    Else if (HSCP2018 = "S37000022").
        Compute LCA = "24".
    Else if (HSCP2018 = "S37000033").
        Compute LCA = "25".
    Else if (HSCP2018 = "S37000024").
        Compute LCA = "26".
    Else if (HSCP2018 = "S37000026").
        Compute LCA = "27".
    Else if (HSCP2018 = "S37000027").
        Compute LCA = "28".
    Else if (HSCP2018 = "S37000028").
        Compute LCA = "29".
    Else if (HSCP2018 = "S37000030").
        Compute LCA = "31".
    Else if (HSCP2018 = "S37000031").
        Compute LCA = "32".
    End if.
End if.

* Next LCA -> HSCP2018 (and CA2018)..
Do if HSCP2018 = "" or CA2018 = "".
    Do if (LCA = "01").
        Compute HSCP2018 = "S37000001".
        Compute CA2018 = "S12000033".
    Else if (LCA = "02").
        Compute HSCP2018 = "S37000002".
        Compute CA2018 = "S12000034".
    Else if (LCA = "03").
        Compute HSCP2018 = "S37000003".
        Compute CA2018 = "S12000041".
    Else if (LCA = "04").
        Compute HSCP2018 = "S37000004".
        Compute CA2018 = "S12000035".
    Else if (LCA = "05").
        Compute HSCP2018 = "S37000025".
        Compute CA2018 = "S12000026".
    Else if (LCA = "06").
        Compute HSCP2018 = "S37000005".
        Compute CA2018 = "S12000005".
    Else if (LCA = "07").
        Compute HSCP2018 = "S37000029".
        Compute CA2018 = "S12000039".
    Else if (LCA = "08").
        Compute HSCP2018 = "S37000006".
        Compute CA2018 = "S12000006".
    Else if (LCA = "09").
        Compute HSCP2018 = "S37000007".
        Compute CA2018 = "S12000042".
    Else if (LCA = "10").
        Compute HSCP2018 = "S37000008".
        Compute CA2018 = "S12000008".
    Else if (LCA = "11").
        Compute HSCP2018 = "S37000009".
        Compute CA2018 = "S12000045".
    Else if (LCA = "12").
        Compute HSCP2018 = "S37000010".
        Compute CA2018 = "S12000010".
    Else if (LCA = "13").
        Compute HSCP2018 = "S37000011".
        Compute CA2018 = "S12000011".
    Else if (LCA = "14").
        Compute HSCP2018 = "S37000012".
        Compute CA2018 = "S12000036".
    Else if (LCA = "15").
        Compute HSCP2018 = "S37000013".
        Compute CA2018 = "S12000014".
    Else if (LCA = "16").
        Compute HSCP2018 = "S37000032".
        Compute CA2018 = "S12000047".
    Else if (LCA = "17").
        Compute HSCP2018 = "S37000015".
        Compute CA2018 = "S12000046".
    Else if (LCA = "18").
        Compute HSCP2018 = "S37000016".
        Compute CA2018 = "S12000017".
    Else if (LCA = "19").
        Compute HSCP2018 = "S37000017".
        Compute CA2018 = "S12000018".
    Else if (LCA = "20").
        Compute HSCP2018 = "S37000018".
        Compute CA2018 = "S12000019".
    Else if (LCA = "21").
        Compute HSCP2018 = "S37000019".
        Compute CA2018 = "S12000020".
    Else if (LCA = "22").
        Compute HSCP2018 = "S37000020".
        Compute CA2018 = "S12000021".
    Else if (LCA = "23").
        Compute HSCP2018 = "S37000021".
        Compute CA2018 = "S12000044".
    Else if (LCA = "24").
        Compute HSCP2018 = "S37000022".
        Compute CA2018 = "S12000023".
    Else if (LCA = "25").
        Compute HSCP2018 = "S37000033".
        Compute CA2018 = "S12000048".
    Else if (LCA = "26").
        Compute HSCP2018 = "S37000024".
        Compute CA2018 = "S12000038".
    Else if (LCA = "27").
        Compute HSCP2018 = "S37000026".
        Compute CA2018 = "S12000027".
    Else if (LCA = "28").
        Compute HSCP2018 = "S37000027".
        Compute CA2018 = "S12000028".
    Else if (LCA = "29").
        Compute HSCP2018 = "S37000028".
        Compute CA2018 = "S12000029".
    Else if (LCA = "30").
        Compute HSCP2018 = "S37000005".
        Compute CA2018 = "S12000030".
    Else if (LCA = "31").
        Compute HSCP2018 = "S37000030".
        Compute CA2018 = "S12000040".
    Else if (LCA = "32").
        Compute HSCP2018 = "S37000031".
        Compute CA2018 = "S12000013".
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

* Find out which GPprac codes are good.
* We don't want any of the other variables at this point.
match files file = *
    /table = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav"
    /In = GPPracMatch
    /Drop PC7 to hbpraccode
    /by gpprac.

* Where there are missing gppraccodes try to fill in from other episodes.

* Since the dummy codes are in the lookup file these will be flagged as valid which is not desirable.
If any(gpprac, 99942, 99957, 99961, 99976, 99981, 99995, 99999) GPPracMatch = 0.

* Work out which CHIs we can do something with (where they have at least one correct practice code and at least one incorrect one).
aggregate
    /Break chi
    /all_match = mean(GPPracMatch).

* Identify CHIs which are 'potentially fixable'.
Compute potentially_fixable = 0.
if chi NE "" and (all_match NE 0 and all_match NE 1) potentially_fixable = 1.

* Save out main file for now.
Temporary.
Select if potentially_fixable = 0.
save outfile = !File + "temp-no-gpprac-changes-" + !FY + ".zsav"
    /zcompressed.

* Work on 'potentially fixable' records for now.
Select if potentially_fixable = 1.

* Keep track of changed practice codes.
Compute changed_gpprac = 0.

sort cases by chi keydate1_dateformat keytime1 keydate2_dateformat keytime2.

* 99999 is a dummy practice code for 'Unknown' so we're good to replace this.
Do if chi = lag(chi) and (sysmis(gpprac) or gpprac = 99999).
    Do if (lag(GPPracMatch) = 1 or lag(changed_gpprac) = 1).
        Compute gpprac = lag(gpprac).
        Compute changed_gpprac = 1.
    Else if chi = lag(chi, 2) and (lag(GPPracMatch, 2) = 1 or lag(changed_gpprac, 2) = 1).
        Compute gpprac = lag(gpprac, 2).
        Compute changed_gpprac = 1.
    End if.
End if.

sort cases by chi (A) keydate2_dateformat keytime2 keydate1_dateformat keytime1 (D).

Do if chi = lag(chi) and (sysmis(gpprac) or gpprac = 99999).
    Do if (lag(GPPracMatch) = 1 or lag(changed_gpprac) = 1).
        Compute gpprac = lag(gpprac).
        Compute changed_gpprac = 1.
    Else if chi = lag(chi, 2) and (lag(GPPracMatch, 2) = 1 or lag(changed_gpprac, 2) = 1).
        Compute gpprac = lag(gpprac, 2).
        Compute changed_gpprac = 1.
    End if.
End if.

sort cases by gpprac.

add files file = *
    /file = !File + "temp-no-gpprac-changes-" + !FY + ".zsav"
    /Drop GPPracMatch all_match potentially_fixable changed_gpprac
    /By gpprac.

match files file = *
    /table = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav"
    /In = GPPracMatch
    /Drop PC7 PC8
    /by gpprac.

* If the gpprac code didn't match use the existing values.
Do if GPPracMatch = 0.
    Compute hbpraccode = hbpraccode_old.
End if.

* Apply dictionary info.
!AddHB2018DictionaryInfo HB = hbrescode hbtreatcode hbpraccode death_board_occurrence.
!AddLCADictionaryInfo LCA = LCA sc_send_lca.

* If the practice code didn't match the lookups and also doesn't have a board code (usually all of them), remove it as it's probably a bad code.
if GPPracMatch = 0 and hbpraccode = "" gpprac = $sysmis.

* Final tweak to geographies, if the episode is still missing a hbrescode but hbpraccode and hbtreatcode agree.
* Not including yet as unsure whether the gains are worth introducing incorrect boards...
* If hbpraccode NE "" and hbrescode = "" and hbpraccode = hbtreatcode hbrescode = hbpraccode.

* Recode according to boundary changes 08/05/2018.
Recode hbrescode hbpraccode hbtreatcode ("S08000018" = "S08000029") ("S08000027" = "S08000030").
Recode HSCP2018 ("S37000014" = "S37000032") ("S37000023" = "S37000033").
Recode CA2018 ("S12000015" = "S12000047") ("S12000024" = "S12000048").

save outfile = !File + "temp-source-episode-file-8-" + !FY + ".zsav"
    /Drop LCA_old HSCP_old Datazone_old hbrescode_old hbpraccode_old PostcodeMatch GPPracMatch
    /zcompressed.   

* Housekeeping.
Erase file = !File + "temp-no-postcode-changes-" + !FY + ".zsav".
Erase file = !File + "temp-no-gpprac-changes-" + !FY + ".zsav".

