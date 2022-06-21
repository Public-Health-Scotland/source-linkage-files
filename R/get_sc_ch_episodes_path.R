#' Care Home Episodes
#'
#' @description Get the file path for Care Home all episodes file
#'
#' @param update The update month to use,
#' defaults to [latest_update()]
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the care home episodes file as an [fs::path()]
#' @export
#' @family social care episodes file paths
#' @seealso [get_file_path()] for the generic function.
get_sc_ch_episodes_path <- function(update = latest_update(), ...) {
  sc_ch_episodes_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care"),
    file_name = glue::glue("all_ch_episodes{update}.rds"),
    ...
  )

  return(sc_ch_episodes_path)
}
