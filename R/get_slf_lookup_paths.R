#' Get the full path to the SLF Postcode lookup
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path]
#'
#' @return the path to the SLF Postcode lookup as an [fs::path]
#' @export
get_slf_postcode_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = glue::glue("source_postcode_lookup_{update}.zsav"),
    check_mode = "write",
    ...
  )
}

#' Get the full path to the SLF GP practice lookup
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path]
#'
#' @return the path to the SLF GP practice lookup as an [fs::path]
#' @export
get_slf_gpprac_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = glue::glue("source_GPprac_lookup_{update}.zsav"),
    check_mode = "write",
    ...
  )
}
