* Encoding: UTF-8.

************************************************************************************************************
** AUTHOR:	James McMahon (james.mcmahon@phs.scot)
** Date:    	01/08/2018
************************************************************************************************************
** Amended by: Jennifer Thom (Jennifer.Thom@phs.scot)
** Date: 22/03/21
** Changes: Switched macro file so there is one universal macro file for each quarterly update. 
                  *and each year will have its own unique year macro. 
************************************************************************************************************.
*A01b Set up (year) Macros - applies to one year only. 
*Run A01a Set up Universal macros and then A01b Set up (year) Macro at the beginning of each update.
*Date: 22/03/21. 
*A01a Set up Universal Macros is located at: 
        * "/conf/irf/11-Development team/Dev00-PLICS-files/All Years/A01a Set up Universal Macros.sps"


 * Set the Financial Year.
Define !FY()
   "1516"
!EndDefine.

* Set the next FY, needed for SPARRA (and HHG).
Define !NextFY ()
    "1617"
!EndDefine.

