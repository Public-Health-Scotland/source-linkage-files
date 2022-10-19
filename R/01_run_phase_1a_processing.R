#' Run phase 1a Lookup processing.
#' @description This script is the top level processing script for processing
#' data lookups and their equivalent tests for the SLFs.
#'
#' @param years Specify years which need to run.
#'
#' @return A list of data with the data lookups as a tibble along with the years.
#' @export
#'
run_process_lookups <- function(years) {
  lookups_data <- run_data_lookups()

  return(lookups_data)
}
