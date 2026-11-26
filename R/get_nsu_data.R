#' Non-Service User data
#'
#' @description Return the data for Non-Service Users.
#'
#' @param year Financial year
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
get_nsu_data <- function(
    year,
    denodo_connect = denodo_connect,
    BYOC_MODE
  ) {
  log_slf_event(stage = "read", status = "start", type = "nsu", year = year)

  # Specify years available for running
  if (!check_year_valid(year, type = "nsu")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read data
  nsu_data <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_nsu_source")
  ) %>%
    # Filter by year
    dplyr::filter(financial_year == year) %>%
    # Select columns
    dplyr::select(
      year = "financial_year",
      anon_chi = "patient_chi",
      postcode = "patient_postcode",
      gpprac = "gpprac",
      dob = "patient_dob",
      gender = "patient_sex"
    ) %>%
    # Collect
    dplyr::collect() %>%
    # Convert "NA" to NA
    mutate(across(where(is.character), ~ na_if(.x, "NA"))) %>%
    # Data type modification
    dplyr::mutate(
      gender = as.numeric(gender)
    )

  log_slf_event(stage = "read", status = "complete", type = "nsu", year = year)

  return(nsu_data)
}

