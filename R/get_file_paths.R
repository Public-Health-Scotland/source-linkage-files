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
#'
#' @return The full file path, an error will be thrown
#' if the path doesn't exist or it's not readable
#' @family file path functions
#' @export
get_file_path <-
  function(directory,
           file_name,
           ext = NULL,
           check_mode = "read",
           create = NULL) {
    if (!fs::dir_exists(directory)) {
      rlang::abort(message = glue::glue("The directory {directory} does not exist"))
    }

    file_path <- fs::path(directory, file_name)

    if (!is.null(ext)) {
      file_path <- fs::path_ext_set(file_path, ext)
    }

    if (!fs::file_exists(file_path)) {
      if (is.null(create) && check_mode == "write" | !is.null(create) && create == TRUE) {
        # The file doesn't exist but we do want to create it
        fs::file_create(file_path)
        rlang::inform(
          message = glue::glue(
            "The file {fs::path_file(file_path)} did not exist in {directory}, it has now been created."
          )
        )
      } else {
        # The file doesn't exists and we don't want to create it
        rlang::abort(
          message = glue::glue(
            "The file {fs::path_file(file_path)} does not exist in {directory}"
          )
        )
      }
    }

    if (!fs::file_access(file_path, mode = check_mode)) {
      rlang::abort(
        message = glue::glue(
          "The file {fs::path_file(file_path)} exists in {directory} but is not {check_mode}able"
        )
      )
    }

    return(file_path)
  }

#' SLF directory - hscdiip
#'
#' @description File path for the general SLF directory for accessing HSCDIIP folders/files
#'
#' @return The path to the main SLF Extracts folder
#' @export
#'
#' @family directories
get_slf_dir <- function() {
  slf_dir <- fs::path("/conf/hscdiip/SLF_Extracts")

  return(slf_dir)
}


#' Year Directory
#'
#' @description Get the directory for Source Linkage File Updates for the given year
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
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year)

  year_extracts_dir <- fs::path(year_dir, "Extracts")

  return(dplyr::if_else(extracts_dir, year_extracts_dir, year_dir))
}
