#' Get the processed source extracts tests path
#'
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the costs lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_source_tests_path <- function(...) {
  source_tests_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Tests"),
    file_name = glue::glue(latest_update(), "_tests.xlsx"),
    ...
  )

  return(source_tests_path)
}
