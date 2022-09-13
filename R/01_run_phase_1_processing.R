#' Run phase 1 processing.
#' @description This script is the top level processing script for processing
#' data extracts and their equivalent tests for the SLFs.
#'
#' @param select_years_to_run Specify years which need to run.
#'
#' @return A list of data with the data extracts as a tibble along with the years.
#' @export
#'
run_phase_1_processing <- function(select_years_to_run) {
  extract_data <- purrr::map(
    select_years_to_run,
    run_data_extracts
  )

  extract_tests<- purrr::iwalk(
    extract_data,
    select_years_to_run,
    run_extract_tests
  )

  return(extract_data)
}
