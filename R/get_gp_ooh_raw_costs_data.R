#' Raw GP Out Of Hours Costs Data
#'
#' @description Return the data for GP OOH raw costs.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_gp_ooh_raw_costs_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "ooh_cost_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  ooh_raw_costs_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_ooh_cost_lookup_source")
  ) %>%
    # Rename variables
    dplyr::select(
      HB2019 = "hb2019",
      Board_Name = "board_name",
      Board_Cypher = "board_cypher",
      year = "year",
      Consultations = "consultations",
      Cost = "cost"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "ooh_cost_lookup", year = "all")

  return(ooh_raw_costs_data)
}
