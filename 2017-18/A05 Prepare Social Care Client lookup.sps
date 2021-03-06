﻿* Encoding: UTF-8.
 * Read the data.
get file = "/conf/hscdiip/Social Care Extracts/SPSS extracts/201718_Client_extract_fix.zsav".
   
 * Variables are all really wide for some reason so tidy this up.
Variable width ALL (8).

 * Change the flags to numerics.
Alter type support_from_unpaid_carer social_worker type_of_housing meals living_alone day_care (F1.0).

 * Add labels to the flag variables.
Variable Labels living_alone 'Indicator of whether the client/service user lives alone.'.
Variable Labels support_from_unpaid_carer 'Indicator of whether the client/service user received support from an unpaid carer at any point during the quarter.'.
Variable Labels social_worker 'Indicator of whether the client/service user has an assigned Social Worker or a Support Worker.'.
Variable Labels type_of_housing 'Housing status of the client at the end of the reporting period.'.
Variable Labels meals 'Indicator of whether the client/service user received a Meals Service at any point during the quarter.'.
Variable Labels day_care 'Indicator of whether the client/service user has received a day care service within the reporting period.'.

 * Add some value labels.
Value Labels support_from_unpaid_carer social_worker meals living_alone day_care
    0 "No"
    1 "Yes"
    9 "Not Known".

Value Labels type_of_housing
    1 "Mainstream"
    2 "Supported"
    3 "Long Stay Care Home"
    4 "Hospital or other medical establishment"
    5 "Other"
    6 "Not Known".

Rename Variables
    living_alone = sc_living_alone
    support_from_unpaid_carer = sc_support_from_unpaid_carer
    social_worker = sc_social_worker
    type_of_housing = sc_type_of_housing
    meals = sc_meals
    day_care = sc_day_care.

 * Sort for matching.
sort cases by social_care_id sending_location.
 * Save and reorder flag variables so they're in the same order as Social Care Dataset definition.
save outfile = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_Client_for_source.zsav"
    /Keep
    social_care_id
    sending_location
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    /zcompressed.

get file = "/conf/hscdiip/Social Care Extracts/SPSS extracts/2017Q4_Client_for_source.zsav".
