* Encoding: UTF-8.
*PIS tests.
get file='/conf/sourcedev/Source Linkage File Updates/1718/prescribing_file_for_source-20' +!FY +'.zsav'.

*to check records with exisiting file.
aggregate outfile=*
/break year
/no_dispensed_items=sum(no_dispensed_items)
/cost_total_net =sum(cost_total_net)
/paid_gic_excl_bb=sum(paid_gic_excl_bb).
exe.
Alter type year(A6).
Dataset Name SLFcurrent.


get file='/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' +!FY +'.zsav'.

select if recid='PIS'.
exe.

aggregate outfile=*
/break year
/no_dispensed_items=sum(no_dispensed_items)
/cost_total_net =sum(cost_total_net).
exe.

Dataset Name SLFprevious.


add files file =SLFprevious
/file = SLFcurrent.
exe.

*Check % variations.
Compute no_dispensed_items_difference=(((no_dispensed_items-lag(no_dispensed_items))/(lag(no_dispensed_items)))*100).
Compute cost_total_net_difference=(((cost_total_net-lag(cost_total_net))/(lag(cost_total_net)))*100).
exe.

*Flag differences with more than or equal to +/- 15%.
If ((100-no_dispensed_items_difference) ge 115 or (100-no_dispensed_items_difference) le 85) Flag_no_dispensed_items_difference =1.
If ((100-cost_total_net_difference) ge 115 or  (100-cost_total_net_difference) le 85) Flag_cost_total_net_difference=1.
exe.

*Close both datasets.
Dataset close SLFcurrent.
Dataset close SLFprevious.











