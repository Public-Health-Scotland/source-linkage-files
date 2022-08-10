#' NSU File Path
#'
#' @description Get the NSU file path for the given year
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the NSU file as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_nsu_path <- function(year, ...) {
  nsu_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "NSU"),
    file_name = glue::glue("All_CHIs_20{year}.rds"),
    ...
  )

  return(nsu_file_path)
}
