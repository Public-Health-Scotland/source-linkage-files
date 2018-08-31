* Read in acute, mental health and geriatric long stay records from the linked catalog. 
* Death registrations are also read in.  Please note that fields specified as date_adm 
* and date_dis for the NRS records are actually the date of death.  Just keeping the same 
* name to keep things 'straight forward'!.


input program.
data list file='/conf/linkage/catalog/catalog_13102016.cis'
 /recid 25-27(a) sdoa 9-14 sdod 17-22.
do  if (recid eq '01A' and sdod le 199603).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) year_dis 17-20(a) diag1 274-277(a) 
            diag2 280-283(a) diag3 286-289(a) diag4 292-295(a) diag5 298-301(a) diag6 304-307(a).
end case.
else if(recid eq '01A' and sdod ge 199604).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 273-276(a) 
            diag2 279-282(a) diag3 285-288(a) diag4 291-294(a) diag5 297-300(a) diag6 303-306(a).
end case.
else if (recid eq '01B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 388-391(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
else if (recid eq '04A' and sdod le 199603).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 283-286(a) 
            diag2 289-292(a) diag3 295-298(a) diag4 301-305(a).
end case.
else if(recid eq '04A' and sdod ge 199604).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 282-285(a) 
            diag2 288-291(a) diag3 294-297(a) diag4 300-304(a).
end case.
else if(recid eq '04B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 388-391(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
else if (recid eq '50A' and sdod le 199603).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 274-277(a) 
            diag2 280-283(a) diag3 286-289(a) diag4 292-295(a) diag5 298-301(a) diag6 304-306(a).
end case.
else if(recid eq '50A' and sdod ge 199604).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 273-276(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
else if(recid eq '50B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 388-391(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
else if (recid eq '99A').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93 (a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24 (a) diag1 130-133 (a) diag2 134-137 (a) diag3 138-141 (a) 
            diag4 142-145 (a).
end case.
else if (recid eq '99B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93 (a) uri 36-43(a)
            date_adm 9-16 (a) date_dis 17-24 (a) diag1 130-133 (a) diag2 135-138 (a) diag3 140-143 (a) 
            diag4 145-148 (a) diag5 150-153 (a) diag6 155-158 (a) diag7 160-163 (a) diag8 165-168 (a) 
            diag9 170-173 (a) diag10 175-178 (a) diag11 180-183 (a).
end if.
end input program.
execute.     

* create three char versions of the diagnosis codes.

string diag1_13 diag2_13 diag3_13 diag4_13 diag5_13 diag6_13 diag7_13 diag8_13 diag9_13 diag10_13 diag11_13 (a3).
compute diag1_13 = substr(diag1,1,3).
compute diag2_13 = substr(diag2,1,3).
compute diag3_13 = substr(diag3,1,3).
compute diag4_13 = substr(diag4,1,3).
compute diag5_13 = substr(diag5,1,3).
compute diag6_13 = substr(diag6,1,3).
compute diag7_13 = substr(diag7,1,3).
compute diag8_13 = substr(diag8,1,3).
compute diag9_13 = substr(diag9,1,3).
compute diag10_13 = substr(diag10,1,3).
compute diag11_13 = substr(diag11,1,3).
execute.

* create a marker to denote records with (a) parkinsons disease and (b) renal failure.

* Parkinsons.
compute parkinsons1 = 0.
compute parkinsons2 = 0.
if ((diag1_13 eq '332') or (diag2_13 eq '332') or (diag3_13 eq '332') or (diag4_13 eq '332') or
    (diag5_13 eq '332') or (diag6_13 eq '332') or (diag7_13 eq '332') or (diag8_13 eq '332') or 
    (diag9_13 eq '332') or (diag10_13 eq '332') or (diag11_13 eq '332') or 
    (diag1 eq '3330') or (diag2 eq '3330') or (diag3 eq '3330') or (diag4 eq '3330') or
    (diag5 eq '3330') or (diag6 eq '3330') or (diag7 eq '3330') or (diag8 eq '3330') or
    (diag9 eq '3330') or (diag10 eq '3330') or (diag11 eq '3330') or 
    (diag1_13 ge 'G20' and diag1_13 le 'G22') or 
    (diag2_13 ge 'G20' and diag2_13 le 'G22') or 
    (diag3_13 ge 'G20' and diag3_13 le 'G22') or 
    (diag4_13 ge 'G20' and diag4_13 le 'G22') or 
    (diag5_13 ge 'G20' and diag5_13 le 'G22') or 
    (diag6_13 ge 'G20' and diag6_13 le 'G22') or 
    (diag7_13 ge 'G20' and diag7_13 le 'G22') or 
    (diag8_13 ge 'G20' and diag8_13 le 'G22') or 
    (diag9_13 ge 'G20' and diag9_13 le 'G22') or 
    (diag10_13 ge 'G20' and diag10_13 le 'G22') or 
    (diag11_13 ge 'G20' and diag11_13 le 'G22')) parkinsons1 = 1.
execute.


if ((diag1_13 eq '332') or (diag2_13 eq '332') or (diag3_13 eq '332') or (diag4_13 eq '332') or
    (diag5_13 eq '332') or (diag6_13 eq '332') or (diag7_13 eq '332') or (diag8_13 eq '332') or 
    (diag9_13 eq '332') or (diag10_13 eq '332') or (diag11_13 eq '332') or 
    (diag1 eq '3330') or (diag2 eq '3330') or (diag3 eq '3330') or (diag4 eq '3330') or
    (diag5 eq '3330') or (diag6 eq '3330') or (diag7 eq '3330') or (diag8 eq '3330') or
    (diag9 eq '3330') or (diag10 eq '3330') or (diag11 eq '3330') or 
    (diag1 eq 'G20X') or (diag2 eq 'G20X') or (diag3 eq 'G20X') or (diag4 eq 'G20X') or (diag5 eq 'G20X') or 
    (diag6 eq 'G20X') or (diag7 eq 'G20X') or (diag8 eq 'G20X') or (diag9 eq 'G20X') or (diag10 eq 'G20X') or 
    (diag11 eq 'G20X') or
    (diag1 eq 'G210') or (diag1 eq 'G211') or (diag1 eq 'G212') or (diag1 eq 'G213') or (diag1 eq 'G218') or (diag1 eq 'G219') or
    (diag2 eq 'G210') or (diag2 eq 'G211') or (diag2 eq 'G212') or (diag2 eq 'G213') or (diag2 eq 'G218') or (diag2 eq 'G219') or
    (diag3 eq 'G210') or (diag3 eq 'G211') or (diag3 eq 'G212') or (diag3 eq 'G213') or (diag3 eq 'G218') or (diag3 eq 'G219') or
    (diag4 eq 'G210') or (diag4 eq 'G211') or (diag4 eq 'G212') or (diag4 eq 'G213') or (diag4 eq 'G218') or (diag4 eq 'G219') or
    (diag5 eq 'G210') or (diag5 eq 'G211') or (diag5 eq 'G212') or (diag5 eq 'G213') or (diag5 eq 'G218') or (diag5 eq 'G219') or
    (diag6 eq 'G210') or (diag6 eq 'G211') or (diag6 eq 'G212') or (diag6 eq 'G213') or (diag6 eq 'G218') or (diag6 eq 'G219') or
    (diag7 eq 'G210') or (diag7 eq 'G211') or (diag7 eq 'G212') or (diag7 eq 'G213') or (diag7 eq 'G218') or (diag7 eq 'G219') or
    (diag8 eq 'G210') or (diag8 eq 'G211') or (diag8 eq 'G212') or (diag8 eq 'G213') or (diag8 eq 'G218') or (diag8 eq 'G219') or
    (diag9 eq 'G210') or (diag9 eq 'G211') or (diag9 eq 'G212') or (diag9 eq 'G213') or (diag9 eq 'G218') or (diag9 eq 'G219') or
    (diag10 eq 'G210') or (diag10 eq 'G211') or (diag10 eq 'G212') or (diag10 eq 'G213') or (diag10 eq 'G218') or (diag10 eq 'G219') or
    (diag11 eq 'G210') or (diag11 eq 'G211') or (diag11 eq 'G212') or (diag11 eq 'G213') or (diag11 eq 'G218') or (diag11 eq 'G219') or
    (diag1 eq 'G22X') or (diag2 eq 'G22X') or (diag3 eq 'G22X') or (diag4 eq 'G22X') or (diag5 eq 'G22X') or 
    (diag6 eq 'G22X') or (diag7 eq 'G22X') or (diag8 eq 'G22X') or (diag9 eq 'G22X') or (diag10 eq 'G22X') or 
    (diag11 eq 'G22X')) parkinsons2 = 1.
execute.

* Renal Failure.
compute refailure1 = 0.
if ((diag1_13 eq '582') or (diag1_13 eq '585') or (diag1 eq '4039') or (diag1 eq '4049')or (diag1_13 eq 'N03') or (diag1_13 eq 'N18') or (diag1_13 eq 'N19') or (diag1_13 eq 'I12') or (diag1_13 eq 'I13') or
    (diag2_13 eq '582') or (diag2_13 eq '585') or (diag2 eq '4039') or (diag2 eq '4049')or (diag2_13 eq 'N03') or (diag2_13 eq 'N18') or (diag2_13 eq 'N19') or (diag2_13 eq 'I12') or (diag2_13 eq 'I13') or
    (diag3_13 eq '582') or (diag3_13 eq '585') or (diag3 eq '4039') or (diag3 eq '4049')or (diag3_13 eq 'N03') or (diag3_13 eq 'N18') or (diag3_13 eq 'N19') or (diag3_13 eq 'I12') or (diag3_13 eq 'I13') or
    (diag4_13 eq '582') or (diag4_13 eq '585') or (diag4 eq '4039') or (diag4 eq '4049')or (diag4_13 eq 'N03') or (diag4_13 eq 'N18') or (diag4_13 eq 'N19') or (diag4_13 eq 'I12') or (diag4_13 eq 'I13') or
    (diag5_13 eq '582') or (diag5_13 eq '585') or (diag5 eq '4039') or (diag5 eq '4049')or (diag5_13 eq 'N03') or (diag5_13 eq 'N18') or (diag5_13 eq 'N19') or (diag5_13 eq 'I12') or (diag5_13 eq 'I13') or
    (diag6_13 eq '582') or (diag6_13 eq '585') or (diag6 eq '4039') or (diag6 eq '4049')or (diag6_13 eq 'N03') or (diag6_13 eq 'N18') or (diag6_13 eq 'N19') or (diag6_13 eq 'I12') or (diag6_13 eq 'I13') or
    (diag7_13 eq '582') or (diag7_13 eq '585') or (diag7 eq '4039') or (diag7 eq '4049')or (diag7_13 eq 'N03') or (diag7_13 eq 'N18') or (diag7_13 eq 'N19') or (diag7_13 eq 'I12') or (diag7_13 eq 'I13') or
    (diag8_13 eq '582') or (diag8_13 eq '585') or (diag8 eq '4039') or (diag8 eq '4049')or (diag8_13 eq 'N03') or (diag8_13 eq 'N18') or (diag8_13 eq 'N19') or (diag8_13 eq 'I12') or (diag8_13 eq 'I13') or
    (diag9_13 eq '582') or (diag9_13 eq '585') or (diag9 eq '4039') or (diag9 eq '4049')or (diag9_13 eq 'N03') or (diag9_13 eq 'N18') or (diag9_13 eq 'N19') or (diag9_13 eq 'I12') or (diag9_13 eq 'I13') or
    (diag10_13 eq '582') or (diag10_13 eq '585') or (diag10 eq '4039') or (diag10 eq '4049')or (diag10_13 eq 'N03') or (diag10_13 eq 'N18') or (diag10_13 eq 'N19') or (diag10_13 eq 'I12') or (diag10_13 eq 'I13') or
    (diag11_13 eq '582') or (diag11_13 eq '585') or (diag11 eq '4039') or (diag11 eq '4049')or (diag11_13 eq 'N03') or (diag11_13 eq 'N18') or (diag11_13 eq 'N19') or (diag11_13 eq 'I12') or (diag11_13 eq 'I13'))
refailure1 = 1.
execute.

compute refailure2 = 0.
if ((diag1 eq '5820') or (diag1 eq '5821') or (diag1 eq '5824') or (diag1 eq '5828') or (diag1 eq '5829') or (diag1 eq '5859') or (diag1 eq '4039') or (diag1 eq '4049') or
    (diag2 eq '5820') or (diag2 eq '5821') or (diag2 eq '5824') or (diag2 eq '5828') or (diag2 eq '5829') or (diag2 eq '5859') or (diag2 eq '4039') or (diag2 eq '4049') or
    (diag3 eq '5820') or (diag3 eq '5821') or (diag3 eq '5824') or (diag3 eq '5828') or (diag3 eq '5829') or (diag3 eq '5859') or (diag3 eq '4039') or (diag3 eq '4049') or
    (diag4 eq '5820') or (diag4 eq '5821') or (diag4 eq '5824') or (diag4 eq '5828') or (diag4 eq '5829') or (diag4 eq '5859') or (diag4 eq '4039') or (diag4 eq '4049') or
    (diag5 eq '5820') or (diag5 eq '5821') or (diag5 eq '5824') or (diag5 eq '5828') or (diag5 eq '5829') or (diag5 eq '5859') or (diag5 eq '4039') or (diag5 eq '4049') or
    (diag6 eq '5820') or (diag6 eq '5821') or (diag6 eq '5824') or (diag6 eq '5828') or (diag6 eq '5829') or (diag6 eq '5859') or (diag6 eq '4039') or (diag6 eq '4049') or
    (diag7 eq '5820') or (diag7 eq '5821') or (diag7 eq '5824') or (diag7 eq '5828') or (diag7 eq '5829') or (diag7 eq '5859') or (diag7 eq '4039') or (diag7 eq '4049') or
    (diag8 eq '5820') or (diag8 eq '5821') or (diag8 eq '5824') or (diag8 eq '5828') or (diag8 eq '5829') or (diag8 eq '5859') or (diag8 eq '4039') or (diag8 eq '4049') or
    (diag9 eq '5820') or (diag9 eq '5821') or (diag9 eq '5824') or (diag9 eq '5828') or (diag9 eq '5829') or (diag9 eq '5859') or (diag9 eq '4039') or (diag9 eq '4049') or
    (diag10 eq '5820') or (diag10 eq '5821') or (diag10 eq '5824') or (diag10 eq '5828') or (diag10 eq '5829') or (diag10 eq '5859') or (diag10 eq '4039') or (diag1 eq '4049') or
    (diag11 eq '5820') or (diag11 eq '5821') or (diag11 eq '5824') or (diag11 eq '5828') or (diag11 eq '5829') or (diag11 eq '5859') or (diag11 eq '4039') or (diag1 eq '4049') or
    (diag1 eq 'N030') or (diag1 eq 'N031') or (diag1 eq 'N032') or (diag1 eq 'N033') or (diag1 eq 'N034') or (diag1 eq 'N035') or (diag1 eq 'N036') or (diag1 eq 'N037') or (diag1 eq 'N038') or (diag1 eq 'N039') or 
    (diag2 eq 'N030') or (diag2 eq 'N031') or (diag2 eq 'N032') or (diag2 eq 'N033') or (diag2 eq 'N034') or (diag2 eq 'N035') or (diag2 eq 'N036') or (diag2 eq 'N037') or (diag2 eq 'N038') or (diag2 eq 'N039') or 
    (diag3 eq 'N030') or (diag3 eq 'N031') or (diag3 eq 'N032') or (diag3 eq 'N033') or (diag3 eq 'N034') or (diag3 eq 'N035') or (diag3 eq 'N036') or (diag3 eq 'N037') or (diag3 eq 'N038') or (diag3 eq 'N039') or 
    (diag4 eq 'N030') or (diag4 eq 'N031') or (diag4 eq 'N032') or (diag4 eq 'N033') or (diag4 eq 'N034') or (diag4 eq 'N035') or (diag4 eq 'N036') or (diag4 eq 'N037') or (diag4 eq 'N038') or (diag4 eq 'N039') or 
    (diag5 eq 'N030') or (diag5 eq 'N031') or (diag5 eq 'N032') or (diag5 eq 'N033') or (diag5 eq 'N034') or (diag5 eq 'N035') or (diag5 eq 'N036') or (diag5 eq 'N037') or (diag5 eq 'N038') or (diag5 eq 'N039') or 
    (diag6 eq 'N030') or (diag6 eq 'N031') or (diag6 eq 'N032') or (diag6 eq 'N033') or (diag6 eq 'N034') or (diag6 eq 'N035') or (diag6 eq 'N036') or (diag6 eq 'N037') or (diag6 eq 'N038') or (diag6 eq 'N039') or 
    (diag7 eq 'N030') or (diag7 eq 'N031') or (diag7 eq 'N032') or (diag7 eq 'N033') or (diag7 eq 'N034') or (diag7 eq 'N035') or (diag7 eq 'N036') or (diag7 eq 'N037') or (diag7 eq 'N038') or (diag7 eq 'N039') or 
    (diag8 eq 'N030') or (diag8 eq 'N031') or (diag8 eq 'N032') or (diag8 eq 'N033') or (diag8 eq 'N034') or (diag8 eq 'N035') or (diag8 eq 'N036') or (diag8 eq 'N037') or (diag8 eq 'N038') or (diag8 eq 'N039') or 
    (diag9 eq 'N030') or (diag9 eq 'N031') or (diag9 eq 'N032') or (diag9 eq 'N033') or (diag9 eq 'N034') or (diag9 eq 'N035') or (diag9 eq 'N036') or (diag9 eq 'N037') or (diag9 eq 'N038') or (diag9 eq 'N039') or 
    (diag10 eq 'N030') or (diag10 eq 'N031') or (diag10 eq 'N032') or (diag10 eq 'N033') or (diag10 eq 'N034') or (diag10 eq 'N035') or (diag10 eq 'N036') or (diag10 eq 'N037') or (diag10 eq 'N038') or (diag10 eq 'N039') or 
    (diag11 eq 'N030') or (diag11 eq 'N031') or (diag11 eq 'N032') or (diag11 eq 'N033') or (diag11 eq 'N034') or (diag11 eq 'N035') or (diag11 eq 'N036') or (diag11 eq 'N037') or (diag11 eq 'N038') or (diag11 eq 'N039') or 
    (diag1 eq 'N180') or (diag1 eq 'N188') or (diag1 eq 'N189') or (diag1 eq 'N19X') or (diag1 eq 'I120') or (diag1 eq 'I129') or (diag1 eq 'I130') or (diag1 eq 'I131') or (diag1 eq 'I132') or (diag1 eq 'N039') or 
    (diag2 eq 'N180') or (diag2 eq 'N188') or (diag2 eq 'N189') or (diag2 eq 'N19X') or (diag2 eq 'I120') or (diag2 eq 'I129') or (diag2 eq 'I130') or (diag2 eq 'I131') or (diag2 eq 'I132') or (diag2 eq 'I139') or 
    (diag3 eq 'N180') or (diag3 eq 'N188') or (diag3 eq 'N189') or (diag3 eq 'N19X') or (diag3 eq 'I120') or (diag3 eq 'I129') or (diag3 eq 'I130') or (diag3 eq 'I131') or (diag3 eq 'I132') or (diag3 eq 'I139') or 
    (diag4 eq 'N180') or (diag4 eq 'N188') or (diag4 eq 'N189') or (diag4 eq 'N19X') or (diag4 eq 'I120') or (diag4 eq 'I129') or (diag4 eq 'I130') or (diag4 eq 'I131') or (diag4 eq 'I132') or (diag4 eq 'I139') or 
    (diag5 eq 'N180') or (diag5 eq 'N188') or (diag5 eq 'N189') or (diag5 eq 'N19X') or (diag5 eq 'I120') or (diag5 eq 'I129') or (diag5 eq 'I130') or (diag5 eq 'I131') or (diag5 eq 'I132') or (diag5 eq 'I139') or 
    (diag6 eq 'N180') or (diag6 eq 'N188') or (diag6 eq 'N189') or (diag6 eq 'N19X') or (diag6 eq 'I120') or (diag6 eq 'I129') or (diag6 eq 'I130') or (diag6 eq 'I131') or (diag6 eq 'I132') or (diag6 eq 'I139') or 
    (diag7 eq 'N180') or (diag7 eq 'N188') or (diag7 eq 'N189') or (diag7 eq 'N19X') or (diag7 eq 'I120') or (diag7 eq 'I129') or (diag7 eq 'I130') or (diag7 eq 'I131') or (diag7 eq 'I132') or (diag7 eq 'I139') or 
    (diag8 eq 'N180') or (diag8 eq 'N188') or (diag8 eq 'N189') or (diag8 eq 'N19X') or (diag8 eq 'I120') or (diag8 eq 'I129') or (diag8 eq 'I130') or (diag8 eq 'I131') or (diag8 eq 'I132') or (diag8 eq 'I139') or 
    (diag9 eq 'N180') or (diag9 eq 'N188') or (diag9 eq 'N189') or (diag9 eq 'N19X') or (diag9 eq 'I120') or (diag9 eq 'I129') or (diag9 eq 'I130') or (diag9 eq 'I131') or (diag9 eq 'I132') or (diag9 eq 'I139') or 
    (diag10 eq 'N180') or (diag10 eq 'N188') or (diag10 eq 'N189') or (diag10 eq 'N19X') or (diag10 eq 'I120') or (diag10 eq 'I129') or (diag10 eq 'I130') or (diag10 eq 'I131') or (diag10 eq 'I132') or (diag10 eq 'I139') or 
    (diag11 eq 'N180') or (diag11 eq 'N188') or (diag11 eq 'N189') or (diag11 eq 'N19X') or (diag11 eq 'I120') or (diag11 eq 'I129') or (diag11 eq 'I130') or (diag11 eq 'I131') or (diag11 eq 'I132') or (diag11 eq 'I139'))
refailure2 = 1.
execute.

compute park_flag = 0.
compute renal_flag = 0.
if (parkinsons1 eq parkinsons2) park_flag = 1.
if (refailure1 eq refailure2) renal_flag = 1.
frequencies park_flag renal_flag. 

temporary.
select if (parkinsons1 eq 1|parkinsons2 eq 1).
save outfile = '/conf/hscdiip/parkinsons_check.sav'.

temporary.
select if (refailure1 eq 1|refailure2 eq 1).
save outfile = '/conf/hscdiip/refailure_check.sav'.



get file = '/conf/hscdiip/refailure_check.sav'.

delete variables parkinsons1 parkinsons2.

select if upi ne ''.
execute.

aggregate outfile = *
 /break upi
 /recid date_adm date_dis diag1 diag2 diag3 diag4 diag5 diag6 diag7 diag8 diag9 diag10 diag11 
  diag1_13 diag2_13 diag3_13 diag4_13 diag5_13 diag6_13 diag7_13 diag8_13 diag9_13 diag10_13 diag11_13
  refailure1 refailure2 park_flag renal_flag check_record lookat lookat2 = 
  first(recid date_adm date_dis diag1 diag2 diag3 diag4 diag5 diag6 diag7 diag8 diag9 diag10 diag11 
  diag1_13 diag2_13 diag3_13 diag4_13 diag5_13 diag6_13 diag7_13 diag8_13 diag9_13 diag10_13 diag11_13
  refailure1 refailure2 park_flag renal_flag check_record lookat lookat2).
execute.

compute check_record = 0.
if (refailure1 ne refailure2) check_record = 1.
select if check_record eq 1.
execute.

compute lookat = 0. 
compute lookat2 = 0.
if check_record eq 1 and refailure1 eq 0 and refailure2 eq 1 lookat = 1.
if check_record eq 1 and refailure1 eq 1 and refailure2 eq 0 lookat2 = 1.
frequencies lookat lookat2.

sort cases by recid date_adm.




* Move on to Parkinsons.  Nothing obvious about differences appearing on analysis of renal failure. 

get file = '/conf/hscdiip/parkinsons_check.sav'.

delete variables refailure1 refailure2. 

select if upi ne ''.
execute.

compute check_record = 0.
if (parkinsons1 ne parkinsons2) check_record = 1.
select if check_record eq 1.
execute.

compute lookat = 0. 
compute lookat2 = 0.
if check_record eq 1 and parkinsons1 eq 0 and parkinsons2 eq 1 lookat = 1.
if check_record eq 1 and parkinsons1 eq 1 and parkinsons2 eq 0 lookat2 = 1.
frequencies lookat lookat2.








