gzip_files <- function(
    extract_year = NULL,
    path = get_year_dir(extract_year, extracts_dir = TRUE)) {
  unzipped_files <- fs::dir_ls(
    path = path,
    regexp = "\\.csv$",
    type = "file",
    recurse = TRUE
  )

  n_unzipped_files <- length(unzipped_files)
  if (n_unzipped_files > 0) {
    cli::cli_inform(c(
      "i" = "{cli::qty(n_unzipped_files)}There {?is/are} {n_unzipped_files}
      uncompressed file{?s} for {extract_year}, which will be compressed with
      gzip.",
      ">" = "{unzipped_files}"
    ))
  } else {
    cli::cli_alert_info(
      "There are 0 uncompressed files for {extract_year}."
    )
  }

  purrr::walk(
    unzipped_files,
    function(file_path) {
      system2(
        command = "gzip",
        args = shQuote(file_path)
      )
    }
  )
}
