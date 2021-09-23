# September 2021 Update - Released 22-Sep-2021

* Removed Social Care data from 2015/16 and 2016/17.
* Add `sigfac` data for A&E records - previously this would be missing.
* New `cij_delay` variable added to the episode file.
* Count of delays added to the individual file.
* Add new variables to the individual file `preventable_admissions` and `preventable_beddays` which count the number of `CIJ_PPA`s and the beddays associated with the stay respectively.
* Added a `NEWS.md` file to easily keep track of major changes.
* Add SPARRA and HHG scores, calculated at April 2021 for end-year 2020/21 and start year 2021/22.
* Update costs for DN, GP OOH and CH's - costs for 1920 now available. 
    * Revised update to CH costs now included and CH costs prior to 1718 are now removed. 
* Update Home Care, Alarms and Telecare and SDS to use new extracts
    * Numbers may be slightly different.
    * Now include `person_id` and `sc_latest_submission` variables.
    * In Home Care missing reablement has been re-coded to unknown (9).
* Data now available in 2021 for DN and CMH - code now amended to include these.

# June 2021 Update - Released 29-Jul-2021

* Included new Care Home data for 2018/19 onwards.
