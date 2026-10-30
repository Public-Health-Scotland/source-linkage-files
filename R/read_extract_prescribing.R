#' Read Prescribing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_prescribing <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "pis", year = year)

  # Check and convert to calendar year
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year) # TODO: Remove?

  # Specify years available for running
  if (!check_year_valid(year, type = "pis")) {
    return(tibble::tibble())
  }

  # Denodo disconnect
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read extract
  pis_file <- dplyr::tbl(
    denodo_connect,
    # TODO: CHANGE TABLE NAME WHEN WE GET SOURCE DATA
    dbplyr::in_schema("sdl", "sdl_pis_static")
  ) %>%
    # Filter by calendar year
    # TODO: UNCOMMENT WHEN WE GET SOURCE DATA
    dplyr::filter(
      .data$financial_year == as.integer(year)
    ) %>%
    # Rename variables
    dplyr::select(
      chi = "patient_chi",
      dob = "patient_dob",
      gender = "patient_sex",
      postcode = "patient_postcode",
      gpprac = "practice_code",
      no_paid_items = "no_of_paid_items",
      cost_total_net = "pd_paid_gic_excl"
    ) %>%
    # Collect and get anonymous CHI
    dplyr::collect() %>%
    # TODO: UNCOMMENT WHEN WE GET SOURCE DATA
    # slfhelper::get_anon_chi("chi") %>%
    # TODO: CHECK THIS IS STILL A DATE IN THE SOURCE DATA
    # Data type modification
    # dplyr::mutate(
    #   dob = lubridate::as_date(.data$dob)
    # )
    # TODO: REMOVE
    dplyr::rename(anon_chi = chi) %>%
    dplyr::mutate(
      gender = as.numeric(gender),
      gpprac = as.numeric(gpprac),
      no_paid_items = as.numeric(no_paid_items),
      cost_total_net = as.numeric(cost_total_net)
    )

  log_slf_event(stage = "read", status = "complete", type = "pis", year = year)

  return(pis_file)
}
