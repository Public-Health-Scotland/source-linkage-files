#' Run phase 1 processing.
#' @description This script is the top level processing script for processing
#' data extracts and their equivalent tests for the SLFs.
#'
#' @param years Specify years which need to run.
#'
#' @return A list of data with the data extracts as a tibble along with the years.
#' @export
#'
run_process_extracts <- function(years) {
  extract_data <- purrr::map(
    years,
    run_data_extracts
  )

  extract_tests <- purrr::map2(
    extract_data,
    years,
    run_extract_tests
  )

  return(extract_data)
}
