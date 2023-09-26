# _targets.R file
library(targets)
library(tarchetypes)
future::plan(future.callr::callr)

options(readr.read_lazy = TRUE)

tar_option_set(
  imports = "createslf",
  packages = "createslf",
  garbage_collection = TRUE,
  format = "parquet",
  resources = tar_resources(
    parquet = tar_resources_parquet(compression = "zstd"),
    qs = tar_resources_qs(preset = "high")
  ),
  error = "continue",
  storage = "worker",
  memory = "persistent" # default option
)

years_to_run <- c("1718", "1819", "1920", "2021", "2122", "2223", "2324")

list(
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
  ## Lookup data ##
  tar_target(gpprac_opendata, get_gpprac_opendata()),
  tar_target(gpprac_ref_path, get_gpprac_ref_path(), format = "file"),
  tar_target(locality_path, get_locality_path(), format = "file"),
  tar_target(simd_path, get_simd_path(), format = "file"),
  tar_target(spd_path, get_spd_path(), format = "file"),
  tar_file_read(it_chi_deaths_extract,
    command = get_it_deaths_path(),
    read = read_it_chi_deaths(!!.x)
  ),
  tar_file_read(dd_data, get_dd_path(), read_extract_delayed_discharges(!!.x)),
  tar_file_read(ltc_data, get_it_ltc_path(), read_lookup_ltc(!!.x)),
  tar_target(
    slf_ch_name_lookup_path,
    get_slf_ch_name_lookup_path(),
    format = "file"
  ),
  ## Process Lookups ##
  tar_target(
    sc_demog_data,
    read_lookup_sc_demographics(),
    cue = tar_cue_age(
      name = sc_demog_data,
      age = as.difftime(28.0, units = "days")
    )
  ),
  tar_target(
    sc_demog_lookup,
    process_lookup_sc_demographics(
      sc_demog_data,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  tar_target(
    tests_sc_demog_lookup,
    process_tests_sc_demographics(sc_demog_lookup)
  ),
  tar_target(
    it_chi_deaths_data,
    process_it_chi_deaths(
      data = it_chi_deaths_extract,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  tar_target(
    tests_it_chi_deaths,
    process_tests_it_chi_deaths(it_chi_deaths_data)
  ),
  tar_target(
    source_gp_lookup,
    process_lookup_gpprac(
      open_data = gpprac_opendata,
      gpprac_ref_path = gpprac_ref_path,
      spd_path = spd_path,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  tar_target(
    tests_source_gp_lookup,
    process_tests_lookup_gpprac(source_gp_lookup)
  ),
  tar_target(
    source_pc_lookup,
    process_lookup_postcode(
      spd_path = spd_path,
      simd_path = simd_path,
      locality_path = locality_path,
      write_to_disk = write_to_disk
    ),
    priority = 0.9
  ),
  tar_target(
    tests_source_pc_lookup,
    process_tests_lookup_pc(source_pc_lookup)
  ),
  ## Cost Lookups ##
  tar_target(ch_cost_lookup, process_costs_ch_rmd(), priority = 0.8),
  tar_target(dn_cost_lookup, process_costs_dn_rmd(), priority = 0.8),
  tar_target(hc_cost_lookup, process_costs_hc_rmd(), priority = 0.8),
  tar_target(gp_ooh_cost_lookup, process_costs_gp_ooh_rmd()),
  ## Social Care - 'All' data ##
  tar_target(
    all_at_extract,
    read_sc_all_alarms_telecare(),
    cue = tar_cue_age(
      name = all_at_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  tar_target(
    all_at,
    process_sc_all_alarms_telecare(
      all_at_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  tar_target(
    all_home_care_extract,
    read_sc_all_home_care(),
    cue = tar_cue_age(
      name = all_home_care_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  tar_target(
    all_home_care,
    process_sc_all_home_care(
      all_home_care_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  tar_target(
    all_care_home_extract,
    read_sc_all_care_home(),
    cue = tar_cue_age(
      name = all_care_home_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  tar_target(
    all_care_home,
    process_sc_all_care_home(
      all_care_home_extract,
      sc_demog_lookup = sc_demog_lookup,
      it_chi_deaths_data = it_chi_deaths_data,
      ch_name_lookup_path = slf_ch_name_lookup_path,
      spd_path = spd_path,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
  tar_target(
    tests_all_care_home,
    process_tests_sc_ch_episodes(all_care_home)
  ),
  tar_target(
    all_sds_extract,
    read_sc_all_sds(),
    cue = tar_cue_age(
      name = all_sds_extract,
      age = as.difftime(28.0, units = "days")
    )
  ),
  tar_target(
    all_sds,
    process_sc_all_sds(
      all_sds_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk
    ),
    priority = 0.5
  ),
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
    ### target data extracts ###
    tar_file_read(
      acute_data,
      get_boxi_extract_path(year, type = "Acute"),
      read_extract_acute(year, !!.x)
    ),
    tar_file_read(
      ae_data,
      get_boxi_extract_path(year, type = "AE"),
      read_extract_ae(year, !!.x)
    ),
    tar_file_read(
      cmh_data,
      get_boxi_extract_path(year, type = "CMH"),
      read_extract_cmh(year, !!.x)
    ),
    tar_file_read(
      dn_data,
      get_boxi_extract_path(year, type = "DN"),
      read_extract_district_nursing(year, !!.x)
    ),
    tar_file_read(
      homelessness_data,
      get_boxi_extract_path(year, type = "Homelessness"),
      read_extract_homelessness(year, !!.x)
    ),
    tar_file_read(
      maternity_data,
      get_boxi_extract_path(year, type = "Maternity"),
      read_extract_maternity(year, !!.x)
    ),
    tar_file_read(
      mental_health_data,
      get_boxi_extract_path(year, type = "MH"),
      read_extract_mental_health(year, !!.x)
    ),
    tar_file_read(
      nrs_deaths_data,
      get_boxi_extract_path(year, type = "Deaths"),
      read_extract_nrs_deaths(year, !!.x)
    ),
    tar_file_read(
      outpatients_data,
      get_boxi_extract_path(year, type = "Outpatient"),
      read_extract_outpatients(year, !!.x)
    ),
    tar_file_read(
      prescribing_data,
      get_it_prescribing_path(year),
      read_extract_prescribing(year, !!.x)
    ),
    tar_target(
      diagnosis_data_path,
      get_boxi_extract_path(year = year, type = "GP_OoH-d"),
      format = "file"
    ),
    tar_target(
      outcomes_data_path,
      get_boxi_extract_path(year = year, type = "GP_OoH-o"),
      format = "file"
    ),
    tar_target(
      consultations_data_path,
      get_boxi_extract_path(year = year, type = "GP_OoH-c"),
      format = "file"
    ),
    tar_qs(
      ooh_data,
      read_extract_gp_ooh(
        year,
        diagnosis_data_path,
        outcomes_data_path,
        consultations_data_path
      )
    ),
    ### Target source processed extracts ###
    tar_target(source_acute_extract, process_extract_acute(
      acute_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_acute_extract,
      process_tests_acute(
        source_acute_extract,
        year
      )
    ),
    tar_target(source_ae_extract, process_extract_ae(
      ae_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_ae_extract,
      process_tests_ae(
        source_ae_extract,
        year
      )
    ),
    tar_target(source_cmh_extract, process_extract_cmh(
      cmh_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_cmh_extract,
      process_tests_cmh(
        source_cmh_extract,
        year
      )
    ),
    tar_target(source_dd_extract, process_extract_delayed_discharges(
      dd_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_dd_extract,
      process_tests_delayed_discharges(
        source_dd_extract,
        year
      )
    ),
    tar_target(source_dn_extract, process_extract_district_nursing(
      dn_data,
      year,
      costs = dn_cost_lookup,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_dn_extract,
      process_tests_district_nursing(
        source_dn_extract,
        year
      )
    ),
    tar_target(
      source_homelessness_extract,
      process_extract_homelessness(
        homelessness_data,
        year,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      tests_source_homelessness_extract,
      process_tests_homelessness(
        source_homelessness_extract,
        year
      )
    ),
    tar_target(source_ltc_lookup, process_lookup_ltc(
      ltc_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_ltc,
      process_tests_ltcs(
        source_ltc_lookup,
        year
      )
    ),
    tar_target(source_maternity_extract, process_extract_maternity(
      maternity_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_maternity_extract,
      process_tests_maternity(
        source_maternity_extract,
        year
      )
    ),
    tar_target(source_mental_health_extract, process_extract_mental_health(
      mental_health_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_mental_health_extract,
      process_tests_mental_health(
        source_mental_health_extract,
        year
      )
    ),
    tar_target(source_nrs_deaths_extract, process_extract_nrs_deaths(
      nrs_deaths_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_nrs_deaths_extract,
      process_tests_nrs_deaths(
        source_nrs_deaths_extract,
        year
      )
    ),
    tar_target(source_ooh_extract, process_extract_gp_ooh(
      year,
      ooh_data,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_ooh_extract,
      process_tests_gp_ooh(
        source_ooh_extract,
        year
      )
    ),
    tar_target(source_outpatients_extract, process_extract_outpatients(
      outpatients_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_source_outpatients_extract,
      process_tests_outpatients(
        source_outpatients_extract,
        year
      )
    ),
    tar_target(source_prescribing_extract, process_extract_prescribing(
      prescribing_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      tests_prescribing,
      process_tests_prescribing(
        source_prescribing_extract,
        year
      )
    ),
    ### Target process year specific social care ###
    tar_target(
      sc_client_data,
      read_lookup_sc_client(fyyear = year)
    ),
    # TODO add tests for the SC client lookup
    tar_target(
      sc_client_lookup,
      process_lookup_sc_client(
        data = sc_client_data,
        year = year,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      source_sc_alarms_tele,
      process_extract_alarms_telecare(
        data = all_at,
        year = year,
        client_lookup = sc_client_lookup,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      tests_alarms_telecare,
      process_tests_alarms_telecare(
        data = source_sc_alarms_tele,
        year = year
      )
    ),
    tar_target(
      source_sc_care_home,
      process_extract_care_home(
        data = all_care_home,
        year = year,
        client_lookup = sc_client_lookup,
        ch_costs = ch_cost_lookup,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      tests_care_home,
      process_tests_care_home(
        data = source_sc_care_home,
        year = year
      )
    ),
    tar_target(
      source_sc_home_care,
      process_extract_home_care(
        data = all_home_care,
        year = year,
        client_lookup = sc_client_lookup,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      tests_home_care,
      process_tests_home_care(
        data = source_sc_home_care,
        year = year
      )
    ),
    tar_target(
      source_sc_sds,
      process_extract_sds(
        data = all_sds,
        year = year,
        client_lookup = sc_client_lookup,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      tests_sds,
      process_tests_sds(
        data = source_sc_sds,
        year = year
      )
    ),
    tar_target(
      slf_deaths_lookup,
      process_slf_deaths_lookup(
        year = year,
        nrs_deaths_data = source_nrs_deaths_extract,
        chi_deaths_data = it_chi_deaths_data,
        write_to_disk = write_to_disk
      )
    ),
    tar_qs(
      processed_data_list,
      list(
        source_acute_extract,
        source_ae_extract,
        source_cmh_extract,
        source_dn_extract,
        source_homelessness_extract,
        source_maternity_extract,
        source_mental_health_extract,
        source_nrs_deaths_extract,
        source_ooh_extract,
        source_outpatients_extract,
        source_prescribing_extract,
        source_sc_care_home,
        source_sc_home_care,
        source_sc_sds,
        source_sc_alarms_tele
      )
    ),
    tar_file_read(nsu_cohort, get_nsu_path(year), read_file(!!.x)),
    tar_target(
      homelessness_lookup,
      create_homelessness_lookup(
        year,
        homelessness_data = source_homelessness_extract
      )
    ),
    tar_target(
      episode_file,
      create_episode_file(
        processed_data_list,
        year,
        homelessness_lookup = homelessness_lookup,
        dd_data = source_dd_extract,
        nsu_cohort = nsu_cohort,
        ltc_data = source_ltc_lookup,
        slf_pc_lookup = source_pc_lookup,
        slf_gpprac_lookup = source_gp_lookup,
        slf_deaths_lookup = slf_deaths_lookup,
        write_to_disk
      )
    ),
    tar_target(
      episode_file_tests,
      process_tests_episode_file(
        data = episode_file,
        year = year
      )
    ),
    tar_target(
      individual_file,
      create_individual_file(
        episode_file = episode_file,
        year = year,
        homelessness_lookup = homelessness_lookup,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      individual_file_tests,
      process_tests_individual_file(
        data = individual_file,
        year = year
      )
    ) # ,
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
  )
)
