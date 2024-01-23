library(targets)

Sys.setenv("CREATESLF_KEYRING_PASS" = "createslf")

year <- "1819"

# use targets for the process until testing episode files
tar_make_future(
  # it does not recognise `contains(year)`
  names = (targets::contains("1819"))
)

# use targets to create individual files due to RAM limit
library(createslf)

episode_file <- arrow::read_parquet(get_slf_episode_path(year))

# Run individual file
create_individual_file(episode_file, year = year) %>%
  process_tests_individual_file(year = year)
