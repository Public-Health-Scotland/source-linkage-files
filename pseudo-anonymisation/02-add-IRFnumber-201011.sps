* 2010/11 data.
* Program to add IRF anonymised number to the master PLICS and CHI PLICS analysis files.

* Program by Denise Hastie, January 2014.


* Define filepaths.
define !filepath()
'/conf/irf/11-Development team/Dev00 - PLICS files/pseudo-anonymisation/'
!enddefine.

define !CostedFiles()
'/conf/irf/06-Mapping/2010_11/2. Hospital/1. PLICS/Programmes/data/'
!enddefine.


* Add IRF number to the 2010/11 CHI master PLICS file.

get file = !CostedFiles + 'CHImasterPLICS_Costed_201011.sav'.

sort cases by chi.

match files file = *
 /table = !filepath + 'CHI-to-IRFnumber-lookup.sav'
 /by chi.
execute. 


* Check to ensure that there aren't any CHI numbers that have not had an IRFnumber assigned. 
* The frequency should produce no results. 
temporary.
select if sysmis(IRFnumber).
frequency variables = chi.

save outfile = !CostedFiles + 'CHImasterPLICS_Costed_201011.sav' 
 /keep year IRFnumber CHI gender dob health_postcode gpprac
       health_net_cost health_net_costincDNAs
       acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
       acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost
       acute_inpatient_beddays acute_el_inpatient_beddays acute_non_el_inpatient_beddays
       mat_episodes mat_daycase_episodes mat_inpatient_episodes 
       mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays 
       mentalh_episodes mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes mentalh_non_el_inpatient_episodes
       mentalh_cost mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost
       mentalh_inpatient_beddays mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays
       gls_episodes gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes gls_non_el_inpatient_episodes
       gls_cost gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost
       gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays
       op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas
       ae_attendances ae_cost pis_dispensed_items pis_cost
       deceased_flag date_death
       hbres lca Datazone CHP
       ward urbrur_8 ukparl_con sparl_con easting northing
       scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile
 /compressed.

get file = !CostedFiles + 'CHImasterPLICS_Costed_201011.sav'.



* Add IRF number to the 2010/11 master PLICS file.

get file = !CostedFiles + 'masterPLICS_Costed_201011.sav'.

sort cases by chi.

match files file = *
 /table = !filepath + 'CHI-to-IRFnumber-lookup.sav'
 /by chi.
execute. 


* Check to ensure that there aren't any CHI numbers that have not had an IRFnumber assigned. 
* The frequency should produce no results. 
temporary.
select if sysmis(IRFnumber) and (chi ne '').
frequency variables = chi.

sort cases by chi record_keydate1 record_keydate2.

save outfile = !CostedFiles + 'masterPLICS_Costed_201011.sav'
 /keep year recid record_keydate1 record_keydate2 IRFnumber chi gender dob prac hbpraccode
       pc7 hbrescode lca chp datazone hbtreatcode location 
       yearstay stay ipdc spec sigfac conc mpat cat tadm admreas adtf admloc oldtadm disch dischto dischloc
       diag1 diag2 diag3 diag4 diag5 diag6 op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 
       smr01_cis hrg4  
       discondition
       stadm adcon1 adcon2 adcon3 adcon4
       reftype refsource attendance_status clinic_type community_flag 
       no_dispensed_items
       death_location_code death_board_occurrence place_death_occurred
       deathdiag1 deathdiag2 deathdiag3 deathdiag4 deathdiag5 deathdiag6 deathdiag7 deathdiag8
       deathdiag9 deathdiag10 deathdiag11
       age cis_marker newCIS_admtype newCIS_ipdc newpattype_CIS
       ward urbrur_8 ukparl_con sparl_con easting northing
       scsimd2012quintile scsimd2012decile hbsimd2012quintile hbsimd2012decile
       Cost_Direct_Net Cost_Allocated_Net Cost_Total_Net Cost_Total_Net_incDNAs NHSHosp
 /compressed.

get file = !CostedFiles + 'masterPLICS_Costed_201011.sav'.

