#' HHG Extract File Path
#'
#' @description Get the path to the HHG extract
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the HHG extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_hhg_path <- function(year, ...) {
  if (!check_year_valid(year, "hhg")) {
    return(get_dummy_boxi_extract_path())
  }

  hhg_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "HHG"),
    file_name = stringr::str_glue("anon-HHG-20{year}.parquet"),
    ...
  )

  return(hhg_file_path)
}

#' SPARRA Extract File Path
#'
#' @description Get the path to the SPARRA extract
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the SPARRA extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_sparra_path <- function(year, ...) {
  if (!check_year_valid(year, "sparra")) {
    return(get_dummy_boxi_extract_path())
  }

  sparra_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "SPARRA"),
    file_name = stringr::str_glue("anon-SPARRA-20{year}.parquet"),
    ...
  )

  return(sparra_file_path)
}


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

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  if (isTRUE(BYOC_MODE)) {
    extract_sparra <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_sparra_source")
    ) %>%
      # Filter on projection variable: `risk_financial_year` e.g.
      # 01-04-2025 relates to financial year 2025/26.
      dplyr::filter(risk_financial_year == c_year) %>%
      dplyr::collect()
  } else {
    extract_sparra <- read_file(get_sparra_path(year))
  }
  return(extract_sparra)
}
