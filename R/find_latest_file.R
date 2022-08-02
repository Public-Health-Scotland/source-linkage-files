#' Find the latest version of a file
#'
#' @description
#' This will return the latest created file matching
#' the criteria. It uses [fs::dir_info()] to
#' find the files then picks the one with the latest
#' \code{birthtime}
#'
#' @param directory The directory to look in
#' @param regexp a [regular expression](https://www.regular-expressions.info/quickstart.html)
#' passed to [fs::dir_info()] to search for the file
#'
#' @return the [fs::path()] to the file
#' @export
#'
#' @examples
#' \dontrun{
#' find_latest_file(get_lookups_dir(),
#'   regexp = "Scottish_Postcode_Directory_.+?\\.rds"
#' )
#' }
find_latest_file <- function(directory, regexp) {
  latest_file_path <-
    fs::dir_info(
      path = directory,
      type = "file",
      regexp = regexp,
      recurse = TRUE
    ) %>%
    dplyr::arrange(
      dplyr::desc(.data$birth_time),
      dplyr::desc(.data$modification_time)
    ) %>%
    dplyr::pull(.data$path) %>%
    magrittr::extract(1)

  if (!is.na(latest_file_path)) {
    return(latest_file_path)
  } else {
    cli::cli_abort("There was no file in {.path {directory}} that matched the
                   regular expression {.arg {regexp}}")
  }
}
