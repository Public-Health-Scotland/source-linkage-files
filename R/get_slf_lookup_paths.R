#' SLF Postcode Lookup File Path
#'
#' @description Get the full path to the SLF Postcode lookup
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the SLF Postcode lookup as an [fs::path()]
#' @export
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_postcode_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = stringr::str_glue("source_postcode_lookup_{update}"),
    ext = "parquet",
    ...
  )
}

#' get uk postcode list file path
#' @description get uk postcode list file
#' @param ... additional arguments passed to [get_file_path()]
#' @family lookup file paths
get_uk_postcode_path <- function(...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "uk_postcode_list",
    ext = "parquet",
    ...
  )
}

#' SLF GP Lookup File Path
#'
#' @description Get the full path to the SLF GP practice lookup
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the SLF GP practice lookup as an [fs::path()]
#' @export
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_gpprac_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = stringr::str_glue("source_gpprac_lookup_{update}.parquet"),
    ...
  )
}

#' SLF Deaths lookup path
#'
#' @description Get the full path to the SLF deaths lookup file
#'
#' @inheritParams get_boxi_extract_path
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_deaths_lookup_path <- function(year, ...) {
  # Review the naming convention of this path and file
  slf_deaths_lookup_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Deaths"),
    file_name = stringr::str_glue("anon-slf_deaths_lookup_{year}.parquet"),
    ...
  )

  return(slf_deaths_lookup_path)
}

#' SLF death dates File Path
#'
#' @description Get the full path to the BOXI NRS Deaths lookup file for all financial years
#' Note this name is very similar to the existing slf_deaths_lookup_path
#' which returns the path for the refined_death with deceased flag for each financial year.
#' This function will return the combined financial years lookup
#' i.e. all years put together.
#'
#' @param ... additional arguments passed to [get_file_path()]
#' @param update the update month (defaults to use [latest_update()])
#'
#' @export
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_combined_slf_deaths_lookup_path <- function(update = latest_update(), ...) {
  # Note this name is very similar to the existing slf_deaths_lookup_path which returns the path for
  # the refined_death with deceased flag for each financial year.
  # This function will return the combined financial
  # years lookup i.e. all years put together.
  combined_slf_deaths_lookup_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Deaths"),
    file_name = stringr::str_glue("anon-combined_slf_deaths_lookup_{update}.parquet"),
    ...
  )
  return(combined_slf_deaths_lookup_path)
}


#' SLF CHI Deaths File Path
#'
#' @description Get the full path to the CHI deaths file
#'
#' @param update The update month to use,
#' defaults to [latest_update()]
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_chi_deaths_path <- function(update = latest_update(), ...) {
  slf_chi_deaths_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Deaths"),
    file_name = stringr::str_glue("anon-chi_deaths_{update}.parquet"),
    ...
  )

  return(slf_chi_deaths_path)
}

#' Get the full path to the SLF read code lookup
#'
#' @param update the update month (defaults to use \code{\link{latest_update}})
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the SLF read code lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_readcode_lookup_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = stringr::str_glue("ReadCodeLookup.rds"),
    ...
  )
}

#' SLF Care Home Lookup File Path
#'
#' @description Get the full path to the Care Home name lookup, which
#' has official Care Home names and addresses provided by the Care Inspectorate.
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the Care Home lookup as an [fs::path()]
#' @export
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_ch_name_lookup_path <- function(update = latest_update(), ...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = stringr::str_glue("Care_Home_Lookup_All.xlsx"),
    check_mode = "read",
    ...
  )
}
