#' Homelessness Completeness SG publication figures
#'
#' @description Return the data for Homelessness Completeness lookup.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_sg_pub_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE = BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "homelessness_completeness", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  sg_pub_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_homelessness_completeness_source")
  ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "homelessness_completeness", year = "all")

  return(get_sg_pub_data)
}
