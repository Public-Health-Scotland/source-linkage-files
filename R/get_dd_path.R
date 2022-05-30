#' Get the Delayed Discharges file path
#'
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#' @param dd_period The period to use for reading the file,
#' defaults to \code{\link{dd_period}}
#'
#' @return The path to the latest Delayed Discharges file
#' as a [fs::path()]
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_dd_path <- function(..., dd_period = NULL) {
  if (is.null(dd_period)) {
    dd_period <- dd_period()
  }

  dd_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Delayed_Discharges"),
    file_name = paste0(dd_period, "DD_LinkageFile.rds"),
    ...
  )

  return(dd_path)
}
