*ADD record keydates in date format - 2 extra variables.

*change directory to output directory.
CD '/conf/irf/10-PLICS/'.

get file='CHImasterPLICS_Costed_201415.sav'.

*Add extra variables for dates. 
compute keydate1_dateformat=record_keydate1.
compute keydate2_dateformat=record_keydate2.
EXECUTE.
*rearrange variables for dates are together at the beginning of the dataset.
add files file=*
   /keep year to record_keydate2 keydate1_dateformat keydate2_dateformat ALL.
EXECUTE.

*convert variables to strings.
alter type keydate1_dateformat keydate2_dateformat (a8).
*compile date convert program.
insert file='/conf/irf/11-Development team/Dev00-PLICS-files/2015-16/convert_date.sps'.
*run date convert program.
convert_date indates = keydate1_dateformat keydate2_dateformat.

