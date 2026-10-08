#' GP Practice Geography Labels (PHS Open Data)
#'
#' @description Return the data for GP Practice Geography Labels
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_geography_labels <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE = FALSE
) {
  log_slf_event(stage = "read", status = "start", type = "gpprac_opendata", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  geography_labels <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_geography_labels_source")
  ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "gpprac_opendata", year = "all")

  return(geography_labels)
}
