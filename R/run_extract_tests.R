run_all_extract_tests = function(year_list) {
  # one-off tests
  run_lookup_tests()
  # year specific tests
  parallel::mclapply(year_list,
                     run_year_extract_tests,
                     mc.cores = length(year_list))
}


run_lookup_tests = function() {
  # Tests, LOOKUP series
  ## sc_demog_lookup
  process_tests_sc_demographics(read_file(get_sc_demog_lookup_path()))
  ## it_chi_deaths
  process_tests_it_chi_deaths(read_file(get_slf_chi_deaths_path()))
  ## gp_lookup
  process_tests_lookup_gpprac(read_file(get_slf_gpprac_path()))
  ## pc_lookup
  process_tests_lookup_pc(read_file(get_slf_postcode_path()))
  ## all_at
  process_tests_sc_all_at_episodes(read_file(get_sc_at_episodes_path()))
  ## all_home_care
  process_tests_sc_all_hc_episodes(read_file(get_sc_hc_episodes_path()))
  ## all_care_home
  process_tests_sc_all_ch_episodes(read_file(get_sc_ch_episodes_path()))
  ## all_sds
  process_tests_sc_all_sds_episodes(read_file(get_sc_sds_episodes_path()))
}

run_year_extract_tests = function(year) {
  # Tests, EXTRACT series, year specific
  ## acute
  process_tests_acute(read_file(get_source_extract_path(year, "acute")),
                      year)
  ## ae
  process_tests_ae(read_file(get_source_extract_path(year, "ae")),
                   year)
  ## cmh
  process_tests_cmh(read_file(get_source_extract_path(year, "cmh")),
                    year)
  ## dd
  process_tests_delayed_discharges(read_file(get_source_extract_path(year, "dd")),
                                   year)
  ## dn
  process_tests_district_nursing(read_file(get_source_extract_path(year, "dn")),
                                 year)
  ## homelessness
  process_tests_homelessness(read_file(get_source_extract_path(year, "homelessness")),
                             year)
  ## ltc
  process_tests_ltcs(read_file(get_ltcs_path(year)),
                     year)
  ## maternity
  process_tests_maternity(read_file(get_source_extract_path(year, "maternity")),
                          year)
  ## mental_health
  process_tests_mental_health(read_file(get_source_extract_path(year, "mh")),
                              year)
  ## nrs_death
  process_tests_nrs_deaths(read_file(get_source_extract_path(year, "deaths")),
                           year)
  ## ooh
  process_tests_gp_ooh(read_file(get_source_extract_path(year, "gp_ooh")),
                       year)
  ## outpatients
  process_tests_outpatients(read_file(get_source_extract_path(year, "outpatients")),
                            year)
  ## prescribing
  process_tests_prescribing(read_file(get_source_extract_path(year, "pis")),
                            year)
  ## sc_client
  process_tests_sc_client_lookup(read_file(get_sc_client_lookup_path(year)),
                                 year)
  ## alarm_telecare
  process_tests_alarms_telecare(read_file(get_source_extract_path(year, type = "at")),
                                year)
  ## care_home
  process_tests_care_home(read_file(get_source_extract_path(year, type = "ch")),
                          year)
  ## home care
  process_tests_home_care(read_file(get_source_extract_path(year, type = "hc")),
                          year)
  ## sds
  process_tests_sds(read_file(get_source_extract_path(year, type = "sds")),
                    year)
}
