#' Get the slf episode file path
#'
#' @param year Financial year
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return Path to the final episode file.
#' @export
#'
get_slf_episode_path <- function(year, ...) {
  slf_episode_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("source-episode-file-{year}.parquet"),
    ...
  )

  return(slf_episode_path)
}

#' Get the SLF individual file path
#'
#' @param year Financial year
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return Path to the final individual file
#' @export
#'
get_slf_individual_path <- function(year, ...) {
  slf_indiv_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("source-individual-file-{year}.parquet"),
    ...
  )
  return(slf_indiv_path)
}
