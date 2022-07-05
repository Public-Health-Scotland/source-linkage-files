library(createslf)

# Create a list of the years to run
# Use set_names so that any returned list will be named.
years_to_run <- convert_year_to_fyyear(as.character(2017:2021)) %>%
  purrr::set_names()

# Only write to disk (for a standard SLF run)
purrr::walk(
  years_to_run,
  process_homelessness_extract
)

# Write to disk and return the data
homelessness_data <- purrr::map(
  years_to_run,
  process_homelessness_extract
)

# Keep the data but don't write to disk (for testing)
homelessness_data <- purrr::map(
  years_to_run,
  process_homelessness_extract,
  write_to_disk = FALSE
)
