# Name of file -  "dummy_targets.R"
#
# Description:
#       A small target example to run as test for BYOC.
#
#       To run the targets pipeline, please use:
#       targets::tar_make(script = 'dummy_targets.R',
#                         store = store_path)
#


library(logger)
library(targets) # main package required
library(tarchetypes) # support for targets
library(crew) # support for parallel processing
library(dplyr)
library(createslf)

# Stage 1 - Setup targets -----------------------------------------

## Set up BYOC_MODE ----
BYOC_MODE <- Sys.getenv("BYOC_MODE")
BYOC_MODE <- dplyr::case_when(
  BYOC_MODE %in% c("TRUE", "T", "true", "True") ~ TRUE,
  BYOC_MODE %in% c("FALSE", "F", "false", "False") ~ FALSE,
  TRUE ~ NA
)

run_id <- Sys.getenv("run_id")
run_date_time <- Sys.getenv("run_date_time")
denodo_dsn <- Sys.getenv("denodo_dsn")


if (isTRUE(BYOC_MODE)) {
  logger::log_info("targets file location on Denodo")
} else {
  logger::log_info("targets file location is local")
}

log_threshold(INFO)

## Set up targets ----
# Set crew controller for parallel processing
controller <- crew::crew_controller_local(
  name = "my_controller",
  # Specify 6 workers for parallel processing - works with 8CPU, 128GB posit session
  workers = 6,
  seconds_idle = 30
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
    parquet = tar_resources_parquet(compression = "zstd")
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

years_to_run <- "1920"

# Stage 2 - Set up targets ----
list(
  tar_rds(write_to_disk, TRUE),
  tar_map(
    list(year = years_to_run),

    ### Maternity (SMR02) Acitivity-----------------------------------------------
    # READ - Maternity
    tar_target(
      # Target name
      maternity_data,
      read_extract_maternity(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        file_path = get_boxi_extract_path(year, type = "maternity", BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - Maternity
    tar_target(
      # Target name
      source_maternity_extract,
      # Function
      process_extract_maternity(
        maternity_data,
        year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Mental Health (SMR02) Activity--------------------------------------------
    # READ - Mental Health
    tar_target(
      mental_health_data,
      read_extract_mental_health(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        file_path = get_boxi_extract_path(
          year = year,
          type = "mh",
          BYOC_MODE = BYOC_MODE
        ),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - Mental Health
    tar_target(
      # Target name
      source_mental_health_extract,
      process_extract_mental_health(
        mental_health_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### IT CHI deaths Activity--------------------------------------------
    # READ - IT CHI deaths------
    tar_target(
      # Target name
      it_chi_deaths_extract,
      read_it_chi_deaths(
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        file_path = get_it_deaths_path(),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - IT CHI deaths------
    tar_target(
      # Target name
      it_chi_deaths_data,
      # Function
      process_it_chi_deaths(
        data = it_chi_deaths_extract,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      ),
    )
  )
)

## End of Targets pipeline ##
