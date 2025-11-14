################################################################################
# Name of file -  Run_individual_file_1920.R
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
year <- "1920"

# Specify TRUE/FALSE for writing temporary files
write_temp_to_disk <- FALSE

# Specify TRUE/FALSE for saving the console output to disk
# Default set as TRUE
console_outputs <- TRUE

# #-------------------------------------------------------------------------------
# # save console outputs if `console_outputs == TRUE`
if (console_outputs) {
  update <- latest_update()

  con_output_dir <- "/conf/sourcedev/Source_Linkage_File_Updates/_console_output/"

  file_name <- stringr::str_glue(
    "ind_{year}_{update}_update.txt"
  )
  file_path <- file.path(con_output_dir, file_name)

  con <- file(file_path, open = "wt")

  sink(con, type = "output", split = TRUE)
  sink(con, type = "message", append = TRUE)

  on.exit({
    sink(type = "message")
    sink(type = "output")
    close(con)
    cat("\n✓ Console output saved to:", file_path, "\n")
  }, add = TRUE)
}

#-------------------------------------------------------------------------------
# Clean temporary files
# clean_temp_data(year, "ep")

# Read the episode file
episode_file <- arrow::read_parquet(get_slf_episode_path(year))

# Run the individual file and tests
create_individual_file(episode_file, year = year, write_temp_to_disk = write_temp_to_disk) %>%
  process_tests_individual_file(year = year)

#-------------------------------------------------------------------------------

## End of Script ##
