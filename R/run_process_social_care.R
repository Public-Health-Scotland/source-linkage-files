#' Run Social Care processing.
#' @description This script is the top level processing script for processing
#' all social care files
#'
#' @param years Specify years which need to run.
#'
#' @return A list of data with the data lookups as a tibble along with the years.
#' @export
#'
run_process_social_care <- function(years) {
  social_care_data <- run_data_social_care()

  return(social_care_data)
}
