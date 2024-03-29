#' Get and check and full file path
#'
#' @description This generic function takes a directory and
#' file name then checks to make sure they exist.
#' The parameter \code{check_mode} will also test to make sure
#' the file is readable (default) or writeable (\code{check_mode = "write"}).
#' By default it will return an error if the file doesn't exist
#' but with \code{create = TRUE} it will create an empty file with
#' appropriate permissions.
#'
#' @param directory The file directory
#' @param file_name The file name (with extension if not supplied to \code{ext})
#' @param ext The extension (type of the file) - optional
#' @param check_mode The mode passed to
#' [fs::file_access()], defaults to "read"
#' to check that you have read access to the file
#' @param create Optionally create the file if it doesn't exists,
#' the default is to only create a file if we set `check_mode = "write"`
#' @param file_name_regexp A regular expression to search for the file name
#' if this is used `file_name` should not be, it will return the most recently
#' created file using [find_latest_file()]
#' @param selection_method Passed only to [find_latest_file()], will select the
#'  file based on latest modification date (default) or file name
#'
#' @return The full file path, an error will be thrown
#' if the path doesn't exist or it's not readable
#'
#' @family file path functions
#' @export
get_file_path <-
  function(directory,
           file_name = NULL,
           ext = NULL,
           check_mode = "read",
           create = NULL,
           file_name_regexp = NULL,
           selection_method = "modification_date") {
    if (!fs::dir_exists(directory)) {
      cli::cli_abort("The directory {.path {directory}} does not exist.")
    }

    check_mode <- match.arg(
      arg = check_mode,
      choices = c("exists", "read", "write", "execute")
    )

    if (!is.null(file_name)) {
      file_path <- fs::path(directory, file_name)
    } else if (!is.null(file_name_regexp)) {
      if (check_mode == "read") {
        file_path <- find_latest_file(directory,
          regexp = file_name_regexp,
          selection_method = selection_method
        )
      } else {
        cli::cli_abort(
          c("{.arg check_mode = \"{check_mode}\"} can't be used to
find the latest file with {.arg file_name_regexp}",
            "v" = "Try {.arg check_mode = \"read\"}"
          )
        )
      }
    } else {
      cli::cli_abort(
        "You must specify a {.var file_name} or a regular expression
                     to search for with {.var file_name_regexp}"
      )
    }

    if (!is.null(ext)) {
      file_path <- fs::path_ext_set(file_path, ext)
    }

    if (!fs::file_exists(file_path) && check_mode != "exists") {
      if (is.null(create) && check_mode == "write" ||
        !is.null(create) && create == TRUE) {
        # The file doesn't exist but we do want to create it
        fs::file_create(file_path)
        cli::cli_alert_info(
          "The file {.file {fs::path_file(file_path)}} did not exist in
          {.path {directory}}, it has now been created."
        )
      } else {
        possible_file_name <- fs::path_file(
          fs::dir_ls(
            directory,
            regexp = fs::path_ext_remove(file_path),
            ignore.case = TRUE
          )
        )

        error_text <- "The file {.file {fs::path_file(file_path)}} does not
        exist in {.path {directory}}"

        if (length(possible_file_name) == 1L) {
          # There was a file matching the name, except for case differences.
          error_text <- c(
            error_text,
            ">" = "Did you mean {.file {possible_file_name}}?"
          )
        }

        # The file doesn't exist and we don't want to create it
        cli::cli_abort(error_text)
      }
    } else if (check_mode == "exists") {
      if (!fs::file_exists(file_path)) {
        return(FALSE)
      }
    }

    if (!fs::file_access(file_path, mode = check_mode)) {
      cli::cli_abort(
        "{.file {fs::path_file(file_path)}} exists in {.path {directory}} but is
        not {check_mode}able."
      )
    }

    return(file_path)
  }

#' SLF directory - hscdiip
#'
#' @description File path for the general SLF directory for accessing HSCDIIP
#' folders/files
#'
#' @return The path to the main SLF Extracts folder
#' @export
#'
#' @family directories
get_slf_dir <- function() {
  slf_dir <- fs::path("/", "conf", "hscdiip", "SLF_Extracts")

  return(slf_dir)
}

#' SLF directory - sourcedev / Source_Linkage_File_Updates
#'
#' @description File path for the SLF development directory on `sourcedev`
#'
#' @return The path to the main SLF dev folder
#' @export
#'
#' @family directories
get_dev_dir <- function() {
  fs::path("/", "conf", "sourcedev", "Source_Linkage_File_Updates")
}

#' Year Directory
#'
#' @description Get the directory for Source Linkage File Updates for the given
#' year.
#'
#' @param year The Financial Year e.g. 1718
#' @param extracts_dir (optional) Whether to
#' return the Extracts folder (`TRUE`) or the top-level
#' folder (`FALSE`).
#'
#' @return The file path to the year directory (on sourcedev)
#' @export
#'
#' @family directories
get_year_dir <- function(year, extracts_dir = FALSE) {
  year_dir <- fs::path(get_dev_dir(), year)

  if (!fs::dir_exists(year_dir)) {
    fs::dir_create(year_dir)
    cli::cli_alert_info(
      "{.path {year_dir}} did not exist, it has now been created."
    )
  }

  if (extracts_dir) {
    year_extracts_dir <- fs::path(year_dir, "Extracts")

    if (!fs::dir_exists(year_extracts_dir)) {
      fs::dir_create(year_extracts_dir)
      cli::cli_alert_info(
        "{.path {year_extracts_dir}} did not exist, it has now been created."
      )
    }

    return(year_extracts_dir)
  } else {
    return(year_dir)
  }
}
