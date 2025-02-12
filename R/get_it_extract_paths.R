#' IT Long Term Conditions File Path
#'
#' @description Get the full path to the IT Long Term Conditions extract
#'
#' @param it_reference Optional argument for the seven-digit code in the
#' IT extract file name
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the LTC extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_ltc_path <- function(it_reference = NULL, ...) {
  if (is.null(it_reference)) {
    it_ltc_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts/anon-chi-IT"),
      file_name_regexp = "anon-SCTASK[0-9]{7}_LTCs\\.parquet",
      ...
    )
  } else {
    it_reference <- check_it_reference(it_reference)

    it_ltc_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts/anon-chi-IT"),
      file_name = stringr::str_glue("anon-SCTASK{it_reference}_LTCs.parquet")
    )
  }

  return(it_ltc_path)
}

#' IT Deaths File Path
#'
#' @description Get the full path to the IT Deaths extract
#'
#' @param it_reference Optional argument for the seven-digit code in the
#' IT extract file name
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the IT Deaths extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_deaths_path <- function(it_reference = NULL, ...) {
  if (is.null(it_reference)) {
    it_deaths_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts/anon-chi-IT"),
      file_name_regexp = "anon-SCTASK[0-9]{7}_Deaths\\.parquet",
      ...
    )
  } else {
    it_reference <- check_it_reference(it_reference)

    it_deaths_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts/anon-chi-IT"),
      file_name = stringr::str_glue("anon-SCTASK{it_reference}_Deaths.parquet")
    )
  }

  return(it_deaths_path)
}

#' IT Prescribing File Path
#'
#' @description Get the full path to the IT PIS extract
#'
#' @param year the year for the required extract
#' @param it_reference Optional argument for the seven-digit code in the
#' IT extract file name
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the PIS extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_prescribing_path <- function(year, it_reference = NULL, ...) {
  if (is.null(it_reference)) {
    it_pis_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts/anon-chi-IT"),
      file_name_regexp = stringr::str_glue(
        "anon-SCTASK[0-9]{{7}}_PIS_{convert_fyyear_to_year(year)}.parquet"
      )
    )
  } else {
    it_reference <- check_it_reference(it_reference)

    it_pis_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts/anon-chi-IT"),
      file_name = stringr::str_glue(
        "anon-SCTASK{it_reference}_PIS_{convert_fyyear_to_year(year)}.parquet"
      )
    )
  }

  return(it_pis_path)
}

#' Check that an IT reference looks valid
#'
#' @param it_reference The IT reference to check
#'
#' @return `it_reference` if valid, with the leading "SCTASK" trimmed if
#' necessary.
check_it_reference <- function(it_reference) {
  if (stringr::str_starts(it_reference, stringr::fixed("SCTASK"))) {
    # If the 'full' reference has been supplied trim to just the number
    it_reference <- stringr::str_sub(it_reference, start = 7L, end = 14L)
  }

  if (stringr::str_detect(it_reference, "^[0-9]{7}$", negate = TRUE)) {
    cli::cli_abort(
      c("x" = "{.arg it_reference} must be exactly 7 numbers."),
      call = rlang::caller_env()
    )
  } else {
    return(it_reference)
  }
}
