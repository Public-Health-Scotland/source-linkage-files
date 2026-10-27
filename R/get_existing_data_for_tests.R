#' SLF Data for Testing
#'
#' @description Get the relevant data from the SLFs
#' use, the year, recid and variable names from the
#' 'new' data to make it as efficient as possible.
#'
#' @param new_data a [tibble][tibble::tibble-package] of the
#' new data which the SLF data will be compared to.
#' @param type Type code
#' @param year Financial year
#' @param benchmark_run_id
#' @param file_version whether to test against the "episode" file (the default)
#' or the "individual" file.
#' @param file_location denodo or hscdiip
#' @param denodo_connect Connection to Denodo
#' @param BYOC_MODE BYOC_MODE
#'
#' @return a [tibble][tibble::tibble-package] from the
#' SLF with the relevant recids and variables.
#'
#' @family test functions
#' @seealso produce_source_extract_tests
#' @export
get_existing_data_for_tests <- function(
    new_data,
    type,
    year,
    benchmark_run_id = NA,
    file_version = "episode",
    file_location = "denodo",
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE = FALSE) {

  # 1. Check Parameters --------------------------------------------------------

  file_version <- match.arg(file_version, c("episode", "individual", "extract"))

  file_location <- match.arg(file_location, c("denodo", "hscdiip")) # TODO: Will this be in sourcedev?

  # Check data is being pulled from Denodo if in BYOC mode
  if (isTRUE(BYOC_MODE) && file_location == "hscdiip"){
    file_location <- "denodo"
    message("\u2139 Data must come from Denodo in BYOC mode.")
  }

  # Check benchmark_run_id is provided if pulling data from Denodo
  if (file_location == "denodo" && (is.na(benchmark_run_id) | is.null(denodo_connect))){
    stop("`benchmark_run_id` must be provided if using data from Denodo.")
  }

  # Look-ups cannot pull from episode/individual file
  # These extracts did not previously use get_existing_data_for_tests()
  # (all_at, all_ch, all_hc, all_sds, client, demog, chi_deaths, ltc, pc_lookup, gpprac_lookup)
  if (file_version %in% c("episode", "individual") && (year == "all" | type %in% c("client", "ltc"))){
    file_version <- "extract"
    message("\u2139 Look-ups and all-year social care extracts cannot be compared to the episode or individual file. Comparing to previous extract.")
  }

  # Year-specific previous extracts not stored in hscdiip
  if (file_version == "extract" && file_location == "hscdiip" && year == "all" && !type %in% c("client", "ltc")){
    file_version <- "episode"
    message("\u2139 No previous extract in hscdiip. Comparing to episode file.")
  }

  message(glue::glue("\u2139 Retrieving {file_version} file from {file_location}..."))

  # 2. Read episode or individual file -----------------------------------------

  if (file_version %in% c("episode", "individual")) {

    # Get recid
    recids <- new_data %>%
      dplyr::pull(.data$recid) %>%
      unique()

    # Set columns to pull from episode file
    if (file_version == "episode") {
      variable_names <- c(
        "anon_chi",
        dplyr::intersect(slfhelper::ep_file_vars, tolower(names(new_data)))
      )
      if ("cost_total_net" %in% names(new_data)) {
        variable_names <- c(
          variable_names,
          "cost_total_net_inc_dnas"
        )
      }
      if ("hscp" %in% names(new_data)) {
        variable_names <- c("hscp2018", variable_names)
      }

      # Set columns to pull from individual file
    } else if (file_version == "individual") {
      variable_names <- c(
        "anon_chi",
        dplyr::intersect(slfhelper::indiv_file_vars, tolower(names(new_data)))
      )
    }

    # Read file from denodo
    if (file_location == "denodo"){
      slf_data <- suppressMessages(read_slf_table(
        years = year,
        file_version = file_version,
        denodo_connect = denodo_connect,
        col_select = all_of(variable_names),
        recids = recids,
        BYOC_MODE = BYOC_MODE
      ))

      # Read file from hscdiip
    } else {
      # Episode
      if (file_version == "episode") {
        slf_data <- suppressMessages(slfhelper::read_slf_episode(
          year = year,
          recids = recids,
          col_select = all_of(variable_names)
        ))
        # Individual
      } else {
        slf_data <- suppressMessages(slfhelper::read_slf_individual(
          year = year,
          col_select = all_of(variable_names)
        ))
      }
    }

    # 3. Read previous extract ---------------------------------------------------

  } else if (file_version == "extract") {

    # Read extract from denodo
    if (file_location == "denodo"){
      slf_data <- get_previous_extract(
        type = type,
        year = year,
        benchmark_run_id = benchmark_run_id,
        denodo_connect = denodo_connect,
        BYOC_MODE = BYOC_MODE
      )

      # Read extract from hscdiip
    } else {
      filepath <- dplyr::case_when(
        type == "chi_deaths" ~ get_slf_chi_deaths_path(update = previous_update(), BYOC_MODE = BYOC_MODE),
        type == "gpprac_lookup" ~ get_slf_gpprac_path(update = previous_update(), BYOC_MODE = BYOC_MODE),
        type == "postcode_lookup" ~ get_slf_postcode_path(update = previous_update(), BYOC_MODE = BYOC_MODE),
        type == "at" ~ get_sc_at_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
        type == "ch" ~ get_sc_ch_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
        type == "hc" ~ get_sc_hc_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
        type == "sds" ~ get_sc_sds_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
        type == "sc_demog_lookup" ~ get_sc_demog_lookup_path(update = previous_update()), # BYOC_MODE = BYOC_MODE),
        type == "ltc" ~ get_ltcs_path(year, update = previous_update(), BYOC_MODE = BYOC_MODE),
        type == "client" ~ get_sc_client_lookup_path(year, update = previous_update(), BYOC_MODE = BYOC_MODE),
        TRUE ~ NA_character_
      )
      slf_data <- read_file(filepath)
    }
  }
  return(slf_data)
}




#' SLF Data for Testing
#'
#' @description Get the relevant data from the SLFs
#' use, the year, recid and variable names from the
#' 'new' data to make it as efficient as possible.
#'
#' @param new_data a [tibble][tibble::tibble-package] of the
#' new data which the SLF data will be compared to.
#' @param year
#' @param benchmark_run_id
#' @param file_version whether to test against the "episode" file (the default)
#' or the "individual" file.
#' @param file_location
#' @param denodo_connect
#' @param BYOC_MODE
#'
#' @return a [tibble][tibble::tibble-package] from the
#' SLF with the relevant recids and variables.
#'
#' @family test functions
#' @seealso produce_source_extract_tests
#' @export
# get_existing_data_for_tests <- function(
#     new_data,
#     year = "all",
#     benchmark_run_id = NA, # ???
#     file_version = "episode",
#     file_location = "denodo",
#     denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
#     BYOC_MODE = FALSE) {
#
#   # 1. Check Parameters --------------------------------------------------------
#
#   file_version <- match.arg(file_version, c("episode", "individual", "extract"))
#
#   file_location <- match.arg(file_location, c("denodo", "hscdiip")) # TODO: Will this be in sourcedev?
#
#   # Check data is being pulled from Denodo if in BYOC mode
#   if (isTRUE(BYOC_MODE) && file_location == "hscdiip"){
#     file_location <- "denodo"
#     message("\u2139 Data must come from Denodo in BYOC mode.")
#   }
#
#   # # Check file_version is not extract if pulling data from hscdiip
#   # if (file_version == "extract" && file_location == "hscdiip") {
#   #   stop("Extracts are only available on Denodo.")
#   # }
#
#   # Check benchmark_run_id and denodo_connect are provided if pulling data from Denodo
#   if (file_location == "denodo" && (is.na(benchmark_run_id) | is.null(denodo_connect))){
#     stop("`benchmark_run_id` must be provided if using data from Denodo.")
#   }
#
#   # Set recid
#   if ("recid" %in% colnames(new_data)){
#     recids <- new_data %>%
#       dplyr::pull(.data$recid) %>%
#       unique()
#   } else {
#     recids <- NA
#   }
#
#   demog_cols <- c(
#     "sending_location","anon_chi","social_care_id","financial_year","gender",
#     "dob","postcode","date_of_death","extract_date","consistent_quality","linking_id"
#   )
#
#   client_cols <- c(
#     "anon_chi","social_care_id","sc_living_alone","sc_support_from_unpaid_carer",
#     "sc_social_worker","sc_type_of_housing","sc_meals","sc_day_care","sc_dementia",
#     "sc_learning_disability","sc_mental_health_disorders","sc_physical_and_sensory_disability",
#     "sc_drugs","sc_alcohol","sc_palliative_care","sc_carer","sc_elderly_frail",
#     "sc_neurological_condition","sc_autism","sc_other_vulnerable_groups","person_id",
#     "linking_id"
#   )
#
#   # Infer type from RECID
#   if (!is.na(recids)){
#     type <- dplyr::case_when(
#       any(recids %in% c("01B", "GLS")) ~ "acute",
#       any(recids == "00B") ~ "outpatients",
#       any(recids == "02B") ~ "maternity",
#       any(recids == "04B") ~ "mh",
#       any(recids == "AE2") ~ "ae",
#       any(recids == "AT") ~ "at",
#       any(recids == "CH") ~ "ch",
#       any(recids == "CMH") ~ "cmh",
#       any(recids == "DD") ~ "dd",
#       any(recids == "DN") ~ "dn",
#       any(recids == "HC") ~ "hc",
#       any(recids == "HL1") ~ "homelessness",
#       any(recids == "NRS") ~ "nrs_deaths",
#       # any(recids == "NSU") ~ "nsu",
#       any(recids == "OoH") ~ "gp_ooh",
#       any(recids == "PIS") ~ "pis",
#       any(recids == "SDS") ~ "sds",
#       TRUE ~ NA_character_
#     )
#     # Infer type from columns
#   } else if ("gpprac" %in% colnames(new_data)){
#     type <- "gpprac_lookup"
#   } else if ("postcode" %in% colnames(new_data)){
#     type <- "postcode_lookup"
#   } else if ("death_date_chi" %in% colnames(new_data)){
#     type <- "chi_deaths"
#   } else if (all(unlist(slfhelper::ltc_vars) %in% colnames(new_data))) {
#     type <- "ltc"
#   } else if (all(unlist(demog_cols) %in% colnames(new_data))) {
#     type <- "sc_demog_lookup"
#   } else if (all(unlist(client_cols) %in% colnames(new_data))) {
#     type <- "client"
#   }
#
#   # Check year
#   if (year == "all" && type %in% c("client", "ltc")){
#     stop("The year argument must be supplied for this extract.")
#   } else if ("year" %in% colnames(new_data)){
#     years_in_data <- new_data %>%
#       dplyr::pull(.data$year) %>%
#       unique()
#     if (length(years_in_data) > 1){
#       years_in_data <- "all"
#     }
#   } else {
#     years_in_data <- "all"
#   }
#
#   if (years_in_data != year){
#     year <- years_in_data
#     message(glue::glue("\u2139 The wrong year has been supplied. Using {year}."))
#   }
#
#   # Cannot pull from episode/individual file if there is no recid or if non-year-specific
#   # These extracts did not previously use get_existing_data_for_tests()
#   # (at, ch, hc, sds, client, demog, chi_deaths, ltc, pc_lookup, gpprac_lookup)
#   if (file_version %in% c("episode", "individual") && (is.na(recids) | year == "all")){
#     file_version <- "extract"
#     message("\u2139 Look-ups and all-year social care extracts cannot be compared to the episode or individual file. Comparing to previous extract.")
#   }
#
#   # Year-specific previous extracts not stored in hscdiip
#   if (file_version == "extract" && file_location == "hscdiip" && (!is.na(recids) | year != "all")){
#     file_version <- "episode"
#     message("\u2139 No previous extract in hscdiip. Comparing to episode file.")
#   }
#
#   message(glue::glue("\u2139 Retrieving {file_version} file from {file_location}..."))
#
#   # 2. Read episode or individual file -----------------------------------------
#
#   if (file_version %in% c("episode", "individual")) {
#
#     # Set columns to pull from episode file
#     if (file_version == "episode") {
#       variable_names <- c(
#         "anon_chi",
#         dplyr::intersect(slfhelper::ep_file_vars, tolower(names(new_data)))
#       )
#       if ("cost_total_net" %in% names(new_data)) {
#         variable_names <- c(
#           variable_names,
#           "cost_total_net_inc_dnas"
#         )
#       }
#       if ("hscp" %in% names(new_data)) {
#         variable_names <- c("hscp2018", variable_names)
#       }
#
#     # Set columns to pull from individual file
#     } else if (file_version == "individual") {
#       variable_names <- c(
#         "anon_chi",
#         dplyr::intersect(slfhelper::indiv_file_vars, tolower(names(new_data)))
#       )
#     }
#
#     # Read file from denodo
#     if (file_location == "denodo"){
#       slf_data <- suppressMessages(read_slf_table(
#         years = year,
#         file_version = file_version,
#         denodo_connect = denodo_connect,
#         col_select = all_of(variable_names),
#         recids = recids,
#         BYOC_MODE = BYOC_MODE
#       ))
#
#     # Read file from hscdiip
#     } else {
#       # Episode
#       if (file_version == "episode") {
#         slf_data <- suppressMessages(slfhelper::read_slf_episode(
#           year = year,
#           recids = recids,
#           col_select = all_of(variable_names)
#         ))
#       # Individual
#       } else {
#         slf_data <- suppressMessages(slfhelper::read_slf_individual(
#           year = year,
#           col_select = all_of(variable_names)
#         ))
#       }
#     }
#
#   # 3. Read previous extract ---------------------------------------------------
#
#   } else if (file_version == "extract") {
#
#     # Read extract from denodo
#     if (file_location == "denodo"){
#       slf_data <- get_previous_extract(
#         type = type,
#         year = year,
#         benchmark_run_id = benchmark_run_id,
#         denodo_connect = denodo_connect,
#         BYOC_MODE = BYOC_MODE
#       )
#
#     # Read extract from hscdiip
#     } else {
#       filepath <- dplyr::case_when(
#         type == "chi_deaths" ~ get_slf_chi_deaths_path(update = previous_update(), BYOC_MODE = BYOC_MODE),
#         type == "gpprac_lookup" ~ get_slf_gpprac_path(update = previous_update(), BYOC_MODE = BYOC_MODE),
#         type == "postcode_lookup" ~ get_slf_postcode_path(update = previous_update(), BYOC_MODE = BYOC_MODE),
#         # TODO: These will need to change when relevant branches are merged into development
#         type == "at" ~ get_sc_at_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
#         type == "ch" ~ get_sc_ch_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
#         type == "hc" ~ get_sc_hc_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
#         type == "sds" ~ get_sc_sds_episodes_path(update = previous_update()),# BYOC_MODE = BYOC_MODE),
#         type == "sc_demog_lookup" ~ get_sc_demog_lookup_path(update = previous_update()), # BYOC_MODE = BYOC_MODE),
#         type == "ltc" ~ get_ltcs_path(year, update = previous_update(), BYOC_MODE = BYOC_MODE),
#         type == "client" ~ get_sc_client_lookup_path(year, update = previous_update(), BYOC_MODE = BYOC_MODE),
#         TRUE ~ NA_character_
#       )
#       slf_data <- read_file(filepath)
#     }
#   }
#   return(slf_data)
# }
