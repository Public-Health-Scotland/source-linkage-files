library(createslf)

year <- "2425"

clean_temp_data(year, "ep")

episode_file <- arrow::read_parquet(get_slf_episode_path(year))

# Run individual file
create_individual_file(episode_file, year = year) %>%
  process_tests_individual_file(year = year)
