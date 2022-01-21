#' Get the full path to the IT
#' Long Term Conditions extract
#'
#' @param it_reference The IT reference to use, defaults to \code{\link{it_extract_ref}}
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the LTC extract as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_it_ltc_path <- function(it_reference = it_extract_ref(), ...) {
  it_ltc_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_reference}_extract_1_LTCs.csv.gz"),
    ...
  )

  return(it_ltc_path)
}

#' Get the full path to the IT Deaths extract
#'
#' @param it_reference The IT reference to use, defaults to \code{\link{it_extract_ref}}
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the IT Deaths extract as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_it_deaths_path <- function(it_reference = it_extract_ref(), ...) {
  it_deaths_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_reference}_extract_2_Deaths.csv.gz")
  )

  return(it_deaths_path)
}

#' Get the full path to the IT PIS extract
#'
#' @param year the year for the required extract
#' @param it_reference The IT reference to use, defaults to \code{\link{it_extract_ref}}
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the PIS extract as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_it_prescribing_path <- function(year, it_reference = it_extract_ref(), ...) {
  it_extracts_dir <- fs::path(get_slf_dir(), "IT_extracts")

  alt_fy <- paste0("20", substr(year, 1, 2))

  file_name <- fs::dir_ls(it_extracts_dir,
    type = "file",
    regexp = it_reference
  ) %>%
    fs::path_file() %>%
    stringr::str_extract(pattern = glue::glue("^.+?{alt_fy}.+$")) %>%
    stats::na.omit()

  if (length(file_name) == 0) {
    rlang::abort(glue::glue(
      "Unable to find file for {year} with reference {it_reference}."
    ))
  }

  it_prescribing_path <- get_file_path(
    directory = it_extracts_dir,
    file_name = file_name,
    ...
  )

  return(it_prescribing_path)
}
