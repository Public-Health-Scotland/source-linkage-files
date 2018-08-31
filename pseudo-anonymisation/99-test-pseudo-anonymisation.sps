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

* Step 1 - create dummy upi dataset1.
data list list /upi. 
begin data
1111111111
2222222222
3333333333
4444444444
5555555555
end data.
alter type upi (a10).
save outfile = !filepath + 'dataset1.sav' 
  /compressed.

* Step 2 - add an IRF number.

get file = !filepath + 'dataset1.sav' .

numeric IRFnumber (f10.0).
do if ($casenum eq 1).
compute IRFnumber = 1000000001.
else.
compute IRFnumber = lag(IRFnumber) + 1.
end if.
execute.
sort cases by upi.
save outfile = !filepath + 'dataset1-with-IRFnum.sav' 
  /compressed.

* Step 3 - create dataset2.
data list list /upi. 
begin data
1111111111
5555555555
6666666666
7777777777
8888888888
end data.
alter type upi (a10).
sort cases by upi.
save outfile = !filepath + 'dataset2.sav' 
  /compressed.

* Step 4. Determine which upi numbers exist distinctly in dataset 2 and create an IRF number for these 
          new records.

match files file = !filepath + 'dataset1-with-IRFnum.sav' 
 /file= !filepath + 'dataset2.sav' 
 /in = new
 /by upi.
execute.

if (IRFnumber gt 1) new = 0.
execute.

sort cases by new.

do if (sysmis(IRFnumber)).
compute IRFnumber = lag(IRFnumber) + 1.
end if.
execute.

save outfile = !filepath + 'dataset1-and-2-with-IRFnumber.sav'
 /drop new.

get file = !filepath + 'dataset1-and-2-with-IRFnumber.sav'.

* Step 5 - Repeat Step 4. 

data list list /upi.
begin data
1111111111
5675675675
1111122222
2222222222
3333333333
4444444444
4545454545
5555555555
6666666666
7777777777
8888888888
end data.
alter type upi (a10).
sort cases by upi.
save outfile = !filepath + 'dataset3.sav' 
  /compressed.

match files file = !filepath + 'dataset1-and-2-with-IRFnumber.sav'
 /file = !filepath + 'dataset3.sav'
 /in = new 
 /by upi.
execute.

if (IRFnumber gt 1) new = 0.
execute.

sort cases by new.

do if (sysmis(IRFnumber)).
compute IRFnumber = lag(IRFnumber) + 1.
end if.
execute.

sort cases by upi.

save outfile = !filepath + 'datasets-1-2-3-with-irf-number.sav'.
