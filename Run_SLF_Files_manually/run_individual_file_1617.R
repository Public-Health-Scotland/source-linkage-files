library(createslf)

year <- "1617"

episode_file <- arrow::read_parquet(get_slf_episode_path(year))

# Run individual file
create_individual_file(episode_file, year = year) #%>%
  #process_tests_individual_file(year = year)
