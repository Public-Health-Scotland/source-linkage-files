library(targets)

# use tar_make_future() to run targets for all years
# This will run everything needed for creating the episode file.
tar_make_future()

# Combine deaths lookup here rather than in targets to make sure that
# it is run after the death file for each year is produced.
combined_deaths_lookup <- process_combined_deaths_lookup()
