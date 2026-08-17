#' GP Practice Reference data
#'
#' @description Return the data for GP Practice Reference.
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_gpprac_ref_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "gpprac_ref_data", year = "all")

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  gpprac_ref_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gpprac_lookup_source") # TODO: rename sdl table
  ) %>%
    # Rename variables
    dplyr::select(
      gpprac = "praccode",
      pc7 = "postcode"
    ) %>%
    # Collect
    dplyr::collect() %>%
    dplyr::mutate(
      pc7 = phsmethods::format_postcode(.data$pc7, format = "pc7")
    )

  log_slf_event(stage = "read", status = "complete", type = "gpprac_ref_data", year = "all")

  return(gpprac_ref_data)
}
