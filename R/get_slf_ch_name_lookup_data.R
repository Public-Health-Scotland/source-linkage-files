#' SLF Care Home Lookup data
#'
#' @description Return data from the Care Home name lookup, which
#' has official Care Home names and addresses provided by the Care Inspectorate.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC_MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_slf_ch_name_lookup_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "ch_name_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  extract_ch_name_lookup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_ch_name_lookup_source")
  ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "ch_name_lookup", year = "all")

  return(extract_ch_name_lookup)
}
