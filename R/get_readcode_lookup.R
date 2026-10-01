#' Read Code Lookup
#'
#' @description Return the data for Read Code lookup.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_readcode_lookup <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "readcode_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  readcode_lookup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_read_code_lookup_source")
  ) %>%
    # Rename variables
    dplyr::select(
      readcode = "readcode",
      description = "description"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "readcode_lookup", year = "all")

  return(readcode_lookup)

}
