library(createslf)

year <- "1819"

## Read data from sourcedev
processed_data_list <- list(
  "ae" = read_file(get_source_extract_path(year, "ae")),
  "acute" = read_file(get_source_extract_path(year, "acute")),
  "at" = read_file(get_source_extract_path(year, "at")),
  "ch" = read_file(get_source_extract_path(year, "ch")),
  "cmh" = read_file(get_source_extract_path(year, "cmh")),
  "nrs_deaths" = read_file(get_source_extract_path(year, "deaths")),
  "district_nursing" = read_file(get_source_extract_path(year, "dn")),
  "gp_ooh" = read_file(get_source_extract_path(year, "gp_ooh")),
  "hc" = read_file(get_source_extract_path(year, "hc")),
  "homelessness" = read_file(get_source_extract_path(year, "homelessness")),
  "maternity" = read_file(get_source_extract_path(year, "maternity")),
  "mental_health" = read_file(get_source_extract_path(year, "mh")),
  "outpatients" = read_file(get_source_extract_path(year, "outpatients")),
  "pis" = read_file(get_source_extract_path(year, "pis")),
  "sds" = read_file(get_source_extract_path(year, "sds"))
)

# Run episode file
create_episode_file(processed_data_list, year = year, write_temp_to_disk = FALSE) %>%
  process_tests_episode_file(year = year)

## End of Script ##
