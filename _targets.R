# _targets.R file
library(targets)
library(tarchetypes)

tar_option_set(
  imports = "createslf",
  packages = "createslf",
  garbage_collection = TRUE,
  #format = "parquet",
  resources = tar_resources(
              #parquet = tar_resources_parquet(compression = "zstd"),
              future = tar_resources_future(plan = future::multisession)),
  error = "continue",
  # default option
  storage = "main",
  # default option
  memory = "persistant"
)


list(
  tar_target(write_to_disk, FALSE),
  ## Lookup data ##
  tar_target(spd_data, get_spd_path(), format = "file"),
  tar_target(simd_data, get_simd_path(), format = "file"),
  tar_target(locality_data, get_locality_path(), format = "file"),
  tar_target(gpprac_data, get_gpprac_opendata()),
  tar_target(gpprac_ref_data, get_gpprac_ref_path(), format = "file"),
  tar_target(chi_deaths_data, get_it_deaths_path(), format = "file"),
  ## Process Lookups ##
  tar_target(
    sc_demog_lookup,
    process_lookup_sc_demographics(read_lookup_sc_demographics(),
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    source_pc_lookup,
    process_lookup_postcode(
      spd_path = spd_data,
      simd_path = simd_data,
      locality_path = locality_data,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    source_gp_lookup,
    process_lookup_gpprac(
      open_data = gpprac_data,
      gpprac_ref_path = gpprac_ref_data,
      spd_path = spd_data,
      write_to_disk = write_to_disk
    )
  ),
  tar_target(
    source_chi_deaths_lookup,
    process_lookup_chi_deaths(read_lookup_chi_deaths(chi_deaths_data),
      write_to_disk = write_to_disk
    )
  ),
  ## Cost Lookups ##
  tar_target(ch_costs, process_costs_ch_rmd()),
  tar_target(hc_costs, process_costs_hc_rmd()),
  tar_target(gp_ooh_costs, process_costs_gp_ooh_rmd()),
  tar_target(dn_costs, process_costs_dn_rmd()),
  ## Social Care - 'All' data ##
  tar_target(sc_demographic_data, get_sc_demog_lookup_path(), format = "file"),
  tar_target(slf_deaths_data, get_slf_deaths_path(), format = "file"),
  tar_target(all_at, process_sc_all_alarms_telecare(
    read_sc_all_alarms_telecare(),
    sc_demographics = sc_demographic_data,
    write_to_disk = write_to_disk
  )),
  tar_target(all_sds, process_sc_all_sds(
    read_sc_all_sds(),
    sc_demographics = sc_demographic_data,
    write_to_disk = write_to_disk
  )),
  tar_target(all_home_care, process_sc_all_home_care(
    read_sc_all_home_care(),
    sc_demographics = sc_demographic_data,
    write_to_disk = write_to_disk
  )),
  tar_target(all_care_home, process_sc_all_care_home(
    read_sc_all_care_home(),
    sc_demographics = sc_demographic_data,
    slf_deaths_path = slf_deaths_data,
    write_to_disk = write_to_disk
  )),
  tarchetypes::tar_map(
    list(year = c(1920)),
    ### target data extracts ###
    tar_target(
      cmh_data,
      get_boxi_extract_path(year, type = "CMH"),
      format = "file"
    ),
    tar_target(
      dd_data,
      get_dd_path(ext = "zsav"),
      format = "file"
    ),
    tar_target(
      dn_data,
      get_boxi_extract_path(year, type = "DN"),
      format = "file"
    ),
    tar_target(
      homelessness_data,
      get_boxi_extract_path(year, type = "Homelessness"),
      format = "file"
    ),
    tar_target(
      acute_data,
      get_boxi_extract_path(year, type = "Acute"),
      format = "file"
    ),
    tar_target(
      ae_data,
      get_boxi_extract_path(year, type = "AE"),
      format = "file"
    ),
    tar_target(
      maternity_data,
      get_boxi_extract_path(year, type = "Maternity"),
      format = "file"
    ),
    tar_target(
      mental_health_data,
      get_boxi_extract_path(year, type = "MH"),
      format = "file"
    ),
    tar_target(
      nrs_deaths_data,
      get_boxi_extract_path(year, type = "Deaths"),
      format = "file"
    ),
    tar_target(
      pis_data,
      get_it_prescribing_path(year),
      format = "file"
    ),
    tar_target(
      outpatients_data,
      get_boxi_extract_path(year, type = "Outpatient"),
      format = "file"
    ),
    tar_target(
      ltc_data,
      get_it_ltc_path(),
      format = "file"
    ),
    tar_target(
      diagnosis_data,
      get_boxi_extract_path(year = year, type = "GP_OoH-d"),
      format = "file"
    ),
    tar_target(
      outcomes_data,
      get_boxi_extract_path(year = year, type = "GP_OoH-o"),
      format = "file"
    ),
    tar_target(
      consultations_data,
      get_boxi_extract_path(year = year, type = "GP_OoH-c"),
      format = "file"
    ),
    ### Target source processed extracts ###
    tar_target(source_cmh_extract, process_extract_cmh(
      read_extract_cmh(year, cmh_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(source_dd_extract, process_extract_delayed_discharges(
      read_extract_delayed_discharges(dd_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(source_dn_extract, process_extract_district_nursing(
      read_extract_district_nursing(year, dn_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(source_homelessness_extract, process_extract_homelessness(
      read_extract_homelessness(year, homelessness_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(acute_source_extract, process_extract_acute(
      read_extract_acute(year, acute_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(ae_source_extract, process_extract_ae(
      read_extract_ae(year, ae_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(maternity_source_extract, process_extract_maternity(
      read_extract_maternity(year, maternity_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(mental_health_source_extract, process_extract_mental_health(
      read_extract_mental_health(year, mental_health_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(nrs_deaths_source_extract, process_extract_nrs_deaths(
      read_extract_nrs_deaths(year, nrs_deaths_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(outpatients_source_extract, process_extract_outpatients(
      read_extract_outpatients(year, outpatients_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(pis_source_extract, process_extract_prescribing(
      read_extract_prescribing(year, pis_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(ltc_source_extract, process_lookup_ltc(
      read_lookup_ltc(ltc_data),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(ooh_source_extract, process_extract_gp_ooh(year,
      read_extract_gp_ooh(
        year,
        diagnosis_data,
        outcomes_data,
        consultations_data
      ),
      write_to_disk = write_to_disk
    )),
    ### Target social care data ###
    tar_target(
      client_lookup_path,
      get_source_extract_path(year, type = "Client"),
      format = "file"
    ),
    tar_target(
      all_at_data_path,
      get_sc_at_episodes_path(),
      format = "file"
    ),
    tar_target(
      all_sds_data_path,
      get_sc_sds_episodes_path(),
      format = "file"
    ),
    tar_target(
      all_hc_data_path,
      get_sc_hc_episodes_path(),
      format = "file"
    ),
    tar_target(
      all_ch_data_path,
      get_sc_ch_episodes_path(update = latest_update(), ext = "zsav"),
      format = "file"
    ),
    ### Target process year specific social care ###
    tar_target(sc_client, process_lookup_sc_client(
      read_lookup_sc_client(fyyear = year),
      year,
      write_to_disk = write_to_disk
    )),
    tar_target(
      source_sc_alarms_tele,
      process_extract_alarms_telecare(
        file_path = all_at_data_path,
        year = year,
        client_lookup_path = client_lookup_path,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      source_sc_sds,
      process_extract_sds(
        file_path = all_sds_data_path,
        year = year,
        client_lookup_path = client_lookup_path,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      source_sc_home_care,
      process_extract_home_care(
        file_path = all_hc_data_path,
        year,
        client_lookup_path = client_lookup_path,
        write_to_disk = write_to_disk
      )
    ),
    tar_target(
      source_sc_care_home,
      process_extract_care_home(
        file_path = all_ch_data_path,
        year = year,
        client_lookup_path = client_lookup_path,
        write_to_disk = write_to_disk
      )
    )
  )
)
