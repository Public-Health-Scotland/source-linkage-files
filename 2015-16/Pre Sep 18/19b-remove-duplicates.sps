* Death flag files - 'home'.
define !DeathsFile()
'/conf/irf/11-Development team/Dev00-PLICS-files/data-extracts/02-NRS-deaths/'
!enddefine.


get file = !Deathsfile + 'Deceased_patient_reference_file.sav'.

* following some investigation one UPI number needs to be excluded.  It shouldn't
* impact any analysis.  

aggregate outfile = *
 /break chi
 /deceased derived_datedeath = first(deceased derived_datedeath).
execute.

select if chi ne '0908269005'.
execute.


save outfile = !Deathsfile + 'Deceased_patient_reference_file-modified.sav'.



******.
* Syntax below was only used for checking purposes.




compute flag = 0.
if (chi eq lag(chi)) flag = 1.
frequency variables = flag.

sort cases chi (a) flag (d).

if (chi eq lag(chi)) flag = 1.
frequency variables = flag.

select if flag eq 1.
execute.

aggregate outfile = * mode=addvariables
 /break chi
 /new_death = first(derived_datedeath).
execute.


compute flag2 = 0.
*if ((chi eq lag(chi)) and (derived_datedeath eq lag(derived_datedeath))) flag2 = 1.
*sort cases chi (a) flag2 (d).
*if ((chi eq lag(chi)) and (derived_datedeath eq lag(derived_datedeath))) flag2 = 1.
*frequency variables = flag2.
if (derived_datedeath eq new_death) flag2 = 1.
frequency variables = flag2.


sort cases by flag2 chi.
