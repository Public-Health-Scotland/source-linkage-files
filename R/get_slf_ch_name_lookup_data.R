#' SLF Care Home Lookup data
#'
#' @description Return data from the Care Home name lookup, which
#' has official Care Home names and addresses provided by the Care Inspectorate.
#'
#' @param denodo_connect connection to denodo
#' @param BYOC_MODE BYOC_MODE
#'
#' @return The path to the Care Home lookup as a dataframe
#' @export
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_ch_name_lookup_data <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                        BYOC_MODE) {
  log_slf_event(stage = "read", status = "start", type = "ch_name_lookup", year = "all")
  # Disconnect from Denodo
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  extract_ch_name_lookup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_ch_name_lookup_source")
  ) %>%
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "ch_name_lookup", year = "all")
  return(extract_ch_name_lookup)
}
