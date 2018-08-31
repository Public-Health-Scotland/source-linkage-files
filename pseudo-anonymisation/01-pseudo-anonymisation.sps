* Pseudo-anonymisation.  Test program.
* This program will:
  - create a small dataset of dummy upi numbers (this will be dataset1)
  - an IRF number will be created
  - a second test dataset (dataset2 will be created) containing new dummy upi numbers and two of the dummy upi numbers
    from dataset1 will be included
  - the upi numbers will be compared so that new IRF numbers can be created for the upi numbers that are distinctly in dataset2
  - create a third test dataset to determine methodology works where the upi number is a number between to existing upi numbers.

* Program by Denise Hastie, January 2014.

* Define filepath.
define !filepath()
'/conf/irf/11-Development team/Dev00 - PLICS files/pseudo-anonymisation/'
!enddefine.

define !CostedFiles1011()
'/conf/irf/06-Mapping/2010_11/2. Hospital/1. PLICS/Programmes/data/'
!enddefine.

define !CostedFiles1112()
'/conf/irf/06-Mapping/2011_12/2. Hospital/1. PLICS/Programmes/data/'
!enddefine.

************************************************************************************.
* Step 1 - get valid CHI numbers for 2010/11 data from the CHI master PLICS costed file for 2010/11.
get file = !CostedFiles1011 + 'CHImasterPLICS_Costed_201011.sav' 
 /keep CHI.

save outfile = !filepath + 'CHInos_1011.sav'.

* Step 2 - add an IRF number.

get file = !filepath + 'CHInos_1011.sav'.

numeric IRFnumber (f10.0).
do if ($casenum eq 1).
compute IRFnumber = 1000000001.
else.
compute IRFnumber = lag(IRFnumber) + 1.
end if.
execute.
sort cases by chi.
save outfile = !filepath + 'CHInos_1011-withIRFnum.sav'
  /compressed.

* Step 3 - get valid CHI numbers for 2010/11 data from the CHI master PLICS costed file for 2011/12.
get file = !CostedFiles1112 + 'CHImasterPLICS_Costed_201112.sav'
 /keep CHI.

save outfile = !filepath + 'CHInos_1112.sav'.

* Step 4. Determine which upi numbers exist distinctly in 2011/12 and create an IRF number for these 
          new records.

match files file = !filepath + 'CHInos_1011-withIRFnum.sav'
 /file= !filepath + 'CHInos_1112.sav'
 /in = new
 /by chi.
execute.

if (IRFnumber gt 1) new = 0.
execute.

sort cases by new.

do if (sysmis(IRFnumber)).
compute IRFnumber = lag(IRFnumber) + 1.
end if.
execute.

sort cases by chi.

save outfile = !filepath + 'CHI-to-IRFnumber-lookup.sav'
 /drop new.

get file = !filepath + 'CHI-to-IRFnumber-lookup.sav'.











