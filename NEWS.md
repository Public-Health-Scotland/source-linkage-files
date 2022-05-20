# June 2022 Update - Unreleased
* Fixed a bug where we were overcounting preventable beddays in the individual file.
  * e.g. if a cij had 2 episodes then it would have 2X the correct number of beddays. This is now corrected.
* Fixed a bug where CH costs was not referring to end of year. 
  * eg. 2018 costs relates to 2017/18
* The changes to Homelessness described in the March update have been properly implemented.
* Cij_marker is now a numeric instead of a string which changes empty strings to missing instead of blank using sysmis.


# March 2022 Update - Released 17-Mar-2022
* NSU extract now available for 2014/15.
* New variable `gender` included in NSU extract.
* Now using Social Care data up to 2021/22 Q2.
  * Issues with client data - should be resolved by next update, client data will be reviewed to include it more completely.
* Big changes to Homelessness data
  * Some LAs have more data thanks to work with DM
  * Some LAs have had data removed as it's incomplete and possibly misleading - all LAs with data now have at least 90% completeness (at the application level).
  * Homelessness Flags now only look at the application decision date (keydate1).
  * Some duplicates removed from West Dunbartonshire and East Ayrshire.
 
# December 2021 Update - Released 16-Dec-2021

* Include Care Home data up to 2021/22 Q1
* Include Home Care data using the new methodology, from 2017/18 Q4 - 2021/22 Q1.
  * New variables `hc_hours_q1`, `hc_hours_q2`, `hc_hours_q3` and `hc_hours_q4`
* All costs are now uplifted by 1% per year from the latest available year.
* Home Care in the individual file now has new variables.
  * episode counts: `HC_reablement_episodes`.
  * sums of hours: `HC_reablement_hours`, `HC_total_hours`, `HC_personal_hours`, `HC_non_personal_hours` and `HC_reablement_hours`.

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
