*Master program to run fix LTCs.

*CD to hscdiip.
CD '/conf/hscdiip/'.

 * SET MPRINT OFF.
insert file='/conf/irf/11-Development team/Dev00-PLICS-files/PLICS_development/ltc_fix.sps'.
 * SET MPRINT ON.
ltc_fix file_type=individual FY=1415.




DATASET NAME DataSet2 WINDOW=FRONT.
