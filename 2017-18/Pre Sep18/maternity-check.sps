GET DATA 
  /TYPE=ODBC 
  /CONNECT='DSN=SMRA;UID=DENISH01;PWD=>n+#&t#t!)#J;SRVR=SMRA.nss.scot.nhs.uk' 
  /SQL='SELECT "LENGTH_OF_STAY", "DISCHARGE_DATE", "ADMISSION_DATE", "DOB", "POSTCODE" FROM '+ 
    '"ANALYSIS"."SMR02A" WHERE ("ADMISSION_DATE" >= {d 2014-04-01} AND "DISCHARGE_DATE" <= {d '+ 
    '2015-03-31})' 
  /ASSUMEDSTRWIDTH=255. 
 
CACHE. 
EXECUTE. 
DATASET NAME DataSet1 WINDOW=FRONT.

compute flag = 0.
if (admission_date eq '20141230' and discharge_date eq '20150101') flag = 1.
if (admission_date eq '20141114' and discharge_date eq '20141117') flag = 1.
sort cases by flag (d).
sort cases by flag (d) admission_date (a) dob (a).

