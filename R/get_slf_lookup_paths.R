#' SLF Postcode Lookup File Path
#'
#' @description Get the full path to the SLF Postcode lookup
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param BYOC_MODE BYOC_MODE
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the SLF Postcode lookup as an [fs::path()]
#' @export
#'
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_postcode_path <- function(update = latest_update(), BYOC_MODE, ...) {
  if (isTRUE(BYOC_MODE)) {
    slf_postcode_path <- file.path(
      directory = denodo_output_path(),
      file_name = "source_postcode_lookup.parquet"
    )
  } else {
    slf_postcode_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Lookups"),
      file_name = stringr::str_glue("source_postcode_lookup_{update}.parquet"),
      ...
    )
  }

  return(slf_postcode_path)
}


#' SLF GP Lookup File Path
#'
#' @description Get the full path to the SLF GP practice lookup
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param BYOC_MODE BYOC_MODE
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the SLF GP practice lookup as an [fs::path()]
#' @export
#'
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_gpprac_path <- function(update = latest_update(), BYOC_MODE, ...) {
  if (isTRUE(BYOC_MODE)) {
    slf_gpprac_path <- file.path(
      directory = denodo_output_path(),
      file_name = "source_gpprac_lookup.parquet"
    )
  } else {
    slf_gpprac_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Lookups"),
      file_name = stringr::str_glue("source_gpprac_lookup_{update}.parquet"),
      ...
    )
  }

  return(slf_gpprac_path)
}


#' SLF CHI Deaths File Path
#'
#' @description Get the full path to the CHI deaths file
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param BYOC_MODE BYOC_MODE
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the CHI deaths lookup as an [fs::path()]
#' @export
#'
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_slf_chi_deaths_path <- function(update = latest_update(), BYOC_MODE, ...) {
  if (BYOC_MODE) {
    slf_chi_deaths_path <- file.path(
      directory = denodo_output_path(),
      file_name = "anon-chi_deaths.parquet"
    )
  } else {
    slf_chi_deaths_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Deaths"),
      file_name = stringr::str_glue("anon-chi_deaths_{update}.parquet"),
      ...
    )
  }

  return(slf_chi_deaths_path)
}


#' SLF Combined Deaths File Path
#'
#' @description Get the path to the combined deaths lookup
#'
#' @param update the update month (defaults to use [latest_update()])
#' @param BYOC_MODE BYOC_MODE
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the combined deaths lookup as an [fs::path()]
#' @export
#'
#' @family slf lookup file path
#' @seealso [get_file_path()] for the generic function.
get_combined_slf_deaths_lookup_path <- function(update = latest_update(), BYOC_MODE = FALSE, ...) {
  # Note this name is very similar to the existing slf_deaths_lookup_path which returns the path for
  # the refined_death with deceased flag for each financial year.
  # This function will return the combined financial
  # years lookup i.e. all years put together.
  if (isTRUE(BYOC_MODE)) {
    combined_slf_deaths_lookup_path <- file.path(
      denodo_output_path(),
      "anon-combined_slf_deaths_lookup.parquet"
    )
  } else {
    combined_slf_deaths_lookup_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Deaths"),
      file_name = stringr::str_glue("anon-combined_slf_deaths_lookup_{update}.parquet"),
      ...
    )
  }
  return(combined_slf_deaths_lookup_path)
}
