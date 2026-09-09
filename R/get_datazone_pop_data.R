#' DataZone population data
#'
#' @description Return the data for DataZone population estimates.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_datazone_pop_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "datazone_pop", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  datazone_pop_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_datazone_population_source")
  ) %>%
    # Rename variables
    dplyr::select(
      year = "year",
      datazone2011 = "datazone2011",
      sex = "sex",
      dplyr::starts_with("age")
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "datazone_pop", year = "all")

  return(datazone_pop_data)
}
