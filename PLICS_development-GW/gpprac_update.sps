*PLICS development - add GP practice code.

CD '/conf/hscdiip/DH-Extract/201617/'.

**************************************************************************************.
*************************************** define this **********************************.
define !FY()
'1617'
!enddefine.

define !FYpat()
'fy2016'
!enddefine.
**************************************************************************************.
**************************************************************************************.

match files file='source-individual-file-20' +!FY +'.sav'
   /table '/conf/hscdiip/DH-Extract/IMT-CR-039908/' +!FYpat +'_patients.sav'
   /by CHI.
EXECUTE.

*check consistency of match.
compute check=0.
EXECUTE.

add files file=*
   /keep year to gpprac prac check ALL.
EXECUTE.

*replace missing values in prac with gpprac.
if prac eq ' ' prac = gpprac.
EXECUTE.

if gpprac eq ' ' OR gpprac eq prac check=1.
EXECUTE.
frequency variables check.

*check for missing values in prac.
frequency variables prac.

*remove gpprac and rename prac to gpprac.
delete variables gpprac check.
EXECUTE.

rename variables prac = gpprac.

alter type gpprac (a=amin).

*save.
save outfile='CHImasterPLICS_Costed_20' +!FY +'.sav'.

