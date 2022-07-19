#' Find the latest version of a file
#'
#' @description
#' This will return the latest created file matching
#' the criteria. It uses [fs::dir_info()] to
#' find the files then picks the one with the latest
#' \code{birthtime}
#'
#' @param dir The directory to look on
#' @param ... additional arguments passed to [fs::dir_info()]
#' @param recurse Should the function search recursively
#' through subfolders? The default `TRUE` is to search subfolders.
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
find_latest_file <- function(dir, ..., recurse = TRUE) {
  fs::dir_info(path = dir, type = "file", ..., recurse = recurse) %>%
    dplyr::arrange(dplyr::desc(.data$birth_time), dplyr::desc(.data$modification_time)) %>%
    dplyr::pull(.data$path) %>%
    magrittr::extract(1)
}
