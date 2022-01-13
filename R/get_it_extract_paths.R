#' Get the full path to the IT
#' Long Term Conditions extract
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the LTC extract as an [fs::path]
#' @export
get_it_ltc_path <- function(...) {
  it_ltc_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_extract_ref()}_extract_1_LTCs.csv.gz"),
    ...
  )

  return(it_ltc_path)
}

#' Get the full path to the IT Deaths extract
#'
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the IT Deaths extract as an [fs::path]
#' @export
get_it_deaths_path <- function(...) {
  it_deaths_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_extract_ref()}_extract_2_Deaths.csv.gz")
  )

  return(it_deaths_path)
}

#' Get the full path to the IT PIS extract
#'
#' @param year the year for the required extract
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the PIS extract as an [fs::path]
#' @export
get_it_prescribing_path <- function(year, ...) {
  extract_number <- switch(year,
    "1516" = "3_2015",
    "1617" = "4_2016",
    "1718" = "5_2017",
    "1819" = "6_2018",
    "1920" = "7_2019",
    "2021" = "8_2020",
    "2122" = "9_2021"
  )

  it_prescribing_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_extract_ref()}_extract_{extract_number}.csv.gz"),
    ...
  )

  return(it_prescribing_path)
}
