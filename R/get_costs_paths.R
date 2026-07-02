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

#' District Nursing Costs File Path
#'
#' @description Get the full District Nursing costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_costs_path <- function(BYOC_MODE, ..., update = NULL) {
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

#' Raw District Nursing Costs File Path
#'
#' @description Get the District Nursing raw costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
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
#' @param file_path Path to local District Nursing raw costs file
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_dn_raw_costs_data <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                  file_path = get_dn_raw_costs_path(),
                                  BYOC_MODE) {
  if (isTRUE(BYOC_MODE)) {
    log_slf_event(stage = "read", status = "start", type = "dn_cost_lookup", year = "all")

    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    dn_raw_costs_data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_dn_costs_source") # TODO: Check table name, column names/data types and whether we need to select columns.
      ) %>%
      dplyr::collect() %>%
      janitor::clean_names()

    log_slf_event(stage = "read", status = "complete", type = "dn_cost_lookup", year = "all")
  } else {

    dn_raw_costs_data <- openxlsx::read.xlsx(get_dn_raw_costs_path()) %>%
      janitor::clean_names() %>%
      # Change 1718 type to numeric - reads in as a character
      dplyr::mutate(across(ends_with("_cost"), as.numeric)) %>%
      tidyr::pivot_longer(
        ends_with("_cost"),
        names_to = "year",
        names_pattern = "(\\d{4})_cost",
        values_to = "cost"
      )
  }

  return(dn_raw_costs_data) # TODO: Check data is the same when BYOC_MODE is TRUE and FALSE
}

#' District Nursing Contacts File Path
#'
#' @description Get the District Nursing contacts path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the contacts lookup as an [fs::path()]
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
#' @param file_path Path to local District Nursing contacts file
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_dn_contacts_data <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                 file_path = get_dn_contacts_path(),
                                 BYOC_MODE) {
  if (isTRUE(BYOC_MODE)) {
    log_slf_event(stage = "read", status = "start", type = "dn_contact_lookup", year = "all")

    on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

    dn_contacts_data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_dn_contacts_source") # TODO: Check table name, column names/data types and whether we need to select columns.
    ) %>%
      dplyr::collect() %>%
      janitor::clean_names() %>%
      dplyr::mutate(year = convert_year_to_fyyear(contact_financial_year)) %>%
      dplyr::rename(
        hb2019 = treatment_nhs_board_code_9,
        number_of_contacts = number_of_contacts
      )

    log_slf_event(stage = "read", status = "complete", type = "dn_contact_lookup", year = "all")
  } else {

    dn_contacts_data <- createslf::read_file(get_dn_contacts_path()) %>%
      janitor::clean_names() %>%
      dplyr::mutate(year = convert_year_to_fyyear(contact_financial_year)) %>%
      dplyr::rename(
        hb2019 = treatment_nhs_board_code_9,
        number_of_contacts = number_of_contacts
      )
  }

  return(dn_contacts_data) # TODO: Check output is the same when BYOC_MODE is TRUE and FALSE
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
