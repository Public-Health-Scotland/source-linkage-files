#' get uk postcode list file data
#' @description get uk postcode list file
#' @param denodo_connect connection to denodo
#' @param BYOC_MODE BYOC_MODE
#' @family lookup file paths
get_uk_postcode_data <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                 BYOC_MODE) {
  log_slf_event(stage = "read", status = "start", type = "uk_postcode", year = "all")

  # Disconnect from Denodo
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  extract_uk_pc <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_uk_postcode_list_source")
  ) %>%
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "uk_postcode", year = "all")

  return(extract_uk_pc)
}
