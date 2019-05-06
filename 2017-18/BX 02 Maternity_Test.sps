* Encoding: UTF-8.
* Encoding: UTF-8.
*Tests for maternity dataset.
get file = !file + 'maternity_for_source-20' + !FY + '.zsav'.

*to check for records that are admitted more than 2 years and records that are discharged after the FY2016.

if record_keydate1 gt 20180331 Flag_keydate2=1.
if record_keydate1 lt 20160401 Flag_keydate1=1.
EXECUTE.

Select if   Flag_keydate2=1 or  Flag_keydate1=1.
exe.


*To check aggregated data variations with the existing SLF 2016/17 data.

get file = !file + 'maternity_for_source-20' + !FY + '.zsav'.

Dataset name SLFcurrent.
Compute Pre_Cost=sum(apr_cost,may_cost, jun_cost, jul_cost, aug_cost, sep_cost, oct_cost, nov_cost, dec_cost, jan_cost, feb_cost, mar_cost).
Compute beddays=sum(apr_beddays, may_beddays, jun_beddays, jul_beddays, aug_beddays, sep_beddays, oct_beddays, nov_beddays, dec_beddays, jan_beddays, feb_beddays, mar_beddays).
exe.
aggregate outfile=*
/break year
/no_records=n
/Pre_Cost=sum(Pre_Cost)
/beddays=sum(beddays)
/Total_Costs_net=Sum(cost_total_net)
/Total_yearstay=Sum(yearstay)
/Total_stay=Sum(stay).
exe.
Dataset name SLFcurrent.
Dataset activate  SLFcurrent.
alter type year(A6).


get file='/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' +!FY+'.zsav'.
select if recid='02B'.
exe.

Dataset name SLFprevious.
Compute Pre_Cost=sum(apr_cost, may_cost, jun_cost, jul_cost, aug_cost, sep_cost, oct_cost, nov_cost, dec_cost, jan_cost, feb_cost, mar_cost).
Compute beddays=sum(apr_beddays, may_beddays, jun_beddays, jul_beddays, aug_beddays, sep_beddays, oct_beddays, nov_beddays, dec_beddays, jan_beddays, feb_beddays, mar_beddays).
exe.

aggregate outfile=*
/break year
/no_records=n
/Pre_Cost=sum(Pre_Cost)
/beddays=sum(beddays)
/Total_Costs_net=Sum(cost_total_net)
/Total_yearstay=Sum(yearstay)
/Total_stay=Sum(stay).
exe.

alter type year(A6).
Compute year=!FY+'p'.
exe.
Dataset name SLFprevious.

add files file =SLFprevious
/file = SLFcurrent.
exe.

*Check % variations.
Compute Costs_difference=(((Total_Costs_net-lag(Total_Costs_net))/(lag(Total_Costs_net)))*100).
Compute Pre_cost_difference=(((Pre_cost-lag(Pre_cost))/(lag(Pre_cost)))*100).
Compute beddays_difference=(((beddays-lag(beddays))/(lag(beddays)))*100).
Compute yearstay_difference=(((Total_yearstay-lag(Total_yearstay))/(lag (Total_yearstay)))*100).
Compute stay_difference =(((Total_stay-lag(Total_stay))/(lag (Total_stay)))*100).
Compute no_records_difference=(((no_records-lag(no_records))/(lag(no_records)))*100).
exe.

*Flag differences with more than or equal to +/- 15%.
If ((100-Costs_difference) ge 115 or (100-Costs_difference) le 85) Flag_Costs_net_difference =1.
If ((100-Pre_cost_difference) ge 115 or  (100-Pre_cost_difference) le 85) Flag_Pre_cost_difference=1.
If ((100-beddays_difference)  ge 115 or (100-beddays_difference) le 85) Flag_beddays_difference=1.
If ((100-yearstay_difference) ge 115 or (100-yearstay_difference) le 85) Flag_yearstay_difference=1 .
If ((100-stay_difference) ge 115  or (100-stay_difference) le 85) Flag_stay_difference=1.
if ((100-no_records_difference) ge 115 or (100-no_records_difference) le 85) Flag_records_difference=1.  
exe.

*Close both datasets.
Dataset close SLFcurrent.
Dataset close SLFprevious.


