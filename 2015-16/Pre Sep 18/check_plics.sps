*check_plics.

*Program to selct a random sample of CHIs with different recids, from different health boards, and check the records, e.g. costs, lengths of stay etc., 
and that all variables are populated. 

*Created 29/9/2016 by GNW.
*Modified 29/6/2016.

define !FY()
'1516'
!enddefine.

CD '/conf/hscdiip/DH-Extract/'.

*change name of file to suit FY.
get file='masterPLICS_Costed_20' + !FY + '.sav'.

alter type record_keydate2 (a8).
do if record(keydate2_dateformat).
compute keydate2_dateformat=date.dmy(substr(record_keydate2, 7, 8),substr(record_keydate2, 5, 6),substr(record_keydate2, 1, 4)).
end if.
EXECUTE.
alter type record_keydate2(f8.0).




