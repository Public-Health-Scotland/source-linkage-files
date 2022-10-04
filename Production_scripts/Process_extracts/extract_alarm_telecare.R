#####################################################
# Alarms Telecare Extract
# Author: Zihao Li
# Date: September 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Social Care Care Home Episodes
# Description - Match on Client data and Costs data
#####################################################

library(createslf)
library(dplyr)

year <- check_year_format("1920")

# Transform B17 ----

client_table <- readr::read_rds(get_source_extract_path(year, type = "Client"))

# Now select epsiodes for given FY

final_out <- readr::read_rds(get_sc_hc_episodes_path(update = latest_update())) %>%
  filter(is_date_in_fyyear(year, record_keydate1, record_keydate2)) %>%
  left_join(client_table, by = c("sending_location", "social_care_id"))

final_out %>%
  select(
    recid,
    smrtype,
    chi,
    dob,
    gender,
    postcode,
    sc_send_lca,
    record_keydate1,
    record_keydate2,
    person_id,
    sc_latest_submission,
    sc_living_alone,
    sc_support_from_unpaid_carer,
    sc_social_worker,
    sc_type_of_housing,
    sc_meals,
    sc_day_care
  ) %>%
  write_rds(get_source_extract_path(year, type = "AT", check_mode = "write"))
