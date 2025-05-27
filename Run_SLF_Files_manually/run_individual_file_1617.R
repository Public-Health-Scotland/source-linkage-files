################################################################################
# Name of file -  Run_individual_file_1617.R
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - March 2023
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description:
# Set up this script as a workbench job to create the SLF Individual file:
#     * Source > Source as a workbench job
#     * Select Workbench job options, please specify 8CPU, 128GB
#     * Select the environment tab, please set the working directory where the
#       project is saved. Eg:
#             /conf/sourcedev/Jen/source-linkage-files
#     * Press start. This will now run the script as a workbench job
#
# The individual file will take approximately 2hrs to run.
# The output will be stored in year specific folders in:
# /conf/sourcedev/Source_Linkage_File_Updates/
#
################################################################################

# Setup-------------------------------------------------------------------------
library(createslf)

# Specify year to run
year <- "1617"

# Specify TRUE/FALSE for writing temporary files
write_temp_to_disk <- FALSE

# Specify TRUE/FALSE for saving the console output to disk
# Default set as TRUE
# console_outputs <- TRUE

#-------------------------------------------------------------------------------
# save console outputs if `console_outputs == TRUE`
# if (console_outputs) {
#   file_name <- stringr::str_glue(
#     "ind_{year}_console_{format(Sys.time(), '%Y-%m-%d_%H-%M-%S')}.txt"
#   )
#   file_path <- get_file_path(
#     ep_ind_console_path(),
#     file_name,
#     create = TRUE
#   )
#   con <- file(file_name, open = "wt")
#
#   # Redirect messages (including warnings and errors) to the file
#   sink(con, type = "output", split = TRUE)
#   sink(con, type = "message", append = TRUE)
# }

#-------------------------------------------------------------------------------
# Clean temporary files
# clean_temp_data(year, "ep")

# Read the episode file
episode_file <- arrow::read_parquet(get_slf_episode_path(year))

# Run the individual file and tests
create_individual_file(episode_file, year = year, write_temp_to_disk = write_temp_to_disk)
# %>%
# process_tests_individual_file(year = year)

#-------------------------------------------------------------------------------
# save console outputs if `console_outputs == TRUE`
# if (console_outputs) {
#   # Restore messages to the console and close the connection
#   sink(type = "message")
#   sink()
#
#   close(con)
#
#   extract_targets_time(file_name)
# }

#-------------------------------------------------------------------------------

## End of Script ##
