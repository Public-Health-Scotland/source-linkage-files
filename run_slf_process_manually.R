# Load Library
library(targets)
library(createslf)

#---

## UPDATE: Year you would like to run ##
  year <- "2223"

## UPDATE: Year on "processed_data_list_XXX" ##
processed_data_list <- targets::tar_read("processed_data_list_2223")

#---

  # Run episode file
  create_episode_file(processed_data_list, year = year) %>%
  process_tests_episode_file(year = year)

  episode_file <- arrow::read_parquet(get_slf_episode_path(year))

  # Run individual file
  create_individual_file(episode_file, year = year) %>%
  process_tests_individual_file(year = year)
