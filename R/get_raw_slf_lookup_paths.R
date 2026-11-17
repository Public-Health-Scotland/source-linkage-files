#' Local UK postcode list file path
#'
#' @description Get the local path to the UK postcode list
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the UK postcode list as an [fs::path()]
#' @export
#'
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_uk_postcode_path <- function(...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "uk_postcode_list",
    ext = "parquet",
    ...
  )
}


#' Local Read code file path
#'
#' @description Get the local path to the Read code file
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the SLF read code lookup as an [fs::path()]
#' @export
#'
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_readcode_lookup_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = stringr::str_glue("ReadCodeLookup.rds"),
    ...
  )
}


#' Local Care Home lookup file path
#'
#' @description Get the local path to the Care Home name lookup, which
#' has official Care Home names and addresses provided by the Care Inspectorate.
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the Care Home lookup as an [fs::path()]
#' @export
#'
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_slf_ch_name_lookup_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = stringr::str_glue("Care_Home_Lookup_All.xlsx"),
    check_mode = "read",
    ...
  )
}
