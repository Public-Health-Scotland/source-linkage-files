#' Get the Care Home all episodes file path
#'
#' @param update The update month to use,
#' defaults to \code{\link{latest_update}}
#'
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the care home episodes file as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_sc_ch_episodes_path <- function(update = latest_update(), ...) {
  sc_ch_episodes_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care"),
    file_name = glue::glue("all_ch_episodes{update}.zsav"),
    ...
  )

  return(sc_ch_episodes_path)
}
