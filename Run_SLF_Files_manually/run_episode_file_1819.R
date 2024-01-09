library(targets)
library(createslf)

year <- "1819"

processed_data_list <- targets::tar_read("processed_data_list_1819",
                                         store = fs::path("/conf/sourcedev/Source_Linkage_File_Updates/", "_targets"))

# Run episode file
create_episode_file(processed_data_list, year = year) %>%
  process_tests_episode_file(year = year)
