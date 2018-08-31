*Source-individual-file consistency checks.

*Created for 1617. 

*Start of more formal file checks to be made to each source/PLICS file.


*Get file.
get file='/conf/hscdiip/DH-Extract/201617/source-episode-file-201617.sav'.
dataset name episode1617.

*perform freq variables to check for missing values.
frequency variables year.

temporary.
select if chi eq ' '.
frequency variables chi.

temporary.
select if CHI ne ' ' AND sysmis(gender).
frequency variables gender.

temporary.
select if dob eq ' '.
frequency variables dob.

temporary.
select if dob gt 1.
frequency variables age.

temporary.
select if sysmis(deceased).
frequency deceased.

temporary.
select if deceased = 1.
frequency variables derived_datedeath.

temporary.
select if ipdc eq ' '.
frequency variables ipdc.


*************** so far so good ****************.

*check numbers by partnership/recid/adm type/ipdc/ compare to previous year.
select if chi ne ' ' .
EXECUTE.

aggregate outfile=*
   /break newcis_admtype newpattype_cis
   /count=n.
EXECUTE.

   






















