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
  tar_rds(write_to_disk, TRUE),

  ## Stage 2.1 non year-specific targets ----

  ### Lookup data ---------------
  #### Local Authority open data -----
  # used by homelessness
  tar_target(
    # Target name
    la_code_opendata,
    # Function
    get_la_code_opendata_lookup(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  #### SG homelessness publication data ----
  tar_target(
    sg_pub_data,
    get_sg_homelessness_pub_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  ### IT CHI deaths Activity ----
  # READ - IT CHI deaths
  tar_target(
    # Target name
    it_chi_deaths_extract,
    read_it_chi_deaths(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # PROCESS - IT CHI deaths
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
    )
  ),

  ### Long-Term Conditions (LTCs) Activity ----
  # READ - LTCs
  tar_target(
    ltc_data,
    read_lookup_ltc(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  ### NRS BOXI Deaths ----
  # PROCESS - Refined deaths - combine all NRS death data into a lookup
  tar_target(
    refined_death_data,
    process_refined_death(
      it_chi_deaths = it_chi_deaths_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ### GP Out of Hours costs------
  tar_target(
    # Target name
    gp_ooh_cost_lookup,
    # Function
    process_costs_gp_ooh(
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ## Stage 2.2 year specific targets ------
  tar_map(
    list(year = years_to_run),

    ### Accident & Emergency (AE2) activity --------------
    # READ - A&E
    tar_target(
      # Target name
      ae_data,
      # Function
      read_extract_ae(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # READ - A&E CUP
    tar_target(
      # Target name
      ae_cup_file,
      # Function
      read_extract_ae_cup(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - A&E
    tar_target(
      # Target name
      source_ae_extract,
      # Function
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

    ### Maternity (SMR02) Activity ----
    # READ - Maternity
    tar_target(
      # Target name
      maternity_data,
      read_extract_maternity(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
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

    ### Mental Health (SMR02) Activity ----
    # READ - Mental Health
    tar_target(
      mental_health_data,
      read_extract_mental_health(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
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


    ### Death Activity ----
    # PROCESS - Deaths
    tar_target(
      # Target name
      source_nrs_deaths_extract,
      # use this anonymous function with redundant but necessary refined_death
      # to make sure reading year-specific NRS deaths extracts after it is produced
      (\(year, refined_death_data) {
        arrow::read_parquet(get_source_extract_path(year, "nrs_deaths", BYOC_MODE = BYOC_MODE)) %>%
          as.data.frame()
      })(year, refined_death_data)
    ),
    # TESTS - Deaths
    tar_target(
      # Target name
      tests_source_nrs_deaths_extract,
      # Function
      process_tests_nrs_deaths(
        source_nrs_deaths_extract,
        year
      )
    ),

    ### GP Out of Hours (GP OOH) Activity--------------
    # GP Out of Hours ALL
    tar_qs(
      # Target name
      ooh_data,
      # Function
      read_extract_gp_ooh(
        year = year,
        BYOC_MODE = BYOC_MODE,
        denodo_connect = NULL
      )
    ),
    # GP Out of Hours CUP
    tar_target(
      gp_ooh_cup,
      read_extract_gp_ooh_cup(
        year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - GP OOH CUP
    tar_target(
      # Target name
      source_ooh_extract,
      # Function
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
    # # TESTS - GP OOH
    # tar_target(
    #   # Target name
    #   tests_source_ooh_extract,
    #   # Function
    #   process_tests_gp_ooh(
    #     source_ooh_extract,
    #     year
    #   )
    # ),

    ### Long-Term Conditions (LTCs) Activity----------------
    # PROCESS - LTCs
    tar_target(
      # Target name
      source_ltc_lookup,
      # Function
      process_lookup_ltc(
        ltc_data,
        year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # # TESTS - LTCs
    # tar_target(
    #   # Target name
    #   tests_ltc,
    #   # Function
    #   process_tests_ltcs(
    #     source_ltc_lookup,
    #     year
    #   )
    # ),

    ### Homelessness (HL1) Activity ----
    # READ - Homelessness
    tar_target(
      # Target name
      homelessness_data,
      # Function
      read_extract_homelessness(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
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
        la_code_lookup = la_code_opendata,
        sg_pub_data = sg_pub_data,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # # TESTS - Homelessness
    # tar_target(
    #   # Target name
    #   tests_source_homelessness_extract,
    #   # Function
    #   process_tests_homelessness(
    #     source_homelessness_extract,
    #     year
    #   )
    # ),
    ### Homelessness lookup------
    tar_target(
      # Target name
      homelessness_lookup,
      # Function
      create_homelessness_lookup(
        year,
        homelessness_data = source_homelessness_extract
      )
    ),

    ### Delayed Discharges Activity---------------------
    # READ - Delayed Discharges
    tar_target(
      # Target name
      dd_data,
      # Function
      read_extract_delayed_discharges(
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - Delayed Discharges
    tar_target(
      # Target name
      source_dd_extract,
      # Function
      process_extract_delayed_discharges(
        dd_data,
        year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Outpatients (SMR00) Activity ------
    # READ - Outpatients
    tar_target(
      # Target name
      outpatients_data,
      # Function
      read_extract_outpatients(
        year = year,
        BYOC_MODE = BYOC_MODE,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE)
      )
    ),
    # PROCESS - Outpatients
    tar_target(
      # Target name
      source_outpatients_extract,
      # Function
      process_extract_outpatients(
        data = outpatients_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    )
  )
)
## End of Targets pipeline ##
