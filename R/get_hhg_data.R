#' HHG data
#'
#' @description Return the data for HHG.
#'
#' @param year Financial year
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
get_hhg_data <- function(
  year,
  denodo_connect = denodo_connect,
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "hhg", year = "all")

  # Specify years available for running
  if (!check_year_valid(year, type = "hhg")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  extract_hhg <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_hhg_source")
  ) %>%
    # Filter by year
    dplyr::filter(financial_year == year) %>%
    # Select columns
    dplyr::select(
      anon_chi = "anon_chi",
      hhg_score = "hhg_score"
    ) %>%
    # Collect
    dplyr::collect() %>%
    # Convert "NA" to NA
    dplyr::mutate(across(where(is.character), ~ na_if(.x, "NA")))

  return(extract_hhg)
}
