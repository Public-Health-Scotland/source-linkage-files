#' Make file path extensions lower-case
#'
#' @param path The path to recurse over
#'
#' @return NULL
#' @export
make_lowercase_ext <- function(path = get_slf_dir()) {
  upper_ext_paths <- fs::dir_ls(
    path = path,
    regexp = "\\.[A-Z]{2,7}$",
    type = "file",
    recurse = TRUE
  )

  if (length(upper_ext_paths) == 0L) {
    cli::cli_alert_info("There are 0 paths with extensions to correct.")
    return(invisible(NULL))
  }

  lower_ext_paths <- fs::path_ext_set(
    upper_ext_paths,
    tolower(fs::path_ext(upper_ext_paths))
  )

  if (any(fs::file_exists(lower_ext_paths))) {
    problem_files <- lower_ext_paths[which(fs::file_exists(lower_ext_paths))]

    cli::cli_warn(c(
      "!" = "There {?is/are} {length(problem_files)} path{?s}
                    where there are lowercase and uppercase extentions.",
      ">" = "{problem_files}"
    ))
  }

  fs::file_move(upper_ext_paths, lower_ext_paths)

  cli::cli_inform(c(
    "!" = "There {?was/were} {length(upper_ext_paths)} path{?s} that had
    {?an/} uppercase extension{?s}.",
    "v" = "{as.character(upper_ext_paths)} {?has/have}
    been renamed to {lower_ext_paths}"
  ))

  return(invisible(NULL))
}
