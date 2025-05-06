library(createslf)

file_name <- stringr::str_glue(
  "ind_{year}_console_{format(Sys.time(), '%Y-%m-%d_%H-%M-%S')}.txt"
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

year <- "1516"

clean_temp_data(year, "ep")

episode_file <- arrow::read_parquet(get_slf_episode_path(year))

# Run individual file
create_individual_file(episode_file, year = year, write_temp_to_disk = FALSE) %>%
  process_tests_individual_file(year = year)

# Restore messages to the console and close the connection
sink(type = "message")
sink()

close(con)

extract_targets_time(file_name)
