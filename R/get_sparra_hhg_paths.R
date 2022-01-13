
#' Get the path to the HHG extract
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [get_file_path]
#'
#' @return the path to the HHG extract as an [fs::path]
#' @export
get_hhg_path <- function(year, ...) {
  hhg_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "HHG"),
    file_name = glue::glue("HHG-20{year}.zsav"),
    ...
  )

  return(hhg_file_path)
}

#' Get the path to the SPARRA extract
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [get_file_path]
#'
#' @return the path to the SPARRA extract as an [fs::path]
#' @export
get_sparra_path <- function(year, ...) {
  sparra_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "SPARRA"),
    file_name = glue::glue("SPARRA-20{year}.zsav"),
    ...
  )

  return(sparra_file_path)
}
