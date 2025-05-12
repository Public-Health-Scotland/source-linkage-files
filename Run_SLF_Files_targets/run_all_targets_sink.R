library(targets)
library(createslf)

file_name <- stringr::str_glue(
  "targets_console_{format(Sys.time(), '%Y-%m-%d_%H-%M-%S')}.txt"
)
file_path <- get_file_path(
  console_output_path(),
  file_name,
  create = TRUE
)

con <- file(file_name, open = "wt")

# Redirect messages (including warnings and errors) to the file
sink(con, type = "output", split = TRUE)
sink(con, type = "message", append = TRUE)

# use tar_make() to run targets for all years
# This will run everything needed for creating the episode file.
tar_make_future()

createslf::combine_tests()

sink()

extract_targets_time(file_name)
