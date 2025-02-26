library(targets)
library(createslf)

year <- "1617"

path <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates/1617/")

processed_data_list <- list(
  acute = arrow::read_parquet(paste0(path, "/anon-acute_for_source-201617.parquet")),
  ae = arrow::read_parquet(paste0(path, "/anon-a_and_e_for_source-201617.parquet")),
  cmh = arrow::read_parquet(paste0(path, "/anon-cmh_for_source-201617.parquet")),
  deaths = arrow::read_parquet(paste0(path, "/anon-deaths_for_source-201617.parquet")),
  dn = arrow::read_parquet(paste0(path, "/anon-district_nursing_for_source-201617.parquet")),
  homelessness = arrow::read_parquet(paste0(path, "/anon-homelessness_for_source-201617.parquet")),
  maternity = arrow::read_parquet(paste0(path, "/anon-maternity_for_source-201617.parquet")),
  mental_health = arrow::read_parquet(paste0(path, "/anon-mental_health_for_source-201617.parquet")),
  outpatients = arrow::read_parquet(paste0(path, "/anon-outpatients_for_source-201617.parquet")),
  gp_ooh = arrow::read_parquet(paste0(path, "/anon-gp_ooh_for_source-201617.parquet")),
  prescribing = arrow::read_parquet(paste0(path, "/anon-prescribing_file_for_source-201617.parquet"))
)


# Run episode file
create_episode_file(processed_data_list, year = year, write_temp_to_disk = FALSE) ## %>%
process_tests_episode_file(year = year)

## End of Script ##
