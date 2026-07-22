#' # Path function for Homelessness Completeness
#'
#' @param ...
#'
#' @returns
#' @export
#' @family get_sdl_path
get_sdl_homelessness_completeness_path <- function(...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Homelessness"),
    file_name = "SDL_homelessness_completeness.parquet",
    ...
  )
}
