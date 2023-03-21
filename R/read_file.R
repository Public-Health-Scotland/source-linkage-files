read_file <- function(path, ...) {
  valid_extensions <- c("rds", "sav", "zsav", "csv", "gz", "parquet")

  ext <- fs::path_ext(path)

  if (!(ext %in% valid_extensions)) {
    cli::cli_abort(c("x" = "Invalid extension: {ext}",
                     "i" = "{.fun read_file} supports
                     {.val {valid_extensions}}")
    )
  }

  data <- switch(ext,
    "rds" = readr::read_rds(path),
    "sav" = haven::read_spss(path, ...),
    "zsav" = haven::read_spss(path, ...),
    "csv" = readr::read_csv(path, ...),
    "gz" = readr::read_csv(path, ...),
    "parquet" = arrow::read_parquet(path, ...)
  )

  return(data)
}
