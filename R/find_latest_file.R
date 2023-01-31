#' Find the latest version of a file
#'
#' @description
#' This will return the latest created file matching
#' the criteria. It uses [fs::dir_info()] to
#' find the files then picks the one with the latest
#' `birthtime`.
#'
#' @param directory The directory in which to search.
#' @param regexp a
#' [regular expression](https://www.regular-expressions.info/quickstart.html)
#' passed to [fs::dir_info()] to search for the file.
#' @param selection_method Valid arguments are "modification_date"
#' (the default) or "file_name".
#'
#' @return the [fs::path()] to the file
#' @export
#'
#' @examples
#' \dontrun{
#' find_latest_file(
#'   directory = get_lookups_dir(),
#'   regexp = "Scottish_Postcode_Directory_.+?\\.rds"
#' )
#' }
find_latest_file <- function(directory,
                             regexp,
                             selection_method = "modification_date") {
  if (selection_method == "modification_date") {
    latest_file <- fs::dir_info(
      path = directory,
      type = "file",
      regexp = regexp,
      recurse = TRUE
    ) %>%
      dplyr::arrange(
        dplyr::desc(.data$birth_time),
        dplyr::desc(.data$modification_time)
      ) %>%
      magrittr::extract(1L, )

    n_matched_files <- nrow(latest_file)

    if (n_matched_files > 1L) {
      cli::cli_inform(
        c(i = "There were {.val {n_matched_files}} files matching the
                    regexp {.val {regexp}}. {.val {fs::path_file(latest_file$path)}} has been selected,
                    which was modified on {.val {latest_file$modification_time}}.")
      )
    }
  } else if (selection_method == "file_name") {
    latest_file <- fs::dir_info(
      path = directory,
      type = "file",
      regexp = regexp,
      recurse = TRUE
    ) %>%
      dplyr::arrange(
        dplyr::desc(.data$path)
      ) %>%
      magrittr::extract(1L, )

    n_matched_files <- nrow(latest_file)

    if (n_matched_files > 1L) {
      cli::cli_inform(
        c(i = "There were {.val {n_matched_files}} files matching the
                    regexp {.val {regexp}}. {.val {fs::path_file(latest_file$path)}} has been selected,
                    as it is first alphabetically.")
      )
    }
  }

  if (n_matched_files == 1L) {
    cli::cli_alert_info("Using {.val {fs::path_file(latest_file$path)}}.")
  } else {
    cli::cli_abort(
      "There was no file in {.path {directory}} that matched the
        regular expression {.val {regexp}}"
    )
  }

  file_path <- latest_file %>%
    dplyr::pull(.data$path)

  return(file_path)
}
