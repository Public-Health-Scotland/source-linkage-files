#' Write a file
#'
#' @description Write a file, the function chosen to write the file is dependant
#' on the file path.
#'  * `.rds` uses [write_rds()].
#'  * `.parquet` uses [write_parquet()].
#'
#' @param data The data to be written
#' @param path The file path to be write
#' @param ... Addition arguments passed to the relevant function.
#'
#' @return the data a [tibble][tibble::tibble-package]
#' @export
write_file <- function(data, path, ...) {
  valid_extensions <- c("rds", "parquet")

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
    "parquet" = write_parquet(data, path, ...)
  )
}
