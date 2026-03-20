#' Read GP OOH Outcomes extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Outcomes extract data
read_extract_ooh_outcomes <- function(year,
                                      denodo_connect, # TO-DO: will be hardcoded to denodo_connect = get_denodo_connection()
                                      file_path = get_boxi_extract_path(year = year, type = "gp_ooh-o", BYOC_MODE),
                                      BYOC_MODE) {
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  }

  ## Load extract file
  outcomes_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gp_ooh_outcome_source")
  ) %>%
    dplyr::filter(
      sc_start_financial_year == !!c_year & # TO-DO: sc_start_financial_year is missing in denodo view
        !is.na(case_outcome) &
        case_outcome != "" & # TO-DO: Might be redundant since it is same as filter above done in BOXI but this filtering is also done in the R code.
        out_of_hours_services_flag == "Y" # TO-DO: out_of_hours_services_flag is missing in denodo view
    ) %>%
    dplyr::select(
      ooh_case_id = "guid",
      outcome = "case_outcome"
    ) %>%
    dplyr::collect() %>%
    dplyr::distinct()

  DBI::dbDisconnect(denodo_connect)

  return(outcomes_extract)
}
