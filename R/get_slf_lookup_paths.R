#' Get the full path to the SLF Postcode lookup
#'
#' @param update the update month (defaults to use \code{\link{latest_update}})
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the SLF Postcode lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
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
#' @param update the update month (defaults to use \code{\link{latest_update}})
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the SLF GP practice lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_slf_gpprac_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = glue::glue("source_GPprac_lookup_{update}.zsav"),
    check_mode = "write",
    ...
  )
}

#' Get the full path to the SLF deaths lookup file
#'
#' @param update The update month to use,
#' defaults to \code{\link{latest_update}}
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the costs lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_slf_deaths_path <- function(update = latest_update(), ...) {
  slf_deaths_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Deaths"),
    file_name = glue::glue("all_deaths_{update}.zsav"),
    ...
  )

  return(slf_deaths_file_path)
}


#' Get the full path to the SLF Care Home lookup
#'
#' @param update the update month (defaults to use \code{\link{latest_update}})
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the SLF Care Home lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_slf_ch_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = glue::glue("Care_Home_Lookup_All.xlsx"),
    check_mode = "write",
    ...
  )
}
