#' Write an SPSS zsav file
#'
#' @description Wrapper around [haven::write_sav()] but with compression as
#' default, it also corrects the file permissions to be writeable by the group,
#' which is often an issue in the PHS RStudio server.
#'
#' @param data [tibble][tibble::tibble-package] to write.
#' @param path Path to where the data will be written.
#' @param compress Compression type to use:
#'
#'   * "byte": uses byte compression (The default in SPSS).
#'   * "none": no compression. This is useful for software that has issues with
#'     byte compressed `.sav` files (e.g. SAS).
#'   * "zsav": The default, uses zlib compression and produces a `.zsav` file.
#'   zlib compression is supported by SPSS version 21.0 and above.
#'
#'   `TRUE` and `FALSE` can be used for backwards compatibility, and correspond
#'   to the "zsav" and "none" options respectively.
#'
#' @return `write_sav()` returns the input `data` invisibly.
#' @export
#'
#' @family write out data
write_sav <- function(data, path, compress = "zsav") {
  haven::write_sav(
    data = data,
    path = path,
    compress = compress
  )

  fs::file_chmod(path = path, mode = "660")

  return(invisible(data))
}

#' Write an R rds file
#'
#' Wrapper around [readr::write_rds()], but with maximum 'xz' compression as
#' default, it also corrects the file permissions to be writeable by the group,
#' which is often an issue in the PHS RStudio server.
#'
#' @param data R object to write to serialise.
#' @param path Path to where the data will be written.
#' @param compress Compression method to use: "none", "gz" ,"bz", or "xz".
#' @param ... Additional arguments to [write_rds()][readr::write_rds()] and the
#' subsequent connection function. For example, control the space-time trade-off
#'  of different compression methods with `compression`. See [connections()]
#' for more details.
#' @return `write_sav()` returns the input `data` invisibly.
#' @export
#'
#' @family write out data
write_rds <- function(data, path, compress = "xz", ...) {
  readr::write_rds(
    x = data,
    file = path,
    compress = compress,
    version = 3,
    ...,
    compression = 9
  )

  fs::file_chmod(path = path, mode = "660")

  return(invisible(data))
}
