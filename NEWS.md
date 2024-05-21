# June 2024 Update - Unreleased
* Update of 2017/18 onwards to include bug fixes within the files.
* Removal of extra variable caused by the LTCs not matching properly.
* New NRS mid-2022 population estimates.
* Homelessness improvements:
   * Removal of filtering the data in SLFs according to completeness levels.
   * New variables:
      * `hl1_completeness` - a data quality indicator by percentage compared to SG annual publication. 
      * `hl1_12_months_pre_app`- date variable
      * `hl1_12_momths_post_app` - date variable 
* Potential inclusions
* Activity after death flag?
* New care home methodology? - potentially this is on hold until September update.
* Additional Documentation?

# March 2024 Update - Released 20-Mar-2024
* Update of 2017/18 onwards to include bug fixes within the files.
* 2023/24 file now includes social care data.
* Geography files updated - SPD and SIMD
* Variable `property_type` in homelessness has been updated to include further description
* Bug fixes:
  * Service use cohort wrongly assigning Non-Service Users (NSU) as `psychiatry`
  * Not Applicable (NA) introduced for variable `high_cc` in Demographic cohort
  * Issue with delayed discharges data not linking to admissions
  * Person ID available in self-directed support (SDS) data
  * Issue with Social Care ID - missing sc id were all being set to one sc id.
 * Improvements to social care methodology
   * Demographics 
    * person_id will now be consistent across social care cases for an individual. The social care ID for a CHI will also be consistent across all areas, not just the latest ID used in AT/SDS/CH/HC.
 * Self-directed Support (SDS) and Alarms Telecare (AT) data
    * Our tests show this is now in line with the social care team’s publications and therefore, the data may have changed slightly. 
 * New Social Care methodology 
    * The new methodology impacts how we match the demographics file and how we select the latest social care ID.
    * Previously we used the `latest_flag` but this isn’t accurate as some IDs have none flagged, and some have more than one flagged. We now have one social care ID flagged for each CHI. This issue mostly affects Edinburgh, Falkirk, Western Isles, and Renfrewshire.
    * Previously, in cases where a social care ID had multiple CHIs associated only one of the CHIs was chosen.
    * The new methodology keeps all CHIs in as there is no way to tell which CHI the activity is for. The new methodology will show duplicate activity but for the different CHIs. The main areas this affects are Midlothian, Western Isles, and Renfrewshire.
      

# December 2023 Update - Released 20-Dec-2023
* Update of 2017/18 onwards to include bug fixes within the files.
* 2023/24 file contain data from 1st April 2023 up to the end of September 2023.
  * No social care data available.
* Re-addition of keep population flag.
* SPARRA update
* NA's introduced for variable `ch_provider` - now fixed.
* Future improvements
  * Activity after death flag
  * Review of social care methodology.
* SLFhelper updated to version 10.1.1.
  * Includes a fix for speeding up function `get_chi()`


# September 2023 Update - Released 22-Sep-2023
* Update of 2017/18 onwards to include bug fixes within the files. 
* New 2023/24 files.
  *No social care data available for new 2023/24 file.
* New NSU cohort for 2022/23 file.
* SPD and SIMD updated.
* Re addition of:
  * HRIs in individual file.
  * Homelessness Flags.
* Bug fixes: 
  * Blank `datazone` in A&E. This has been fixed and was due to PC8 postcode format matching onto SLF pc lookup. 
  * Large increase in preventable beddays. This was caused due to an SPSS vs R logic difference. Uses SPSS logic which 
    brings the difference down to `3.3%`. 
  * Issue with `locality` which showed `locality` in each row instead of its true `locality`. This has now been fixed. 
  * Duplicated CHI in the individual file. The issue was identified when trying to include HRIs. This has now been corrected. 
* Internal changes to SLF development: 
  * `DN` and `CMH` data are now archived in an HSCDIIP folder as the BOXI datamart is now closed down for these. Function `get_boxi_extract_path` has been updated to reflect this. 
  * Tests updated to include `HSCP`count. 
  * Tests created for `Delayed Discharges` extract and `Social care Client lookup`.


# June 2023 Update - Released 24-Jul-2023
* 2011/12 -> 2013/14 – These files have not been altered, other than to make them available in a new file type (parquet).
* 2017/18 – These files have been recreated using our new R pipeline, but the data has not changed. We did this so that we would have a good comparator file.
* 2018/19 -> 2022/23 – These files have been recreated using the R pipeline and are also using updated data (as in a ‘normal’ update).
* Files changed into parquet format. 
* SLFhelper updated. 
* Removal of `keydate1_dateformat` and `keydate2_dateformat`.
* `dd_responsible_lca` – This variable now uses CA2019 codes instead of the 2-digit ‘old’ LCA code.
* Preventable beddays - not able to calculate these correctly. * Death fixes not included.
* Variables not ordered in R like they used to be in SPSS.
* End of HHG.
* New variable `ch_postcode`.
* rename of variables `cost_total_net_incdnas`, `ooh_outcome.1`, `ooh_outcome.2`, `ooh_outcome.3`, `ooh_outcome.4`, `totalnodncontacts`. 
* HRI's not included. 
* Homelessness flags not included. 
* Keep_population flag not included. 


# March 2023 Update - Released 10-Mar-2023
* 2021/22 episode and individual files refreshed with updated activity.
* 2022/23 file updated and contains data up to the end of Q3. 
* Social care data is available for 2022/23. 
* Typo in the variable name `ooh_covid_assessment`
* Next update in May as a test run in R but won't be released. 
* Next release in June. 

# December 2022 Update - Released 07-Dec-2022
* Now using the 2022v2 Scottish Postcode Directory.
* Now using the 2020 Urban Rural classifications (instead of the older 2016 ones), this means variables such as `URx_2016` will now be called `URx_2020`.
* Now using the 2021 Datazone population estimates to derive the `keep_population` flag.
* Fixed a typo in the Service Use Cohort `substance` where the ICD-10 code `F11` (Opioids) was used instead of the correct `F13` (sedatives or hypnotics).
* Prescribing (PIS) changes
  * Changed from using 'dispensed items' (count and cost) to 'paid items'.
  * Changed from using the Net cost (in `cost_total_net`) to using the Gross cost.
  * `no_dispensed_items` has been replaced with `no_paid_items` in the episode file.
  * `pis_dispensed_items` has been replaced with `pis_paid_items` in the individual file.
* `health_net_costincIncomplete` has been removed from the individual file. This was only relevant to District Nursing, so was deemed to be not worth keeping as a separate variable.
* HRI changes and fixes
  * The variables `hri_lca_incDN` and `hri_lcap_incdn` have been removed. They were dependent on `health_net_costincIncomplete` which has now been removed.
  * Only people with health activity, not Social (Care Home, Home Care, SDS or Alarms and Telecare), or Community care (District Nursing or Community Mental Health) will be included in the HRI calculation.
* GP Out of Hours fixes and changes.
  * GP OoH costs updated - Now using real contact numbers (from unscheduled care team publication) for 2020/21, and 2021/22. Costs are uplifted from 2019/20 using the same methodology as with PLICS. 2022/23 now has costs (previously missing).
  * New COVID-19 related consultation types have now been included in `smrtype`. This was an oversight as it should have been included at the last update.
  * `ooh_case_id` has replaced `ooh_CC` in the older files. This was implemented for years 2017/18 -> 2022/23 at the last update, so this completes that change.
  * Added new variables to the individual file to count the recently added consultation types for GP OoHs - `ooh_covid_advice`, `ooh_covid_assessment` and `ooh_covid_other`.
  * Fixed `ooh_cases` - this was overcounting, such that everyone had at least one case and the majority of people had one more case than they should have had.


# September 2022 Update - Released 05-Sep-2022
* Costs uplifted for 2021 onwards.
  * 1.5% for 2020/21
  * 4.1% for 2021/22
  * 6.2% for 2022/23
*  Alarms - Telecare and SDS data added.
* SPARRA and HHG - new 22/23 scores added.  
* Created new files for 2022/23.
* The NSU cohort has been added for 2021/22.
* Home Care - If the start date is after the end date we will now discard the end date (`sysmis`/`NA`), previously we would have dropped these records entirely.
* Changes to GP Out of Hours data
  * Include some new categories to `smrtype` for COVID type consultations. This is consistent with the Unscheduled Care publication.
  * Exclude some records which were previously included. These were data from 'Flow navigation centres' and are incorrectly being added to the data mart. This is also consistent with what the Unscheduled Care team do.
  * The `ooh_cc` variable has been replaced with `ooh_case_id`. Each row for GP OoH is a 'consultation' but many consultations can be grouped into a 'case' previously `ooh_cc` simply numbered unique cases for a person in the year e.g. 1,2,3... This could be confusing as cases could reasonably span multiple years. `ooh_case_id` is the unique ID for the case as found in the datamart (called `GUID`), you can count unique `ooh_case_id`s to get a count of cases in the year, or aggregate on it to merge the consultations into a case. Unlike `ooh_cc` this will now work properly across years too
* Care Home admission reason - `ch_adm_reason` now uses the variable `type_of_admission` from the V1.4 definitions, instead of the older `reason_for_admission`. Records submitted before 2020/21 which do not have this variable have been re-coded but should be used with some scepticism.


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
