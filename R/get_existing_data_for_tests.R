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
#' @param benchmark_run_id benchmark_run_id
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
  BYOC_MODE = FALSE
) {
  # 1. Check Parameters --------------------------------------------------------

  file_version <- match.arg(file_version, c("episode", "individual", "extract"))

  file_location <- match.arg(file_location, c("denodo", "hscdiip")) # TODO: Will this be in sourcedev?

  # Check data is being pulled from Denodo if in BYOC mode
  if (isTRUE(BYOC_MODE) && file_location == "hscdiip") {
    file_location <- "denodo"
    message("\u2139 Data must come from Denodo in BYOC mode.")
  }

  # Check benchmark_run_id is provided if pulling data from Denodo
  if (file_location == "denodo" && (is.na(benchmark_run_id) | is.null(denodo_connect))) {
    stop("`benchmark_run_id` and `denodo_connect` must be provided if using data from Denodo.")
  }

  # Look-ups cannot pull from episode/individual file
  # These extracts did not previously use get_existing_data_for_tests()
  # (client, demog, chi_deaths, ltc, pc_lookup, gpprac_lookup)
  if (file_version %in% c("episode", "individual") && (year == "all" | type %in% c("client", "ltc"))) {
    file_version <- "extract"
    message("\u2139 Look-ups and all-year social care extracts cannot be compared to the episode or individual file. Comparing to previous extract.")
  }

  # Year-specific previous extracts not stored in hscdiip
  if (file_version == "extract" && file_location == "hscdiip" && year != "all" && !type %in% c("client", "ltc")) {
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
    if (file_location == "denodo") {
      slf_data <- suppressMessages(read_slf_table(
        years = year,
        file_version = file_version,
        denodo_connect = denodo_connect,
        col_select = dplyr::all_of(variable_names),
        recids = recids,
        run_id = benchmark_run_id,
        BYOC_MODE = BYOC_MODE
      ))

      # Read file from hscdiip
    } else {
      # Episode
      if (file_version == "episode") {
        slf_data <- suppressMessages(slfhelper::read_slf_episode(
          year = year,
          recids = recids,
          col_select = dplyr::all_of(variable_names)
        ))
        # Individual
      } else {
        slf_data <- suppressMessages(slfhelper::read_slf_individual(
          year = year,
          col_select = dplyr::all_of(variable_names)
        ))
      }
    }

    # 3. Read previous extract ---------------------------------------------------
  } else if (file_version == "extract") {
    # Read extract from denodo
    if (file_location == "denodo") {
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
        type == "at" ~ get_sc_at_episodes_path(update = previous_update()), # BYOC_MODE = BYOC_MODE),
        type == "ch" ~ get_sc_ch_episodes_path(update = previous_update()), # BYOC_MODE = BYOC_MODE),
        type == "hc" ~ get_sc_hc_episodes_path(update = previous_update()), # BYOC_MODE = BYOC_MODE),
        type == "sds" ~ get_sc_sds_episodes_path(update = previous_update()), # BYOC_MODE = BYOC_MODE),
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
