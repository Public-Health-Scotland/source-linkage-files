library(targets)
library(createslf)

year <- "1718"

targets_store <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates/", "_targets")

processed_data_list <- list(
  acute = targets::tar_read(
    "source_acute_extract_1718",
    store = targets_store
  ),
  ae = targets::tar_read(
    "source_ae_extract_1718",
    store = targets_store
  ),
  cmh = targets::tar_read(
    "source_cmh_extract_1718",
    store = targets_store
  ),
  dn = targets::tar_read(
    "source_dn_extract_1718",
    store = targets_store
  ),
  deaths = targets::tar_read(
    "source_nrs_deaths_extract_1718",
    store = targets_store
  ),
  homelessness = targets::tar_read(
    "source_homelessness_extract_1718",
    store = targets_store
  ),
  maternity = targets::tar_read(
    "source_maternity_extract_1718",
    store = targets_store
  ),
  mental_health = targets::tar_read(
    "source_mental_health_extract_1718",
    store = targets_store
  ),
  outpatients = targets::tar_read(
    "source_outpatients_extract_1718",
    store = targets_store
  ),
  gp_ooh = targets::tar_read(
    "source_ooh_extract_1718",
    store = targets_store
  ),
  prescribing = targets::tar_read(
    "source_prescribing_extract_1718",
    store = targets_store
  ),
  care_home = targets::tar_read(
    "source_sc_care_home_1718",
    store = targets_store
  ),
  home_care = targets::tar_read(
    "source_sc_home_care_1718",
    store = targets_store
  ),
  at = targets::tar_read(
    "source_sc_alarms_tele_1718",
    store = targets_store
  ),
  sds = targets::tar_read(
    "source_sc_sds_1718",
    store = targets_store
  )
)

# Run episode file
create_episode_file(processed_data_list, year = year, write_temp_to_disk = FALSE) %>%
  process_tests_episode_file(year = year)

## End of Script ##
