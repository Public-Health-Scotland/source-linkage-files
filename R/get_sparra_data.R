#' SPARRA Extract File data
#'
#' @description Get the path to the SPARRA extract
#'
#' @param year Year of extract
#' @param denodo_connect connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return The path to the SPARRA extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_sparra_data <- function(year,
                            denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                            BYOC_MODE) {
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  log_slf_event(stage = "read", status = "start", type = "sparra", year = year)

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  extract_sparra <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_sparra_source")
  ) %>%
    # Filter on projection variable: `risk_financial_year` e.g.
    # 01-04-2025 relates to financial year 2025/26.
    dplyr::filter(risk_financial_year == c_year) %>%
    dplyr::collect() %>%
    slfhelper::get_anon_chi("patient_chi")

  log_slf_event(stage = "read", status = "complete", type = "sparra", year = year)

  return(extract_sparra)
}

