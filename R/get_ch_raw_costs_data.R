#' Raw Care Home Costs Data
#'
#' @description Return the data for Care Home raw costs.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_ch_raw_costs_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "ch_costs", year = "all")

  # Disconnect from denodo
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  raw_ch_costs_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_carehomecostopendata_source")
  ) %>%
    # Rename variables
    janitor::clean_names() %>%
    dplyr::select(
      year = "year",
      council_area_code = "council_area_code",
      funding_source = "funding_source",
      nursing_care_provision = "nursing_care_provision",
      cost_per_week = "value"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "ch_costs", year = "all")

  return(raw_ch_costs_data)
}
