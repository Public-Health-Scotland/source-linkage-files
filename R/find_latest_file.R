#' Find the latest version of a file
#'
#' @description
#' This will return the latest created file matching
#' the criteria. It uses \code{\link[fs]{dir_info}} to
#' find the files then picks the one with the latest
#' \code{birthtime}
#'
#' @param dir The directory to look on
#' @param ... additional arguments passed to \code{\link[fs]{dir_info}}
#'
#' @return the \code{\link[fs]{path}} to the file
#' @export
#'
#' @examples
#' find_latest_file(spd_dir, regexp = "Scottish_Postcode_Directory_.+?\\.rds", recurse = TRUE)
find_latest_file <- function(dir, ...) {
  fs::dir_info(path = dir, type = "file", ...) %>%
    dplyr::arrange(desc(.data$birth_time), desc(.data$modification_time)) %>%
    dplyr::pull(.data$path) %>%
    magrittr::extract(1)
}
