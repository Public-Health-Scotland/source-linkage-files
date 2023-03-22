#' Read a file
#'
#' @description Read a file, the function chosen to read the file is dependant
#' on the file path.
#'  * `.rds` uses [readr::read_rds()].
#'  * `.fst` uses [fst::read_fst()].
#'  * `.sav` and `.zsav` use [haven::read_spss()].
#'  * `.csv` and `.gz` use [readr::read_csv()]. Note that this assumes any file
#'  ending with `.gz` is a zipped CSV which isn't necessarily true!
#'  * `.parquet` uses [arrow::read_parquet()].
#'
#' @param path The file path to be read
#' @param ... Addition arguments passed to the relevant function.
#'
#' @return the data a [tibble][tibble::tibble-package]
#' @export
read_file <- function(path, ...) {
  valid_extensions <- c("rds", "fst", "sav", "zsav", "csv", "gz", "parquet")

  ext <- fs::path_ext(path)

  if (!(ext %in% valid_extensions)) {
    cli::cli_abort(c(
      "x" = "Invalid extension: {.val {ext}}",
      "i" = "{.fun read_file} supports
                     {.val {valid_extensions}}"
    ))
  }

  data <- switch(ext,
    "rds" = readr::read_rds(path),
    "fst" = fst::read_fst(path),
    "sav" = haven::read_spss(path, ...),
    "zsav" = haven::read_spss(path, ...),
    "csv" = readr::read_csv(path, ..., show_col_types = FALSE),
    "gz" = readr::read_csv(path, ..., show_col_types = FALSE),
    "parquet" = arrow::read_parquet(path, ...)
  )

  return(data)
}
