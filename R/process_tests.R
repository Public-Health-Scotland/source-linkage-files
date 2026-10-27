#' Process tests
#'
#' @description This script takes a processed extract and produces
#' a test comparison with the previous data. This is returned for stacking in BYOC
#' mode or written to disk as an xlsx in local mode.
#'
#' @param data
#' @param year
#' @param BYOC_MODE
#' @param denodo_connect
#' @param file_location
#' @param benchmark_comparison_type
#' @param benchmark_run_id
#' @param run_id
#' @param run_date_time
#'
#' @export
process_tests <- function(data,
                          year = NA,
                          BYOC_MODE = FALSE,
                          denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                          file_location = "denodo",
                          benchmark_comparison_type = "episode",
                          benchmark_run_id = NA,
                          run_id = NA,
                          run_date_time = NA) {

  # 1. Infer type, year and workbook from data ---------------------------------

  # Set recid
  if ("recid" %in% colnames(data)){
    recids <- data %>%
      dplyr::pull(.data$recid) %>%
      unique()
  } else {
    recids <- NULL
  }

  # Set type
  demog_cols <- c(
    "sending_location","anon_chi","social_care_id","financial_year","gender",
    "dob","postcode","date_of_death","extract_date","consistent_quality","linking_id"
  )

  client_cols <- c(
    "anon_chi","social_care_id","sc_living_alone","sc_support_from_unpaid_carer",
    "sc_social_worker","sc_type_of_housing","sc_meals","sc_day_care","sc_dementia",
    "sc_learning_disability","sc_mental_health_disorders","sc_physical_and_sensory_disability",
    "sc_drugs","sc_alcohol","sc_palliative_care","sc_carer","sc_elderly_frail",
    "sc_neurological_condition","sc_autism","sc_other_vulnerable_groups","person_id",
    "linking_id"
  )

  # Infer type from RECID
  if (!is.null(recids)){
    type <- dplyr::case_when(
      any(recids %in% c("01B", "GLS")) ~ "acute",
      any(recids == "00B") ~ "outpatients",
      any(recids == "02B") ~ "maternity",
      any(recids == "04B") ~ "mh",
      any(recids == "AE2") ~ "ae",
      any(recids == "AT") ~ "at",
      any(recids == "CH") ~ "ch",
      any(recids == "CMH") ~ "cmh",
      any(recids == "DD") ~ "dd",
      any(recids == "DN") ~ "dn",
      any(recids == "HC") ~ "hc",
      any(recids == "HL1") ~ "homelessness",
      any(recids == "NRS") ~ "nrs_deaths",
      # any(recids == "NSU") ~ "nsu",
      any(recids == "OoH") ~ "gp_ooh",
      any(recids == "PIS") ~ "pis",
      any(recids == "SDS") ~ "sds",
      TRUE ~ NA_character_
    )
    # Infer type from columns
  } else if ("gpprac" %in% colnames(new_data)){
    type <- "gpprac_lookup"
  } else if ("postcode" %in% colnames(new_data)){
    type <- "postcode_lookup"
  } else if ("death_date_chi" %in% colnames(new_data)){
    type <- "chi_deaths"
  } else if (all(unlist(slfhelper::ltc_vars) %in% colnames(new_data))) {
    type <- "ltc"
  } else if (all(unlist(demog_cols) %in% colnames(new_data))) {
    type <- "sc_demog_lookup"
  } else if (all(unlist(client_cols) %in% colnames(new_data))) {
    type <- "client"
  }

  # Set year (must be provided for SC Client and LTC but can be overwridden for others)
  if (!type %in% c("client", "ltc")){
    if ("year" %in% colnames(new_data)){
      year <- new_data %>%
        dplyr::pull(.data$year) %>%
        unique()
      if (length(year) > 1){
        year <- "all"
      }
    } else {
      year <- "all"
    }
  }

  # Set all-year SC types
  if (type %in% c("at", "ch", "hc", "sds") && year == "all"){
    type <- glue::glue("sc_{type}_all")
  }

  # Set workbook and benchmark_comparison_type
  workbook <- ifelse(year == "all", "lookup", "extract")

  # 2. Process test ------------------------------------------------------------

  log_slf_event(stage = "test", status = "start", type = type, year = year)

  # Deal with years where we have no data (archived extracts)
  if (type %in% c("cmh", "dn")){
    if (identical(data, tibble::tibble())) {
      return(data)
    }
  }

  # Year-specific SC extracts
  if (type %in% c("at", "ch", "client", "hc", "sds")){
    if (check_year_valid(year, type)) {
      return(NULL)
    }
  }

  # Cost uplift
  if (type %in% c("acute", "ae", "maternity", "mh", "outpatients{")){
    data <- apply_cost_uplift(data)
  }

  # Rename HSCP
  if (type %in% c("acute", "ae", "at", "ch", "cmh", "dd", "dn", "ooh", "hc", "homelessness",
                  "maternity", "mh", "nrs_deaths", "outpatients", "pis", "sds")){
    data <- rename_hscp(data)
  }

  # Parameters for produce_source_extract_tests()
  sum_mean_vars <- c("beddays", "cost", "yearstay")
  max_min_vars <- c("record_keydate1", "record_keydate2","cost_total_net", "yearstay")
  add_hscp_count <- TRUE
  smr00_ep <- FALSE

  if (type %in% c("ae", "gp_ooh", "outpatients")) {
    sum_mean_vars <- "cost"
  }
  if (type %in% c("ae", "outpatients")){
    max_min_vars <- c("record_keydate1", "record_keydate2", "cost_total_net")
  }
  if (type == "outpatients"){
    add_hscp_count <- FALSE
    smr00_ep <- TRUE
  }

  test_function <- if (type %in% c(
    "acute", "ae", "ooh", "maternity", "mh", "outpatients"
  )) {
    function(data) produce_source_extract_tests(
      data,
      sum_mean_vars,
      max_min_vars,
      add_hscp_count,
      smr00_ep
    )
  } else {
    switch(
      type,
      "at" = produce_source_at_tests,
      "ch" = produce_source_ch_tests,
      "cmh" = produce_source_cmh_tests,
      "dd" = produce_source_dd_tests,
      "dn" = produce_source_dn_tests,
      "hc" = produce_source_hc_tests,
      "homelessness" = produce_slf_homelessness_tests,
      "chi_deaths" = produce_it_chi_deaths_tests,
      "gpprac_lookup" = produce_slf_gpprac_tests,
      "pc_lookup" = produce_slf_postcode_tests,
      "ltc" = produce_source_ltc_tests,
      "nrs_deaths" = produce_source_nrs_tests,
      "pis" = produce_source_pis_tests,
      "sc_at_all" = produce_sc_all_episodes_tests,
      "ac_ch_all" = produce_sc_all_episodes_tests,
      "sc_hc_all" = produce_sc_all_episodes_tests,
      "sc_sds_all" = produce_sc_all_episodes_tests,
      "client" = produce_tests_sc_client_lookup,
      "demog" = produce_sc_demog_lookup_tests,
      "sds" = produce_source_sds_tests
    )
  }

  # Get previous data to compare to
  old_data <- get_existing_data_for_tests(
    new_data = data,
    type = type,
    year = year,
    benchmark_run_id = benchmark_run_id,
    file_version = benchmark_comparison_type,
    file_location = file_location,
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE = BYOC_MODE
  )

  # Produce comparison
  comparison <- produce_test_comparison(
    old_data = test_function(old_data),
    new_data = test_function(data)
  ) %>%
    dplyr::mutate(
      benchmark_comparison_type = benchmark_comparison_type,
      benchmark_run_id = benchmark_run_id,
      run_id = run_id,
      run_date_time = run_date_time,
      dataset_name = type,
      year = year
    ) %>%
    dplyr::select(
      "year",
      "dataset_name",
      "measure",
      "value_old",
      "value_new",
      "difference",
      "pct_change",
      "issue",
      "run_id",
      "run_date_time",
      "benchmark_comparison_type",
      "benchmark_run_id"
    ) %>%
    # Write tests
    write_tests_xlsx(sheet_name = type, year, workbook_name = workbook, BYOC_MODE = BYOC_MODE)

  log_slf_event(stage = "test", status = "complete", type = type, year = year)

  return(comparison)
}
