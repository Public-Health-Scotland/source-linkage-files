#' Locality data
#'
#' @description Return the data for centrally held HSCP Localities.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_locality_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "hscp_locality", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  locality_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_hscp_localities_source")
  ) %>%
    # Rename variables
    dplyr::select(
      locality = "hscp_locality",
      datazone2011 = "datazone2011",
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "hscp_locality", year = "all")

  return(locality_data)
}
