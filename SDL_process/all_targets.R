################################################################################ .
# Name of file -  "all_targets.R"
#
# Description:
#       This stores all targets objects for BYOC.
#       Keep building this on.
################################################################################ .

library(logger)
library(targets) # main package required
library(tarchetypes) # support for targets
library(crew) # support for parallel processing
library(dplyr)
library(createslf)

################################################################################ .
# Stage 1 - Setup targets ----
################################################################################ .

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

# Define years
years_to_run <- "1920"

################################################################################ .
# Stage 2 - Run Targets ----
################################################################################ .

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

  ### Readcode Lookup ----------------------------------------------------------
  # (GP OOH Diagnosis)
  # GET - Readcode Lookup
  tar_target(
    # Target name
    readcode_lookup,
    # Function
    get_readcode_lookup(
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

  ### SG Homelessness Publication Data -----------------------------------------
  # (Homelessness)
  # GET - SG Homelessness Publication Data
  tar_target(
    # Target name
    sg_pub_data,
    # Function
    get_sg_homelessness_pub_data(
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
      ch_costs_data = ch_raw_costs,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ### District Nursing Costs ---------------------------------------------------
  # GET - District Nursing Costs
  tar_target(
    # Target name
    dn_raw_costs,
    # Function
    get_dn_raw_costs_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # GET - District Nursing Contacts
  tar_target(
    # Target name
    dn_contacts,
    # Function
    get_dn_contacts_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # GET - HSCP Population
  tar_target(
    # Target name
    hscp_population,
    # Function
    get_hscp_pop_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # PROCESS - District Nursing Costs
  tar_target(
    # Target name
    dn_cost_lookup,
    # Function
    process_costs_dn(
      dn_raw_costs = dn_raw_costs,
      dn_contacts = dn_contacts,
      hscp_population = hscp_population,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ### GP Out of Hours Costs ----------------------------------------------------
  # GET - GP Out of Hours Costs
  tar_target(
    # Target name
    gp_ooh_raw_costs,
    # Function
    get_gp_ooh_raw_costs_data(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # PROCESS - GP Out of Hours Costs
  tar_target(
    # Target name
    gp_ooh_cost_lookup,
    # Function
    process_costs_gp_ooh(
      ooh_raw_costs = gp_ooh_raw_costs,
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
      hc_costs_raw = hc_raw_costs,
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
  # TEST - Postcode Lookup
  tar_target(
    # Target name
    tests_source_pc_lookup,
    # Function
    process_tests_lookup_pc(
      data = source_pc_lookup,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  ### GP Lookup ----------------------------------------------------------------
  # GET - GP Practice Cluster Information
  tar_target(
    # Target name
    gpprac_cluster,
    # Function
    get_gpprac_cluster(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
    )
  ),
  # GET - GP Practice Geography Labels
  tar_target(
    # Target name
    geography_labels,
    # Function
    get_geography_labels(
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
  # PROCESS - GP Practice Open Data
  tar_target(
    # Target name
    gpprac_opendata,
    # Function
    process_gpprac_opendata(
      gpprac_cluster = gpprac_cluster,
      geography_labels = geography_labels,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
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
  # TEST - GP Lookup
  tar_target(
    # Target name
    tests_source_gp_lookup,
    # Function
    process_tests_lookup_gpprac(
      data = source_gp_lookup,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
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
  # TEST - IT CHI Deaths
  tar_target(
    # Target name
    tests_it_chi_deaths,
    # Function
    process_tests_it_chi_deaths(
      data = it_chi_deaths_data,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
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

  ### Long-Term Conditions (LTCs) ----------------------------------------------
  # READ - Long-Term Conditions (LTCs)
  tar_target(
    # Target name
    ltc_data,
    # Function
    read_lookup_ltc(
      denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
      BYOC_MODE = BYOC_MODE
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
  # TEST - All SC Alarms Telecare
  tar_target(
    # Target name
    tests_sc_all_at,
    # Function
    process_tests_sc_all_at_episodes(
      data = all_at,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
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
      uk_pc_directory = uk_postcode_data,
      ch_name_lookup = slf_ch_name_lookup_data,
      spd_data = spd_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),
  # TEST - All SC Care Homes
  tar_target(
    # Target name
    tests_all_care_home,
    # Function
    process_tests_sc_all_ch_episodes(
      data = all_care_home,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time
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
      uk_pc_directory = uk_postcode_data,
      ch_name_lookup = slf_ch_name_lookup_data,
      spd_data = spd_data,
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),
  # TEST - All SC Demographics
  tar_target(
    # Target name
    tests_sc_demog_lookup,
    # Function
    process_tests_sc_demographics(
      data = sc_demog_lookup,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
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
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),
  # TEST - All SC Home Care
  tar_target(
    # Target name
    tests_sc_all_home_care,
    # Function
    process_tests_sc_all_hc_episodes(
      data = all_home_care,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time
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
      write_to_disk = write_to_disk,
      BYOC_MODE = BYOC_MODE,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),
  # TESTS - All SC Self-Directed-Support (SDS)
  tar_target(
    # Target name
    tests_sc_all_sds,
    # Function
    process_tests_sc_all_sds_episodes(
      data = all_sds,
      BYOC_MODE = BYOC_MODE,
      update = previous_update(),
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time
    )
  ),

  # ============================================================================.
  ## Stage 2.5 - Year Specific Targets ----
  # ============================================================================.

  tar_map(
    list(year = years_to_run),

    ### Accident & Emergency (AE2) ---------------------------------------------
    # READ - Accident & Emergency (AE2)
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
    # READ - Accident & Emergency CUP
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
    # PROCESS - Accident & Emergency (AE2)
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
    # TEST - Accident & Emergency (AE2)
    tar_target(
      # Target name
      tests_source_ae_extract,
      # Function
      process_tests_ae(
        data = source_ae_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Acute (SMR01) ----------------------------------------------------------
    # READ - Acute
    tar_target(
      # Target name
      acute_data,
      # Function
      read_extract_acute(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # READ - Acute Cup
    tar_target(
      # Target name
      acute_cup_data,
      # Function
      read_extract_acute_cup(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - Acute
    tar_target(
      # Target name
      source_acute_extract,
      # Function
      process_extract_acute(
        data = acute_data,
        acute_cup_data = acute_cup_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - Acute
    tar_target(
      # Target name
      tests_source_acute_extract,
      # Function
      process_tests_acute(
        data = source_acute_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Community Mental Health (CMH) ------------------------------------------
    # READ - Community Mental Health (CMH)
    tar_target(
      # Target name
      cmh_data,
      # Function
      read_extract_cmh(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - Community Mental Health (CMH)
    tar_target(
      # Target name
      source_cmh_extract,
      # Function
      process_extract_cmh(
        data = cmh_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - Community Mental Health (CMH)
    tar_target(
      # Target name
      tests_source_cmh_extract,
      # Function
      process_tests_cmh(
        data = source_cmh_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Delayed Discharges  ----------------------------------------------------
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
        data = dd_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - Delayed Discharges
    tar_target(
      # Target name
      tests_source_dd_extract,
      # Function
      process_tests_delayed_discharges(
        data = source_dd_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### District Nursing -------------------------------------------------------
    # READ - District Nursing
    tar_target(
      # Target name
      dn_data,
      # Function
      read_extract_district_nursing(
        year = year,
        BYOC_MODE = BYOC_MODE,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE)
      )
    ),
    # PROCESS - District Nursing
    tar_target(
      # Target name
      source_dn_extract,
      # Function
      process_extract_district_nursing(
        data = dn_data,
        year = year,
        costs = dn_cost_lookup,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - District Nursing
    tar_target(
      # Target name
      tests_source_dn_extract,
      # Function
      process_tests_district_nursing(
        data = source_dn_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### GP Out of Hours (GP OOH) -----------------------------------------------
    # TODO: Suggest reading and processing OOH extracts separately before joining together
    # This is more consistent and easier to debug
    # READ - GP OOH Consultations
    tar_target(
      # Target name
      ooh_consultations_data,
      # Function
      read_extract_ooh_consultations(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # READ - GP OOH Diagnosis
    tar_target(
      # Target name
      ooh_diagnosis_data,
      # Function
      read_extract_ooh_diagnosis(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # READ - GP OOH Outcomes
    tar_target(
      # Target name
      ooh_outcomes_data,
      # Function
      read_extract_ooh_outcomes(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # READ - GP OOH CUP
    tar_target(
      # Target name
      gp_ooh_cup,
      # Function
      read_extract_gp_ooh_cup(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - GP Out of Hours
    tar_target(
      # Target name
      source_ooh_extract,
      # Function
      process_extract_gp_ooh(
        year = year,
        ooh_consultations = ooh_consultations_data,
        ooh_diagnosis = ooh_diagnosis_data,
        ooh_outcomes = ooh_outcomes_data,
        readcode_lookup = readcode_lookup,
        gp_ooh_cup = gp_ooh_cup,
        ooh_cost_lookup = gp_ooh_cost_lookup,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - GP Out of Hours
    tar_target(
      # Target name
      tests_source_ooh_extract,
      # Function
      process_tests_gp_ooh(
        data = source_ooh_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Homelessness (HL1) -----------------------------------------------------
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
    # TEST - Homelessness
    tar_target(
      # Target name
      tests_source_homelessness_extract,
      # Function
      process_tests_homelessness(
        data = source_homelessness_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # PROCESS - Homelessness Lookup
    tar_target(
      # Target name
      homelessness_lookup,
      # Function
      create_homelessness_lookup(
        year = year,
        homelessness_data = source_homelessness_extract
      )
    ),

    ### Long-Term Conditions (LTCs) --------------------------------------------
    # PROCESS - LTCs
    tar_target(
      # Target name
      source_ltc_lookup,
      # Function
      process_lookup_ltc(
        data = ltc_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - LTCs
    tar_target(
      # Target name
      tests_source_ltc_lookup,
      # Function
      process_tests_ltcs(
        data = source_ltc_lookup,
        year = year,
        BYOC_MODE = BYOC_MODE,
        update = previous_update(),
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Maternity (SMR02) ------------------------------------------------------
    # READ - Maternity
    tar_target(
      # Target name
      maternity_data,
      # Function
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
    # TEST - Maternity
    tar_target(
      # Target name
      tests_source_maternity_extract,
      # Function
      process_tests_maternity(
        data = source_maternity_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Mental Health (SMR04) --------------------------------------------------
    # READ - Mental Health
    tar_target(
      # Target name
      mental_health_data,
      # Function
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
      # Function
      process_extract_mental_health(
        mental_health_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - Mental Health
    tar_target(
      # Target name
      tests_source_mental_health_extract,
      # Function
      process_tests_mental_health(
        data = source_mental_health_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

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
    # TEST - NRS Deaths
    tar_target(
      # Target name
      tests_source_nrs_deaths_extract,
      # Function
      process_tests_nrs_deaths(
        data = source_nrs_deaths_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Outpatients (SMR00) ----------------------------------------------------
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
    ),
    # TEST - Outpatients
    tar_target(
      # Target name
      tests_source_outpatients_extract,
      # Function
      process_tests_outpatients(
        data = source_outpatients_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),

    ### Prescribing (PIS) ------------------------------------------------------
    # READ - Prescribing (PIS)
    tar_target(
      # Target name
      prescribing_data,
      # Function
      read_extract_prescribing(
        year = year,
        denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE
      )
    ),
    # PROCESS - Prescribing (PIS)
    tar_target(
      # Target name
      source_prescribing_extract,
      # Function
      process_extract_prescribing(
        data = prescribing_data,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
    ),
    # TEST - Prescribing (PIS)
    tar_target(
      # Target name
      tests_source_prescribing_extract,
      # Function
      process_tests_prescribing(
        data = source_prescribing_extract,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
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
        BYOC_MODE = BYOC_MODE
      )
    ),
    # TEST - SC Alarms Telecare
    tar_target(
      # Target name
      tests_alarms_telecare,
      # Function
      process_tests_alarms_telecare(
        data = source_sc_alarms_tele,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
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
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE
      )
    ),
    # TEST - SC Care Home
    tar_target(
      # Target name
      tests_care_home,
      # Function
      process_tests_care_home(
        data = source_sc_care_home,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
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
    # TEST - SC Client Lookup
    tar_target(
      # Target name
      tests_source_client_lookup,
      # Function
      process_tests_sc_client_lookup(
        data = sc_client_lookup,
        year = year,
        BYOC_MODE = BYOC_MODE,
        update = previous_update(),
        benchmark_run_id = benchmark_run_id,
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
    # TEST - SC Home Care
    tar_target(
      # Target name
      tests_home_care,
      # Function
      process_extract_home_care(
        data = all_home_care,
        year = year,
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE
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
        write_to_disk = write_to_disk,
        BYOC_MODE = BYOC_MODE
      )
    ),
    # TEST - SC Self-Directed Support (SDS)
    tar_target(
      # Target name
      tests_sds,
      # Function
      process_tests_sds(
        data = source_sc_sds,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )
    )
  )
)

########################### End of Targets Pipeline ############################.
