*convert_date.
*MACRO (program) that takes X number of input dates in STRING format and produces X number of output dates in DATE format.

DEFINE convert_date (INDATES=!CMDEND).

*Begin loop over however many date variables.
!DO !I !IN (!INDATES).

*Seperate date into dd mm yyyy.
string day (a2).
compute day = substr(!I, 9, 2).
string month (a2).
compute month = substr(!I, 6, 2).
string yr (a4).
compute yr = substr(!I, 1, 4).
execute.

alter type !I (a10).

*Arrange date in new format yyyymmdd.
compute !I = concat(day,'.',month,'.',yr,'.').
EXECUTE.

*Make data type date so that the difference can be found.
alter type !I (date10).

delete variables day month yr.

!DOEND.

!ENDDEFINE.


