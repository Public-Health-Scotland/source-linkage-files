define !DataFiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

define !LTCfiles()
'/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/03-data/'
!enddefine.

input program.
data list file='/conf/linkage/catalog/catalog_01112014.cis'
 /recid 25-27(a) sdoa 9-14 sdod 17-22.
do  if (recid eq '01A' and sdod le 199603).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) year_dis 17-20(a) diag1 274-277(a) 
            diag2 280-283(a) diag3 286-289(a) diag4 292-295(a) diag5 298-301(a) diag6 304-307(a).
end case.
else if(recid eq '01A' and sdod ge 199604).
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 273-276(a) 
            diag2 279-282(a) diag3 285-288(a) diag4 291-294(a) diag5 297-300(a) diag6 303-306(a).
end case.
else if (recid eq '01B').
reread.
data list / linkno 1-8 (a) recid 25-27 (a) upi 84-93(a)
            date_adm 9-16 (a) date_dis 17-24(a) diag1 388-391(a) 
            diag2 394-397(a) diag3 400-403(a) diag4 406-409(a) diag5 412-415(a) diag6 418-421(a).
end case.
end if.
end input program.
execute.           

* create 3 character length diagnosis codes.
string d1c13 d2c13 d3c13 d4c13 d5c13 d6c13 (a3).
compute d1c13 = substr(diag1,1,3).
compute d2c13 = substr(diag2,1,3).
compute d3c13 = substr(diag3,1,3).
compute d4c13 = substr(diag4,1,3).
compute d5c13 = substr(diag5,1,3).
compute d6c13 = substr(diag6,1,3).
execute.

rename variables (diag1 diag2 diag3 diag4 diag5 diag6 = d1c14 d2c14 d3c14 d4c14 d5c14 d6c14).

* Create a marker for Cerebrovascular Disease (CVD) ICD codes: 430-438; I60-I69, G45.
compute cvd = 0.
if ((d1c13 ge '430' and d1c13 le '438') or (d1c13 ge 'I60' and d1c13 le 'I69') or (d1c13 eq 'G45') or
    (d2c13 ge '430' and d2c13 le '438') or (d2c13 ge 'I60' and d2c13 le 'I69') or (d2c13 eq 'G45') or
    (d3c13 ge '430' and d3c13 le '438') or (d3c13 ge 'I60' and d3c13 le 'I69') or (d3c13 eq 'G45') or
    (d4c13 ge '430' and d4c13 le '438') or (d4c13 ge 'I60' and d4c13 le 'I69') or (d4c13 eq 'G45') or
    (d5c13 ge '430' and d5c13 le '438') or (d5c13 ge 'I60' and d5c13 le 'I69') or (d5c13 eq 'G45') or
    (d6c13 ge '430' and d6c13 le '438') or (d6c13 ge 'I60' and d6c13 le 'I69') or (d6c13 eq 'G45')) cvd = 1.

select if cvd eq 1.
execute.

save outfile = !Datafiles + 'cvd_extract.sav'.
get file = !Datafiles + 'cvd_extract.sav'.

aggregate outfile = *
 /break upi 
 /date_adm_cvd = first(date_adm).
execute.

select if upi ne ''.
execute.

compute year_1213 = 0.
if (date_adm_cvd le '20130331') year_1213 = 1.
frequency variables = year_1213.

save outfile = !Datafiles + 'cvd1213_hospSMR01only.sav'.

get file = '/conf/linkage/output/deniseh/CHImasterPLICS_Costed_201213.sav'
 /keep chi date_death deceased_flag.
sort cases by chi.
match files file = *
 /table = !LTCfiles + 'cvd1213_hospSMR01only.sav'
 /rename (upi = chi)
 /by chi.
execute.
select if year_1213 eq 1.
execute.

match files file = *
 /file = '/conf/irf/11-Development team/Dev00-PLICS-files/LTCs/SPARRA_1apr13_CVD1.sav'
 /in = sparra
 /by chi.
execute.

delete variables EMERG ELECT DAYCASE los_emerg los_elect los_tot ed_attendance alcad drugad fallad
                 finalProb finalProbGrp cohortFlag carehome
                 asthma1 diabetes1 chd1 copd1 epilepsy1 dementia1 renalf1 cancer1 allarth1 artfib1 
                 hrtfail1 alz1 parkin1 ms1 cld1 ltc_count.

rename variables (year_1213 = cvd).
recode cvd cvd1 (sysmis = 0).
execute.
descriptives variables = cvd cvd1
 /statistics = sum.

* Create a file that has the people flagged with CVD in my file, who are not in SPARRA file.
temporary.
select if (cvd eq 1) and (cvd1 ne 1).
save outfile = !LTCfiles + 'CVDinPLICs-notSPARRA.sav'.
execute.

* Create a file that has the people flagged with CVD1 in the sparra file, but are not flagged as having 
  CVD in my file.

temporary.
select if (cvd ne 1) and (cvd1 eq 1).
save outfile = !LTCfiles + 'CVDinSPARRA-notPLICS.sav'.
execute.


* Look at list of CHI numbers (in PLICS not SPARRA).
get file !LTCfiles + 'CVDinPLICs-notSPARRA.sav'.


* Look at list of CHI numbers (in SPARRA not PLICS).
get file = !LTCfiles + 'CVDinSPARRA-notPLICS.sav'.


