gzip_files <- function(
    extract_year = NULL,
    path = get_year_dir(extract_year, extracts_dir = TRUE)) {
  unzipped_files <- fs::dir_ls(
    path = path,
    regexp = "\\.csv$",
    type = "file",
    recurse = TRUE
  )

  cli::cli_inform(c(
    "i" = "There {?is/are} {length(unzipped_files)} uncompressed
                   file{?s}, which will be compressed with gzip.",
    ">" = "{unzipped_files}"
  ))

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
