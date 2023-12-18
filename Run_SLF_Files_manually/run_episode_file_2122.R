library(targets)
library(createslf)

year <- "2122"

processed_data_list <- targets::tar_read("processed_data_list_2122")

# Run episode file
create_episode_file(processed_data_list, year = year) %>%
  process_tests_episode_file(year = year)
