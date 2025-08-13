################################################################################
# Name of file -  "_targets.R"
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - July 2024
# Written/run on - R Posit
# Version of R - 4.1.2
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
#
################################################################################

# Stage 1 - Set up
#-------------------------------------------------------------------------------
# Load libraries
library(targets) # main package required
library(tarchetypes) # support for targets
library(crew) # support for parallel processing

options(readr.read_lazy = TRUE)

# Set crew controller for parallel processing
controller <- crew::crew_controller_local(
  name = "my_controller",
  # Specify 6 workers for parallel processing - works with 8CPU, 128GB posit session
  workers = 6,
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
years_to_run <- createslf::years_to_run()

# Stage 2 - Set up targets
#-------------------------------------------------------------------------------
## Phase I, all years ##
#-------------------------------------------------------------------------------
list(
  tar_rds(test_mode, TRUE),
  tar_rds(write_to_disk, TRUE),
  tar_rds(
    file_path_ext_clean,
    make_lowercase_ext(),
    priority = 1.0,
    cue = tar_cue_age(
      name = file_path_ext_clean,
      age = as.difftime(7.0, units = "days")
    )
  ),
  ## Lookup data ##-----------------------------------------------------------
  # GP practice open data------
  tar_target(
    # Target name
    gpprac_opendata,
    # Function
    get_gpprac_opendata()
  ),
  # Local Authority open data------
  tar_target(
    # Target name
    la_code_opendata,
    # Function
    get_la_code_opendata_lookup()
  ),
  # GP Practice reference file------
  tar_target(
    # Target name
    gpprac_ref_path,
    # Function
    get_gpprac_ref_path(),
    format = "file"
  ),
  # Locality path------
  tar_target(
    # Target name
    locality_path,
    # Function
    get_locality_path(),
    format = "file"
  ),
  # SIMD path------
  tar_target(
    # Target name
    simd_path,
    # Function
    get_simd_path(),
    format = "file"
  ),
  # Scottish postcode directory------
  tar_target(
    # Target name
    spd_path,
    # Function
    get_spd_path(),
    format = "file"
  ),
  # Update NHS UK postcode directory -----
  tar_target(
    # Target name
    uk_pc_list,
    update_uk_postcode_directory(),
    format = "file",
    cue = tar_cue_age(
      name = uk_pc_list,
      age = as.difftime(90, units = "days")
    )
  ),
  # Care home name look up------
  tar_target(
    slf_ch_name_lookup_path,
    get_slf_ch_name_lookup_path(),
    format = "file"
  ),
  ## Process Lookups ##-------------------------------------------------------
  # Social care demographics
  # READ - SC Demographics
  tar_target(
    # Target name
    sc_demog_data,
    # Function
    read_lookup_sc_demographics(),
    cue = tar_cue_age(
      name = sc_demog_data,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # PROCESS - SC Demographics
  tar_target(
    # Target name
    sc_demog_lookup,
    # Function
    process_lookup_sc_demographics(
      sc_demog_data,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  # TEST - SC Demographics
  tar_target(
    # Target name
    tests_sc_demog_lookup,
    # Function
    process_tests_sc_demographics(sc_demog_lookup)
  ),
  # IT deaths-----------------------------------------------------------------
  # READ - IT CHI deaths------
  tar_file_read(it_chi_deaths_extract,
    command = get_it_deaths_path(),
    read = read_it_chi_deaths(!!.x)
  ),
  # PROCESS - IT CHI deaths------
  tar_target(
    # Target name
    it_chi_deaths_data,
    # Function
    process_it_chi_deaths(
      data = it_chi_deaths_extract,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  # TESTS - IT CHI deaths------
  tar_target(
    # target name
    tests_it_chi_deaths,
    # Function
    process_tests_it_chi_deaths(it_chi_deaths_data)
  ),
  # GP Lookup-----------------------------------------------------------------
  # PROCESS - GP lookup------
  tar_target(
    # Target name
    source_gp_lookup,
    # Function
    process_lookup_gpprac(
      open_data = gpprac_opendata,
      gpprac_ref_path = gpprac_ref_path,
      spd_path = spd_path,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  # TESTS - GP lookup------
  tar_target(
    # Target name
    tests_source_gp_lookup,
    # Function
    process_tests_lookup_gpprac(source_gp_lookup)
  ),
  # Postcode lookup-----------------------------------------------------------
  # PROCESS - postcode lookup------
  tar_target(
    # Target name
    source_pc_lookup,
    # Function
    process_lookup_postcode(
      spd_path = spd_path,
      simd_path = simd_path,
      locality_path = locality_path,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  # TESTS - postcode lookup------
  tar_target(
    # Target name
    tests_source_pc_lookup,
    # Function
    process_tests_lookup_pc(source_pc_lookup)
  ),
  ### Cost Lookups -----------------------------------------------------------
  # Care home costs------
  tar_target(
    # Target name
    ch_cost_lookup,
    # Function
    process_costs_ch_rmd(),
    priority = 0.8
  ),
  # District nursing costs------
  tar_target(
    # Target name
    dn_cost_lookup,
    # Function
    process_costs_dn_rmd(),
    priority = 0.8
  ),
  # Home care costs------
  tar_target(
    # Target name
    hc_cost_lookup,
    # Function
    process_costs_hc_rmd(),
    priority = 0.8
  ),
  # GP Out of Hours costs------
  tar_target(
    # Target name
    gp_ooh_cost_lookup,
    # Function
    process_costs_gp_ooh_rmd()
  ),
  ### Social Care - 'All' data -----------------------------------------------
  # Alarms Telecare
  # READ - Alarms Telecare
  tar_target(
    # Target name
    all_at_extract,
    # Function
    read_sc_all_alarms_telecare(),
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
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  # TESTS - Alarms Telecare
  tar_target(
    # Tests, LOOKUP series
    tests_sc_all_at,
    process_tests_sc_all_at_episodes(all_at)
  ),
  # Home Care-----------------------------------------------------------------
  # READ - Home Care
  tar_target(
    all_home_care_extract,
    read_sc_all_home_care(),
    cue = tar_cue_age(
      name = all_home_care_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # PROCESS - Home Care
  tar_target(
    # Target name
    all_home_care,
    # Function
    process_sc_all_home_care(
      all_home_care_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  # TESTS - Home Care
  tar_target(
    # Target name
    tests_sc_all_home_care,
    # Function
    process_tests_sc_all_hc_episodes(all_home_care)
  ),
  # Care Homes----------------------------------------------------------------
  # READ - Care Homes
  tar_target(
    # Target name
    all_care_home_extract,
    # Function
    read_sc_all_care_home(),
    cue = tar_cue_age(
      name = all_care_home_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  # TODO - restructure section
  # Refined deaths
  tar_target(
    refined_death_data,
    process_refined_death(
      it_chi_deaths = it_chi_deaths_data,
      write_to_disk = write_to_disk
    )
  ),
  # PROCESS - Care Homes
  tar_target(
    # Target name
    all_care_home,
    # Function
    process_sc_all_care_home(
      all_care_home_extract,
      sc_demog_lookup = sc_demog_lookup,
      refined_death = refined_death_data,
      ch_name_lookup_path = slf_ch_name_lookup_path,
      spd_path = spd_path,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  # TESTS - Care Homes
  tar_target(
    # Target name
    tests_all_care_home,
    # Function
    process_tests_sc_all_ch_episodes(all_care_home)
  ),
  # Self-Directed-Support (SDS)-----------------------------------------------
  # READ - SDS
  tar_target(
    # Target name
    all_sds_extract,
    # Function
    read_sc_all_sds(),
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
  #-----------------------------------------------------------------------------
  ## Phase II, year specific ##
  #-----------------------------------------------------------------------------
  # Set up for reading each file and map over years
  tar_map(
    list(year = years_to_run),
    tar_rds(
      compress_extracts,
      gzip_files(year),
      priority = 1.0,
      cue = tar_cue_age(
        name = compress_extracts,
        age = as.difftime(7.0, units = "days")
      )
    ),
    #---------------------------------------------------------------------------
    # TODO - restructure section
    # READ EXTRACTS
    #---------------------------------------------------------------------------
    # Acute Extract
    # READ - Acute
    tar_file_read(
      # Target name
      acute_data,
      get_boxi_extract_path(year, type = "acute"),
      # Function
      read_extract_acute(year, !!.x)
    ),
    # A&E Extract---------------------------------------------------------------
    # READ - A&E
    tar_file_read(
      # Target name
      ae_data,
      get_boxi_extract_path(year, type = "ae"),
      # Function
      read_extract_ae(year, !!.x)
    ),
    # Community Mental Health (CMH) Extract-------------------------------------
    # READ - Community Mental Health (CMH)
    tar_file_read(
      # Target name
      cmh_data,
      get_boxi_extract_path(year, type = "cmh"),
      # Function
      read_extract_cmh(year, !!.x)
    ),
    # District Nursing Extract--------------------------------------------------
    # READ - District Nursing
    tar_file_read(
      # Target name
      dn_data,
      get_boxi_extract_path(year, type = "dn"),
      # Function
      read_extract_district_nursing(year, !!.x)
    ),
    # Homelessness Extract------------------------------------------------------
    # READ - Homelessness
    tar_file_read(
      # Target name
      homelessness_data,
      get_boxi_extract_path(year, type = "homelessness"),
      # Function
      read_extract_homelessness(year, !!.x)
    ),
    # Maternity Extract---------------------------------------------------------
    # READ - Maternity
    tar_file_read(
      # Target name
      maternity_data,
      get_boxi_extract_path(year, type = "maternity"),
      # Function
      read_extract_maternity(year, !!.x)
    ),
    # Mental Health Extract-----------------------------------------------------
    # READ - Mental Health
    tar_file_read(
      # Target name
      mental_health_data,
      get_boxi_extract_path(year, type = "mh"),
      # Function
      read_extract_mental_health(year, !!.x)
    ),
    ### TODO - Remove section - now done in refined deaths
    # tar_file_read(
    #   nrs_deaths_data,
    #   get_boxi_extract_path(year, type = "deaths"),
    #   read_extract_nrs_deaths(year, !!.x)
    # ),
    # Outpatients Extract-------------------------------------------------------
    # READ -Outpatients
    tar_file_read(
      # Target name
      outpatients_data,
      get_boxi_extract_path(year, type = "outpatient"),
      # Function
      read_extract_outpatients(year, !!.x)
    ),
    # Prescribing Extract-------------------------------------------------------
    # READ - Prescribing (PIS)
    tar_file_read(
      # Target name
      prescribing_data,
      get_it_prescribing_path(year),
      # Function
      read_extract_prescribing(year, !!.x)
    ),
    # GP Out of Hours Extract---------------------------------------------------
    # READ - GP Out of Hours diagnoses
    tar_target(
      # Target name
      diagnosis_data_path,
      get_boxi_extract_path(year = year, type = "gp_ooh-d"),
      format = "file"
    ),
    # READ - GP Out of Hours outcomes
    tar_target(
      # Target name
      outcomes_data_path,
      get_boxi_extract_path(year = year, type = "gp_ooh-o"),
      format = "file"
    ),
    # READ - GP Out of Hours consultations
    tar_target(
      consultations_data_path,
      get_boxi_extract_path(year = year, type = "gp_ooh-c"),
      format = "file"
    ),
    ## TODO - Restructure
    # READ - Acute CUP
    tar_target(
      # Target name
      acute_cup_path,
      get_boxi_extract_path(year, type = "acute_cup"),
      format = "file"
    ),
    ## TODO - Restructure
    # GP Out of Hours CUP
    tar_target(
      gp_ooh_cup_path,
      get_boxi_extract_path(year, type = "gp_ooh_cup"),
      format = "file"
    ),
    ## TODO - Restructure
    # GP Out of Hours ALL-------------------------------------------------------
    tar_qs(
      # Target name
      ooh_data,
      # Function
      read_extract_gp_ooh(
        year,
        diagnosis_data_path,
        outcomes_data_path,
        consultations_data_path
      )
    ),
    #---------------------------------------------------------------------------
    # TODO - RESTRUCTURE
    # PROCESS EXTRACTS
    #---------------------------------------------------------------------------
    # Acute (SMR01) Activity
    # PROCESS - Acute
    tar_target(
      # Target name
      source_acute_extract,
      # Function
      process_extract_acute(
        acute_data,
        year,
        acute_cup_path,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - Acute
    tar_target(
      # Target name
      tests_source_acute_extract,
      # Function
      process_tests_acute(
        source_acute_extract,
        year
      )
    ),
    # Accident & Emergency (AE2) activity --------------------------------------
    # PROCESS - A&E
    tar_target(
      # Target name
      source_ae_extract,
      # Function
      process_extract_ae(
        ae_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - A&E
    tar_target(
      # Target name
      tests_source_ae_extract,
      # Function
      process_tests_ae(
        source_ae_extract,
        year
      )
    ),
    # Community Mental Health (CMH) Activity------------------------------------
    # PROCESS - CMH
    tar_target(
      # Target name
      source_cmh_extract,
      # Function
      process_extract_cmh(
        cmh_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - CMH
    tar_target(
      # Target name
      tests_source_cmh_extract,
      # Function
      process_tests_cmh(
        source_cmh_extract,
        year
      )
    ),
    # Delayed Discharges Activity-----------------------------------------------
    # READ - Delayed Discharges
    tar_file_read(dd_data, get_dd_path(), read_extract_delayed_discharges(!!.x)),
    # PROCESS - Delayed Discharges
    tar_target(
      # Target name
      source_dd_extract,
      # Function
      process_extract_delayed_discharges(
        dd_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - Delayed Discharges
    tar_target(
      # Target name
      tests_source_dd_extract,
      # Function
      process_tests_delayed_discharges(
        source_dd_extract,
        year
      )
    ),
    # District Nursing Activity-------------------------------------------------
    # PROCESS - District Nursing
    tar_target(
      # Target name
      source_dn_extract,
      # Function
      process_extract_district_nursing(
        dn_data,
        year,
        costs = dn_cost_lookup,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - District Nursing
    tar_target(
      # Target name
      tests_source_dn_extract,
      # Function
      process_tests_district_nursing(
        source_dn_extract,
        year
      )
    ),
    # Homelessness (HL1) Activity-----------------------------------------------
    # PROCESS - Homelessness
    tar_target(
      # Target name
      source_homelessness_extract,
      # Function
      process_extract_homelessness(
        data = homelessness_data,
        year = year,
        write_to_disk = write_to_disk,
        la_code_lookup = la_code_opendata
      )
    ),
    # TESTS - Homelessness
    tar_target(
      # Target name
      tests_source_homelessness_extract,
      # Function
      process_tests_homelessness(
        source_homelessness_extract,
        year
      )
    ),
    # Long-Term Conditions (LTCs) Activity--------------------------------------
    # READ - LTCs
    tar_file_read(ltc_data, get_it_ltc_path(), read_lookup_ltc(!!.x)),
    # PROCESS - LTCs
    tar_target(
      # Target name
      source_ltc_lookup,
      # Function
      process_lookup_ltc(
        ltc_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - LTCs
    tar_target(
      # Target name
      tests_ltc,
      # Function
      process_tests_ltcs(
        source_ltc_lookup,
        year
      )
    ),
    # Maternity (SMR02) Acitivity-----------------------------------------------
    # PROCESS - Maternity
    tar_target(
      # Target name
      source_maternity_extract,
      # Function
      process_extract_maternity(
        maternity_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - Maternity
    tar_target(
      # Target name
      tests_source_maternity_extract,
      # Function
      process_tests_maternity(
        source_maternity_extract,
        year
      )
    ),
    # Mental Health (SMR02) Activity--------------------------------------------
    # PROCESS - Mental Health
    tar_target(
      # Target name
      source_mental_health_extract,
      # Function
      process_extract_mental_health(
        mental_health_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - Mental Health
    tar_target(
      # Tests, EXTRACT series
      tests_source_mental_health_extract,
      process_tests_mental_health(
        source_mental_health_extract,
        year
      )
    ),
    ## TODO - Remove as this is in refined deaths now
    # tar_target(source_nrs_deaths_extract, process_extract_nrs_deaths(
    #   nrs_deaths_data,
    #   year,
    #   write_to_disk = write_to_disk
    # )),
    # Death Activity------------------------------------------------------------
    # PROCESS - Deaths
    tar_target(
      # Target name
      source_nrs_deaths_extract,
      # use this anonymous function with redundant but necessary refined_death
      # to make sure reading year-specific nrs deaths extracts after it is produced
      (\(year, refined_death_data) {
        read_file(get_source_extract_path(year, "deaths")) %>%
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
    # GP Out of Hours (GP OOH) Activity-----------------------------------------

    ## TODO - RESTRUCTURE
    # PROCESS - GP OOH CUP
    tar_target(
      # Target name
      source_ooh_extract,
      # Function
      process_extract_gp_ooh(
        year,
        ooh_data,
        gp_ooh_cup_path,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - GP OOH
    tar_target(
      # Target name
      tests_source_ooh_extract,
      # Function
      process_tests_gp_ooh(
        source_ooh_extract,
        year
      )
    ),
    # Outpatients (SMR00) Activity----------------------------------------------
    # PROCESS - Outpatients
    tar_target(
      # Target name
      source_outpatients_extract,
      # Function
      process_extract_outpatients(
        outpatients_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - Outpatients
    tar_target(
      # Tests, EXTRACT series
      tests_source_outpatients_extract,
      process_tests_outpatients(
        source_outpatients_extract,
        year
      )
    ),
    # Prescribing (PIS) Activity------------------------------------------------
    # PROCESS - Prescribing
    tar_target(
      # Target name
      source_prescribing_extract,
      # Function
      process_extract_prescribing(
        prescribing_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - Prescribing
    tar_target(
      # Target name
      tests_prescribing,
      # Function
      process_tests_prescribing(
        source_prescribing_extract,
        year
      )
    ),
    ### Social Care - 'Year Specific' data -------------------------------------

    # Client file-----
    # READ - Client data
    tar_target(
      # Target name
      sc_client_data,
      # Function
      read_lookup_sc_client(fyyear = year)
    ),
    # PROCESS - Client data
    tar_target(
      # Target name
      sc_client_lookup,
      # Function
      process_lookup_sc_client(
        data = sc_client_data,
        year = year,
        sc_demographics = sc_demog_lookup %>%
          dplyr::select(c("sending_location", "social_care_id", "anon_chi", "latest_flag")),
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - Client data
    tar_target(
      # Target name
      tests_sc_client_lookup,
      # Function
      process_tests_sc_client_lookup(sc_client_lookup, year = year)
    ),
    # Alarms Telecare (AT) Activity---------------------------------------------
    # PROCESS - AT
    tar_target(
      # Target name
      source_sc_alarms_tele,
      # Function
      process_extract_alarms_telecare(
        data = all_at,
        year = year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - AT
    tar_target(
      # Target name
      tests_alarms_telecare,
      # Function
      process_tests_alarms_telecare(
        data = source_sc_alarms_tele,
        year = year
      )
    ),
    # Care Homes (CH) Activity--------------------------------------------------
    # PROCESS - CH
    tar_target(
      # Target name
      source_sc_care_home,
      # Function
      process_extract_care_home(
        data = all_care_home,
        year = year,
        ch_costs = ch_cost_lookup,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - CH
    tar_target(
      # Target name
      tests_care_home,
      # Function
      process_tests_care_home(
        data = source_sc_care_home,
        year = year
      )
    ),
    # Home Care (HC) Activity---------------------------------------------------
    # PROCESS - HC
    tar_target(
      # Target name
      source_sc_home_care,
      # Function
      process_extract_home_care(
        data = all_home_care,
        year = year,
        write_to_disk = write_to_disk
      )
    ),
    # TESTS - HC
    tar_target(
      # Target name
      tests_home_care,
      # Function
      process_tests_home_care(
        data = source_sc_home_care,
        year = year
      )
    ),
    # Self-Directed Support (SDS) Activity--------------------------------------
    # PROCESS - SDS
    tar_target(
      # Target name
      source_sc_sds,
      # Function
      process_extract_sds(
        data = all_sds,
        year = year,
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
    ),
    ## TODO - RESTRUCTURE
    # Deaths - Year specific SLF lookup-----------------------------------------
    tar_target(
      # Target name
      slf_deaths_lookup,
      # Function
      process_slf_deaths_lookup(
        year = year,
        refined_death = refined_death_data,
        write_to_disk = write_to_disk
      )
    ),
    ## TODO - RESTRUCTURE
    # Non-Service Users (NSU)---------------------------------------------------
    tar_file_read(nsu_cohort, get_nsu_path(year), read_file(!!.x)),
    ## TODO - RESTRUCTURE
    # Homelessness lookup-------------------------------------------------------
    tar_target(
      # Target name
      homelessness_lookup,
      # Function
      create_homelessness_lookup(
        year,
        homelessness_data = source_homelessness_extract
      )
    )
  )

  #-------------------------------------------------------------------------------

  ## End of Targets pipeline ##

  #-------------------------------------------------------------------------------

  ## TODO - REMOVE REDUNDANT CODE

  # ,
  # tar_target(
  #   combined_deaths_lookup,
  #   process_combined_deaths_lookup()
  # )
)


## Phase III, create ep file and ind file----
## Redundant code which may still be useful for including ep/indiv files.
# tar_qs(
#   processed_data_list,
#   list(
#     source_acute_extract,
#     source_ae_extract,
#     source_cmh_extract,
#     source_dn_extract,
#     source_homelessness_extract,
#     source_maternity_extract,
#     source_mental_health_extract,
#     source_nrs_deaths_extract,
#     source_ooh_extract,
#     source_outpatients_extract,
#     source_prescribing_extract,
#     source_sc_care_home,
#     source_sc_home_care,
#     source_sc_sds,
#     source_sc_alarms_tele
#   )
# ),
# tar_target(
#   episode_file,
#   create_episode_file(
#     processed_data_list,
#     year,
#     homelessness_lookup = homelessness_lookup,
#     dd_data = source_dd_extract,
#     nsu_cohort = nsu_cohort,
#     ltc_data = source_ltc_lookup,
#     slf_pc_lookup = source_pc_lookup,
#     slf_gpprac_lookup = source_gp_lookup,
#     slf_deaths_lookup = slf_deaths_lookup,
#     sc_client = sc_client_lookup,
#     write_to_disk
#   )
# ),
# tar_target(
#   episode_file_tests,
#   process_tests_episode_file(
#     data = episode_file,
#     year = year
#   )
# ) # ,
# tar_target(
#   cross_year_tests,
#   process_tests_cross_year(year = year)
# ), # ,
# tar_target(
#   individual_file,
#   create_individual_file(
#     episode_file = episode_file,
#     year = year,
#     homelessness_lookup = homelessness_lookup,
#     write_to_disk = write_to_disk
#   )
# ),
# tar_target(
#   individual_file_tests,
#   process_tests_individual_file(
#     data = individual_file,
#     year = year
#   )
# ) # ,
# tar_target(
#   episode_file_dataset,
#   arrow::write_dataset(
#     dataset = episode_file,
#     path = fs::path(
#       get_year_dir(year),
#       stringr::str_glue("source-episode-file-{year}")
#     ),
#     format = "parquet",
#     # Should correspond to the available slfhelper filters
#     partitioning = c("recid", "hscp2018"),
#     compression = "zstd",
#     version = "latest"
#   )
# ),
# tar_target(
#   individual_file_dataset,
#   arrow::write_dataset(
#     dataset = individual_file,
#     path = fs::path(
#       get_year_dir(year),
#       stringr::str_glue("source-individual-file-{year}")
#     ),
#     format = "parquet",
#     # Should correspond to the available slfhelper filters
#     partitioning = c("hscp2018"),
#     compression = "zstd",
#     version = "latest"
#   )
# )
