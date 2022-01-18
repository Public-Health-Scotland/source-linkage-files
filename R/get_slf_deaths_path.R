#' Get the full path to the SLF deaths lookup file
#'
#' @param update The update month to use,
#' defaults to \code{\link{latest_update}}
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the costs lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_slf_deaths_path <- function(update = latest_update(), ...) {
  slf_deaths_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Deaths"),
    file_name = glue::glue("all_deaths_{update}.zsav"),
    ...
  )

  return(slf_deaths_file_path)
}
