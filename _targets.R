# Name of file -  "_targets.R"
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - July 2024
# Written/run on - R Posit
# Version of R - 4.5.1
#
# Description:
#       This script is the main set up for processing the SLF extracts.
#       The targets file links together each "read_extract_XXX" and
#       "process_extract_XXX" and writes the output to disk ready to pass to:
#       /Run_SLF_Files_manually/run_episode_file_XXX.R
#
#       To make adjustments to the targets pipeline please edit this script.
#
#       To run the targets pipeline please see the script:
#       /Run_SLF_Files_targets/run_all_targets.R

# Stage 0 - Setup BYOC_MODE in targets -----------------------------------------
BYOC_MODE <- Sys.getenv("BYOC_MODE")
BYOC_MODE <- dplyr::case_when(
  BYOC_MODE %in% c("TRUE", "T", "true", "True")  ~ TRUE,
  BYOC_MODE %in% c("FALSE", "F", "false", "False") ~ FALSE,
  TRUE ~ NA
)

#### remember to set up denodo_connect mode whenever you feel reasonable
####

if (BYOC_MODE) {
  targets::tar_config_set(store = createslf::denodo_output_path())
  logger::log_info("targets file location on Denodo")
} else{
  targets::tar_config_set(store = "/conf/sourcedev/Source_Linkage_File_Updates/_targets")
  logger::log_info("targets file location is local")
}

# Stage 1 - Set up----
# Load libraries
library(targets) # main package required
library(tarchetypes) # support for targets
library(crew) # support for parallel processing

options(readr.read_lazy = TRUE)

# Set crew controller for parallel processing
controller <- crew::crew_controller_local(
  name = "my_controller",
  # Specify number of CPU (workers) for parallel processing
  # works with 8CPU, 128GB posit session if local
  # workers = 6,
  seconds_idle = 3
)

# Targets options
# For more info, please see: https://docs.ropensci.org/targets/reference/tar_option_set.html
tar_option_set(
  # imports - for tracking everything in the createslf package
  imports = "createslf",
  # packages - for tracking everything in the createslf package
  packages = "createslf",
  # garbage collection - for maintaining each r process independently
  garbage_collection = TRUE,
  # format - default is parquet format
  format = "parquet",
  resources = tar_resources(
    parquet = tar_resources_parquet(compression = "zstd"),
    qs = tar_resources_qs(preset = "high")
  ),
  # error - if an error occurs, the pipeline will continue
  error = "continue",
  # storage - the worker saves/uploads the value.
  storage = "worker",
  # retrieval - the worker loads the target's dependencies.
  retrieval = "worker",
  # memory - default option: the target stays in memory until the end of the pipeline
  memory = "persistent",
  # controller - A controller or controller group object produced by the crew R package
  controller = controller
)

# Run all the R scripts in a directory in the environment specified.
tar_source()

# specify years to run
# years_to_run() is found in 00-update_refs.R
# TODO: update this using the control sheet when the control sheet is ready
years_to_run <- createslf::years_to_run()

# Stage 2 - Set up targets ----
## Phase I, all years ----
list(
  tar_rds(test_mode, TRUE),
  tar_rds(write_to_disk, TRUE),


  ## Phase II, year specific ----
  # Set up for reading each file and map over years
  tar_map(
    list(year = years_to_run),
    tar_rds(
      compress_extracts,
      gzip_files(year),
      priority = 1.0,
      cue = tar_cue_age(name = compress_extracts, age = as.difftime(7.0, units = "days"))
    ),
    ### PROCESS YEAR SPECIFIC EXTRACTS----
    #
    # READ data
    # PROCESS data
    # TESTS - output tests

    #### Homelessness (HL1) Activity-----------------------------------------------
    # READ - Homelessness
    tar_file_read(
      # Target name
      homelessness_data,
      get_boxi_extract_path(year, type = "homelessness"),
      # Function
      read_extract_homelessness(
        year = year,
        denodo_connect = denodo_connect,
        !!.x,
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - Homelessness
    tar_target(
      # Target name
      source_homelessness_extract,
      # Function
      process_extract_homelessness(
        data = homelessness_data,
        year = year,
        write_to_disk = write_to_disk,
        la_code_lookup = read_file("la_code_lookup.parquet"),
        sg_pub_data = read_file("sg_pub_data.parquet"),
        BYOC_MODE = BYOC_MODE
      )
    )
  )
)

## End of Targets pipeline ##
