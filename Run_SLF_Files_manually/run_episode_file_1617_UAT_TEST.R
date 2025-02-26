library(targets)
library(createslf)

year <- "1617"

path <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates/1617/")

processed_data_list <- list(
  acute = arrow::read_parquet(paste0(path, "/anon-acute_for_source-201617.parquet")),
  ae = arrow::read_parquet(paste0(path, "/anon-a_and_e_for_source-201617.parquet")),
  cmh = arrow::read_parquet(paste0(path, "/anon-cmh_for_source-201617.parquet")),
  deaths = arrow::read_parquet(paste0(path, "/anon-deaths_for_source-201617.parquet")),
  dn = arrow::read_parquet(paste0(path, "/anon-district_nursing_for_source-201617.parquet")),
  homelessness = arrow::read_parquet(paste0(path, "/anon-homelessness_for_source-201617.parquet")),
  maternity = arrow::read_parquet(paste0(path, "/anon-maternity_for_source-201617.parquet")),
  mental_health = arrow::read_parquet(paste0(path, "/anon-mental_health_for_source-201617.parquet")),
  outpatients = arrow::read_parquet(paste0(path, "/anon-outpatients_for_source-201617.parquet")),
  gp_ooh = arrow::read_parquet(paste0(path, "/anon-gp_ooh_for_source-201617.parquet")),
  prescribing = arrow::read_parquet(paste0(path, "/anon-prescribing_file_for_source-201617.parquet"))
)


dd_data <- read_file(get_source_extract_path(year, "dd"))
homelessness_lookup <- create_homelessness_lookup(year)
nsu_cohort <- read_file(get_nsu_path(year))
ltc_data <- read_file(get_ltcs_path(year))
slf_pc_lookup <- read_file(get_slf_postcode_path())
slf_gpprac_lookup <- read_file(
  get_slf_gpprac_path(),
  col_select = c("gpprac", "cluster", "hbpraccode")
)
slf_deaths_lookup <- read_file(get_slf_deaths_lookup_path(year))
sc_client <- read_file(get_sc_client_lookup_path(year))

cli::cli_alert_info("Create episode file function started at {Sys.time()}")

processed_data_list <- purrr::discard(processed_data_list, ~ is.null(.x) | identical(.x, tibble::tibble()))

episode_file <- dplyr::bind_rows(processed_data_list) %>%
  add_homelessness_flag(year, lookup = homelessness_lookup) %>%
  add_homelessness_date_flags(year, lookup = homelessness_lookup) %>%
  link_delayed_discharge_eps(year, dd_data) %>%
  create_cost_inc_dna() %>%
  apply_cost_uplift() %>%
  store_ep_file_vars(
    year = year,
    vars_to_keep = c(
      "year",
      "recid",
      "record_keydate1",
      "record_keydate2",
      "smrtype",
      "anon_chi",
      "gender",
      "dob",
      "gpprac",
      "hbpraccode",
      "postcode",
      "hbrescode",
      "lca",
      "location",
      "hbtreatcode",
      "ipdc",
      "spec",
      "sigfac",
      "diag1",
      "diag2",
      "diag3",
      "diag4",
      "diag5",
      "diag6",
      "op1a",
      "age",
      "cij_marker",
      "cij_start_date",
      "cij_end_date",
      "cij_pattype_code",
      "cij_ipdc",
      "cij_admtype",
      "cij_adm_spec",
      "cij_dis_spec",
      "cost_total_net",
      "hscp",
      "datazone2011",
      "attendance_status",
      "deathdiag1",
      "deathdiag2",
      "deathdiag3",
      "deathdiag4",
      "deathdiag5",
      "deathdiag6",
      "deathdiag7",
      "deathdiag8",
      "deathdiag9",
      "deathdiag10",
      "deathdiag11",
      "yearstay",
      "apr_beddays",
      "may_beddays",
      "jun_beddays",
      "jul_beddays",
      "aug_beddays",
      "sep_beddays",
      "oct_beddays",
      "nov_beddays",
      "dec_beddays",
      "jan_beddays",
      "feb_beddays",
      "mar_beddays"
    )
  ) %>%
  # match on sc client variables
  join_sc_client(year, sc_client = sc_client, file_type = "episode") %>%
  # change to chi for phsmethods
  slfhelper::get_chi() %>%
  # Check chi is valid using phsmethods function
  # If the CHI is invalid for whatever reason, set the CHI to NA
  dplyr::mutate(
    chi = dplyr::if_else(
      phsmethods::chi_check(.data$chi) != "Valid CHI",
      NA_character_,
      .data$chi
    ),
    gpprac = convert_eng_gpprac_to_dummy(.data[["gpprac"]]),
    # PC8 format may still be used. Ensure here that all datasets are in PC7 format.
    postcode = phsmethods::format_postcode(.data$postcode, "pc7")
  ) %>%
  # change back to anon_chi
  slfhelper::get_anon_chi() %>%
  correct_cij_vars() %>%
  fill_missing_cij_markers() %>%
  add_ppa_flag() %>%
  add_nsu_cohort(year, nsu_cohort) %>%
  match_on_ltcs(year, ltc_data) %>%
  correct_demographics(year) %>%
  join_cohort_lookups(year) %>%
  join_sparra_hhg(year) %>%
  fill_geographies(
    slf_pc_lookup,
    slf_gpprac_lookup
  ) %>%
  join_deaths_data(
    year,
    slf_deaths_lookup
  ) %>%
  add_activity_after_death_flag(year,
    deaths_data = read_file(get_combined_slf_deaths_lookup_path())
  ) %>%
  load_ep_file_vars(year)


## End of Script ##
