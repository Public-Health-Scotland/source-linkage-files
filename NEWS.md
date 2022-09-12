# September 2022 Update - Unreleased
* Costs uplifted for 2021 onwards.
  * 1.5% for 2020/21
  * 4.1% for 2021/22
  * 6.2% for 2022/23
*  Alarms - Telecare and SDS data added.
* SPARRA and HHG - new 22/23 scores added.  
* Created new files for 2022/23.
* The NSU cohort has been added for 2021/22.
* Home Care - If the start date is after the end date we will now discard the end date (`sysmis`/`NA`), previously we would have dropped these records entirely.
* Changes to GP OoH data
  * Include some new categories to `smrtype` for COVID type consultations. This is consistent with the Unscheduled Care publication.
  * Exclude some records which were previously included. These were data from 'Flow navigation centres' and are incorrectly being added to the data mart. This is also consistent with what the UC team do.
  * The `ooh_cc` variable has been replaced with `ooh_case_id`. Each row for GP OoH is a 'consultation' but many consultations can be grouped into a 'case' previously `ooh_cc` simply numbered unique cases for a person in the year e.g. 1,2,3... This could be confusing as cases could reasonably span multiple years. `ooh_case_id` is the unique ID for the case as found in the datamart (called `GUID`), you can count unique `ooh_case_id`s to get a count of cases in the year, or aggregate on it to merge the consultations into a case. Unlike `ooh_cc` this will now work properly across years too
* Care Home admission reason - `ch_adm_reason` now uses the variable `type_of_admission` from the V1.4 definitions, instead of the older `reason_for_admission`. Records submitted before 2020/21 which do not have this variable have been re-coded but should be used with some skeptisism.


# June 2022 Update - Released 10-Jun-2022

* Fixed a bug where CH costs was not referring to end of year. 
  * e.g. 2018 costs relates to 2017/18
* The changes to Homelessness described in the March update have been properly implemented.
* We now use [`{haven}`](https://haven.tidyverse.org/news/index.html) to compress the SPSS files which compresses them better than SPSS does 🤷
♂️
* `cij_marker` is now a numeric instead of a string which changes empty strings to missing instead of blank using sysmis.
  * Check code of the form `cij_marker = "x"`. `x` now needs to be a numeric.
  * Check code of the form `cij_maker = lag(cij_marker)`. If the previous `cij_marker` is missing, the expression will fail, previously it would have compared to an empty string.
* We now match on clusters from the past 5 years, rather than just the latest (quarterly) release. This means that more GP practices will be assigned to a cluster (even if the code has been retired at the time of the SLF refresh).
* The ACaDMe variable `glsrecord` is now the only thing we use to determine if an episode should have recid `01B` (Acute) or `GLS`. Previously `lineno` was also used.
* Fixed a bug where we were over-counting preventable beddays in the individual file.
  * e.g. if a CIJ had 2 episodes then it would have 2X the correct number of beddays. This is now corrected.
* We were correcting some costs for FV and A&A (see previous update). `cost_total_net` was being correctly updated, however the monthly cost variables for Forth Valley were not being changed, this is now fixed.
* Fixed a bug where people with no Care Home episodes would have 1 `ch_cis_episodes` in the individual file.
* Added the `keep_population` variable to 2014/15 individual file, this was missed when we added the NSU cohort.

# March 2022 Update - Released 17-Mar-2022
* NSU extract now available for 2014/15.
* New variable `gender` included in NSU extract.
* Now using Social Care data up to 2021/22 Q2.
  * Issues with client data - should be resolved by next update, client data will be reviewed to include it more completely.
* Big changes to Homelessness data
  * Some LAs have more data thanks to work with Data Management
  * Some LAs have had data removed as it's incomplete and possibly misleading - all LAs with data now have at least 90% completeness (at the application level).
  * Homelessness Flags now only look at the application decision date (`keydate1`).
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
* Add new variables to the individual file `preventable_admissions` and `preventable_beddays` which count the number of `cij_ppa`s and the beddays associated with the stay respectively.
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

* Included new Care Home data for 2018/19 onward.
