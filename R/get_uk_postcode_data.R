#' UK Postcode List data
#'
#' @description Return the data for the UK Postcode List.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC_MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup file paths
get_uk_postcode_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "uk_postcode", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  extract_uk_pc <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_uk_postcode_list_source")
  ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "uk_postcode", year = "all")

  return(extract_uk_pc)
}
