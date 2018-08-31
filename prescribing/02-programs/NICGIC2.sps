
* IRF2014-0008
* Customer: Denise Hastie / Andrew Lee

* Brief details: Analysis of NIC and GIC costs across Health Boards by Age Band and BNF Chapter

* Time period: Financial year 2012/13.

* Analysis by Peter McClurg, August 2014.

**********************************************************************************************.


define !Working()
'/conf/irf/11-Development team/Dev00-PLICS-files/prescribing/03-data/'
!enddefine.
define !Output()
'/conf/irf/11-Development team/Dev00-PLICS-files/prescribing/03-data/'
!enddefine.

define !Finaloutput()
'/conf/irf/11-Development team/Dev00-PLICS-files/prescribing/04-outputs/'
!enddefine.
**************************************************************************************************
A. read in the CSV file with the prescribing extract.
**************************************************************************************************.


* /FILE="/conf/irf/11-Development team/Dev00-PLICS-files/prescribing/03-data/".
GET DATA  /TYPE=TXT
  /FILE="/conf/irf/11-Development team/Dev00-PLICS-files/prescribing/03-data/NICvGICagespec.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  PaidFinancialYear F4.0
  DIPaidNICexcl.BB F10.2
  DIPaidGICexcl.BB F10.2
  PatHealthBoardofResidenceNinedigitCode A9
  PatAgeBandatprompteddate A5
  PIBNFChapterDescription A40
  PatAgeatprompteddate F3.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.


* rename variables to more manageable names.
set mprint on.
rename variables (PaidFinancialYear DIPaidNICexcl.BB DIPaidGICexcl.BB PatHealthBoardofResidenceNinedigitCode PatAgebandatprompteddate PIBNFChapterDescription PatAgeatprompteddate= Year NIC GIC HBRES Ageband BNFchap Age).

* Recode the Ageband required to match previous output.
RECODE Age (0 THRU 17='0-17') (18 THRU 64='18-64') (65 THRU 74='65-74') (75 THRU 84='75-84') (85 THRU HI='85+')(else ='999')INTO AGEBAND.
execute.

save outfile = !Working + 'PISextract2.sav'.

* Calculating proportion and saving as each health board column.

select if (HBRES eq 'S08000001').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SAA=(GIC/NIC).
save outfile= !Working + 'SAAAge.sav'
/keep Ageband SAA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000002').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SBA=(GIC/NIC).
save outfile= !Working + 'SBAAge.sav'
/keep Ageband SBA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000003').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SYA=(GIC/NIC).
save outfile= !Working + 'SYAAge.sav'
/keep Ageband SYA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000004').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SFA=(GIC/NIC).
save outfile= !Working + 'SFAAge.sav'
/keep Ageband SFA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000005').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SVA=(GIC/NIC).
save outfile= !Working + 'SVAAge.sav'
/keep Ageband SVA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000006').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SNA=(GIC/NIC).
save outfile= !Working + 'SNAAge.sav'
/keep Ageband SNA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000007').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SGA=(GIC/NIC).
save outfile= !Working + 'SGAAge.sav'
/keep Ageband SGA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000008').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SHA=(GIC/NIC).
save outfile= !Working + 'SHAAge.sav'
/keep Ageband SHA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000009').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SLA=(GIC/NIC).
save outfile= !Working + 'SLAAge.sav'
/keep Ageband SLA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000010').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SSA=(GIC/NIC).
save outfile= !Working + 'SSAAge.sav'
/keep Ageband SSA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000011').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SRA=(GIC/NIC).
save outfile= !Working + 'SRAAge.sav'
/keep Ageband SRA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000012').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SZA=(GIC/NIC).
save outfile= !Working + 'SZAAge.sav'
/keep Ageband SZA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000013').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute STA=(GIC/NIC).
save outfile= !Working + 'STAAge.sav'
/keep Ageband STA.
execute.

get file=!Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000014').
aggregate outfile=*
 /break Ageband
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SWA=(GIC/NIC).
save outfile= !Working + 'SWAAge.sav'
/keep Ageband SWA.
execute.

Match files file=!Working + 'SAAAge.sav'
       file= !Working + 'SBAAge.sav'
       file= !Working + 'SYAAge.sav'
       file= !Working + 'SFAAge.sav'
       file= !Working + 'SVAAge.sav'
       file= !Working + 'SNAAge.sav'
       file= !Working + 'SGAAge.sav'
       file= !Working + 'SHAAge.sav'
       file= !Working + 'SLAAge.sav'
       file= !Working + 'SSAAge.sav'
       file= !Working + 'SRAAge.sav'
       file= !Working + 'SZAAge.sav'
       file= !Working + 'STAAge.sav'
       file= !Working + 'SWAAge.sav'.
execute.

save translate outfile= !Finaloutput + 'HBTotals.xlsx'
 /TYPE=XLS 
 /VERSION=12
 /MAP 
 /REPLACE 
 /FIELDNAMES 
 /CELLS=VALUES.

* Calculate Proportions at Health Board and BNF Chapter.
***************************************************************************************************.

get file = !Working + 'PISextract2.sav'.

set mprint on.


select if (HBRES eq 'S08000001').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SAA=(GIC/NIC).
save outfile= !Working + 'SAABNF.sav'
/keep BNFchap SAA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000002').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SBA=(GIC/NIC).
save outfile= !Working + 'SBABNF.sav'
/keep BNFchap SBA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000003').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SYA=(GIC/NIC).
save outfile= !Working + 'SYABNF.sav'
/keep BNFchap SYA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000004').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SFA=(GIC/NIC).
save outfile= !Working + 'SFABNF.sav'
/keep BNFchap SFA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000005').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SVA=(GIC/NIC).
save outfile= !Working + 'SVABNF.sav'
/keep BNFchap SVA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000006').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SNA=(GIC/NIC).
save outfile= !Working + 'SNABNF.sav'
/keep BNFchap SNA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000007').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SGA=(GIC/NIC).
save outfile= !Working + 'SGABNF.sav'
/keep BNFchap SGA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000008').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SHA=(GIC/NIC).
save outfile= !Working + 'SHABNF.sav'
/keep BNFchap SHA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000009').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SLA=(GIC/NIC).
save outfile= !Working + 'SLABNF.sav'
/keep BNFchap SLA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000010').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SSA=(GIC/NIC).
save outfile= !Working + 'SSABNF.sav'
/keep BNFchap SSA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000011').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SRA=(GIC/NIC).
save outfile= !Working + 'SRABNF.sav'
/keep BNFchap SRA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000012').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SZA=(GIC/NIC).
save outfile= !Working + 'SZABNF.sav'
/keep BNFchap SZA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000013').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute STA=(GIC/NIC).
save outfile= !Working + 'STABNF.sav'
/keep BNFchap STA.
execute.

get file = !Working + 'PISextract2.sav'.

select if (HBRES eq 'S08000014').
aggregate outfile=*
 /break BNFchap
 /NIC=sum(NIC)
 /GIC=sum(GIC).
 compute SWA=(GIC/NIC).
save outfile= !Working + 'SWABNF.sav'
/keep BNFchap SWA.
execute.

****************************************

Match files file=!Working + 'SAABNF.sav'
       file= !Working + 'SBABNF.sav'
       file= !Working + 'SYABNF.sav'
       file= !Working + 'SFABNF.sav'
       file= !Working + 'SVABNF.sav'
       file= !Working + 'SNABNF.sav'
       file= !Working + 'SGABNF.sav'
       file= !Working + 'SHABNF.sav'
       file= !Working + 'SLABNF.sav'
       file= !Working + 'SSABNF.sav'
       file= !Working + 'SRABNF.sav'
       file= !Working + 'SZABNF.sav'
       file= !Working + 'STABNF.sav'
       file= !Working + 'SWABNF.sav'.
execute.

save translate outfile= !Finaloutput + 'HBBNF.xlsx'
 /TYPE=XLS 
 /VERSION=12
 /MAP 
 /REPLACE 
 /FIELDNAMES 
 /CELLS=VALUES.

*********************************************************
Housekeeping
*********************************************************.

 * erase files= !Working + 'SAAAge.sav'.
 * erase files = !Working + 'SBAAge.sav'.
 * erase files = !Working + 'SYAAge.sav'.
 * erase files = !Working + 'SFAAge.sav'.
 * erase files = !Working + 'SVAAge.sav'.
 * erase files = !Working + 'SNAAge.sav'.
 * erase files = !Working + 'SGAAge.sav'.
 * erase files = !Working + 'SHAAge.sav'.
 * erase files = !Working + 'SLAAge.sav'.
 * erase files = !Working + 'SSAAge.sav'.
 * erase files = !Working + 'SRAAge.sav'.
 * erase files = !Working + 'SZAAge.sav'.
 * erase files = !Working + 'STAAge.sav'.
 * erase files = !Working + 'SWAAge.sav'.


 * erase files = !Working + 'SAABNF.sav'.
 * erase files = !Working + 'SBABNF.sav'.
 * erase files = !Working + 'SYABNF.sav'.
 * erase files = !Working + 'SFABNF.sav'.
 * erase files = !Working + 'SVABNF.sav'.
 * erase files = !Working + 'SNABNF.sav'.
 * erase files = !Working + 'SGABNF.sav'.
 * erase files = !Working + 'SHABNF.sav'.
 * erase files = !Working + 'SLABNF.sav'.
 * erase files = !Working + 'SSABNF.sav'.
 * erase files = !Working + 'SRABNF.sav'.
 * erase files = !Working + 'SZABNF.sav'.
 * erase files = !Working + 'STABNF.sav'.
 * erase files = !Working + 'SWABNF.sav'.
 * erase files= !Working + 'PISextract2.sav'.

      
