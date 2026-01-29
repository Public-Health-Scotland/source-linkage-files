################################################################################
# Name of file -  Run_episode_file_2425.R
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - March 2023
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description:
# Set up this script as a workbench job to create the SLF episode file:
#     * Source > Source as a workbench job
#     * Select Workbench job options, please specify 8CPU, 128GB
#     * Select the environment tab, please set the working directory where the
#       project is saved. Eg:
#             /conf/sourcedev/Jen/source-linkage-files
#     * Press start. This will now run the script as a workbench job
#
# The episode file will take approximately 2hrs to run.
# The output will be stored in year specific folders in:
# /conf/sourcedev/Source_Linkage_File_Updates/
#
################################################################################

# Setup-------------------------------------------------------------------------
library(createslf)

# Specify year to run
year <- "2425"

# Specify TRUE/FALSE for writing temporary files
write_temp_to_disk <- FALSE

# Specify TRUE/FALSE for saving the console output to disk
# Default set as TRUE
console_outputs <- TRUE

#-------------------------------------------------------------------------------
# save console outputs if `console_outputs == TRUE`
write_console_output(
  console_outputs = console_outputs,
  file_type = "episode",
  year = year
)

#-------------------------------------------------------------------------------
log_ep_message("start", year)

## Read processed data and create episode file
log_ep_message("read_data", year)

processed_data_list <- list(
  "ae" = read_file(get_source_extract_path(year, "ae")),
  "acute" = read_file(get_source_extract_path(year, "acute")),
  "at" = read_file(get_source_extract_path(year, "at")),
  "ch" = read_file(get_source_extract_path(year, "ch")),
  "cmh" = read_file(get_source_extract_path(year, "cmh")),
  "nrs_deaths" = read_file(get_source_extract_path(year, "deaths")),
  "district_nursing" = read_file(get_source_extract_path(year, "dn")),
  "gp_ooh" = read_file(get_source_extract_path(year, "gp_ooh")),
  "hc" = read_file(get_source_extract_path(year, "hc")),
  "homelessness" = read_file(get_source_extract_path(year, "homelessness")),
  "maternity" = read_file(get_source_extract_path(year, "maternity")),
  "mental_health" = read_file(get_source_extract_path(year, "mh")),
  "outpatients" = read_file(get_source_extract_path(year, "outpatients")),
  "pis" = read_file(get_source_extract_path(year, "pis")),
  "sds" = read_file(get_source_extract_path(year, "sds"))
)

log_ep_message("creating", year)

create_episode_file(processed_data_list,
                    year = year,
                    write_temp_to_disk = write_temp_to_disk
) %>%
  process_tests_episode_file(year = year)

log_ep_message("complete", year)

#-------------------------------------------------------------------------------
## End of Script ##
