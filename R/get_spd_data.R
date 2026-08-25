#' Scottish Postcode Directory data
#'
#' @description Return the data for centrally held Scottish Postcode Directory
#' (SPD).
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_spd_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "spd", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  spd_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_spd_source")
  ) %>%
    # Rename variables
    dplyr::select(
      "pc7",
      "pc8",
      "datazone2011",
      "datazone2022",
      "hb2019",
      "hb2018",
      "hb2014",
      "hb2006",
      "hscp2019",
      "hscp2018",
      "hscp2016",
      "ca2019",
      "ca2018",
      "ca2011",
      "hb1995",
      "ur8_2022",
      "ur6_2022",
      "ur3_2022",
      "ur2_2022"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "spd", year = "all")

  return(spd_data)
}
