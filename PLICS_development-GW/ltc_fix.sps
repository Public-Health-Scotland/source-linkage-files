*Fix source linkage file (PLICS) LTCs. 
*This correction is needed because the 1516 LTC file was applied to all historic (pre 1516) source linkage files, without accounting for the first instance of LTCs being after the current FY.

*Input: Financial years and file type (episode or individual).

Define ltc_fix (file_type=!TOKENS(1) / FY=!CMDEND)

*Begin loop over however many financial years.
!DO !F !IN (!FY).

*Get the source linkage file.
get file=!QUOTE(!CONCAT("01-Source-linkage-files/source-", !file_type, "-file-20", !F, ".sav")).

compute fin_year=!F.
alter type fin_year (a4).

*use FY to define the end date of the financial year. 
string yr_end (a8).
compute yr_end=concat('20', substr(fin_year, 3, 2), '0331').

*if diagnosis date of LTC occurs after yr_end, then delete this date and make the LTC flag = 0.
do if arth_date gt yr_end.
compute arth_date eq ' '.
compute arth = 0.
end if.
execute.

do if asthma_date gt yr_end.
compute asthma_date eq ' '.
compute asthma = 0.
end if.
execute.

do if atrialfib_date gt yr_end.
compute atrialfib_date eq ' '.
compute atrialfib = 0.
end if.
execute.

do if cancer_date gt yr_end.
compute cancer_date eq ' '.
compute cancer = 0.
end if.
execute.

do if cvd_date gt yr_end.
compute cvd_date eq ' '.
compute cvd = 0.
end if.
execute.

do if liver_date  gt yr_end.
compute liver_date  eq ' '.
compute liver = 0.
end if.
execute.

do if copd_date  gt yr_end.
compute copd_date  eq ' '.
compute copd = 0.
end if.
execute.

do if dementia_date gt yr_end.
compute dementia_date eq ' '.
compute dementia = 0.
end if.
execute.

do if diabetes_date gt yr_end.
compute diabetes_date eq ' '.
compute diabetes = 0.
end if.
execute.

do if epilepsy_date gt yr_end.
compute epilepsy_date eq ' '.
compute epilepsy = 0.
end if.
execute.

do if arth_date gt yr_end.
compute arth_date eq ' '.
compute arth = 0.
end if.
execute.

do if chd_date gt yr_end.
compute chd_date eq ' '.
compute chd = 0.
end if.
execute.

do if hefailure_date gt yr_end.
compute hefailure_date eq ' '.
compute hefailure = 0.
end if.
execute.

do if ms_date gt yr_end.
compute ms_date eq ' '.
compute ms = 0.
end if.
execute.

do if parkinsons_date gt yr_end.
compute parkinsons_date eq ' '.
compute parkinsons = 0.
end if.
execute.

do if refailure_date gt yr_end.
compute refailure_date eq ' '.
compute refailure = 0.
end if.
execute.

do if congen_date gt yr_end.
compute congen_date eq ' '.
compute congen = 0.
end if.
execute.

do if bloodbfo_date gt yr_end.
compute bloodbfo_date eq ' '.
compute bloodbfo = 0.
end if.
execute.

do if endomet_date gt yr_end.
compute endomet_date eq ' '.
compute endomet = 0.
end if.
execute.

do if digestive_date gt yr_end.
compute digestive_date eq ' '.
compute digestive = 0.
end if.
execute.

*delete added variables.
delete variables fin_year yr_end.
execute.

*save output.
 * save outfile=!QUOTE(!CONCAT("01-Source-linkage-files/source-", !file_type, "-file-20", !F, ".sav")) /compressed.

save outfile=!QUOTE(!CONCAT("/conf/linkage/output/gemma/source-", !file_type, "-file-20", !F, ".sav")) /compressed.

!DOEND.

!enddefine.



GET
  FILE='/conf/hscdiip/01-Source-linkage-files/source-individual-file-201011.sav'.
