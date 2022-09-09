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
#' @param selection_method Valid arguments are "modification_date" (the default) or "file_name"
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
find_latest_file <- function(directory, regexp, selection_method = "modification_date") {
  if (selection_method == "modification_date") {
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
      )
    cli::cli_inform(c(i = "There were {.val {nrow(latest_file_path)}} files matching the
                    regexp {.val {regexp}}. {.val {latest_file_path$path[[1]]}} has been selected,
                    which was modified on {.val {latest_file_path$modification_time[[1]]}}"))
    latest_file_path <- latest_file_path %>%
      dplyr::pull(.data$path) %>%
      magrittr::extract(1)
  } else if (selection_method == "file_name") {
    latest_file_path <-
      fs::dir_info(
        path = directory,
        type = "file",
        regexp = regexp,
        recurse = TRUE
      ) %>%
      dplyr::arrange(
        dplyr::desc(.data$path)
      )
    cli::cli_inform(c(i = "There were {.val {nrow(latest_file_path)}} files matching the
                    regexp {.val {regexp}}. {.val {latest_file_path$path[[1]]}} has been selected,
                    as it has the highest IT reference number"))
    latest_file_path <- latest_file_path %>%
      dplyr::pull(.data$path) %>%
      magrittr::extract(1)
  }

  if (!is.na(latest_file_path)) {
    return(latest_file_path)
  } else {
    cli::cli_abort("There was no file in {.path {directory}} that matched the
                   regular expression {.arg {regexp}}")
  }
}
