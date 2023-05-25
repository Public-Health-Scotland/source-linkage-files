# _targets.R file
library(targets)
library(tarchetypes)
library(future.callr)

options(readr.read_lazy = TRUE)

tar_option_set(
  imports = "createslf",
  packages = "createslf",
  garbage_collection = TRUE,
  format = "parquet",
  resources = tar_resources(
    parquet = tar_resources_parquet(compression = "zstd"),
    future = tar_resources_future(plan = callr)
  ),
  error = "continue",
  storage = "worker",
  memory = "persistent" # default option
)

years_to_run <- c("1819", "1920", "2021", "2122", "2223")

list(
  tar_rds(write_to_disk, TRUE),
  ## Lookup data ##
  tar_target(gpprac_opendata, get_gpprac_opendata()),
  tar_target(gpprac_ref_path, get_gpprac_ref_path(), format = "file"),
  tar_target(locality_path, get_locality_path(), format = "file"),
  tar_target(simd_path, get_simd_path(), format = "file"),
  tar_target(spd_path, get_spd_path(), format = "file"),
  tar_file_read(chi_deaths_data,
    command = get_it_deaths_path(),
    read = read_lookup_chi_deaths(!!.x)
  ),
  tar_file_read(dd_data, get_dd_path(), read_extract_delayed_discharges(!!.x)),
  tar_file_read(ltc_data, get_it_ltc_path(), read_lookup_ltc(!!.x)),
  tar_target(slf_ch_name_lookup_path, get_slf_ch_name_lookup_path(), format = "file"),
  ## Process Lookups ##
  tar_target(
    sc_demog_data,
    read_lookup_sc_demographics(),
    cue = tar_cue_age(
      name = sc_demog_data,
      age = as.difftime(28, units = "days")
    )
  ),
  tar_target(
    sc_demog_lookup,
    process_lookup_sc_demographics(
      sc_demog_data,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    sc_demog_lookup_tests,
    process_tests_sc_demographics(sc_demog_lookup)
  ),
  tar_target(
    slf_chi_deaths_lookup,
    process_lookup_chi_deaths(
      data = chi_deaths_data,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    source_gp_lookup,
    process_lookup_gpprac(
      open_data = gpprac_opendata,
      gpprac_ref_path = gpprac_ref_path,
      spd_path = spd_path,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    source_pc_lookup,
    process_lookup_postcode(
      spd_path = spd_path,
      simd_path = simd_path,
      locality_path = locality_path,
      write_to_disk = write_to_disk
    )
  ),
  ## Cost Lookups ##
  tar_target(ch_cost_lookup, process_costs_ch_rmd()),
  tar_target(dn_cost_lookup, process_costs_dn_rmd()),
  tar_target(hc_cost_lookup, process_costs_hc_rmd()),
  tar_target(gp_ooh_cost_lookup, process_costs_gp_ooh_rmd()),
  ## Social Care - 'All' data ##
  tar_target(
    all_at_extract,
    read_sc_all_alarms_telecare(),
    cue = tar_cue_age(
      name = all_at_extract,
      age = as.difftime(28, units = "days")
    )
  ),
  tar_target(
    all_at,
    process_sc_all_alarms_telecare(
      all_at_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    all_home_care_extract,
    read_sc_all_home_care(),
    cue = tar_cue_age(
      name = all_home_care_extract,
      age = as.difftime(28, units = "days")
    )
  ),
  tar_target(
    all_home_care,
    process_sc_all_home_care(
      all_home_care_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    all_care_home_extract,
    read_sc_all_care_home(),
    cue = tar_cue_age(
      name = all_care_home_extract,
      age = as.difftime(28, units = "days")
    )
  ),
  tar_target(
    all_care_home,
    process_sc_all_care_home(
      all_care_home_extract,
      sc_demog_lookup = sc_demog_lookup,
      slf_deaths_lookup = slf_chi_deaths_lookup,
      ch_name_lookup_path = slf_ch_name_lookup_path,
      spd_path = spd_path,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    all_care_home_tests,
    process_tests_sc_ch_episodes(all_care_home)
  ),
  tar_target(
    all_sds_extract,
    read_sc_all_sds(),
    cue = tar_cue_age(
      name = all_sds_extract,
      age = as.difftime(28, units = "days")
    )
  ),
  tar_target(
    all_sds,
    process_sc_all_sds(
      all_sds_extract,
      sc_demog_lookup = sc_demog_lookup,
      write_to_disk = write_to_disk
    )
  ),
  tar_map(
    list(year = years_to_run),
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
    tar_target(ooh_data,
      read_extract_gp_ooh(
        year,
        diagnosis_data_path,
        outcomes_data_path,
        consultations_data_path
      ),
      format = "rds"
    ),
    ### Target source processed extracts ###
    tar_target(acute_source_extract, process_extract_acute(
      acute_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      acute_source_extract_tests,
      process_tests_acute(
        acute_data,
        year
      )
    ),
    tar_target(ae_source_extract, process_extract_ae(
      ae_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      ae_source_extract_tests,
      process_tests_ae(
        ae_data,
        year
      )
    ),
    tar_target(source_cmh_extract, process_extract_cmh(
      cmh_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      source_cmh_extract_tests,
      process_tests_cmh(
        source_cmh_extract,
        year
      )
    ),
    # TODO add tests for the Delayed Discharges extract
    tar_target(source_dd_extract, process_extract_delayed_discharges(
      dd_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(source_dn_extract, process_extract_district_nursing(
      dn_data,
      year,
      costs = dn_cost_lookup,
      write_to_disk = write_to_disk
    )),
    tar_target(
      source_dn_extract_tests,
      process_tests_district_nursing(
        source_dn_extract,
        year
      )
    ),
    tar_target(source_homelessness_extract, process_extract_homelessness(
      homelessness_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      source_homelessness_extract_tests,
      process_tests_homelessness(
        source_homelessness_extract,
        year
      )
    ),
    tar_target(ltc_source_extract, process_lookup_ltc(
      ltc_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      ltc_tests,
      process_tests_ltcs(
        ltc_source_extract,
        year
      )
    ),
    tar_target(maternity_source_extract, process_extract_maternity(
      maternity_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      maternity_source_extract_tests,
      process_tests_maternity(
        maternity_source_extract,
        year
      )
    ),
    tar_target(mental_health_source_extract, process_extract_mental_health(
      mental_health_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      mental_health_source_extract_tests,
      process_tests_mental_health(
        mental_health_source_extract,
        year
      )
    ),
    tar_target(nrs_deaths_source_extract, process_extract_nrs_deaths(
      nrs_deaths_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      nrs_deaths_source_extract_tests,
      process_tests_nrs_deaths(
        nrs_deaths_source_extract,
        year
      )
    ),
    tar_target(ooh_source_extract, process_extract_gp_ooh(
      year,
      ooh_data,
      write_to_disk = write_to_disk
    )),
    tar_target(
      ooh_source_extract_tests,
      process_tests_gp_ooh(
        ooh_source_extract,
        year
      )
    ),
    tar_target(outpatients_source_extract, process_extract_outpatients(
      outpatients_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      outpatients_source_extract_tests,
      process_tests_outpatients(
        outpatients_source_extract,
        year
      )
    ),
    tar_target(pis_source_extract, process_extract_prescribing(
      prescribing_data,
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      prescribing_tests,
      process_tests_prescribing(
        pis_source_extract,
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
    )
  )
)
