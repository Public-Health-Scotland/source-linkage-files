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

  ### Lookup data -------------

  #### Locality data -------
  tar_target(
    # Target name
    locality_data,
    # Function
    get_locality_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE
    )
  ),
  #### SIMD data ---------------
  tar_target(
    # Target name
    simd_data,
    # Function
    get_simd_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE
    )
  ),
  #### SPD data  -------
  tar_target(
    # Target name
    spd_data,
    # Function
    get_spd_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  #### GP practice open data ---------
  tar_target(
    # Target name
    gpprac_opendata,
    # Function
    get_gpprac_opendata(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  #### GP Practice reference file -----
  tar_target(
    # Target name
    gpprac_ref_data,
    # Function
    get_gpprac_ref_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  #### Postcode lookup ------------
  # PROCESS - postcode lookup
  tar_target(
    # Target name
    source_pc_lookup,
    # Function
    process_lookup_postcode(
      spd_data = spd_data,
      simd_data = simd_data,
      locality_data = locality_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),
  #### GP Lookup-----
  # PROCESS - GP lookup
  tar_target(
    # Target name
    source_gp_lookup,
    # Function
    process_lookup_gpprac(
      gpprac_opendata = gpprac_opendata,
      gpprac_ref_data = gpprac_ref_data,
      spd_data = spd_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    ),
  ),
  # # TESTS - postcode lookup
  # tar_target(
  #   # Target name
  #   tests_source_pc_lookup,
  #   # Function
  #   process_tests_lookup_pc(source_pc_lookup)
  # ),

  #### Scottish postcode directory------
  tar_target(
    # Target name
    spd_data,
    # Function
    get_spd_data(BYOC_MODE = BYOC_MODE),
    format = "file"
  ),

  #### Update NHS UK postcode directory -----
  tar_target(
    # Target name
    uk_postcode_data,
    get_uk_postcode_data(BYOC_MODE = BYOC_MODE)
  ),

  #### Care home name look up------
  tar_target(
    slf_ch_name_lookup_data,
    get_slf_ch_name_lookup_data(BYOC_MODE = BYOC_MODE),
    format = "file"
  ),

  ### Cost lookups ----
  #### Care home costs------
  tar_target(
    # Target name
    ch_cost_lookup,
    # Function
    process_costs_care_homes(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  #### Home care costs------
  # lca data - phsopendata
  tar_target(
    # Target name
    lca_data,
    # Function
    get_lca_data(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE))
  ),

  # home care costs lookup
  tar_target(
    # Target name
    hc_cost_lookup,
    # Function
    process_costs_home_care(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      lca_data = lca_data,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    ),
    priority = 0.8
  ),

  ### Social Care, all years -----

  #### SC - Care Homes ----
  # READ - Care Homes
  tar_target(
    # Target name
    all_care_home_extract,
    # Function
    read_sc_all_care_home(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    cue = tar_cue_age(
      name = all_care_home_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # PROCESS - Care Homes
  tar_target(
    # Target name
    all_care_home,
    # Function
    process_sc_all_care_home(
      all_care_home_extract = all_care_home_extract,
      sc_demog_lookup = sc_demog_lookup,
      refined_death = refined_death_data,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time,
      ch_name_lookup_path = slf_ch_name_lookup_path,
      spd_data = spd_data,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),

  #### SC - demographics ----
  # READ - SC Demographics
  tar_target(
    # Target name
    sc_demog_data,
    # Function
    read_lookup_sc_demographics(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    cue = tar_cue_age(name = sc_demog_data, age = as.difftime(28.0, units = "days"))
  ),
  # PROCESS - SC Demographics
  tar_target(
    # Target name
    sc_demog_lookup,
    # Function
    process_lookup_sc_demographics(
      sc_demog_data,
      all_care_home_extract = all_care_home_extract,
      spd_data = spd_data,
      uk_postcode_data = uk_postcode_data,
      ch_name_lookup = slf_ch_name_lookup_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    ),
    priority = 0.9
  ),
  # TEST - SC Demographics
  # tar_target(
  #   # Target name
  #   tests_sc_demog_lookup,
  #   # Function
  #   process_tests_sc_demographics(sc_demog_lookup)
  # ),


  #### SC - Home Care, all year ----
  # READ - Home Care
  tar_target(
    all_home_care_extract,
    read_sc_all_home_care(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    cue = tar_cue_age(name = all_home_care_extract, age = as.difftime(28.0, units = "days"))
  ),
  # PROCESS - Home Care
  tar_target(
    # Target name
    all_home_care,
    # Function
    process_sc_all_home_care(
      all_home_care_extract,
      sc_demog_lookup = sc_demog_lookup,
      home_care_costs = hc_cost_lookup,
      BYOC_MODE = BYOC_MODE,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  # # TESTS - Home Care
  # tar_target(
  #   # Target name
  #   tests_sc_all_home_care,
  #   # Function
  #   process_tests_sc_all_hc_episodes(all_home_care)

  #### SC - Alarms Telecare  ---------------
  # READ - Alarms Telecare
  tar_target(
    # Target name
    all_at_extract,
    # Function
    read_sc_all_alarms_telecare(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    cue = tar_cue_age(
      name = all_at_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # PROCESS - Alarms Telecare
  tar_target(
    # Target name
    all_at,
    # Function
    process_sc_all_alarms_telecare(
      all_at_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    ),
    priority = 0.5
  ),
  # # TESTS - Alarms Telecare
  # tar_target(
  #   # Tests, LOOKUP series
  #   tests_sc_all_at,
  #   process_tests_sc_all_at_episodes(all_at)
  # ),

  #### SC - Self-Directed-Support (SDS)-------------
  # READ - SDS
  tar_target(
    # Target name
    all_sds_extract,
    # Function
    read_sc_all_sds(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    cue = tar_cue_age(
      name = all_sds_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # PROCESS - SDS
  tar_target(
    # Target name
    all_sds,
    # Function
    process_sc_all_sds(
      all_sds_extract,
      sc_demog_lookup = sc_demog_lookup,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  # TESTS - SDS
  tar_target(
    # Target name
    tests_sc_all_sds,
    # Function
    process_tests_sc_all_sds_episodes(all_sds)
  ),

  ## Stage 2.2 year specific targets ------
  tar_map(
    list(year = years_to_run),

      ### Social Care ----

      #### SC - Care Home (CH) Activity -----
      # READ - CH
      # Target: all_care_home passed to PROCESS CH

      # PROCESS - CH
      tar_target(
        # Target name
        source_sc_care_home,
        # Function
        process_extract_care_home(
          data = all_care_home,
          year = year,
          ch_costs = ch_cost_lookup,
          BYOC_MODE = BYOC_MODE,
          run_id = run_id,
          run_date_time = run_date_time,
          write_to_disk = write_to_disk
        )
      ),

      #### SC - Home Care (HC) Activity--------
      # READ - HC
      # Target: all_home_care passed to PROCESS HC

      # PROCESS - HC
      tar_target(
        # Target name
        source_sc_home_care,
        # Function
        process_extract_home_care(
          data = all_home_care,
          year = year,
          BYOC_MODE = BYOC_MODE,
          write_to_disk = write_to_disk
        )
      ),
      # # TESTS - HC
      # tar_target(
      #   # Target name
      #   tests_home_care,
      #   # Function
      #   process_tests_home_care(
      #     data = source_sc_home_care,
      #     year = year
      #   )
      # ),

      #### SC - Alarms Telecare (AT) Activity-----
      # READ - AT
      # Target: all_at passed to PROCESS AT

      # PROCESS - AT
      tar_target(
        # Target name
        source_sc_alarms_tele,
        # Function
        process_extract_alarms_telecare(
          data = all_at,
          year = year,
          write_to_disk = write_to_disk,
          BYOC_MODE = BYOC_MODE,
          run_id = run_id,
          run_date_time = run_date_time
        )
      ),
      # # TESTS - AT
      # tar_target(
      #   # Target name
      #   tests_alarms_telecare,
      #   # Function
      #   process_tests_alarms_telecare(
      #     data = source_sc_alarms_tele,
      #     year = year
      #   )
      # ),

      #### SC - Self-Directed Support (SDS) Activity--------
      # READ - SDS
      #
      # Target: all_sds passed to PROCESS SDS
      #
      # PROCESS - SDS
      tar_target(
        # Target name
        source_sc_sds,
        # Function
        process_extract_sds(
          data = all_sds,
          year = year,
          BYOC_MODE = BYOC_MODE,
          run_id = run_id,
          run_date_time = run_date_time,
          write_to_disk = write_to_disk
        )
      ),
      # TESTS - SDS
      tar_target(
        # Target name
        tests_sds,
        # Function
        process_tests_sds(
          data = source_sc_sds,
          year = year
        )
      )
    )
  )
)
## End of Targets pipeline ##
