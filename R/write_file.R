#' Write a data to a file
#'
#' @description Write data to a file, the function chosen to write the file is
#' dependant on the file path extension.
#'  * `.rds` uses [readr::write_rds()].
#'  * `.parquet` uses [arrow::write_parquet()].
#'
#' @param data The data to be written
#' @param path The file path to be write
#' @param group_id The group id for setting permissions. The default is 3356 for
#'            sourcedev. To set this to hscdiip, use 3206.
#' @param ... Additional arguments passed to the relevant function.
#'
#' @return the data (invisibly) as a [tibble][tibble::tibble-package].
#' @export
write_file <- function(data, path, group_id = 3356, ...) {
  valid_extensions <- c("rds", "parquet")

  ext <- fs::path_ext(path)

  if (!(ext %in% valid_extensions)) {
    cli::cli_abort(c(
      "x" = "Invalid extension: {.val {ext}}",
      "i" = "{.fun read_file} supports {.val {valid_extensions}}"
    ))
  }

  switch(ext,
    "rds" = readr::write_rds(
      x = data,
      file = path,
      compress = "xz",
      version = 3L,
      ...,
      compression = 9L
    ),
    "parquet" = arrow::write_parquet(
      x = data,
      sink = path,
      compression = "zstd",
      version = "latest",
      ...
    )
  )

  if (fs::file_info(path)$user == Sys.getenv("USER")) {
    # Set the correct permissions (read, write, execute)
    fs::file_chmod(path = path, mode = "770")
    # change the owner so that sourcedev is the group owner.
    # use fs::group_ids() for checking
    fs::file_chown(path = path, group_id = group_id)
  }

  return(invisible(data))
}
