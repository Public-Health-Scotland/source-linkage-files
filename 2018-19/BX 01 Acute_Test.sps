* Encoding: UTF-8.

*Tests for acute dataset.
*to check for records that are admitted more than 2 years and records that are discharged after the FY2016.
get file = !file + 'acute_for_source-20' + !FY + '.zsav'.
if record_keydate2 gt 20180331 Flag_keydate2 = 1.
if record_keydate1 lt 20160401 Flag_keydate1 = 1.

Select if  Flag_keydate2 = 1 or Flag_keydate1 = 1.
Execute.

*One record with admission in 1997.
*To check aggregated data variations with the existing SLF 2016/17 data.

get file = !file + 'acute_for_source-20' + !FY + '.zsav'.

Dataset name SLFcurrent.
Compute Pre_Cost = sum(apr_cost to mar_cost).
Compute beddays = sum(apr_beddays to mar_beddays).

aggregate outfile = *
  /presorted
  /break year
  /no_records = n
  /Pre_Cost = sum(Pre_Cost)
  /beddays = sum(beddays)
  /Total_Costs_net = Sum(cost_total_net)
  /Total_yearstay = Sum(yearstay)
  /Total_stay = Sum(stay).

Dataset name SLFcurrent.
Dataset activate SLFcurrent.
alter type year(A6).


get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !FY + '.zsav'.
select if recid = '01B'.

Dataset name SLFprevious.
Compute Pre_Cost = sum(apr_cost to mar_cost).
Compute beddays = sum(apr_beddays to mar_beddays).

aggregate outfile = *
  /presorted
  /break year
  /no_records = n
  /Pre_Cost = sum(Pre_Cost)
  /beddays = sum(beddays)
  /Total_Costs_net = Sum(cost_total_net)
  /Total_yearstay = Sum(yearstay)
  /Total_stay = Sum(stay).

alter type year(A6).
Compute year = !FY + "p".

Dataset name SLFprevious.

add files file = SLFprevious
  /file = SLFcurrent.
exe.
*Check % variations.
Compute Costs_difference = (((Total_Costs_net - lag(Total_Costs_net)) / (lag(Total_Costs_net))) * 100).
Compute Pre_cost_difference = (((Pre_cost - lag(Pre_cost)) / (lag(Pre_cost))) * 100).
Compute beddays_difference = (((beddays - lag(beddays)) / (lag(beddays))) * 100).
Compute yearstay_difference = (((Total_yearstay - lag(Total_yearstay)) / (lag (Total_yearstay))) * 100).
Compute stay_difference = (((Total_stay - lag(Total_stay)) / (lag(Total_stay))) * 100).
Compute no_records_difference = (((no_records - lag(no_records)) / (lag(no_records))) * 100).

Descriptives Costs_difference Pre_cost_difference beddays_difference yearstay_difference stay_difference no_records_difference.

*Flag differences with more than or equal to +/ -  15%.
If ~Range((100 - abs(Costs_difference)), 85, 115) Flag_Costs_net_difference = 1.
If ~Range((100 - abs(Pre_cost_difference)), 85, 115) Flag_Pre_cost_difference = 1.
If ~Range((100 - abs(beddays_difference)), 85, 115) Flag_beddays_difference = 1.
If ~Range((100 - abs(yearstay_difference)), 85, 115) Flag_yearstay_difference = 1 .
If ~Range((100 - abs(stay_difference)), 85, 115) Flag_stay_difference = 1.
If ~Range((100 - abs(no_records_difference)), 85, 115) Flag_records_difference = 1. 

frequencies Flag_Costs_net_difference Flag_Pre_cost_difference Flag_beddays_difference Flag_yearstay_difference Flag_stay_difference Flag_records_difference.

*Close both datasets.
Dataset close SLFcurrent.
Dataset close SLFprevious.
