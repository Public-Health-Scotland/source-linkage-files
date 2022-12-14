
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
  hhg_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "HHG"),
    file_name = glue::glue("HHG-20{year}.rds"),
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
  sparra_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "SPARRA"),
    file_name = glue::glue("SPARRA-20{year}.rds"),
    ...
  )

  return(sparra_file_path)
}