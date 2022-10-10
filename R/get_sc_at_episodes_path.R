#' Alarms Telecare Episodes File Path
#'
#' @description Get the file path for Alarms Telecare all episodes file
#'
#' @param update The update month to use,
#' defaults to [latest_update()]
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the alarms telecare episodes file as an [fs::path()]
#' @export
#' @family social care episodes file paths
#' @seealso [get_file_path()] for the generic function.
get_sc_at_episodes_path <- function(update = latest_update(), ...) {
  sc_at_episodes_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care"),
    file_name = glue::glue("all_at_episodes_{update}.rds"),
    ...
  )

  return(sc_at_episodes_path)
}
