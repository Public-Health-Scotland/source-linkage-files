*Source-individual-file consistency checks.

*Created for 1617. 

*Start of more formal file checks to be made to each source/PLICS file.

*Get file.
get file='/conf/hscdiip/DH-Extract/201617/source-individual-file-201617.sav'.
dataset name individual1617.

*perform freq variables to check for missing values.
frequency variables year.

temporary.
select if chi eq ' '.
frequency variables chi.

temporary.
select if sysmis(gender).
frequency variables gender.

temporary.
select if dob eq ' '.
frequency variables dob.

temporary.
select if sysmis(age).
frequency variables age.

temporary.
select if sysmis(deceased_flag).
frequency deceased_flag.

temporary.
select if deceased_flag = 1.
frequency variables date_death.

temporary.
select if health_postcode eq ' '.
frequency variables health_postcode.

*************** so far so good ****************.
temporary.
select if gpprac eq ' '.
frequency variables health_postcode.

temporary.
select if health_net_cost=0.
frequency variables health_net_costincDNAs.

*check numbers by partnership/recid/adm type/ipdc/ compare to previous year.
aggregate outfile=*
   /break Lca hri_lca
   /count=n.
EXECUTE.

aggregate outfile=* mode addvariables
   /break Lca 
   /total=sum(count).
EXECUTE.

select if lca ne ' '.
EXECUTE.

compute pcent=count/total*100.
EXECUTE.

dataset name aggregate.

CASESTOVARS   
   /ID lca
   /index HRI_lca
   /drop count total.
EXECUTE.

rename variables (pcent.0 = nonHRI) (pcent.1 = HRI).

sort cases by nonHRI.

save translate outfile='/conf/linkage/output/gemma/lca_hri_1617.xls'
   /type = xls
   /replace
   /FIELDNAMES
   /cells=values.

   






















