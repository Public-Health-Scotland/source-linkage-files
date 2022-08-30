#' IT Long Term Conditions File Path
#'
#' @description Get the full path to the IT Long Term Conditions extract
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the LTC extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_ltc_path <- function(...) {
  it_ltc_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name_regexp = "SCTASK[0-9]{7}_LTCs\\.csv(?:\\.gz)?",
    ...
  )

  return(it_ltc_path)
}

#' IT Deaths File Path
#'
#' @description Get the full path to the IT Deaths extract
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the IT Deaths extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_deaths_path <-
  function(...) {
    it_deaths_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts"),
      file_name_regexp = "SCTASK[0-9]{7}_Deaths\\.csv(?:\\.gz)?",
      ...
    )

    return(it_deaths_path)
  }

#' IT Prescribing File Path
#'
#' @description Get the full path to the IT PIS extract
#'
#' @param year the year for the required extract
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the PIS extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_prescribing_path <-
  function(year, ...) {
    it_pis_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts"),
      file_name_regexp = glue::glue("SCTASK[0-9]{{7}}_PIS_{convert_fyyear_to_year(year)}.csv(?:\\.gz)?")
    )

    return(it_pis_path)
  }
