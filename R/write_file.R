#' Write a file
#'
#' @description Write a file, the function chosen to write the file is dependant
#' on the file path.
#'  * `.rds` uses [write_rds()].
#'  * `.fst` uses [fst::write_fst()].
#'  * `.sav` and `.zsav` use [haven::write_sav()].
#'  * `.csv` and `.gz` use [readr::write_csv()]. Note that this assumes any file
#'  ending with `.gz` is a zipped CSV which isn't necessarily true!
#'  * `.parquet` uses [arrow::write_parquet()].
#'
#' @param path The file path to be write
#' @param ... Addition arguments passed to the relevant function.
#'
#' @return the data a [tibble][tibble::tibble-package]
#' @export
write_file <- function(data, path, ...) {
  valid_extensions <- c("rds", "fst", "sav", "zsav", "csv", "gz", "parquet")

  ext <- fs::path_ext(path)

  if (!(ext %in% valid_extensions)) {
    cli::cli_abort(c(
      "x" = "Invalid extension: {.val {ext}}",
      "i" = "{.fun read_file} supports
                     {.val {valid_extensions}}"
    ))
  }

  switch(ext,
    "rds" = write_rds(data, path),
    "fst" = fst::write_fst(data, path),
    "sav" = haven::write_sav(data, path, compress = "none", ...),
    "zsav" = haven::write_sav(data, path, compress = "zsav", ...),
    "csv" = readr::write_csv(data, path, ...),
    "gz" = readr::write_csv(data, path, ...),
    "parquet" = write_parquet(data, path, ...)
  )
}
