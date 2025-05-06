library(targets)
library(createslf)

year <- "2021"

file_name <- stringr::str_glue(
  "ep_{year}_console_{format(Sys.time(), '%Y-%m-%d_%H-%M-%S')}.txt"
)
file_path <- get_file_path(
  ep_ind_console_path(),
  file_name,
  create = TRUE
)
con <- file(file_name, open = "wt")

# Redirect messages (including warnings and errors) to the file
sink(con, type = "output", split = TRUE)
sink(con, type = "message", append = TRUE)


targets_store <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates/", "_targets")

processed_data_list <- list(
  acute = targets::tar_read("source_acute_extract_2021", store = targets_store),
  ae = targets::tar_read("source_ae_extract_2021", store = targets_store),
  cmh = targets::tar_read("source_cmh_extract_2021", store = targets_store),
  dn = targets::tar_read("source_dn_extract_2021", store = targets_store),
  deaths = targets::tar_read("source_nrs_deaths_extract_2021", store = targets_store),
  homelessness = targets::tar_read("source_homelessness_extract_2021", store = targets_store),
  maternity = targets::tar_read("source_maternity_extract_2021", store = targets_store),
  mental_health = targets::tar_read("source_mental_health_extract_2021", store = targets_store),
  outpatients = targets::tar_read("source_outpatients_extract_2021", store = targets_store),
  gp_ooh = targets::tar_read("source_ooh_extract_2021", store = targets_store),
  prescribing = targets::tar_read("source_prescribing_extract_2021", store = targets_store),
  care_home = targets::tar_read("source_sc_care_home_2021", store = targets_store),
  home_care = targets::tar_read("source_sc_home_care_2021", store = targets_store),
  at = targets::tar_read("source_sc_alarms_tele_2021", store = targets_store),
  sds = targets::tar_read("source_sc_sds_2021", store = targets_store)
)

# Run episode file
create_episode_file(processed_data_list,
  year = year,
  write_temp_to_disk = FALSE
) %>%
  process_tests_episode_file(year = year)

## End of Script ##


# Restore messages to the console and close the connection
sink(type = "message")
sink()

close(con)

extract_targets_time(file_name)
