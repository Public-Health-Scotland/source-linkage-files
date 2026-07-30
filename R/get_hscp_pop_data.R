#' HSCP population data
#'
#' @description Return the data for HSCP population estimates.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_hscp_pop_data <- function(
    denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
    BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "hscp_pop_lookup", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  hscp_pop_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_hscp_population_source")
  ) %>%
    # Select only the HSCPs for NHS Highland & years since 2015
    dplyr::filter(
      hscp2019 %in% c("S37000004", "S37000016"),
      year >= 2015L
    ) %>%
    # Rename variables
    dplyr::select(
      year = "year",
      hscp2019 = "hscp2019",
      hscp2019_name = "hscp2019_name",
      hscp2018 = "hscp2018",
      hscp2016 = "hscp2016",
      age = "age",
      sex = "sex",
      sex_name = "sex_name",
      pop = "pop"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "hscp_pop_lookup", year = "all")

  return(hscp_pop_data)
}




