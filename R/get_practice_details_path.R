#' Get the path to the Practice Details file
#'
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the Practice Details file as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_practice_details_path <- function(...) {
  practice_details_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "Practice Details.sav",
    ...
  )

  return(practice_details_path)
}
