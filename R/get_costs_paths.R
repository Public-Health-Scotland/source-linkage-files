#' Care Home Costs File Path
#'
#' @description Get the full Care Home costs lookup path
#'
#' @param ... additional arguments passed to [get_file_path()]
#' @param update passed through [latest_update()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_ch_costs_path <- function(..., update = NULL) {
  ch_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue(
      "Cost_CH_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.parquet"
    ),
    ...
  )

  return(ch_costs_path)
}

#' Processed District Nursing Costs File Path
#'
#' @description Get the processed District Nursing costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the processed costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_costs_path <- function(BYOC_MODE, ...) {
  if (isTRUE(BYOC_MODE)) {
    dn_costs_path <- file.path(
      denodo_output_path(),
      stringr::str_glue("cost_dn_lookup.parquet")
    )
  } else {
    dn_costs_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Costs"),
      file_name = stringr::str_glue(
        "Cost_DN_Lookup.parquet"
      ),
      ...
    )
  }
  return(dn_costs_path)
}

#' Raw District Nursing Costs File Path - LOCAL ONLY
#'
#' @description Get the raw District Nursing costs path - LOCAL ONLY
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the local raw costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_raw_costs_path <- function(...) {
  dn_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("DN_Costs.xlsx"),
    ...
  )

  return(dn_raw_costs_path)
}

#' Raw District Nursing Costs Data
#'
#' @description Return the data for District Nursing raw costs.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_dn_raw_costs_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "dn_cost_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  dn_raw_costs_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_dn_cost_lookup_source")
  ) %>%
    # Rename variables
    dplyr::select(
      hb2019 = "hb2019",
      board_name = "board_name",
      board_cypher = "board_cypher",
      year = "year",
      cost = "cost"
    ) %>%
    # Collect
    dplyr::collect() %>%
    # Data type modification
    dplyr::mutate(
      year = check_year_format(.data$year)
    )

  log_slf_event(stage = "read", status = "complete", type = "dn_cost_lookup", year = "all")

  return(dn_raw_costs_data)
}

#' District Nursing Contacts File Path - LOCAL ONLY
#'
#' @description Get the District Nursing contacts path - LOCAL ONLY
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the local contacts lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_contacts_path <- function(...) {
  dn_contacts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("DN-Contacts-Numbers-for-Costs.csv"),
    ...
  )

  return(dn_contacts_path)
}

#' District Nursing Contacts Data
#'
#' @description Return the data for District Nursing contacts.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_dn_contacts_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "dn_contact_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  dn_contacts_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_dn_contacts_source")
  ) %>%
    # Rename variables
    dplyr::select(
      contact_financial_year = "contact_financial_year",
      hb2019 = "treatment_nhs_board_code_9",
      treatment_nhs_board_name = "treatment_nhs_board_name",
      number_of_contacts = "number_of_contacts"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "dn_contact_lookup", year = "all")

  return(dn_contacts_data)
}

#' GP Out of Hours Costs File Path
#'
#' @description Get the full GP Out of Hours costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_gp_ooh_costs_path <- function(..., update = NULL) {
  gp_ooh_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue(
      "Cost_GPOoH_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.parquet"
    ),
    ...
  )

  return(gp_ooh_costs_path)
}

#' Raw GP OoH Costs File Path
#'
#' @description Get the GP Out of Hours raw costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_gp_ooh_raw_costs_path <- function(...) {
  gp_ooh_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("OOH_Costs.xlsx"),
    ...
  )

  return(gp_ooh_raw_costs_path)
}

#' Full Home Care Costs File Path
#'
#' @description Get the full Home Care costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_hc_costs_path <- function(..., update = NULL) {
  hc_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue(
      "costs_hc_lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.parquet"
    ),
    ...
  )

  return(hc_costs_path)
}

#' Raw Home Care Costs File Path
#'
#' @description Get the Home Care raw costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_hc_raw_costs_path <- function(...) {
  hc_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("hc_costs.xlsx"),
    ...
  )

  return(hc_raw_costs_path)
}
