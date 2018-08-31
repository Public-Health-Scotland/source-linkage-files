* IRF2014-0008
* Customer: Denise Hastie / Andrew Lee

* Brief details: Analysis of NIC and GIC costs utilising in depth Grampian Region customer data.

* Time period: Financial years 2011/12 and 2012/13 ( NHS Grampian Region ).

* Notes: 

* Different CHI numbers are generated ( sample of 12 ) each time this syntax is run.

* Data source(s):  CHI plics files 2011/12 and 2012/13.  
       
* Program by Peter McClurg, June 2014.

* Define macro(s) for working data files.
**************************************************************************************************.

define !pathname1()
'//conf/linkage/output/deniseh/'
!enddefine.

define !Output()
'/conf/irf/11-Development team/Dev00-PLICS-files/prescribing/03-data/'
!enddefine.

define !Finaloutput()
'/conf/irf/11-Development team/Dev00-PLICS-files/prescribing/04-outputs/'
!enddefine.
**************************************************************************************************
A. Obtain data file to produce totals for the whole dataset prior to selecting 12 patients
**************************************************************************************************.

get file=!pathname1 + 'IRF2014-0008-output.sav'.
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
execute.
save outfile=!Output + 'IRF2014-0008A-output.sav'.


*********Assessing by bnf chapter**************.
temporary.
aggregate outfile=*
 /break bnf_chapter_desc
 /paid_gic_excl_bb=sum(paid_gic_excl_bb)
 /paid_nic_excl_bb=sum(paid_nic_excl_bb).
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
save outfile=!Output+'Totalsbybnf.sav'
/keep bnf_chapter_desc paid_gic_excl_bb paid_nic_excl_bb Prop.
save translate outfile= !Finaloutput + 'Totalsbybnf.xlsx'
 /TYPE=XLS 
 /VERSION=12
 /MAP 
 /REPLACE 
 /FIELDNAMES 
 /CELLS=VALUES.
execute.


*********Assessing by Age Categories**************.
temporary.
RECODE pat_age_at_presc_date (0 THRU 17=1) (18 THRU 64=2) (65 THRU 74=3) (75 THRU 84=4) (85 THRU HI=5)(else =999)INTO AGEBAND.
aggregate outfile=*
 /break AGEBAND
 /paid_gic_excl_bb=sum(paid_gic_excl_bb)
 /paid_nic_excl_bb=sum(paid_nic_excl_bb).
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
save outfile=!Output+'Totalsbyageband.sav'
/keep ageband paid_gic_excl_bb paid_nic_excl_bb Prop.
save translate outfile= !Finaloutput + 'Totalageband.xlsx'
 /TYPE=XLS 
 /VERSION=12
 /MAP 
 /REPLACE 
 /FIELDNAMES 
 /CELLS=VALUES.
execute.



*********Calculating two year total**************.
temporary.
compute flag=1.
aggregate outfile=*
 /break flag
 /paid_gic_excl_bb=sum(paid_gic_excl_bb)
 /paid_nic_excl_bb=sum(paid_nic_excl_bb).
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
rename variables flag=financial_year.
compute financial_year=1113.
save outfile=!Output+'Totals.sav'
/keep financial_year paid_gic_excl_bb paid_nic_excl_bb Prop.
execute.


*********Calculating each year **************.

temporary.
get file=!Output + 'IRF2014-0008A-output.sav'.
aggregate outfile=*
 /break financial_year
 /paid_gic_excl_bb=sum(paid_gic_excl_bb)
 /paid_nic_excl_bb=sum(paid_nic_excl_bb).
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
save outfile=!Output+'TotalsB.sav'
/keep financial_year paid_gic_excl_bb paid_nic_excl_bb Prop.
execute.
get file = !Output+'TotalsB.sav'.

*********Combining each year and totals **************.

add files file=*
 /file=!Output+ 'Totals.sav'
 /BY financial_year paid_gic_excl_bb paid_nic_excl_bb Prop.
execute.
save translate outfile= !Finaloutput + 'Totals.xlsx'
 /TYPE=XLS 
 /VERSION=12
 /MAP 
 /REPLACE 
 /FIELDNAMES 
 /CELLS=VALUES.




**************************************************************************************************
B. Creating one record for each Patient ( in order to select 12 at random )
**************************************************************************************************.

get file=!Output + 'IRF2014-0008A-output.sav'.
temporary.
aggregate outfile=!Output + 'IRF2014-0008A-output.sav'
 /break chi
 /paid_gic_excl_bb=sum(paid_gic_excl_bb)
 /paid_nic_excl_bb=sum(paid_nic_excl_bb).
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
save outfile=!Output+'Totals2.sav'.
execute.


get file=!Output+'Totals2.sav'.

****************************************************
C.Selecting 12 chi numbers to investigate further
****************************************************.
USE ALL.
do if $casenum=1.
compute #s_$_1=12.
compute #s_$_2=499058.
end if.
do if  #s_$_2 > 0.
compute filter_$=uniform(1)* #s_$_2 < #s_$_1.
compute #s_$_1=#s_$_1 - filter_$.
compute #s_$_2=#s_$_2 - 1.
else.
compute filter_$=0.
end if.
VARIABLE LABELS filter_$ '12 from the first 499058 cases (SAMPLE)'.
FORMATS filter_$ (f1.0).
FILTER  BY filter_$.
EXECUTE.

select if filter_$=1.
execute.

save outfile=!Output+'random12chis.sav'.
get file=!Output + 'random12chis.sav'.
**********************************************************
D. Using 12 random patients for analysis of each record
**********************************************************.

get file=!pathname1 + 'IRF2014-0008-output.sav'.
sort cases by chi.
match files file =*
/Table =!Output+ 'random12chis.sav'
/by chi.
execute.

select if filter_$=1.
execute.
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
execute.

save outfile=!Output + 'Selectedrecords.sav'
/keep chi bnf_chapter_desc paid_gic_excl_bb paid_nic_excl_bb Prop.
get file=!Output + 'Selectedrecords.sav'.
save translate outfile=!Finaloutput+ 'Selected_Patient_records.xlsx'
 /TYPE=XLS 
 /VERSION=12
 /MAP 
 /REPLACE 
 /FIELDNAMES 
 /CELLS=VALUES.

**********************************************************
E. Calculating totals for each selected patient
**********************************************************.


get file=!Output + 'Selectedrecords.sav'.
aggregate outfile=*
 /break chi
 /paid_gic_excl_bb=sum(paid_gic_excl_bb)
 /paid_nic_excl_bb=sum(paid_nic_excl_bb).
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
save outfile=!Output+'TotalsB1.sav'
/keep chi paid_gic_excl_bb paid_nic_excl_bb Prop.
execute.
get file = !Output+'TotalsB1.sav'.




************************************************************
F. Aggregating totals for the 12 randomly selected patients
************************************************************.

compute flag=1.
aggregate outfile=*
 /break flag
 /paid_gic_excl_bb=sum(paid_gic_excl_bb)
 /paid_nic_excl_bb=sum(paid_nic_excl_bb).
compute Prop=(paid_gic_excl_bb/paid_nic_excl_bb).
rename variables flag='chi'.
alter type chi(a10).
compute chi='Total'.
save outfile=!Output+'Totals3.sav'.
execute.



************************************************************
G. Grouping 12 sample patients and total.
************************************************************.

get file= !Output+'TotalsB1.sav'.


add files file=*
 /file=!Output+ 'Totals3.sav'
 /BY chi paid_gic_excl_bb paid_nic_excl_bb Prop.
execute.
save translate outfile= !Finaloutput + 'Totals.xlsx'
 /TYPE=XLS 
 /VERSION=12
 /MAP 
 /REPLACE 
 /FIELDNAMES 
 /CELLS=VALUES.


************************************************************
F. Housekeeping
************************************************************.

erase file=!Output + 'IRF2014-0008A-output.sav'.
erase file=!Output + 'Totals2.sav'.


***********************************************************.





