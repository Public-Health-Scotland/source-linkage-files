Define !Existing(FY = !Tokens(1))
!Quote(!Concat("/conf/hscdiip/01-Source-linkage-files/source-episode-file-20", !FY, ".sav"))
!EndDefine.

Define !New(FY = !Tokens(1))
!Quote(!Concat("/conf/sourcedev/source-episode-file-20", !FY, ".zsav"))
!EndDefine.
************************************************************************.
************************************************************************.
 * Fix the DNA costs for Outpatients. - DONE.
get file = !Existing FY = 1617
   /Keep chi recid attendance_status keydate1_dateformat keydate2_dateformat location stay spec sigfac conc reftype refsource clinic_type nhshosp Cost_Total_Net_incDNAs .

select if recid = '00B' AND any(attendance_status, '5', '8').
aggregate
   /outfile = *
   /break chi recid attendance_status keydate1_dateformat keydate2_dateformat location stay spec sigfac conc reftype refsource clinic_type nhshosp 
   /Cost_Total_Net_incDNAs = First(Cost_Total_Net_incDNAs).
alter type location (a7).
save outfile = "/conf/sourcedev/James/Temp/OutPCostsLookup.zsav"
   /zcompressed.

get  !New FY = 1617.
sort cases by chi recid attendance_status keydate1_dateformat keydate2_dateformat location stay spec sigfac conc reftype refsource clinic_type nhshosp.
save outfile = "/conf/sourcedev/James/Temp/NewSorted.zsav"
   /zcompressed.

match files
   /file = "/conf/sourcedev/James/Temp/NewSorted.zsav"
   /Table = "/conf/sourcedev/James/Temp/OutPCostsLookup.zsav"
   /Rename (Cost_Total_Net_incDNAs = new_cost)
   /by chi recid attendance_status keydate1_dateformat keydate2_dateformat location stay spec sigfac conc reftype refsource clinic_type nhshosp.
execute.

If Not(Sysmis(new_cost)) Cost_Total_Net_incDNAs = new_cost.

Descriptives Cost_Total_Net_incDNAs.

sort cases by chi keydate1_dateformat.

save outfile = !New FY = 1617
   /drop new_cost
   /zcompressed.

************************************************************************.
 * Fix the Care home gender and the 16/17 costs. - DONE.
get file = "/conf/sourcedev/James/Care Homes/Care_Home_For_Source-1617.zsav"
   /Keep chi recid keydate1_dateformat keydate2_dateformat gender Cost_Total_Net_incDNAs Cost_Total_Net.

sort cases by chi recid keydate1_dateformat keydate2_dateformat.

save outfile = "/conf/sourcedev/James/Temp/CHSorted.zsav"
   /zcompressed.

get file = !New FY = 1617.
sort cases by chi recid keydate1_dateformat keydate2_dateformat.
save outfile = "/conf/sourcedev/James/Temp/NewSorted.zsav"
   /zcompressed.

match files 
   /file = "/conf/sourcedev/James/Temp/NewSorted.zsav"
   /Table = "/conf/sourcedev/James/Temp/CHSorted.zsav"
   /Rename(gender Cost_Total_Net_incDNAs Cost_Total_Net = new_gender new_Cost_Total_Net_incDNAs new_Cost_Total_Net)
   /By chi recid keydate1_dateformat keydate2_dateformat.

Do if Recid = 'CH'.
   Compute gender = new_gender.
   Compute Cost_Total_Net = new_Cost_Total_Net.
   Compute Cost_Total_Net_incDNAs = new_Cost_Total_Net_incDNAs.
End if.

xsave outfile = !New FY = 1617
   /Drop new_gender new_Cost_Total_Net_incDNAs new_Cost_Total_Net
   /zcompressed.

*****************************************************************************.
 * Add lca to DN - also fill in any blank lca, HB or DZ for other ones where we have a valid PostCode. - DONE.
get file = !New FY = 1617.
sort cases by pc7.
save outfile = "/conf/sourcedev/James/Temp/NewSorted.zsav"
   /zcompressed.

match files 
   /file = "/conf/sourcedev/James/Temp/NewSorted.zsav"
   /Table = "/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2018_1.sav"
   /Rename (DataZone2011 DataZone2001= DZ2011 DZ2001)
   /In = PcMatch
   /Keep year to SPARRA_RISK_SCORE CA2011 HB2014 DZ2011 DZ2001
   /By Pc7.

Do if (PCMatch = 1).
   Compute hbrescode = HB2014.
   Compute datazone = DZ2011.
   Compute DataZone2011 = DZ2011.
   Compute DataZone2001 = DZ2011.
   Do If CA2011='S12000033'.
      Compute lca='01'.
   Else If CA2011='S12000034'.
      Compute lca='02'.
   Else If CA2011='S12000041'.
      Compute lca='03'.
   Else If CA2011='S12000035'.
      Compute lca='04'.
   Else If CA2011='S12000026'.
      Compute lca='05'.
   Else If CA2011='S12000005'.
      Compute lca='06'.
   Else If CA2011='S12000039'.
      Compute lca='07'.
   Else If CA2011='S12000006'.
      Compute lca='08'.
   Else If CA2011='S12000042'.
      Compute lca='09'.
   Else If CA2011='S12000008'.
      Compute lca='10'.
   Else If CA2011='S12000045'.
      Compute lca='11'.
   Else If CA2011='S12000010'.
      Compute lca='12'.
   Else If CA2011='S12000011'.
      Compute lca='13'.
   Else If CA2011='S12000036'.
      Compute lca='14'.
   Else If CA2011='S12000014'.
      Compute lca='15'.
   Else If CA2011='S12000015'.
      Compute lca='16'.
   Else If CA2011='S12000046'.
      Compute lca='17'.
   Else If CA2011='S12000017'.
      Compute lca='18'.
   Else If CA2011='S12000018'.
      Compute lca='19'.
   Else If CA2011='S12000019'.
      Compute lca='20'.
   Else If CA2011='S12000020'.
      Compute lca='21'.
   Else If CA2011='S12000021'.
      Compute lca='22'.
   Else If CA2011='S12000044'.
      Compute lca='23'.
   Else If CA2011='S12000023'.
      Compute lca='24'.
   Else If CA2011='S12000024'.
      Compute lca='25'.
   Else If CA2011='S12000038'.
      Compute lca='26'.
   Else If CA2011='S12000027'.
      Compute lca='27'.
   Else If CA2011='S12000028'.
      Compute lca='28'.
   Else If CA2011='S12000029'.
      Compute lca='29'.
   Else If CA2011='S12000030'.
      Compute lca='30'.
   Else If CA2011='S12000040'.
      Compute lca='31'.
   Else If CA2011='S12000013'.
      Compute lca='32'.
   End If.
End if.

sort cases by chi keydate1_dateformat.

save outfile = !New FY = 1617
   /drop CA2011 HB2014 DZ2011 DZ2001 PCMatch
   /zcompressed.

*****************************************************************************.
 * Add a day to the Care home stay calculation, this means it now includes the last day. - DONE.
 * Trim the location and diag vars for district nursing. - DONE.
get file !New FY = 1617.

Do if recid = 'CH'.
   Compute stay = stay + 1.
   Compute yearstay = yearstay + 1.
Else if recid = 'DN'.
   Do Repeat var = location diag1 to diag6.
      Compute var = Rtrim(Ltrim(var)).
   End Repeat.
End if.

save outfile !New FY = 1617
   /zcompressed.

*****************************************************************************.
* Alter ae_time and merge with ooh. - DONE.
get file !New FY = 1617.
Alter type ae_arrivaltime (Time5).

Rename variables (ae_arrivaltime ConsultationEndTime = keyTime1 keyTime2).

If Not(sysmis(ConsultationStartTime)) keyTime1 = ConsultationStartTime.

Variable Labels
   keyTime1 "Record KeyTime 1"
   keyTime2 "Record KeyTime 2".

save outfile !New FY = 1617
   /Keep year to keydate2_dateformat keyTime1 keyTime2 All
   /Drop ConsultationStartTime
   /zcompressed.

*****************************************************************************.
 * Fix Gender, from CHI if gender is 0.
get file !New FY = 1617.
Recode Gender (SYSMIS = 0).

Do if Chi NE '' AND Gender = 0.
   Do If Mod(Number(char.substr(chi, 9, 1), F1.0), 2) = 1.
      Compute Gender = 1.
   Else If Mod(Number(char.substr(chi, 9, 1), F1.0), 2) = 0.
      Compute Gender = 2.
   End if.
End if.

 * Add Value Lables.
Insert file = "/conf/irf/11-Development team/Dev00-PLICS-files/2015-16/New dataset additions/Source dictionary syntax.sps" Error = Stop.

!AddHBDictionaryInfo HB = hbpraccode hbrescode hbtreatcode death_board_occurrence.
!AddLCADictionaryInfo LCA = LCA sc_send_lca ch_lca.

 * Add Variable Lables.
VARIABLE LABELS 
keydate1_dateformat "Record Key date 1 in date format"
keydate2_dateformat "Record Key date 2 in date format"
SPARRA_RISK_SCORE "SPARRA Risk score allocated to CHI for the 12 month period from start of next Financial Year".

save outfile !New FY = 1617
   /zcompressed.



