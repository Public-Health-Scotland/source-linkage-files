#' SIMD data
#'
#' @description Return the data for centrally held Scottish Index of Multiple
#' Deprivation (SIMD).
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_simd_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "simd", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  simd_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_simd_source")
  ) %>%
    # Rename variables
    # When a new version of the SIMD is released,
    # the column names within the file will change.
    dplyr::select(
      pc7 = "pc7",
      simd2020v2_rank = "simd2020v2_rank",
      simd2020v2_sc_decile = "simd2020v2_sc_decile",
      simd2020v2_sc_quintile = "simd2020v2_sc_quintile",
      simd2020v2_hb2019_decile = "simd2020v2_hb2019_decile",
      simd2020v2_hb2019_quintile = "simd2020v2_hb2019_quintile",
      simd2020v2_hscp2019_decile = "simd2020v2_hscp2019_decile",
      simd2020v2_hscp2019_quintile = "simd2020v2_hscp2019_quintile"
    ) %>%
    # Collect
    dplyr::collect()

  log_slf_event(stage = "read", status = "complete", type = "simd", year = "all")

  return(simd_data)
}
