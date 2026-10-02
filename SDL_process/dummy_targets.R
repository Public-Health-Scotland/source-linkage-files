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

  # ============================================================================.
  ## Stage 2.1 - Look-ups ----
  # ============================================================================.

  ### Care Home Name Lookup ----------------------------------------------------
  # (Demographics, Care Home)
  # GET - Care Home Name Lookup
  tar_target(
    # Target name
    slf_ch_name_lookup_data,
    # Function
    get_slf_ch_name_lookup_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  ### Local Authority Open Data ------------------------------------------------
  # (Homelessness, Home Care Costs)
  # GET - Local Authority Open Data
  tar_target(
    # Target name
    la_code_opendata,
    # Function
    get_la_code_opendata_lookup(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  ### Scottish Postcode Directory ----------------------------------------------
  # (Demographics, Care Home, Postcode Lookup, GP Practice Lookup)
  # GET - Scottish Postcode Directory
  tar_target(
    # Target name
    spd_data,
    # Function
    get_spd_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  ### UK Postcode Directory ----------------------------------------------------
  # (Demographics, Care Home)
  # GET - UK Postcode Directory
  tar_target(
    # Target name
    uk_postcode_data,
    # Function
    get_uk_postcode_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),

  # ============================================================================.
  ## Stage 2.2 Cost Look-ups ----
  # ============================================================================.

  ### Care Home Costs ----------------------------------------------------------
  # GET - Care HomeCosts
  tar_target(
    # Target name
    ch_raw_costs,
    # Function
    get_ch_raw_costs_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE,
    ),
  ),
  # PROCESS - Care Home Costs
  tar_target(
    # Target name
    ch_cost_lookup,
    # Function
    process_costs_care_homes(
      ch_raw_costs = ch_raw_costs,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ### Home Care Costs ----------------------------------------------------------
  # GET - Home Care Costs
  tar_target(
    # Target name
    hc_raw_costs,
    # Function
    get_hc_raw_costs_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE,
    ),
  ),
  # PROCESS - Home Care Costs
  tar_target(
    # Target name
    hc_cost_lookup,
    # Function
    process_costs_home_care(
      hc_raw_costs = hc_raw_costs,
      lca_data = la_code_opendata,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    ),
  ),

  # ============================================================================.
  ## Stage 2.3 Non Year-Specific Targets ----
  # ============================================================================.

  ### Postcode Lookup ----------------------------------------------------------
  # GET - HSCP Locality Data
  tar_target(
    # Target name
    locality_data,
    # Function
    get_locality_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # GET - SIMD Data
  tar_target(
    # Target name
    simd_data,
    # Function
    get_simd_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # PROCESS - Postcode Lookup
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

  ### GP Lookup ----------------------------------------------------------------
  # GET - GP Practice Open Data
  tar_target(
    # Target name
    gpprac_opendata,
    # Function
    get_gpprac_opendata(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # GET - GP Practice Reference File
  tar_target(
    # Target name
    gpprac_ref_data,
    # Function
    get_gpprac_ref_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # PROCESS - GP Lookup
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
    )
  ),

  ### IT CHI Deaths ------------------------------------------------------------
  # READ - IT CHI Deaths
  tar_target(
    # Target name
    it_chi_deaths_extract,
    # Function
    read_it_chi_deaths(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # PROCESS - IT CHI Deaths
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
  # PROCESS - Refined Deaths
  tar_target(
    # Target name
    refined_death_data,
    # Function
    process_refined_death(
      it_chi_deaths = it_chi_deaths_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  # ============================================================================.
  ## Stage 2.4 - Social Care All Years ----
  # ============================================================================.

  ### All SC Alarms Telecare ---------------------------------------------------
  # READ - All SC Alarms Telecare
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
  # PROCESS - All SC Alarms Telecare
  tar_target(
    # Target name
    all_at,
    # Function
    process_sc_all_alarms_telecare(
      data = all_at_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ### All SC Care Homes --------------------------------------------------------
  # READ - All SC Care Homes
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
  # PROCESS - All SC Care Homes
  tar_target(
    # Target name
    all_care_home,
    # Function
    process_sc_all_care_home(
      data = all_care_home_extract,
      sc_demog_lookup = sc_demog_lookup,
      refined_death = refined_death_data,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time,
      ch_name_lookup_path = slf_ch_name_lookup_path,
      spd_data = spd_data,
      write_to_disk = write_to_disk
    )
  ),

  ### All SC Demographics ------------------------------------------------------
  # READ - All SC Demographics
  tar_target(
    # Target name
    sc_demog_data,
    # Function
    read_lookup_sc_demographics(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    cue = tar_cue_age(
      name = sc_demog_data,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # PROCESS - All SC Demographics
  tar_target(
    # Target name
    sc_demog_lookup,
    # Function
    process_lookup_sc_demographics(
      data = sc_demog_data,
      all_care_home_extract = all_care_home_extract,
      spd_data = spd_data,
      uk_postcode_data = uk_postcode_data,
      ch_name_lookup = slf_ch_name_lookup_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ### All SC Home Care ---------------------------------------------------------
  # READ - All SC Home Care
  tar_target(
    # Target name
    all_home_care_extract,
    # Function
    read_sc_all_home_care(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    ),
    cue = tar_cue_age(
      name = all_home_care_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # PROCESS - All SC Home Care
  tar_target(
    # Target name
    all_home_care,
    # Function
    process_sc_all_home_care(
      data = all_home_care_extract,
      sc_demog_lookup = sc_demog_lookup,
      home_care_costs = hc_cost_lookup,
      BYOC_MODE = BYOC_MODE,
      write_to_disk = write_to_disk
    )
  ),

  ### All SC Self-Directed-Support (SDS) ---------------------------------------
  # READ - All SC Self-Directed-Support (SDS)
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
  # PROCESS - All SC Self-Directed-Support (SDS)
  tar_target(
    # Target name
    all_sds,
    # Function
    process_sc_all_sds(
      data = all_sds_extract,
      sc_demog_lookup = sc_demog_lookup,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time,
      write_to_disk = write_to_disk
    )
  ),

  # ============================================================================.
  ## Stage 2.5 - Year Specific Targets ----
  # ============================================================================.

  tar_map(
    list(year = years_to_run),

    ### NRS Deaths -------------------------------------------------------------
    # PROCESS - NRS Deaths
    tar_target(
      # Target name
      source_nrs_deaths_extract,
      # Function: Use this anonymous function with redundant but necessary refined_death
      # to make sure reading year-specific NRS deaths extracts after it is produced
      (\(year, refined_death_data) {
        createslf::read_file(get_source_extract_path(year, "nrs_deaths", BYOC_MODE = BYOC_MODE)) %>%
          as.data.frame()
      })(year, refined_death_data)
    ),

    ### SC Alarms Telecare -----------------------------------------------------
    # PROCESS - SC Alarms Telecare
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

    ### SC Care Home -----------------------------------------------------------
    # PROCESS - SC Care Home
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

    ### SC Client Lookup -------------------------------------------------------
    # READ - SC Client Lookup
    tar_target(
      # Target name
      sc_client_data,
      # Function
      read_lookup_sc_client(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - SC Client Lookup
    tar_target(
      # Target name
      sc_client_lookup,
      # Function
      process_lookup_sc_client(
        data = sc_client_data,
        year = year,
        sc_demographics = sc_demog_lookup,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### SC Home Care -----------------------------------------------------------
    # PROCESS - SC Home Care
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

    ### SC Self-Directed Support (SDS) -----------------------------------------
    # PROCESS - SC Self-Directed Support (SDS)
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
    )
  )
)

########################### End of Targets Pipeline ############################.
