
get file = '/conf/hscdiip/DH-Extract/maternity_file_for_plics-201415.sav'
 /keep recid chi record_keydate1 record_keydate2 yearstay.

alter type record_keydate1 record_keydate2 (a8).
string year1 month1 day1 year2 month2 day2 (a2).
compute year1 = substr(record_keydate1,3,2).
compute month1 = substr(record_keydate1,5,2).
compute day1 = substr(record_keydate1,7,2).
compute year2 = substr(record_keydate2,3,2).
compute month2 = substr(record_keydate2,5,2).
compute day2 = substr(record_keydate2,7,2).
execute.

alter type year1 month1 day1 year2 month2 day2 (f2.0).

compute stay = yrmoda(year2,month2,day2) - yrmoda(year1,month1,day1).
execute.


* if date of admission and date of discharge are within the financial year 2014/15
* check that the OBD and the length of stay are the same.

do if (record_keydate1 ge '20140401' and record_keydate2 le '20150331').
compute year = 1.
else.
compute year = 0.
end if. 
frequency variables = year. 



select if (year eq 1).

compute match = 0.
if (stay eq yearstay) match = 1.
execute.


* alter type record_keydate1 record_keydate2 (f8.0).
