#' Get the slf episode file path - Stage 1
#'
#' @param year Financial year
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return Path to the final episode file.
#' @export
#'
get_slf_episode_stage_1_path <- function(year, ...) {
  slf_episode_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("source-episode-file-{year}_stage_1.parquet"),
    ...
  )

  return(slf_episode_path)
}


