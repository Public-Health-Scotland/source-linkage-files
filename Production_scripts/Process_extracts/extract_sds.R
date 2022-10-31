#####################################################
# SDS year specific Extract
# Author: Zihao Li
# Date: October 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - SDS Episodes
# Description -
#####################################################

library(createslf)
library(dplyr)

year <- check_year_format("1920")

# Now select epsiodes for given FY

final_out <- readr::read_rds(get_sc_sds_episodes_path(update = latest_update())) %>%
  filter(is_date_in_fyyear(year, record_keydate1, record_keydate2))

final_out %>%
  select(
    recid,
    smrtype,
    chi,
    dob,
    gender,
    postcode,
    record_keydate1,
    record_keydate2,
    sc_send_lca,
    sc_living_alone,
    sc_support_from_unpaid_carer,
    sc_social_worker,
    sc_type_of_housing,
    sc_meals,
    sc_day_care
  ) %>%
  write_rds(get_source_extract_path(year, type = "SDS", check_mode = "write"))
