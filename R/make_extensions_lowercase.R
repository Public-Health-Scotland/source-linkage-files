make_extensions_lowercase <- function(path = get_slf_dir()) {
  upper_ext_paths <- fs::dir_ls(
    path = path,
    regexp = "\\.[A-Z]{3,4}$",
    type = "file",
    recurse = TRUE
  )

  if (length(upper_ext_paths) == 0L) {
    return(invisible(NULL))
  }

  lower_ext_paths <- fs::path_ext_set(
    upper_ext_paths,
    tolower(fs::path_ext(upper_ext_paths))
  )

  if (any(fs::file_exists(lower_ext_paths))) {
    problem_files <- lower_ext_paths[which(fs::file_exists(lower_ext_paths))]

    cli::cli_warn(c(
      "!" = "There {?is/are} {length(problem_files)} file path{?s}
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
}
