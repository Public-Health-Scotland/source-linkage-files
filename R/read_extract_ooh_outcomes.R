#' Read GP OOH Outcomes extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Outcomes extract data
read_extract_ooh_outcomes <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "gp_ooh-o", year = year)

  # Check and convert to calendar year
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (!check_year_valid(year, type = "gpooh")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  outcomes_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gp_ooh_outcome_source")
  ) %>%
    # Filter by calendar year
    dplyr::filter(
      .data$sc_start_financial_year == !!c_year,
      .data$case_outcome != "",
      .data$out_of_hours_services_flag == "Y"
    ) %>%
    # Rename variables
    dplyr::select(
      ooh_case_id = "guid",
      outcome = "case_outcome"
    ) %>%
    # Collect
    dplyr::collect() %>%
    # Convert " " to NA
    dplyr::mutate(across(where(is.character), ~ na_if(.x, " "))) %>%
    dplyr::distinct()

  log_slf_event(stage = "read", status = "complete", type = "gp_ooh-o", year = year)

  return(outcomes_extract)
}
