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
  resources = tar_resources(parquet = tar_resources_parquet(compression = "zstd")),
  # error - if an error occurs, the pipeline will continue
  error = "stop",
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
  tar_rds(
    write_to_disk,
    TRUE
  ),

  ## Non-year-specific dependencies --------------------------------

  # Homelessness: Local Authority lookup
  tar_target(
    la_code_opendata,
    get_la_code_opendata_lookup(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  # Homelessness: Scottish Government publication data
  tar_target(
    sg_pub_data,
    get_sg_homelessness_pub_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  # GP OOH cost lookup
  tar_target(
    gp_ooh_cost_lookup,
    process_costs_gp_ooh(
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  # LTC source data
  tar_target(
    ltc_data,
    read_lookup_ltc(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  ## Year-specific targets ------------------------------------------

  tar_map(
    values = list(year = years_to_run),

    ## A&E ----------------------------------------------------------

    tar_target(
      ae_data,
      read_extract_ae(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),

    tar_target(
      ae_cup_file,
      read_extract_ae_cup(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),

    tar_target(
      source_ae_extract,
      process_extract_ae(
        data = ae_data,
        year = year,
        ae_cup_file = ae_cup_file,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ## Delayed Discharges -------------------------------------------

    tar_target(
      dd_data,
      read_extract_delayed_discharges(
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),

    tar_target(
      source_dd_extract,
      process_extract_delayed_discharges(
        dd_data,
        year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ## GP Out of Hours ----------------------------------------------

    tar_qs(
      ooh_data,
      read_extract_gp_ooh(
        year = year,
        BYOC_MODE = BYOC_MODE,
        denodo_connect = NULL
      )
    ),

    tar_target(
      gp_ooh_cup,
      read_extract_gp_ooh_cup(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),

    tar_target(
      source_ooh_extract,
      process_extract_gp_ooh(
        year = year,
        data_list = ooh_data,
        gp_ooh_cup = gp_ooh_cup,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ## Long-Term Conditions -----------------------------------------

    tar_target(
      source_ltc_lookup,
      process_lookup_ltc(
        ltc_data,
        year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ## Homelessness -------------------------------------------------

    tar_target(
      homelessness_data,
      read_extract_homelessness(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),

    tar_target(
      source_homelessness_extract,
      process_extract_homelessness(
        data = homelessness_data,
        year = year,
        write_to_disk = write_to_disk,
        la_code_lookup = la_code_opendata,
        sg_pub_data = sg_pub_data,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    tar_target(
      homelessness_lookup,
      create_homelessness_lookup(
        year,
        homelessness_data = source_homelessness_extract
      )
    )
  )
)
## End of Targets pipeline ##
