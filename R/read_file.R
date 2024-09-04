#' Read a file
#'
#' @description Read a file, the function chosen to read the file is dependant
#' on the file path.
#'  * `.rds` uses [readr::read_rds()].
#'  * `.csv` and `.gz` use [readr::read_csv()]. Note that this assumes any file
#'  ending with `.gz` is a zipped CSV which isn't necessarily true!
#'  * `.parquet` uses [arrow::read_parquet()].
#'
#' @param path The file path to be read
#' @inheritParams arrow::read_parquet
#' @param ... Addition arguments passed to the relevant function.
#'
#' @return the data a [tibble][tibble::tibble-package]
#' @export
read_file <- function(path, col_select = NULL, as_data_frame = TRUE, ...) {
  valid_extensions <- c(
    "rds",
    "rds.gz",
    "csv",
    "csv.gz",
    "parquet"
  )

  # Return an empty tibble if trying to read the dummy path
  if (path == get_dummy_boxi_extract_path()) {
    return(tibble::tibble(anon_chi = NA_character_))
  }

  ext <- fs::path_ext(path)

  if (ext == "gz") {
    ext <- paste(
      fs::path_ext(fs::path_ext_remove(path)),
      "gz",
      sep = "."
    )
  }

  if (!(ext %in% valid_extensions)) {
    cli::cli_abort(c(
      "x" = "Invalid extension: {.val {ext}}",
      "i" = "{.fun read_file} supports
                     {.val {valid_extensions}}"
    ))
  }

  if ((!missing(col_select) || !missing(as_data_frame)) && ext != "parquet") {
    cli::cli_abort(c(
      "x" = "{.arg col_select} and/or {.arg as_data_frame} must only be used
        when reading a {.field .parquet} file."
    ))
  }

  data <- switch(ext,
    "rds" = readr::read_rds(file = path),
    "rds.gz" = readr::read_rds(file = path),
    "csv" = readr::read_csv(file = path, ..., show_col_types = FALSE),
    "csv.gz" = readr::read_csv(file = path, ..., show_col_types = FALSE),
    "parquet" = arrow::read_parquet(
      file = path,
      col_select = !!col_select,
      as_data_frame = as_data_frame,
      ...
    )
  )

  return(data)
}
