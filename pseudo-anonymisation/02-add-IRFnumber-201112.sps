* 2010/11 data.
* Program to add IRF anonymised number to the master PLICS and CHI PLICS analysis files.

* Program by Denise Hastie, January 2014.


* Define filepaths.
define !filepath()
'/conf/irf/11-Development team/Dev00 - PLICS files/pseudo-anonymisation/'
!enddefine.

define !CostedFiles1011()
'/conf/irf/06-Mapping/2010_11/2. Hospital/1. PLICS/Programmes/data/'
!enddefine.

define !CostedFiles1112()
'/conf/irf/06-Mapping/2011_12/2. Hospital/1. PLICS/Programmes/data/'
!enddefine.




get file = !CostedFiles1011 + 'CHImasterPLICS_Costed_201011.sav'.
get file = !CostedFiles1112 + 'CHImasterPLICS_Costed_201112.sav'.
