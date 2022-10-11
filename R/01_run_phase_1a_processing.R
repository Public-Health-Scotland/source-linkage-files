#' Run phase 1a Lookup processing.
#' @description This script is the top level processing script for processing
#' data lookups and their equivalent tests for the SLFs.
#'
#' @param select_years_to_run Specify years which need to run.
#'
#' @return A list of data with the data lookups as a tibble along with the years.
#' @export
#'
run_process_1a_lookups <- function(select_years_to_run) {
  lookups_data <- purrr::map(
    select_years_to_run,
    run_data_lookups
  )

  extract_tests <- purrr::map2(
    lookups_data,
    select_years_to_run,
    run_lookups_tests
  )

  return(lookups_data)
}
