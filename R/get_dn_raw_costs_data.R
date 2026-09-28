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
