#' Get the path to the Practice Details file
#'
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return The practice details file
#' @export
get_practice_details_path <- function(...) {
  practice_details_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "Practice Details.sav",
    ...
  )

  return(practice_details_path)
}
