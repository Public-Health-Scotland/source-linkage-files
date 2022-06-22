#' Practice Details File Path
#'
#' @description Get the path to the Practice Details file
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the Practice Details file as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_practice_details_path <- function(update = latest_update(), ...) {
  practice_details_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = glue::glue("practice_details_{update}.rds"),
    ...
  )

  return(practice_details_path)
}
